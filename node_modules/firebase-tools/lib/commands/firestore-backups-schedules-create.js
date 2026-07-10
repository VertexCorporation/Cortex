"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const backupUtils_1 = require("../firestore/backupUtils");
const firestore_1 = require("../gcp/firestore");
const types = require("../firestore/api-types");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const pretty_print_1 = require("../firestore/pretty-print");
const error_1 = require("../error");
exports.command = new command_1.Command("firestore:backups:schedules:create")
    .description("create a backup schedule under your Cloud Firestore database")
    .option("-d, --database <databaseId>", "database under which you want to create a schedule. Defaults to the (default) database")
    .option("--retention <duration>", "duration string (e.g. 12h or 30d) for backup retention")
    .option("--recurrence <recurrence>", "recurrence settings; either DAILY or WEEKLY")
    .option("--day-of-week <dayOfWeek>", "on which day of the week to perform backups; one of MONDAY, TUESDAY, WEDNESDAY, THURSDAY, FRIDAY, SATURDAY, or SUNDAY")
    .before(requirePermissions_1.requirePermissions, ["datastore.backupSchedules.create"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (options) => {
    const printer = new pretty_print_1.PrettyPrint();
    const helpCommandText = "See firebase firestore:backups:schedules:create --help for more info.";
    const databaseId = options.database || "(default)";
    if (!options.retention) {
        throw new error_1.FirebaseError(`Missing required flag --retention. ${helpCommandText}`);
    }
    const retention = (0, backupUtils_1.calculateRetention)(options.retention);
    if (!options.recurrence) {
        throw new error_1.FirebaseError(`Missing required flag --recurrence. ${helpCommandText}`);
    }
    const recurrenceType = options.recurrence;
    if (recurrenceType !== types.RecurrenceType.DAILY &&
        recurrenceType !== types.RecurrenceType.WEEKLY) {
        throw new error_1.FirebaseError(`Invalid value for flag --recurrence. ${helpCommandText}`);
    }
    let dailyRecurrence;
    let weeklyRecurrence;
    if (options.recurrence === types.RecurrenceType.DAILY) {
        dailyRecurrence = {};
        if (options.dayOfWeek) {
            throw new error_1.FirebaseError(`--day-of-week should not be provided if --recurrence is DAILY. ${helpCommandText}`);
        }
    }
    else if (options.recurrence === types.RecurrenceType.WEEKLY) {
        if (!options.dayOfWeek) {
            throw new error_1.FirebaseError(`If --recurrence is WEEKLY, --day-of-week must be provided. ${helpCommandText}`);
        }
        const day = options.dayOfWeek;
        weeklyRecurrence = {
            day,
        };
    }
    const backupSchedule = await (0, firestore_1.createBackupSchedule)(options.project, databaseId, retention, dailyRecurrence, weeklyRecurrence);
    logger_1.logger.info(clc.bold(`Successfully created ${printer.prettyBackupScheduleString(backupSchedule)}`));
    return backupSchedule;
});
