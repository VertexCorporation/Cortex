"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const colorette_1 = require("colorette");
const api_1 = require("../hosting/api");
const command_1 = require("../command");
const expireUtils_1 = require("../hosting/expireUtils");
const error_1 = require("../error");
const utils_1 = require("../utils");
const prompt_1 = require("../prompt");
const requirePermissions_1 = require("../requirePermissions");
const projectUtils_1 = require("../projectUtils");
const logger_1 = require("../logger");
const requireConfig_1 = require("../requireConfig");
const marked_1 = require("marked");
const requireHostingSite_1 = require("../requireHostingSite");
const getDefaultHostingSite_1 = require("../getDefaultHostingSite");
const LOG_TAG = "hosting:channel";
exports.command = new command_1.Command("hosting:channel:create [channelId]")
    .description("create a Firebase Hosting channel")
    .option("-e, --expires <duration>", "duration string (e.g. 12h or 30d) for channel expiration, max 30d")
    .option("--site <siteId>", "site for which to create the channel")
    .before(requireConfig_1.requireConfig)
    .before(requirePermissions_1.requirePermissions, ["firebasehosting.sites.update"])
    .before(async (options) => {
    try {
        await (0, requireHostingSite_1.requireHostingSite)(options);
    }
    catch (err) {
        if (err === getDefaultHostingSite_1.errNoDefaultSite) {
            throw new error_1.FirebaseError(`Unable to deploy to Hosting as there is no Hosting site. Use ${(0, colorette_1.bold)("firebase hosting:sites:create")} to create a site.`);
        }
        throw err;
    }
})
    .action(async (channelId, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const site = options.site;
    let expireTTL = expireUtils_1.DEFAULT_DURATION;
    if (options.expires) {
        expireTTL = (0, expireUtils_1.calculateChannelExpireTTL)(options.expires);
    }
    if (channelId) {
        options.channelId = channelId;
    }
    channelId =
        channelId ||
            (await (0, prompt_1.input)({
                message: "Please provide a URL-friendly name for the channel:",
                validate: (s) => s.length > 0,
            }));
    channelId = (0, api_1.normalizeName)(channelId);
    let channel;
    try {
        channel = await (0, api_1.createChannel)(projectId, site, channelId, expireTTL);
    }
    catch (e) {
        if (e.status === 409) {
            throw new error_1.FirebaseError(`Channel ${(0, colorette_1.bold)(channelId)} already exists on site ${(0, colorette_1.bold)(site)}. Deploy to ${(0, colorette_1.bold)(channelId)} with: ${(0, colorette_1.yellow)(`firebase hosting:channel:deploy ${channelId}`)}`, { original: e });
        }
        throw e;
    }
    try {
        await (0, api_1.addAuthDomains)(projectId, [channel.url]);
    }
    catch (e) {
        (0, utils_1.logLabeledWarning)(LOG_TAG, await (0, marked_1.marked)(`Unable to add channel domain to Firebase Auth. Visit the Firebase Console at ${(0, utils_1.consoleUrl)(projectId, "/authentication/providers")}`));
        logger_1.logger.debug("[hosting] unable to add auth domain", e);
    }
    logger_1.logger.info();
    (0, utils_1.logLabeledSuccess)(LOG_TAG, `Channel ${(0, colorette_1.bold)(channelId)} has been created on site ${(0, colorette_1.bold)(site)}.`);
    (0, utils_1.logLabeledSuccess)(LOG_TAG, `Channel ${(0, colorette_1.bold)(channelId)} will expire at ${(0, colorette_1.bold)((0, utils_1.datetimeString)(new Date(channel.expireTime)))}.`);
    (0, utils_1.logLabeledSuccess)(LOG_TAG, `Channel URL: ${channel.url}`);
    logger_1.logger.info();
    logger_1.logger.info(`To deploy to this channel, use ${(0, colorette_1.yellow)(`firebase hosting:channel:deploy ${channelId}`)}.`);
    return channel;
});
