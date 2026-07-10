"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const fsi = require("../firestore/api");
const types = require("../firestore/api-types");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const pretty_print_1 = require("../firestore/pretty-print");
const error_1 = require("../error");
exports.command = new command_1.Command("firestore:databases:update <database>")
    .description("update a database in your Firebase project. Must specify at least one property to update")
    .option("--json", "prints raw json response of the create API call if specified")
    .option("--delete-protection <deleteProtectionState>", "whether or not to prevent deletion of database, for example 'ENABLED' or 'DISABLED'. Default is 'DISABLED'")
    .option("--point-in-time-recovery <enablement>", "whether to enable the PITR feature on this database, for example 'ENABLED' or 'DISABLED'. Default is 'DISABLED'")
    .before(requirePermissions_1.requirePermissions, ["datastore.databases.update"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (database, options) => {
    const api = new fsi.FirestoreApi();
    const printer = new pretty_print_1.PrettyPrint();
    const helpCommandText = "See firebase firestore:databases:update --help for more info.";
    if (!options.deleteProtection && !options.pointInTimeRecovery) {
        throw new error_1.FirebaseError(`Missing properties to update. ${helpCommandText}`);
    }
    types.validateEnablementOption(options.deleteProtection, "delete-protection", helpCommandText);
    let deleteProtectionState;
    if (options.deleteProtection === types.EnablementOption.ENABLED) {
        deleteProtectionState = types.DatabaseDeleteProtectionState.ENABLED;
    }
    else if (options.deleteProtection === types.EnablementOption.DISABLED) {
        deleteProtectionState = types.DatabaseDeleteProtectionState.DISABLED;
    }
    types.validateEnablementOption(options.pointInTimeRecovery, "point-in-time-recovery", helpCommandText);
    let pointInTimeRecoveryEnablement;
    if (options.pointInTimeRecovery === types.EnablementOption.ENABLED) {
        pointInTimeRecoveryEnablement = types.PointInTimeRecoveryEnablement.ENABLED;
    }
    else if (options.pointInTimeRecovery === types.EnablementOption.DISABLED) {
        pointInTimeRecoveryEnablement = types.PointInTimeRecoveryEnablement.DISABLED;
    }
    const databaseResp = await api.updateDatabase(options.project, database, deleteProtectionState, pointInTimeRecoveryEnablement);
    logger_1.logger.info(clc.bold(`Successfully updated ${printer.prettyDatabaseString(databaseResp)}`));
    return databaseResp;
});
