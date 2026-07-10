"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const commandUtils_1 = require("../emulator/commandUtils");
const types_1 = require("../emulator/types");
const database_1 = require("../management/database");
const projectUtils_1 = require("../projectUtils");
const getDefaultDatabaseInstance_1 = require("../getDefaultDatabaseInstance");
const error_1 = require("../error");
const requireDatabaseInstance_1 = require("../requireDatabaseInstance");
exports.command = new command_1.Command("database:instances:create <instanceName>")
    .description("create a Realtime Database instance")
    .option("-l, --location <location>", "(optional) location for the database instance, defaults to us-central1")
    .before(requirePermissions_1.requirePermissions, ["firebasedatabase.instances.create"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.DATABASE)
    .action(async (instanceName, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const defaultDatabaseInstance = await (0, getDefaultDatabaseInstance_1.getDefaultDatabaseInstance)(projectId);
    if (defaultDatabaseInstance === "") {
        throw new error_1.FirebaseError(requireDatabaseInstance_1.MISSING_DEFAULT_INSTANCE_ERROR_MESSAGE);
    }
    const location = (0, database_1.parseDatabaseLocation)(options.location, database_1.DatabaseLocation.US_CENTRAL1);
    const instance = await (0, database_1.createInstance)(projectId, instanceName, location, database_1.DatabaseInstanceType.USER_DATABASE);
    logger_1.logger.info(`created database instance ${instance.name}`);
    return instance;
});
