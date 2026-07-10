"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const Table = require("cli-table3");
const command_1 = require("../command");
const clc = require("colorette");
const ora = require("ora");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const experiments = require("../experiments");
const projectUtils_1 = require("../projectUtils");
const database_1 = require("../management/database");
exports.command = new command_1.Command("database:instances:list")
    .description("list realtime database instances, optionally filtered by a specified location")
    .before(requirePermissions_1.requirePermissions, ["firebasedatabase.instances.list"])
    .option("-l, --location <location>", "(optional) location for the database instance, defaults to all regions")
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.DATABASE)
    .action(async (options) => {
    const location = (0, database_1.parseDatabaseLocation)(options.location, database_1.DatabaseLocation.ANY);
    const spinner = ora("Preparing the list of your Firebase Realtime Database instances" +
        `${location === database_1.DatabaseLocation.ANY ? "" : ` for location: ${location}`}`).start();
    const projectId = (0, projectUtils_1.needProjectId)(options);
    let instances = [];
    try {
        instances = await (0, database_1.listDatabaseInstances)(projectId, location);
    }
    catch (err) {
        spinner.fail();
        throw err;
    }
    spinner.succeed();
    if (instances.length === 0) {
        logger_1.logger.info(clc.bold("No database instances found."));
        return;
    }
    if (!experiments.isEnabled("rtdbmanagement")) {
        for (const instance of instances) {
            logger_1.logger.info(instance.name);
        }
        logger_1.logger.info(`Project ${options.project} has ${instances.length} database instances`);
        return instances;
    }
    const tableHead = ["Database Instance Name", "Location", "Type", "State"];
    const table = new Table({ head: tableHead, style: { head: ["green"] } });
    for (const db of instances) {
        table.push([db.name, db.location, db.type, db.state]);
    }
    logger_1.logger.info(table.toString());
    logger_1.logger.info(`${instances.length} database instance(s) total.`);
    return instances;
});
