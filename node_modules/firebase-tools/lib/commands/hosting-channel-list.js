"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const colorette_1 = require("colorette");
const Table = require("cli-table3");
const api_1 = require("../hosting/api");
const command_1 = require("../command");
const requirePermissions_1 = require("../requirePermissions");
const projectUtils_1 = require("../projectUtils");
const logger_1 = require("../logger");
const requireConfig_1 = require("../requireConfig");
const utils_1 = require("../utils");
const requireHostingSite_1 = require("../requireHostingSite");
const TABLE_HEAD = ["Channel ID", "Last Release Time", "URL", "Expire Time"];
exports.command = new command_1.Command("hosting:channel:list")
    .description("list all Firebase Hosting channels for your project")
    .option("--site <siteName>", "list channels for the specified site")
    .before(requireConfig_1.requireConfig)
    .before(requirePermissions_1.requirePermissions, ["firebasehosting.sites.update"])
    .before(requireHostingSite_1.requireHostingSite)
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const siteId = options.site;
    const channels = await (0, api_1.listChannels)(projectId, siteId);
    const table = new Table({ head: TABLE_HEAD, style: { head: ["green"] } });
    for (const channel of channels) {
        const channelId = channel.name.split("/").pop();
        table.push([
            channelId,
            (0, utils_1.datetimeString)(new Date(channel.updateTime)),
            channel.url,
            channel.expireTime ? (0, utils_1.datetimeString)(new Date(channel.expireTime)) : "never",
        ]);
    }
    logger_1.logger.info();
    logger_1.logger.info(`Channels for site ${(0, colorette_1.bold)(siteId)}`);
    logger_1.logger.info();
    logger_1.logger.info(table.toString());
    return { channels };
});
