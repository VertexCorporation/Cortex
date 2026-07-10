"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const semver = require("semver");
const functionsConfig = require("../functionsConfig");
const command_1 = require("../command");
const error_1 = require("../error");
const prompt_1 = require("../prompt");
const requirePermissions_1 = require("../requirePermissions");
const utils_1 = require("../utils");
const requireConfig_1 = require("../requireConfig");
const secrets_1 = require("../functions/secrets");
const secretManager_1 = require("../gcp/secretManager");
const projectUtils_1 = require("../projectUtils");
const requireAuth_1 = require("../requireAuth");
const secretManager_2 = require("../gcp/secretManager");
const versioning_1 = require("../deploy/functions/runtimes/node/versioning");
const RUNTIME_CONFIG_PERMISSIONS = [
    "runtimeconfig.configs.list",
    "runtimeconfig.configs.get",
    "runtimeconfig.variables.list",
    "runtimeconfig.variables.get",
];
const SECRET_MANAGER_PERMISSIONS = [
    "secretmanager.secrets.create",
    "secretmanager.secrets.get",
    "secretmanager.secrets.update",
    "secretmanager.versions.add",
];
const DEFAULT_SECRET_NAME = "FUNCTIONS_CONFIG_EXPORT";
function maskConfigValues(obj) {
    if (typeof obj === "object" && obj !== null && !Array.isArray(obj)) {
        const masked = {};
        for (const [key, value] of Object.entries(obj)) {
            masked[key] = maskConfigValues(value);
        }
        return masked;
    }
    return "******";
}
exports.command = new command_1.Command("functions:config:export")
    .description("export environment config as a JSON secret to store in Cloud Secret Manager")
    .option("--secret <name>", `name of the secret to create (default: ${DEFAULT_SECRET_NAME})`)
    .withForce("use default secret name without prompting")
    .before(requireAuth_1.requireAuth)
    .before(secretManager_2.ensureApi)
    .before(requirePermissions_1.requirePermissions, [...RUNTIME_CONFIG_PERMISSIONS, ...SECRET_MANAGER_PERMISSIONS])
    .before(requireConfig_1.requireConfig)
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    (0, utils_1.logBullet)("This command retrieves your Runtime Config values (accessed via " +
        clc.bold("functions.config()") +
        ") and exports them as a Secret Manager secret.");
    console.log("");
    (0, utils_1.logBullet)(`Fetching your existing functions.config() from ${clc.bold(projectId)}...`);
    let configJson;
    try {
        configJson = await functionsConfig.materializeAll(projectId);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to fetch runtime config for project ${projectId}. ` +
            "Ensure you have the required permissions:\n\t" +
            RUNTIME_CONFIG_PERMISSIONS.join("\n\t"), { original: err });
    }
    if (Object.keys(configJson).length === 0) {
        (0, utils_1.logSuccess)("Your functions.config() is empty. Nothing to do.");
        return;
    }
    (0, utils_1.logSuccess)("Fetched your existing functions.config().");
    console.log("");
    if (!options.nonInteractive) {
        (0, utils_1.logBullet)(clc.bold("Configuration to be exported:"));
        console.log(JSON.stringify(maskConfigValues(configJson), null, 2));
        console.log("");
    }
    let secretName = options.secret;
    if (!secretName) {
        if (options.force) {
            secretName = DEFAULT_SECRET_NAME;
        }
        else {
            secretName = await (0, prompt_1.input)({
                message: "What would you like to name the new secret for your configuration?",
                default: DEFAULT_SECRET_NAME,
                nonInteractive: options.nonInteractive,
            });
        }
    }
    const key = await (0, secrets_1.ensureValidKey)(secretName, options);
    await (0, secrets_1.ensureSecret)(projectId, key, options);
    const versions = await (0, secretManager_1.listSecretVersions)(projectId, key);
    const enabledVersions = versions.filter((v) => v.state === "ENABLED");
    enabledVersions.sort((a, b) => (b.createTime || "").localeCompare(a.createTime || ""));
    const latest = enabledVersions[0];
    if (latest) {
        (0, utils_1.logBullet)(`Secret ${clc.bold(key)} already exists (latest version: ${clc.bold(latest.versionId)}, created: ${latest.createTime}).`);
        const proceed = await (0, prompt_1.confirm)({
            message: "Do you want to add a new version to this secret?",
            default: false,
            nonInteractive: options.nonInteractive,
            force: options.force,
        });
        if (!proceed) {
            return;
        }
        console.log("");
    }
    const secretValue = JSON.stringify(configJson, null, 2);
    const sizeInBytes = Buffer.byteLength(secretValue, "utf8");
    const maxSize = 64 * 1024;
    if (sizeInBytes > maxSize) {
        throw new error_1.FirebaseError(`Configuration size (${sizeInBytes} bytes) exceeds the 64KB limit for JSON secrets. ` +
            "Please reduce the size of your configuration or split it into multiple secrets.");
    }
    const secretVersion = await (0, secretManager_1.addVersion)(projectId, key, secretValue);
    console.log("");
    (0, utils_1.logSuccess)(`Created new secret version ${(0, secretManager_1.toSecretVersionResourceName)(secretVersion)}`);
    console.log("");
    (0, utils_1.logBullet)(clc.bold("To complete the migration, update your code:"));
    console.log("");
    console.log(clc.gray(`  // Before:
  const functions = require('firebase-functions');

  exports.myFunction = functions.https.onRequest((req, res) => {
    const apiKey = functions.config().service.key;
    // ...
  });

  // After:
  const functions = require('firebase-functions');
  const { defineJsonSecret } = require('firebase-functions/params');

  const config = defineJsonSecret("${key}");

  exports.myFunction = functions
    .runWith({ secrets: [config] })  // Bind secret here
    .https.onRequest((req, res) => {
      const apiKey = config.value().service.key;
      // ...
    });`));
    console.log("");
    let sdkVersion;
    try {
        const functionsConfig = options.config.get("functions");
        const source = Array.isArray(functionsConfig)
            ? functionsConfig[0]?.source
            : functionsConfig?.source;
        if (source) {
            const sourceDir = options.config.path(source);
            sdkVersion = (0, versioning_1.getFunctionsSDKVersion)(sourceDir);
        }
    }
    catch (e) {
    }
    if (!sdkVersion || semver.lt(sdkVersion, "6.6.0")) {
        (0, utils_1.logBullet)(clc.bold("Note: ") +
            "defineJsonSecret requires firebase-functions v6.6.0 or later. " +
            `Update to a newer version with ${clc.bold("npm i firebase-functions @latest")}${!sdkVersion ? " if needed" : ""}.`);
    }
    (0, utils_1.logBullet)("Then deploy your functions:\n  " + clc.bold("firebase deploy --only functions"));
    return secretName;
});
