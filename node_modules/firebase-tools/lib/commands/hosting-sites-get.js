"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const Table = require("cli-table3");
const command_1 = require("../command");
const api_1 = require("../hosting/api");
const requirePermissions_1 = require("../requirePermissions");
const projectUtils_1 = require("../projectUtils");
const logger_1 = require("../logger");
const error_1 = require("../error");
exports.command = new command_1.Command("hosting:sites:get <siteId>")
    .description("print info about a Firebase Hosting site")
    .before(requirePermissions_1.requirePermissions, ["firebasehosting.sites.get"])
    .action(async (siteId, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    if (!siteId) {
        throw new error_1.FirebaseError("<siteId> must be specified");
    }
    const site = await (0, api_1.getSite)(projectId, siteId);
    const table = new Table();
    table.push(["Site ID:", site.name.split("/").pop()]);
    table.push(["Default URL:", site.defaultUrl]);
    table.push(["App ID:", site.appId || ""]);
    logger_1.logger.info();
    logger_1.logger.info(table.toString());
    return site;
});
