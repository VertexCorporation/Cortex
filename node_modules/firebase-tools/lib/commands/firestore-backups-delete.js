"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const firestore_1 = require("../gcp/firestore");
const prompt_1 = require("../prompt");
const clc = require("colorette");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const error_1 = require("../error");
exports.command = new command_1.Command("firestore:backups:delete <backup>")
    .description("delete a backup under your Cloud Firestore database")
    .option("--force", "attempt to delete backup without prompting for confirmation")
    .before(requirePermissions_1.requirePermissions, ["datastore.backups.delete"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (backupName, options) => {
    const backup = await (0, firestore_1.getBackup)(backupName);
    if (!options.force) {
        const confirmMessage = `You are about to delete ${backupName}. Do you wish to continue?`;
        const consent = await (0, prompt_1.confirm)({
            message: confirmMessage,
            default: false,
        });
        if (!consent) {
            throw new error_1.FirebaseError("Delete backup canceled.");
        }
    }
    try {
        await (0, firestore_1.deleteBackup)(backupName);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to delete the backup ${backupName}`, { original: err });
    }
    logger_1.logger.info(clc.bold(`Successfully deleted ${clc.yellow(backupName)}`));
    return backup;
});
