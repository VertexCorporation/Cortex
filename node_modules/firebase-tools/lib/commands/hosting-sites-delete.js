"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const colorette_1 = require("colorette");
const command_1 = require("../command");
const utils_1 = require("../utils");
const api_1 = require("../hosting/api");
const prompt_1 = require("../prompt");
const error_1 = require("../error");
const requirePermissions_1 = require("../requirePermissions");
const projectUtils_1 = require("../projectUtils");
const requireConfig_1 = require("../requireConfig");
const logger_1 = require("../logger");
const LOG_TAG = "hosting:sites";
exports.command = new command_1.Command("hosting:sites:delete <siteId>")
    .description("delete a Firebase Hosting site")
    .withForce()
    .before(requireConfig_1.requireConfig)
    .before(requirePermissions_1.requirePermissions, ["firebasehosting.sites.delete"])
    .action(async (siteId, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    if (!siteId) {
        throw new error_1.FirebaseError("siteId is required");
    }
    logger_1.logger.info(`Deleting a site is a permanent action. If you delete a site, Firebase doesn't maintain records of deployed files or deployment history, and the site ${(0, colorette_1.underline)(siteId)} cannot be reactivated by you or anyone else.`);
    logger_1.logger.info();
    const confirmed = await (0, prompt_1.confirm)({
        message: `Are you sure you want to delete the Hosting site ${(0, colorette_1.underline)(siteId)} for project ${(0, colorette_1.underline)(projectId)}? `,
        default: false,
        force: options.force,
        nonInteractive: options.nonInteractive,
    });
    if (!confirmed) {
        return;
    }
    await (0, api_1.getSite)(projectId, siteId);
    await (0, api_1.deleteSite)(projectId, siteId);
    (0, utils_1.logLabeledSuccess)(LOG_TAG, `Successfully deleted site ${(0, colorette_1.bold)(siteId)} from project ${(0, colorette_1.bold)(projectId)}`);
});
