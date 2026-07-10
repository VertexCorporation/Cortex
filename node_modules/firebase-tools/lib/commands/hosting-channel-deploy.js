"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
exports.hostingChannelDeployAction = hostingChannelDeployAction;
const colorette_1 = require("colorette");
const command_1 = require("../command");
const error_1 = require("../error");
const api_1 = require("../hosting/api");
const requirePermissions_1 = require("../requirePermissions");
const deploy_1 = require("../deploy");
const projectUtils_1 = require("../projectUtils");
const logger_1 = require("../logger");
const requireConfig_1 = require("../requireConfig");
const expireUtils_1 = require("../hosting/expireUtils");
const utils_1 = require("../utils");
const config_1 = require("../hosting/config");
const marked_1 = require("marked");
const requireHostingSite_1 = require("../requireHostingSite");
const LOG_TAG = "hosting:channel";
exports.command = new command_1.Command("hosting:channel:deploy [channelId]")
    .description("deploy to a specific Firebase Hosting channel")
    .option("-e, --expires <duration>", "duration string (e.g. 12h, 30d) for channel expiration, max 30d; defaults to 7d")
    .option("--only <target1,target2...>", "only create previews for specified targets")
    .option("--open", "open a browser to the channel after deploying")
    .option("--no-authorized-domains", "do not sync channel domains with Firebase Auth")
    .before(requireConfig_1.requireConfig)
    .before(requirePermissions_1.requirePermissions, ["firebasehosting.sites.update"])
    .before(requireHostingSite_1.requireHostingSite)
    .action(hostingChannelDeployAction);
async function hostingChannelDeployAction(channelId, options) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    if (options.open) {
        throw new error_1.FirebaseError("open is not yet implemented");
    }
    let expireTTL = expireUtils_1.DEFAULT_DURATION;
    if (options.expires) {
        expireTTL = (0, expireUtils_1.calculateChannelExpireTTL)(options.expires);
        logger_1.logger.debug(`Expires TTL: ${expireTTL}`);
    }
    if (!channelId) {
        throw new error_1.FirebaseError("channelID is currently required");
    }
    channelId = (0, api_1.normalizeName)(channelId);
    if (channelId.toLowerCase().trim() === "live") {
        throw new error_1.FirebaseError(`Cannot deploy to the ${(0, colorette_1.bold)("live")} channel using this command. Please use ${(0, colorette_1.bold)((0, colorette_1.yellow)("firebase deploy"))} instead.`);
    }
    if (options.only) {
        options.only = options.only
            .split(",")
            .map((o) => `hosting:${o}`)
            .join(",");
    }
    else {
        options.only = "hosting";
    }
    const sites = (0, config_1.hostingConfig)(options).map((config) => {
        return {
            target: config.target,
            site: config.site,
            url: "",
            version: "",
            expireTime: "",
        };
    });
    await Promise.all(sites.map(async (siteInfo) => {
        const site = siteInfo.site;
        let chan = await (0, api_1.getChannel)(projectId, site, channelId);
        if (chan) {
            logger_1.logger.debug("[hosting] found existing channel for site", site, chan);
            const channelExpires = Boolean(chan.expireTime);
            if (!channelExpires && options.expires) {
                chan = await (0, api_1.updateChannelTtl)(projectId, site, channelId, expireTTL);
            }
            else if (channelExpires) {
                const channelTimeRemaining = new Date(chan.expireTime).getTime() - Date.now();
                if (options.expires || channelTimeRemaining < expireTTL) {
                    chan = await (0, api_1.updateChannelTtl)(projectId, site, channelId, expireTTL);
                    logger_1.logger.debug("[hosting] updated TTL for existing channel for site", site, chan);
                }
            }
        }
        else {
            chan = await (0, api_1.createChannel)(projectId, site, channelId, expireTTL);
            logger_1.logger.debug("[hosting] created new channnel for site", site, chan);
            (0, utils_1.logLabeledSuccess)(LOG_TAG, `Channel ${(0, colorette_1.bold)(channelId)} has been created on site ${(0, colorette_1.bold)(site)}.`);
        }
        siteInfo.url = chan.url;
        siteInfo.expireTime = chan.expireTime;
        return;
    }));
    const { hosting } = await (0, deploy_1.deploy)(["hosting"], options, { hostingChannel: channelId });
    const versionNames = [];
    if (typeof hosting === "string") {
        versionNames.push(hosting);
    }
    else if (Array.isArray(hosting)) {
        hosting.forEach((version) => {
            versionNames.push(version);
        });
    }
    if (options.authorizedDomains) {
        await syncAuthState(projectId, sites);
    }
    else {
        logger_1.logger.debug(`skipping syncAuthState since authorizedDomains is ${options.authorizedDomains}`);
    }
    logger_1.logger.info();
    const deploys = {};
    sites.forEach((d) => {
        deploys[d.target || d.site] = d;
        let expires = "";
        if (d.expireTime) {
            expires = `[expires ${(0, colorette_1.bold)((0, utils_1.datetimeString)(new Date(d.expireTime)))}]`;
        }
        const versionPrefix = `sites/${d.site}/versions/`;
        const versionName = versionNames.find((v) => {
            return v.startsWith(versionPrefix);
        });
        let version = "";
        if (versionName) {
            d.version = versionName.replace(versionPrefix, "");
            version = ` [version ${(0, colorette_1.bold)(d.version)}]`;
        }
        (0, utils_1.logLabeledSuccess)(LOG_TAG, `Channel URL (${(0, colorette_1.bold)(d.site || d.target || "")}): ${d.url} ${expires}${version}`);
    });
    return deploys;
}
async function syncAuthState(projectId, sites) {
    const siteNames = sites.map((d) => d.site);
    const urlNames = sites.map((d) => d.url);
    try {
        await (0, api_1.addAuthDomains)(projectId, urlNames);
        logger_1.logger.debug("[hosting] added auth domain for urls", urlNames);
    }
    catch (e) {
        (0, utils_1.logLabeledWarning)(LOG_TAG, await (0, marked_1.marked)(`Unable to add channel domain to Firebase Auth. Visit the Firebase Console at ${(0, utils_1.consoleUrl)(projectId, "/authentication/providers")}`));
        logger_1.logger.debug("[hosting] unable to add auth domain", e);
    }
    try {
        await (0, api_1.cleanAuthState)(projectId, siteNames);
    }
    catch (e) {
        (0, utils_1.logLabeledWarning)(LOG_TAG, "Unable to sync Firebase Auth state.");
        logger_1.logger.debug("[hosting] unable to sync auth domain", e);
    }
}
