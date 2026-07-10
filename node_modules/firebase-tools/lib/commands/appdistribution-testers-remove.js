"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const utils = require("../utils");
const requireAuth_1 = require("../requireAuth");
const error_1 = require("../error");
const client_1 = require("../appdistribution/client");
const options_parser_util_1 = require("../appdistribution/options-parser-util");
const logger_1 = require("../logger");
exports.command = new command_1.Command("appdistribution:testers:remove [emails...]")
    .description("remove testers from a project (or App Distribution group, if specified via flag)")
    .option("--file <file>", "a path to a file containing a list of tester emails to be removed")
    .option("--group-alias <group-alias>", "if specified, the testers are only removed from the group identified by this alias, but not the project")
    .before(requireAuth_1.requireAuth)
    .action(async (emails, options) => {
    const projectName = await (0, options_parser_util_1.getProjectName)(options);
    const appDistroClient = new client_1.AppDistributionClient();
    const emailsArr = (0, options_parser_util_1.getEmails)(emails, options.file);
    if (options.groupAlias) {
        utils.logBullet(`Removing ${emailsArr.length} testers from group`);
        await appDistroClient.removeTestersFromGroup(`${projectName}/groups/${options.groupAlias}`, emailsArr);
    }
    else {
        let deleteResponse;
        try {
            utils.logBullet(`Deleting ${emailsArr.length} testers from project`);
            deleteResponse = await appDistroClient.removeTesters(projectName, emailsArr);
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to remove testers ${(0, error_1.getErrMsg)(err)}`);
        }
        if (!deleteResponse.emails) {
            utils.logSuccess(`Testers did not exist`);
            return;
        }
        logger_1.logger.debug(`Testers: ${deleteResponse.emails}, have been successfully deleted`);
        utils.logSuccess(`${deleteResponse.emails.length} testers have successfully been deleted`);
    }
});
