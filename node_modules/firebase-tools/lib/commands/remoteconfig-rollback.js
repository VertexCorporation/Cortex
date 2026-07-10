"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const error_1 = require("../error");
const prompt_1 = require("../prompt");
const requireAuth_1 = require("../requireAuth");
const rollback_1 = require("../remoteconfig/rollback");
const requirePermissions_1 = require("../requirePermissions");
const versionslist_1 = require("../remoteconfig/versionslist");
const projectUtils_1 = require("../projectUtils");
exports.command = new command_1.Command("remoteconfig:rollback")
    .description("roll back a project's published Remote Config template to the one specified by the provided version number")
    .before(requireAuth_1.requireAuth)
    .before(requirePermissions_1.requirePermissions, ["cloudconfig.configs.get", "cloudconfig.configs.update"])
    .option("-v, --version-number <versionNumber>", "rollback to the specified version of the template")
    .withForce()
    .action(async (options) => {
    const templateVersion = await (0, versionslist_1.getVersions)((0, projectUtils_1.needProjectId)(options), 1);
    let targetVersion = 0;
    if (options.versionNumber) {
        targetVersion = options.versionNumber;
    }
    else {
        if (templateVersion?.versions[0]?.versionNumber) {
            const latestVersion = templateVersion.versions[0].versionNumber.toString();
            const previousVersion = parseInt(latestVersion) - 1;
            targetVersion = previousVersion;
        }
    }
    if (targetVersion <= 0) {
        throw new error_1.FirebaseError(`Failed to rollback Firebase Remote Config template for project to version` +
            targetVersion +
            `. ` +
            `Invalid Version Number`);
    }
    const proceed = await (0, prompt_1.confirm)({
        message: "Proceed to rollback template to version " + targetVersion + "?",
        default: false,
        force: options.force,
        nonInteractive: options.nonInteractive,
    });
    if (!proceed) {
        return;
    }
    return (0, rollback_1.rollbackTemplate)((0, projectUtils_1.needProjectId)(options), targetVersion);
});
