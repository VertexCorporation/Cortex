"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const colorette_1 = require("colorette");
const ora = require("ora");
const command_1 = require("../command");
const error_1 = require("../error");
const api_1 = require("../hosting/api");
const utils = require("../utils");
const requireAuth_1 = require("../requireAuth");
const logger_1 = require("../logger");
exports.command = new command_1.Command("hosting:clone <source> <targetChannel>")
    .description("clone a version from one site to another")
    .help(`<source> and <targetChannel> accept the following format: <siteId>:<channelId>

For example, to copy the content for a site \`my-site\` from a preview channel \`staging\` to a \`live\` channel, the command would look be:

  firebase hosting:clone my-site:foo my-site:live`)
    .before(requireAuth_1.requireAuth)
    .action(async (source = "", targetChannel = "") => {
    let sourceVersionName;
    let sourceVersion;
    let [sourceSiteId, sourceChannelId] = source.split(":");
    let [targetSiteId, targetChannelId] = targetChannel.split(":");
    if (!sourceSiteId || !sourceChannelId) {
        [sourceSiteId, sourceVersion] = source.split("@");
        if (!sourceSiteId || !sourceVersion) {
            throw new error_1.FirebaseError(`"${source}" is not a valid source. Must be in the form "<site>:<channel>" or "<site>@<version>"`);
        }
        sourceVersionName = `sites/${sourceSiteId}/versions/${sourceVersion}`;
    }
    if (!targetSiteId || !targetChannelId) {
        throw new error_1.FirebaseError(`"${targetChannel}" is not a valid target channel. Must be in the form "<site>:<channel>" (to clone to the active website, use "live" as the channel).`);
    }
    targetChannelId = (0, api_1.normalizeName)(targetChannelId);
    if (sourceChannelId) {
        sourceChannelId = (0, api_1.normalizeName)(sourceChannelId);
    }
    const equalSiteIds = sourceSiteId === targetSiteId;
    const equalChannelIds = sourceChannelId === targetChannelId;
    if (equalSiteIds && equalChannelIds) {
        throw new error_1.FirebaseError(`Source and destination cannot be equal. Please pick a different source or desination.`);
    }
    if (!sourceVersionName) {
        const sChannel = await (0, api_1.getChannel)("-", sourceSiteId, sourceChannelId);
        if (!sChannel) {
            throw new error_1.FirebaseError(`Could not find the channel ${(0, colorette_1.bold)(sourceChannelId)} for site ${(0, colorette_1.bold)(sourceSiteId)}.`);
        }
        sourceVersionName = sChannel.release?.version?.name;
        if (!sourceVersionName) {
            throw new error_1.FirebaseError(`Could not find a version on the channel ${(0, colorette_1.bold)(sourceChannelId)} for site ${(0, colorette_1.bold)(sourceSiteId)}.`);
        }
    }
    let tChannel = await (0, api_1.getChannel)("-", targetSiteId, targetChannelId);
    if (!tChannel) {
        utils.logBullet(`could not find channel ${(0, colorette_1.bold)(targetChannelId)} in site ${(0, colorette_1.bold)(targetSiteId)}, creating it...`);
        try {
            tChannel = await (0, api_1.createChannel)("-", targetSiteId, targetChannelId);
        }
        catch (e) {
            throw new error_1.FirebaseError(`Could not create the channel ${(0, colorette_1.bold)(targetChannelId)} for site ${(0, colorette_1.bold)(targetSiteId)}.`, { original: e });
        }
        utils.logSuccess(`Created new channel ${targetChannelId}`);
        try {
            const tProjectId = parseProjectId(tChannel.name);
            await (0, api_1.addAuthDomains)(tProjectId, [tChannel.url]);
        }
        catch (e) {
            utils.logLabeledWarning("hosting:clone", `Unable to add channel domain to Firebase Auth. Visit the Firebase Console at ${utils.consoleUrl(targetSiteId, "/authentication/providers")}`);
            logger_1.logger.debug("[hosting] unable to add auth domain", e);
        }
    }
    const currentTargetVersionName = tChannel.release?.version?.name;
    if (equalSiteIds && sourceVersionName === currentTargetVersionName) {
        utils.logSuccess(`Channels ${(0, colorette_1.bold)(sourceChannelId)} and ${(0, colorette_1.bold)(targetChannel)} are serving identical versions. No need to clone.`);
        return;
    }
    let targetVersionName = sourceVersionName;
    const spinner = ora("Cloning site content...").start();
    try {
        if (!equalSiteIds) {
            const targetVersion = await (0, api_1.cloneVersion)(targetSiteId, sourceVersionName, true);
            if (!targetVersion) {
                throw new error_1.FirebaseError(`Could not clone the version ${(0, colorette_1.bold)(sourceVersion)} for site ${(0, colorette_1.bold)(targetSiteId)}.`);
            }
            targetVersionName = targetVersion.name;
        }
        await (0, api_1.createRelease)(targetSiteId, targetChannelId, targetVersionName);
    }
    catch (err) {
        spinner.fail();
        throw err;
    }
    spinner.succeed();
    utils.logSuccess(`Site ${(0, colorette_1.bold)(sourceSiteId)} ${sourceChannelId ? "channel" : "version"} ${(0, colorette_1.bold)(sourceChannelId || sourceVersion)} has been cloned to site ${(0, colorette_1.bold)(targetSiteId)} channel ${(0, colorette_1.bold)(targetChannelId)}.`);
    utils.logSuccess(`Channel URL (${targetChannelId}): ${tChannel.url}`);
});
function parseProjectId(name) {
    const matches = name.match(`^projects/([^/]+)`);
    return matches ? matches[1] || "" : "";
}
