"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const requireDatabaseInstance_1 = require("../requireDatabaseInstance");
const database_1 = require("../management/database");
const requirePermissions_1 = require("../requirePermissions");
const utils = require("../utils");
const profiler_1 = require("../profiler");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
exports.command = new command_1.Command("database:profile")
    .description("profile the Realtime Database and generate a usage report")
    .option("-o, --output <filename>", "save the output to the specified file")
    .option("-d, --duration <seconds>", "collect database usage information for the specified number of seconds")
    .option("--raw", "output the raw stats collected as newline delimited json")
    .option("--no-collapse", "prevent collapsing similar paths into $wildcard locations")
    .option("-i, --input <filename>", "generate the report based on the specified file instead " +
    "of streaming logs from the database")
    .option("--instance <instance>", "use the database <instance>.firebaseio.com (if omitted, use default database instance)")
    .before(requirePermissions_1.requirePermissions, ["firebasedatabase.instances.update"])
    .before(requireDatabaseInstance_1.requireDatabaseInstance)
    .before(database_1.populateInstanceDetails)
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.DATABASE)
    .action((options) => {
    if (options.raw && options.input) {
        return utils.reject("Cannot specify both an input file and raw format", {
            exit: 1,
        });
    }
    else if (options.parent.json && options.raw) {
        return utils.reject("Cannot output raw data in json format", { exit: 1 });
    }
    else if (options.input && options.duration !== undefined) {
        return utils.reject("Cannot specify a duration for input files", {
            exit: 1,
        });
    }
    else if (options.duration !== undefined && options.duration <= 0) {
        return utils.reject("Must specify a positive number of seconds", {
            exit: 1,
        });
    }
    return (0, profiler_1.profiler)(options);
});
