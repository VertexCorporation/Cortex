"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const backupUtils_1 = require("../firestore/backupUtils");
const firestore_1 = require("../gcp/firestore");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const pretty_print_1 = require("../firestore/pretty-print");
const error_1 = require("../error");
exports.command = new command_1.Command("firestore:backups:schedules:update <backupSchedule>")
    .description("update a backup schedule under your Cloud Firestore database")
    .option("--retention <duration>", "duration string (e.g. 12h or 30d) for backup retention")
    .before(requirePermissions_1.requirePermissions, ["datastore.backupSchedules.update"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (backupScheduleName, options) => {
    const printer = new pretty_print_1.PrettyPrint();
    const helpCommandText = "See firebase firestore:backups:schedules:update --help for more info.";
    if (!options.retention) {
        throw new error_1.FirebaseError(`Missing required flag --retention. ${helpCommandText}`);
    }
    const retention = (0, backupUtils_1.calculateRetention)(options.retention);
    const backupSchedule = await (0, firestore_1.updateBackupSchedule)(backupScheduleName, retention);
    logger_1.logger.info(clc.bold(`Successfully updated ${printer.prettyBackupScheduleString(backupSchedule)}`));
    return backupSchedule;
});
