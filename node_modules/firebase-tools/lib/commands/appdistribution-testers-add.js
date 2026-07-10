"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const utils = require("../utils");
const requireAuth_1 = require("../requireAuth");
const client_1 = require("../appdistribution/client");
const options_parser_util_1 = require("../appdistribution/options-parser-util");
exports.command = new command_1.Command("appdistribution:testers:add [emails...]")
    .description("add testers to project (and App Distribution group, if specified via flag)")
    .option("--file <file>", "a path to a file containing a list of tester emails to be added")
    .option("--group-alias <group-alias>", "if specified, the testers are also added to the group identified by this alias")
    .before(requireAuth_1.requireAuth)
    .action(async (emails, options) => {
    const projectName = await (0, options_parser_util_1.getProjectName)(options);
    const appDistroClient = new client_1.AppDistributionClient();
    const emailsToAdd = (0, options_parser_util_1.getEmails)(emails, options.file);
    utils.logBullet(`Adding ${emailsToAdd.length} testers to project`);
    await appDistroClient.addTesters(projectName, emailsToAdd);
    if (options.groupAlias) {
        utils.logBullet(`Adding ${emailsToAdd.length} testers to group`);
        await appDistroClient.addTestersToGroup(`${projectName}/groups/${options.groupAlias}`, emailsToAdd);
    }
});
