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
exports.command = new command_1.Command("firestore:databases:create <database>")
    .description("create a database in your Firebase project")
    .option("--location <locationId>", "region to create database, for example 'nam5'. Run 'firebase firestore:locations' to get a list of eligible locations (required)")
    .option("--edition <edition>", "the edition of the database to create, for example 'standard' or 'enterprise'. If not provided, 'standard' is used as a default.")
    .option("--delete-protection <deleteProtectionState>", "whether or not to prevent deletion of database, for example 'ENABLED' or 'DISABLED'. Default is 'DISABLED'")
    .option("--point-in-time-recovery <enablement>", "whether to enable the PITR feature on this database, for example 'ENABLED' or 'DISABLED'. Default is 'DISABLED'")
    .option("--realtime-updates <enablement>", "Whether realtime updates are enabled for this database, for example 'ENABLED' or 'DISABLED'. Can only be specified for 'enterprise' edition databases. Defaults to 'ENABLED' when firestore-data-access is enabled, otherwise the server default is used.")
    .option("--firestore-data-access <enablement>", "Whether the Firestore API can be used for this database, for example 'ENABLED' or 'DISABLED'. Can only be specified for 'enterprise' edition databases. Default is 'ENABLED'.")
    .option("--mongodb-compatible-data-access <enablement>", "Whether the MongoDB compatible API can be used for this database, for example 'ENABLED' or 'DISABLED'. Can only be specified for 'enterprise' edition databases. Default is 'DISABLED'.")
    .option("-k, --kms-key-name <kmsKeyName>", "the resource ID of a Cloud KMS key. If set, the database created will be a " +
    "Customer-managed Encryption Key (CMEK) database encrypted with this key. " +
    "This feature is allowlist only in initial launch")
    .before(requirePermissions_1.requirePermissions, ["datastore.databases.create"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (database, options) => {
    const api = new fsi.FirestoreApi();
    const printer = new pretty_print_1.PrettyPrint();
    const helpCommandText = "See firebase firestore:databases:create --help for more info.";
    if (!options.location) {
        throw new error_1.FirebaseError(`Missing required flag --location. ${helpCommandText}`);
    }
    const type = types.DatabaseType.FIRESTORE_NATIVE;
    let databaseEdition = types.DatabaseEdition.STANDARD;
    if (options.edition) {
        const edition = options.edition.toUpperCase();
        if (edition !== types.DatabaseEdition.STANDARD &&
            edition !== types.DatabaseEdition.ENTERPRISE) {
            throw new error_1.FirebaseError(`Invalid value for flag --edition. ${helpCommandText}`);
        }
        databaseEdition = edition;
    }
    types.validateEnablementOption(options.deleteProtection, "delete-protection", helpCommandText);
    const deleteProtectionState = options.deleteProtection === types.EnablementOption.ENABLED
        ? types.DatabaseDeleteProtectionState.ENABLED
        : types.DatabaseDeleteProtectionState.DISABLED;
    types.validateEnablementOption(options.pointInTimeRecovery, "point-in-time-recovery", helpCommandText);
    const pointInTimeRecoveryEnablement = options.pointInTimeRecovery === types.EnablementOption.ENABLED
        ? types.PointInTimeRecoveryEnablement.ENABLED
        : types.PointInTimeRecoveryEnablement.DISABLED;
    types.validateEnablementOption(options.firestoreDataAccess, "firestore-data-access", helpCommandText);
    let userFirestoreDataAccess;
    if (options.firestoreDataAccess === types.EnablementOption.ENABLED) {
        userFirestoreDataAccess = types.DataAccessMode.ENABLED;
    }
    else if (options.firestoreDataAccess === types.EnablementOption.DISABLED) {
        userFirestoreDataAccess = types.DataAccessMode.DISABLED;
    }
    types.validateEnablementOption(options.mongodbCompatibleDataAccess, "mongodb-compatible-data-access", helpCommandText);
    let userMongodbDataAccess;
    if (options.mongodbCompatibleDataAccess === types.EnablementOption.ENABLED) {
        userMongodbDataAccess = types.DataAccessMode.ENABLED;
    }
    else if (options.mongodbCompatibleDataAccess === types.EnablementOption.DISABLED) {
        userMongodbDataAccess = types.DataAccessMode.DISABLED;
    }
    let firestoreDataAccessMode = userFirestoreDataAccess;
    if (firestoreDataAccessMode == null) {
        firestoreDataAccessMode = getDefaultFirestoreDataAccessMode(databaseEdition, userMongodbDataAccess);
    }
    let mongodbCompatibleDataAccessMode = userMongodbDataAccess;
    if (mongodbCompatibleDataAccessMode == null) {
        mongodbCompatibleDataAccessMode = getDefaultMongodbDataAccessMode(databaseEdition, userFirestoreDataAccess);
    }
    types.validateEnablementOption(options.realtimeUpdates, "realtime-updates", helpCommandText);
    let realtimeUpdatesMode;
    if (options.realtimeUpdates === types.EnablementOption.ENABLED) {
        realtimeUpdatesMode = types.RealtimeUpdatesMode.ENABLED;
    }
    else if (options.realtimeUpdates === types.EnablementOption.DISABLED) {
        realtimeUpdatesMode = types.RealtimeUpdatesMode.DISABLED;
    }
    if (realtimeUpdatesMode == null &&
        databaseEdition === types.DatabaseEdition.ENTERPRISE &&
        firestoreDataAccessMode === types.DataAccessMode.ENABLED) {
        realtimeUpdatesMode = types.RealtimeUpdatesMode.ENABLED;
    }
    let cmekConfig;
    if (options.kmsKeyName) {
        cmekConfig = {
            kmsKeyName: options.kmsKeyName,
        };
    }
    const createDatabaseReq = {
        project: options.project,
        databaseId: database,
        locationId: options.location,
        type,
        databaseEdition,
        deleteProtectionState,
        pointInTimeRecoveryEnablement,
        realtimeUpdatesMode,
        firestoreDataAccessMode,
        mongodbCompatibleDataAccessMode,
        cmekConfig,
    };
    const databaseResp = await api.createDatabase(createDatabaseReq);
    logger_1.logger.info(clc.bold(`Successfully created ${printer.prettyDatabaseString(databaseResp)}`));
    logger_1.logger.info("Please be sure to configure Firebase rules in your Firebase config file for\n" +
        "the new database. By default, created databases will have closed rules that\n" +
        "block any incoming third-party traffic.");
    logger_1.logger.info(`Your database may be viewed at ${printer.firebaseConsoleDatabaseUrl(options.project, database)}`);
    return databaseResp;
});
function getDefaultFirestoreDataAccessMode(databaseEdition, userMongodbDataAccess) {
    if (databaseEdition !== types.DatabaseEdition.ENTERPRISE) {
        return types.DataAccessMode.UNSPECIFIED;
    }
    switch (userMongodbDataAccess) {
        case types.DataAccessMode.ENABLED:
            return types.DataAccessMode.DISABLED;
        default:
            return types.DataAccessMode.ENABLED;
    }
}
function getDefaultMongodbDataAccessMode(databaseEdition, userFirestoreDataAccess) {
    if (databaseEdition !== types.DatabaseEdition.ENTERPRISE) {
        return types.DataAccessMode.UNSPECIFIED;
    }
    switch (userFirestoreDataAccess) {
        case types.DataAccessMode.ENABLED:
            return types.DataAccessMode.DISABLED;
        default:
            return types.DataAccessMode.DISABLED;
    }
}
