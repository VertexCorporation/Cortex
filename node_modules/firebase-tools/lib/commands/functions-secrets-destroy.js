"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const secretManager_1 = require("../gcp/secretManager");
const prompt_1 = require("../prompt");
const utils_1 = require("../utils");
const requireAuth_1 = require("../requireAuth");
const secrets = require("../functions/secrets");
const backend = require("../deploy/functions/backend");
exports.command = new command_1.Command("functions:secrets:destroy <KEY>[@version]")
    .description("destroy a secret. Defaults to destroying the latest version")
    .withForce("destroy a secret without confirmation")
    .before(requireAuth_1.requireAuth)
    .before(secretManager_1.ensureApi)
    .action(async (key, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    const haveBackend = await backend.existingBackend({ projectId });
    let [name, version] = key.split("@");
    if (!version) {
        version = "latest";
    }
    const sv = await (0, secretManager_1.getSecretVersion)(projectId, name, version);
    if (sv.state === "DESTROYED") {
        (0, utils_1.logBullet)(`Secret ${sv.secret.name}@${version} is already destroyed. Nothing to do.`);
        return;
    }
    const boundEndpoints = backend
        .allEndpoints(haveBackend)
        .filter((e) => secrets.inUse({ projectId, projectNumber }, sv.secret, e));
    if (boundEndpoints.length > 0) {
        const endpointsMsg = boundEndpoints
            .map((e) => `${e.id}[${e.platform}](${e.region})`)
            .join("\t\n");
        (0, utils_1.logWarning)(`Secret ${name}@${version} is currently in use by following functions:\n\t${endpointsMsg}`);
        if (!options.force) {
            (0, utils_1.logWarning)("Refusing to destroy secret in use. Use -f to destroy the secret anyway.");
            return;
        }
    }
    const areYouSure = await (0, prompt_1.confirm)({
        message: `Are you sure you want to destroy ${sv.secret.name}@${sv.versionId}`,
        default: true,
        nonInteractive: options.nonInteractive,
        force: options.force,
    });
    if (!areYouSure) {
        return;
    }
    await (0, secretManager_1.destroySecretVersion)(projectId, name, version);
    (0, utils_1.logBullet)(`Destroyed secret version ${name}@${sv.versionId}`);
    const secret = await (0, secretManager_1.getSecret)(projectId, name);
    if ((0, secretManager_1.isFunctionsManaged)(secret)) {
        const versions = await (0, secretManager_1.listSecretVersions)(projectId, name);
        if (versions.filter((v) => v.state === "ENABLED").length === 0) {
            (0, utils_1.logBullet)(`No active secret versions left. Destroying secret ${name}`);
            await (0, secretManager_1.deleteSecret)(projectId, name);
        }
    }
});
