"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const firestore_1 = require("../gcp/firestore");
const pretty_print_1 = require("../firestore/pretty-print");
exports.command = new command_1.Command("firestore:backups:schedules:list")
    .description("list backup schedules under your Cloud Firestore database")
    .option("-d, --database <databaseId>", "database whose schedules you wish to list. Defaults to the (default) database")
    .before(requirePermissions_1.requirePermissions, ["datastore.backupSchedules.list"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (options) => {
    const printer = new pretty_print_1.PrettyPrint();
    const databaseId = options.database ?? "(default)";
    const backupSchedules = await (0, firestore_1.listBackupSchedules)(options.project, databaseId);
    printer.prettyPrintBackupSchedules(backupSchedules, databaseId);
    return backupSchedules;
});
