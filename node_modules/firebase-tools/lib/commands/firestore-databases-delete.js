"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const fsi = require("../firestore/api");
const prompt_1 = require("../prompt");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const error_1 = require("../error");
const pretty_print_1 = require("../firestore/pretty-print");
exports.command = new command_1.Command("firestore:databases:delete <database>")
    .description("delete a database in your Cloud Firestore project")
    .option("--force", "attempt to delete database without prompting for confirmation")
    .before(requirePermissions_1.requirePermissions, ["datastore.databases.delete"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (database, options) => {
    const api = new fsi.FirestoreApi();
    const printer = new pretty_print_1.PrettyPrint();
    if (!options.force) {
        const confirmMessage = `You are about to delete projects/${options.project}/databases/${database}. Do you wish to continue?`;
        const consent = await (0, prompt_1.confirm)(confirmMessage);
        if (!consent) {
            throw new error_1.FirebaseError("Delete database canceled.");
        }
    }
    const databaseResp = await api.deleteDatabase(options.project, database);
    logger_1.logger.info(clc.bold(`Successfully deleted ${printer.prettyDatabaseString(databaseResp)}`));
    return databaseResp;
});
