"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const fsi = require("../firestore/api");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const pretty_print_1 = require("../firestore/pretty-print");
const projectUtils_1 = require("../projectUtils");
exports.command = new command_1.Command("firestore:indexes")
    .description("list indexes in a Cloud Firestore database")
    .option("--pretty", "pretty print the indexes. When not specified the indexes are printed in the " +
    "JSON specification format")
    .option("--database <databaseId>", "database ID of the firestore database from which to list indexes. (default) if none provided")
    .before(requirePermissions_1.requirePermissions, ["datastore.indexes.list"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (options) => {
    const indexApi = new fsi.FirestoreApi();
    const printer = new pretty_print_1.PrettyPrint();
    const databaseId = options.database ?? "(default)";
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const indexes = await indexApi.listIndexes(projectId, databaseId);
    const fieldOverrides = await indexApi.listFieldOverrides(projectId, databaseId);
    const indexSpec = indexApi.makeIndexSpec(indexes, fieldOverrides);
    if (options.pretty) {
        logger_1.logger.info(clc.bold(clc.white("Compound Indexes")));
        printer.prettyPrintIndexes(indexes);
        if (fieldOverrides) {
            logger_1.logger.info();
            logger_1.logger.info(clc.bold(clc.white("Field Overrides")));
            printer.printFieldOverrides(fieldOverrides);
        }
    }
    else {
        logger_1.logger.info(JSON.stringify(indexSpec, undefined, 2));
    }
    return indexSpec;
});
