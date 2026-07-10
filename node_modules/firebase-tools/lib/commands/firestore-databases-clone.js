"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const fsi = require("../firestore/api");
const util_1 = require("../firestore/util");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const options_1 = require("../firestore/options");
const pretty_print_1 = require("../firestore/pretty-print");
const error_1 = require("../error");
exports.command = new command_1.Command("firestore:databases:clone <sourceDatabase> <targetDatabase>")
    .description("clone one Firestore database to another")
    .option("-e, --encryption-type <encryptionType>", `encryption method of the cloned database; one of ${options_1.EncryptionType.USE_SOURCE_ENCRYPTION} (default), ` +
    `${options_1.EncryptionType.CUSTOMER_MANAGED_ENCRYPTION}, ${options_1.EncryptionType.GOOGLE_DEFAULT_ENCRYPTION}`)
    .option("-k, --kms-key-name <kmsKeyName>", "resource ID of the Cloud KMS key to encrypt the cloned database. This " +
    "feature is allowlist only in initial launch")
    .option("-s, --snapshot-time <snapshotTime>", "snapshot time of the source database to use, in ISO 8601 format. Can be any minutely snapshot after the database's earliest version time. If unspecified, takes the most recent available snapshot")
    .before(requirePermissions_1.requirePermissions, ["datastore.databases.clone"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (sourceDatabase, targetDatabase, options) => {
    const api = new fsi.FirestoreApi();
    const printer = new pretty_print_1.PrettyPrint();
    const helpCommandText = "See firebase firestore:databases:clone --help for more info.";
    if (options.database) {
        throw new error_1.FirebaseError(`--database is not a supported flag for 'firestoree:databases:clone'. ${helpCommandText}`);
    }
    let snapshotTime;
    if (options.snapshotTime) {
        snapshotTime = options.snapshotTime;
    }
    else {
        snapshotTime = (0, util_1.getCurrentMinuteAsIsoString)();
    }
    let encryptionConfig = undefined;
    switch (options.encryptionType) {
        case options_1.EncryptionType.GOOGLE_DEFAULT_ENCRYPTION:
            throwIfKmsKeyNameIsSet(options.kmsKeyName);
            encryptionConfig = { googleDefaultEncryption: {} };
            break;
        case options_1.EncryptionType.USE_SOURCE_ENCRYPTION:
            throwIfKmsKeyNameIsSet(options.kmsKeyName);
            encryptionConfig = { useSourceEncryption: {} };
            break;
        case options_1.EncryptionType.CUSTOMER_MANAGED_ENCRYPTION:
            encryptionConfig = {
                customerManagedEncryption: { kmsKeyName: getKmsKeyOrThrow(options.kmsKeyName) },
            };
            break;
        case undefined:
            throwIfKmsKeyNameIsSet(options.kmsKeyName);
            break;
        default:
            throw new error_1.FirebaseError(`Invalid value for flag --encryption-type. ${helpCommandText}`);
    }
    const targetDatabaseName = (0, util_1.parseDatabaseName)(targetDatabase);
    const parentProject = targetDatabaseName.projectId;
    const targetDatabaseId = targetDatabaseName.databaseId;
    const sourceProject = (0, util_1.parseDatabaseName)(sourceDatabase).projectId;
    if (parentProject !== sourceProject) {
        throw new error_1.FirebaseError(`Cloning across projects is not supported.`);
    }
    const lro = await api.cloneDatabase(sourceProject, {
        database: sourceDatabase,
        snapshotTime,
    }, targetDatabaseId, encryptionConfig);
    if (lro.error) {
        logger_1.logger.error(clc.bold(`Clone to ${printer.prettyDatabaseString(targetDatabase)} failed. See below for details.`));
        printer.prettyPrintOperation(lro);
    }
    else {
        logger_1.logger.info(clc.bold(`Successfully initiated clone to ${printer.prettyDatabaseString(targetDatabase)}`));
        logger_1.logger.info("Please be sure to configure Firebase rules in your Firebase config file for\n" +
            "the new database. By default, created databases will have closed rules that\n" +
            "block any incoming third-party traffic.");
        logger_1.logger.info();
        logger_1.logger.info(`You can monitor the progress of this clone by executing this command:`);
        logger_1.logger.info();
        logger_1.logger.info(`firebase firestore:operations:describe --database="${targetDatabaseId}" ${lro.name}`);
        logger_1.logger.info();
        logger_1.logger.info(`Once the clone is complete, your database may be viewed at ${printer.firebaseConsoleDatabaseUrl(options.project, targetDatabaseId)}`);
    }
    return lro;
    function throwIfKmsKeyNameIsSet(kmsKeyName) {
        if (kmsKeyName) {
            throw new error_1.FirebaseError("--kms-key-name can only be set when specifying an --encryption-type " +
                `of ${options_1.EncryptionType.CUSTOMER_MANAGED_ENCRYPTION}.`);
        }
    }
    function getKmsKeyOrThrow(kmsKeyName) {
        if (kmsKeyName)
            return kmsKeyName;
        throw new error_1.FirebaseError("--kms-key-name must be provided when specifying an --encryption-type " +
            `of ${options_1.EncryptionType.CUSTOMER_MANAGED_ENCRYPTION}.`);
    }
});
