"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const logger_1 = require("../logger");
const requireAuth_1 = require("../requireAuth");
const secretManager_1 = require("../gcp/secretManager");
const secretManager = require("../gcp/secretManager");
const requirePermissions_1 = require("../requirePermissions");
const Table = require("cli-table3");
exports.command = new command_1.Command("apphosting:secrets:describe <secretName>")
    .description("get metadata for secret and its versions")
    .before(requireAuth_1.requireAuth)
    .before(secretManager.ensureApi)
    .before(requirePermissions_1.requirePermissions, ["secretmanager.secrets.get"])
    .action(async (secretName, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const versions = await (0, secretManager_1.listSecretVersions)(projectId, secretName);
    const table = new Table({
        head: ["Name", "Version", "Status", "Create Time"],
        style: { head: ["yellow"] },
    });
    for (const version of versions) {
        table.push([secretName, version.versionId, version.state, version.createTime]);
    }
    logger_1.logger.info(table.toString());
    return { secrets: versions };
});
