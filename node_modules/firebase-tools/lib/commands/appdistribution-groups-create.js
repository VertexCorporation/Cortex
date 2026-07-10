"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const utils = require("../utils");
const requireAuth_1 = require("../requireAuth");
const client_1 = require("../appdistribution/client");
const options_parser_util_1 = require("../appdistribution/options-parser-util");
exports.command = new command_1.Command("appdistribution:groups:create <displayName> [alias]")
    .description("create an App Distribution group")
    .alias("appdistribution:group:create")
    .before(requireAuth_1.requireAuth)
    .action(async (displayName, alias, options) => {
    const projectName = await (0, options_parser_util_1.getProjectName)(options);
    const appDistroClient = new client_1.AppDistributionClient();
    utils.logBullet(`Creating group in project`);
    const group = await appDistroClient.createGroup(projectName, displayName, alias);
    alias = group.name.split("/").pop();
    utils.logSuccess(`Group '${group.displayName}' (alias: ${alias}) created successfully`);
});
