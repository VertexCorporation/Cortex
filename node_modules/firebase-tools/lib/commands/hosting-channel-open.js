"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const lodash_1 = require("lodash");
const colorette_1 = require("colorette");
const open = require("open");
const command_1 = require("../command");
const error_1 = require("../error");
const api_1 = require("../hosting/api");
const requirePermissions_1 = require("../requirePermissions");
const projectUtils_1 = require("../projectUtils");
const requireConfig_1 = require("../requireConfig");
const utils_1 = require("../utils");
const requireHostingSite_1 = require("../requireHostingSite");
const prompt_1 = require("../prompt");
exports.command = new command_1.Command("hosting:channel:open [channelId]")
    .description("opens the URL for a Firebase Hosting channel")
    .help("if unable to open the URL in a browser, it will be displayed in the output")
    .option("--site <siteId>", "the site to which the channel belongs")
    .before(requireConfig_1.requireConfig)
    .before(requirePermissions_1.requirePermissions, ["firebasehosting.sites.get"])
    .before(requireHostingSite_1.requireHostingSite)
    .action(async (channelId, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const siteId = options.site;
    if (!channelId) {
        if (options.nonInteractive) {
            throw new error_1.FirebaseError(`Please provide a channelId.`);
        }
        const channels = await (0, api_1.listChannels)(projectId, siteId);
        (0, lodash_1.sortBy)(channels, ["name"]);
        channelId = await (0, prompt_1.select)({
            message: "Which channel would you like to open?",
            choices: channels.map((c) => (0, lodash_1.last)(c.name.split("/")) || c.name),
        });
    }
    channelId = (0, api_1.normalizeName)(channelId);
    const channel = await (0, api_1.getChannel)(projectId, siteId, channelId);
    if (!channel) {
        throw new error_1.FirebaseError(`Could not find the channel ${(0, colorette_1.bold)(channelId)} for site ${(0, colorette_1.bold)(siteId)}.`);
    }
    (0, utils_1.logLabeledBullet)("hosting:channel", channel.url);
    if (!options.nonInteractive) {
        open(channel.url);
    }
    return { url: channel.url };
});
