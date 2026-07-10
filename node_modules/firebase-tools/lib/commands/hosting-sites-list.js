"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const colorette_1 = require("colorette");
const Table = require("cli-table3");
const command_1 = require("../command");
const api_1 = require("../hosting/api");
const requirePermissions_1 = require("../requirePermissions");
const projectUtils_1 = require("../projectUtils");
const logger_1 = require("../logger");
const TABLE_HEAD = ["Site ID", "Default URL", "App ID (if set)"];
exports.command = new command_1.Command("hosting:sites:list")
    .description("list Firebase Hosting sites")
    .before(requirePermissions_1.requirePermissions, ["firebasehosting.sites.get"])
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const sites = await (0, api_1.listSites)(projectId);
    const table = new Table({ head: TABLE_HEAD, style: { head: ["green"] } });
    for (const site of sites) {
        const siteId = site.name.split("/").pop();
        table.push([siteId, site.defaultUrl, site.appId || "--"]);
    }
    logger_1.logger.info();
    logger_1.logger.info(`Sites for project ${(0, colorette_1.bold)(projectId)}`);
    logger_1.logger.info();
    logger_1.logger.info(table.toString());
    return { sites };
});
