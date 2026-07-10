"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const fs = require("fs");
const utils = require("../utils");
const command_1 = require("../command");
const import_1 = require("../database/import");
const types_1 = require("../emulator/types");
const error_1 = require("../error");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const commandUtils_1 = require("../emulator/commandUtils");
const prompt_1 = require("../prompt");
const database_1 = require("../management/database");
const api_1 = require("../database/api");
const requireDatabaseInstance_1 = require("../requireDatabaseInstance");
const requirePermissions_1 = require("../requirePermissions");
const MAX_CHUNK_SIZE_MB = 1;
const MAX_PAYLOAD_SIZE_MB = 256;
const CONCURRENCY_LIMIT = 5;
exports.command = new command_1.Command("database:import <path> [infile]")
    .description("non-atomically import the contents of a JSON file to the specified path in Realtime Database")
    .withForce()
    .option("--instance <instance>", "use the database <instance>.firebaseio.com (if omitted, use default database instance)")
    .option("--disable-triggers", "suppress any Cloud functions triggered by this operation, default to true", true)
    .option("--filter <dataPath>", "import only data at this path in the JSON file (if omitted, import entire file)")
    .option("--chunk-size <mb>", "max chunk size in megabytes, default to 1 MB")
    .option("--concurrency <val>", "concurrency limit, default to 5")
    .before(requirePermissions_1.requirePermissions, ["firebasedatabase.instances.update"])
    .before(requireDatabaseInstance_1.requireDatabaseInstance)
    .before(database_1.populateInstanceDetails)
    .before(commandUtils_1.printNoticeIfEmulated, types_1.Emulators.DATABASE)
    .action(async (path, infile, options) => {
    if (!path.startsWith("/")) {
        throw new error_1.FirebaseError("Path must begin with /");
    }
    if (!infile) {
        throw new error_1.FirebaseError("No file supplied");
    }
    const chunkMegabytes = options.chunkSize ? parseInt(options.chunkSize, 10) : MAX_CHUNK_SIZE_MB;
    if (chunkMegabytes > MAX_PAYLOAD_SIZE_MB) {
        throw new error_1.FirebaseError("Max chunk size cannot exceed 256 MB");
    }
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const origin = (0, api_1.realtimeOriginOrEmulatorOrCustomUrl)(options.instanceDetails.databaseUrl);
    const dbPath = utils.getDatabaseUrl(origin, options.instance, path);
    const dbUrl = new URL(dbPath);
    if (options.disableTriggers) {
        dbUrl.searchParams.set("disableTriggers", "true");
    }
    const areYouSure = await (0, prompt_1.confirm)({
        message: "You are about to import data to " + clc.cyan(dbPath) + ". Are you sure?",
        force: options.force,
    });
    if (!areYouSure) {
        throw new error_1.FirebaseError("Command aborted.");
    }
    const inStream = fs.createReadStream(infile);
    const dataPath = options.filter || "";
    const chunkBytes = chunkMegabytes * 1024 * 1024;
    const concurrency = options.concurrency ? parseInt(options.concurrency, 10) : CONCURRENCY_LIMIT;
    const importer = new import_1.default(dbUrl, inStream, dataPath, chunkBytes, concurrency);
    let responses;
    try {
        responses = await importer.execute();
    }
    catch (err) {
        if (err instanceof error_1.FirebaseError) {
            throw err;
        }
        logger_1.logger.debug((0, error_1.getErrMsg)(err));
        throw new error_1.FirebaseError(`Unexpected error while importing data: ${(0, error_1.getErrMsg)(err)}`, {
            exit: 2,
        });
    }
    if (responses.length) {
        utils.logSuccess("Data persisted successfully");
    }
    else {
        utils.logWarning("No data was persisted. Check the data path supplied.");
    }
    logger_1.logger.info();
    logger_1.logger.info(clc.bold("View data at:"), utils.getDatabaseViewDataUrl(origin, projectId, options.instance, path));
});
