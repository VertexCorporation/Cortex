"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const fsi = require("../firestore/api");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const options_1 = require("../firestore/options");
const pretty_print_1 = require("../firestore/pretty-print");
const error_1 = require("../error");
exports.command = new command_1.Command("firestore:databases:restore")
    .description("restore a Firestore database from a backup")
    .option("-d, --database <databaseID>", "ID of the database to restore into")
    .option("-b, --backup <backup>", "backup from which to restore")
    .option("-e, --encryption-type <encryptionType>", `encryption method of the restored database; one of ${options_1.EncryptionType.USE_SOURCE_ENCRYPTION} (default), ` +
    `${options_1.EncryptionType.CUSTOMER_MANAGED_ENCRYPTION}, ${options_1.EncryptionType.GOOGLE_DEFAULT_ENCRYPTION}`)
    .option("-k, --kms-key-name <kmsKeyName>", "resource ID of the Cloud KMS key to encrypt the restored database. This " +
    "feature is allowlist only in initial launch")
    .before(requirePermissions_1.requirePermissions, ["datastore.backups.restoreDatabase"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (options) => {
    const api = new fsi.FirestoreApi();
    const printer = new pretty_print_1.PrettyPrint();
    const helpCommandText = "See firebase firestore:databases:restore --help for more info.";
    if (!options.database) {
        throw new error_1.FirebaseError(`Missing required flag --database. ${helpCommandText}`);
    }
    const databaseId = options.database;
    if (!options.backup) {
        throw new error_1.FirebaseError(`Missing required flag --backup. ${helpCommandText}`);
    }
    const backupName = options.backup;
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
    const databaseResp = await api.restoreDatabase(options.project, databaseId, backupName, encryptionConfig);
    logger_1.logger.info(clc.bold(`Successfully initiated restore of ${printer.prettyDatabaseString(databaseResp)}`));
    logger_1.logger.info("Please be sure to configure Firebase rules in your Firebase config file for\n" +
        "the new database. By default, created databases will have closed rules that\n" +
        "block any incoming third-party traffic.");
    logger_1.logger.info(`Once the restore is complete, your database may be viewed at ${printer.firebaseConsoleDatabaseUrl(options.project, databaseId)}`);
    return databaseResp;
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
