"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const ora = require("ora");
const client_1 = require("../appdistribution/client");
const options_parser_util_1 = require("../appdistribution/options-parser-util");
const command_1 = require("../command");
const error_1 = require("../error");
const logger_1 = require("../logger");
const requireAuth_1 = require("../requireAuth");
const utils = require("../utils");
const Table = require("cli-table3");
exports.command = new command_1.Command("appdistribution:groups:list")
    .description("list App Distribution groups")
    .alias("appdistribution:group:list")
    .before(requireAuth_1.requireAuth)
    .action(async (options) => {
    const projectName = await (0, options_parser_util_1.getProjectName)(options);
    const appDistroClient = new client_1.AppDistributionClient();
    let groups;
    const spinner = ora("Preparing the list of your App Distribution Groups").start();
    try {
        groups = await appDistroClient.listGroups(projectName);
    }
    catch (err) {
        spinner.fail();
        throw new error_1.FirebaseError("Failed to list groups.", {
            exit: 1,
            original: err,
        });
    }
    spinner.succeed();
    printGroupsTable(groups);
    utils.logSuccess(`Groups listed successfully`);
    return { groups };
});
function printGroupsTable(groups) {
    const tableHead = ["Group", "Display Name", "Tester Count", "Release Count", "Invite Link Count"];
    const table = new Table({
        head: tableHead,
        style: { head: ["green"] },
    });
    for (const group of groups) {
        const name = group.name.split("/").pop();
        table.push([
            name,
            group.displayName,
            group.testerCount || 0,
            group.releaseCount || 0,
            group.inviteLinkCount || 0,
        ]);
    }
    logger_1.logger.info(table.toString());
}
