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
exports.command = new command_1.Command("appdistribution:testers:list [group]")
    .description("list testers in project")
    .before(requireAuth_1.requireAuth)
    .action(async (group, options) => {
    const projectName = await (0, options_parser_util_1.getProjectName)(options);
    const appDistroClient = new client_1.AppDistributionClient();
    let testers;
    const spinner = ora("Preparing the list of your App Distribution testers").start();
    try {
        testers = await appDistroClient.listTesters(projectName, group);
    }
    catch (err) {
        spinner.fail();
        throw new error_1.FirebaseError("Failed to list testers.", {
            exit: 1,
            original: err,
        });
    }
    spinner.succeed();
    printTestersTable(testers);
    utils.logSuccess(`Testers listed successfully`);
    return { testers };
});
function printTestersTable(testers) {
    const tableHead = ["Name", "Display Name", "Last Activity Time", "Groups"];
    const table = new Table({
        head: tableHead,
        style: { head: ["green"] },
    });
    for (const tester of testers) {
        const name = tester.name.split("/").pop();
        const groups = (tester.groups ?? [])
            .map((grp) => grp.split("/").pop())
            .sort()
            .join(";");
        table.push([name, tester.displayName ?? "", tester.lastActivityTime.toString(), groups]);
    }
    logger_1.logger.info(table.toString());
}
