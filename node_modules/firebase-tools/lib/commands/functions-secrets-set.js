"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const tty = require("tty");
const logger_1 = require("../logger");
const error_1 = require("../error");
const secrets_1 = require("../functions/secrets");
const command_1 = require("../command");
const requirePermissions_1 = require("../requirePermissions");
const prompt_1 = require("../prompt");
const utils_1 = require("../utils");
const projectUtils_1 = require("../projectUtils");
const secretManager_1 = require("../gcp/secretManager");
const ensureApiEnabled_1 = require("../ensureApiEnabled");
const requireAuth_1 = require("../requireAuth");
const secrets = require("../functions/secrets");
const backend = require("../deploy/functions/backend");
exports.command = new command_1.Command("functions:secrets:set <KEY>")
    .description("create or update a secret for use in Cloud Functions for Firebase")
    .withForce("automatically updates functions to use the new secret")
    .before(requireAuth_1.requireAuth)
    .before(secretManager_1.ensureApi)
    .before(requirePermissions_1.requirePermissions, [
    "secretmanager.secrets.create",
    "secretmanager.secrets.get",
    "secretmanager.secrets.update",
    "secretmanager.versions.add",
])
    .option("--data-file <dataFile>", 'file path from which to read secret data. Set to "-" to read the secret data from stdin')
    .option("--format <format>", "format of the secret value. 'string' (default) or 'json'")
    .action(async (unvalidatedKey, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    const key = await (0, secrets_1.ensureValidKey)(unvalidatedKey, options);
    const secret = await (0, secrets_1.ensureSecret)(projectId, key, options);
    let format = options.format;
    const dataFile = options.dataFile;
    if (!format && dataFile && dataFile !== "-") {
        if (dataFile.endsWith(".json")) {
            format = "json";
        }
    }
    if (!dataFile && tty.isatty(0) && options.nonInteractive) {
        throw new error_1.FirebaseError(`Cannot prompt for secret value in non-interactive mode.\n` +
            `Use --data-file to provide the secret value from a file.`);
    }
    const promptSuffix = format === "json" ? " (JSON format)" : "";
    const secretValue = await (0, utils_1.readSecretValue)(`Enter a value for ${key}${promptSuffix}:`, dataFile);
    if (format === "json") {
        (0, secrets_1.validateJsonSecret)(key, secretValue);
    }
    const secretVersion = await (0, secretManager_1.addVersion)(projectId, key, secretValue);
    (0, utils_1.logSuccess)(`Created a new secret version ${(0, secretManager_1.toSecretVersionResourceName)(secretVersion)}`);
    if (!(0, secretManager_1.isFunctionsManaged)(secret)) {
        (0, utils_1.logBullet)("Please deploy your functions for the change to take effect by running:\n\t" +
            clc.bold("firebase deploy --only functions"));
        return;
    }
    const functionsEnabled = await (0, ensureApiEnabled_1.check)(projectId, "cloudfunctions.googleapis.com", "functions", true);
    if (!functionsEnabled) {
        logger_1.logger.debug("Customer set secrets before enabling functions. Exiting");
        return;
    }
    let haveBackend = await backend.existingBackend({ projectId });
    const endpointsToUpdate = backend
        .allEndpoints(haveBackend)
        .filter((e) => secrets.inUse({ projectId, projectNumber }, secret, e));
    if (endpointsToUpdate.length === 0) {
        return;
    }
    (0, utils_1.logBullet)(`${endpointsToUpdate.length} functions are using stale version of secret ${secret.name}:\n\t` +
        endpointsToUpdate.map((e) => `${e.id}(${e.region})`).join("\n\t"));
    const redeploy = options.nonInteractive
        ? false
        : await (0, prompt_1.confirm)({
            message: `Do you want to re-deploy the functions and destroy the stale version of secret ${secret.name}?`,
            default: true,
            force: options.force,
        });
    if (!redeploy) {
        (0, utils_1.logBullet)("Please deploy your functions for the change to take effect by running:\n\t" +
            clc.bold("firebase deploy --only functions"));
        return;
    }
    const updateOps = endpointsToUpdate.map(async (e) => {
        (0, utils_1.logBullet)(`Updating function ${e.id}(${e.region})...`);
        const updated = await secrets.updateEndpointSecret({ projectId, projectNumber }, secretVersion, e);
        (0, utils_1.logBullet)(`Updated function ${e.id}(${e.region}).`);
        return updated;
    });
    await Promise.all(updateOps);
    haveBackend = await backend.existingBackend({ projectId }, true);
    const staleEndpoints = backend.allEndpoints(backend.matchingBackend(haveBackend, (e) => {
        const pInfo = { projectId, projectNumber };
        return secrets.inUse(pInfo, secret, e) && !secrets.versionInUse(pInfo, secretVersion, e);
    }));
    if (staleEndpoints.length !== 0) {
        (0, utils_1.logWarning)(`${staleEndpoints.length} functions are unexpectedly using old version of secret ${secret.name} still:\n\t` +
            staleEndpoints.map((e) => `${e.id}(${e.region})`).join("\n\t"));
        (0, utils_1.logBullet)("Please deploy your functions manually for the change to take effect by running:\n\t" +
            clc.bold("firebase deploy --only functions"));
    }
    const secretsToPrune = (await secrets.pruneSecrets({ projectId, projectNumber }, backend.allEndpoints(haveBackend))).filter((sv) => sv.key === key);
    (0, utils_1.logBullet)(`Removing secret versions: ${secretsToPrune
        .map((sv) => sv.key + "[" + sv.version + "]")
        .join(", ")}`);
    await Promise.all(secretsToPrune.map((sv) => (0, secretManager_1.destroySecretVersion)(projectId, sv.secret, sv.version)));
});
