"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const fsi = require("../firestore/api");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const pretty_print_1 = require("../firestore/pretty-print");
exports.command = new command_1.Command("firestore:operations:list")
    .description("list pending Cloud Firestore admin operations and their status")
    .option("--database <databaseName>", 'Database ID for database to list operations for. "(default)" if none is provided.')
    .option("--limit <number>", "The maximum number of operations to list. Uses 100 by default.")
    .before(commandUtils_1.errorMissingProject)
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (options) => {
    const databaseId = options.database || "(default)";
    const limit = options.limit === undefined ? 100 : Number(options.limit);
    const api = new fsi.FirestoreApi();
    const { operations } = await api.listOperations(options.project, databaseId, limit);
    const printer = new pretty_print_1.PrettyPrint();
    printer.prettyPrintOperations(operations);
    return operations;
});
