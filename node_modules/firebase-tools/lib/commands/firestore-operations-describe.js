"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const fsi = require("../firestore/api");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const pretty_print_1 = require("../firestore/pretty-print");
const firestore_utils_1 = require("./firestore-utils");
exports.command = new command_1.Command("firestore:operations:describe <operationName>")
    .description("retrieves information about a Cloud Firestore admin operation")
    .option("--database <databaseName>", 'Database ID for which the operation is running. "(default)" if none is provided.')
    .before(commandUtils_1.errorMissingProject)
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (operationName, options) => {
    const databaseId = options.database || "(default)";
    operationName = (0, firestore_utils_1.getShortOperationName)(operationName);
    const api = new fsi.FirestoreApi();
    const operation = await api.describeOperation(options.project, databaseId, operationName);
    const printer = new pretty_print_1.PrettyPrint();
    printer.prettyPrintOperation(operation);
    return operation;
});
