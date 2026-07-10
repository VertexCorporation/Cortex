"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const utils = require("../utils");
const requireAuth_1 = require("../requireAuth");
const error_1 = require("../error");
const client_1 = require("../appdistribution/client");
const options_parser_util_1 = require("../appdistribution/options-parser-util");
exports.command = new command_1.Command("appdistribution:groups:delete <alias>")
    .description("delete an App Distribution group")
    .alias("appdistribution:group:delete")
    .before(requireAuth_1.requireAuth)
    .action(async (alias, options) => {
    const projectName = await (0, options_parser_util_1.getProjectName)(options);
    const appDistroClient = new client_1.AppDistributionClient();
    try {
        utils.logBullet(`Deleting group from project`);
        await appDistroClient.deleteGroup(`${projectName}/groups/${alias}`);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to delete group ${(0, error_1.getErrMsg)(err)}`);
    }
    utils.logSuccess(`Group ${alias} has successfully been deleted`);
});
