"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const colorette_1 = require("colorette");
const command_1 = require("../command");
const interactive_1 = require("../hosting/interactive");
const utils_1 = require("../utils");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const requirePermissions_1 = require("../requirePermissions");
const api_1 = require("../hosting/api");
const error_1 = require("../error");
const LOG_TAG = "hosting:sites";
exports.command = new command_1.Command("hosting:sites:create [siteId]")
    .description("create a Firebase Hosting site")
    .option("--app <appId>", "specify an existing Firebase Web App ID")
    .before(requirePermissions_1.requirePermissions, ["firebasehosting.sites.update"])
    .action(async (siteId, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const appId = options.app;
    if (options.nonInteractive && !siteId) {
        throw new error_1.FirebaseError(`${(0, colorette_1.bold)("siteId")} is required in a non-interactive environment`);
    }
    siteId = await (0, interactive_1.pickHostingSiteName)(siteId ?? "", options);
    const site = await (0, api_1.createSite)(projectId, siteId, appId);
    logger_1.logger.info();
    (0, utils_1.logLabeledSuccess)(LOG_TAG, `Site ${(0, colorette_1.bold)(siteId)} has been created in project ${(0, colorette_1.bold)(projectId)}.`);
    if (appId) {
        (0, utils_1.logLabeledSuccess)(LOG_TAG, `Site ${(0, colorette_1.bold)(siteId)} has been linked to web app ${(0, colorette_1.bold)(appId)}`);
    }
    (0, utils_1.logLabeledSuccess)(LOG_TAG, `Site URL: ${site.defaultUrl}`);
    logger_1.logger.info();
    logger_1.logger.info(`To deploy to this site, follow the guide at https://firebase.google.com/docs/hosting/multisites.`);
    return site;
});
