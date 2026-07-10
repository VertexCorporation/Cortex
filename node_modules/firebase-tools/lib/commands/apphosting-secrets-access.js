"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const secretManager_1 = require("../gcp/secretManager");
const requireAuth_1 = require("../requireAuth");
const secretManager = require("../gcp/secretManager");
const requirePermissions_1 = require("../requirePermissions");
exports.command = new command_1.Command("apphosting:secrets:access <secretName[@version]>")
    .description("access secret value given secret and its version. Defaults to accessing the latest version")
    .before(requireAuth_1.requireAuth)
    .before(secretManager.ensureApi)
    .before(requirePermissions_1.requirePermissions, ["secretmanager.versions.access"])
    .action(async (key, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    let [name, version] = key.split("@");
    if (!version) {
        version = "latest";
    }
    const value = await (0, secretManager_1.accessSecretVersion)(projectId, name, version);
    logger_1.logger.info(value);
});
