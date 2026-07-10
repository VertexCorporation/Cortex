"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const fs = require("fs");
const apiv2_1 = require("../apiv2");
const command_1 = require("../command");
const types_1 = require("../emulator/types");
const error_1 = require("../error");
const database_1 = require("../management/database");
const commandUtils_1 = require("../emulator/commandUtils");
const api_1 = require("../database/api");
const requirePermissions_1 = require("../requirePermissions");
const url_1 = require("url");
const logger_1 = require("../logger");
const requireDatabaseInstance_1 = require("../requireDatabaseInstance");
const utils = require("../utils");
exports.command = new command_1.Command("database:push <path> [infile]")
    .description("add a new JSON object to a list of data in your Firebase")
    .option("-d, --data <data>", "specify escaped JSON directly")
    .option("--instance <instance>", "use the database <instance>.firebaseio.com (if omitted, use default database instance)")
    .option("--disable-triggers", "suppress any Cloud functions triggered by this operation")
    .before(requirePermissions_1.requirePermissions, ["firebasedatabase.instances.update"])
    .before(requireDatabaseInstance_1.requireDatabaseInstance)
    .before(database_1.populateInstanceDetails)
    .before(commandUtils_1.printNoticeIfEmulated, types_1.Emulators.DATABASE)
    .action(async (path, infile, options) => {
    if (!path.startsWith("/")) {
        throw new error_1.FirebaseError("Path must begin with /");
    }
    const inStream = utils.stringToStream(options.data) || (infile ? fs.createReadStream(infile) : process.stdin);
    const origin = (0, api_1.realtimeOriginOrEmulatorOrCustomUrl)(options.instanceDetails.databaseUrl);
    const u = new url_1.URL(utils.getDatabaseUrl(origin, options.instance, path + ".json"));
    if (options.disableTriggers) {
        u.searchParams.set("disableTriggers", "true");
    }
    if (!infile && !options.data) {
        utils.explainStdin();
    }
    logger_1.logger.debug(`Database URL: ${u}`);
    const c = new apiv2_1.Client({ urlPrefix: u.origin, auth: true });
    let res;
    try {
        res = await c.request({
            method: "POST",
            path: u.pathname,
            body: inStream,
            queryParams: u.searchParams,
        });
    }
    catch (err) {
        logger_1.logger.debug((0, error_1.getErrMsg)(err));
        throw new error_1.FirebaseError(`Unexpected error while pushing data: ${(0, error_1.getErrMsg)(err)}`, {
            exit: 2,
        });
    }
    if (!path.endsWith("/")) {
        path += "/";
    }
    const consoleUrl = utils.getDatabaseViewDataUrl(origin, options.project, options.instance, path + res.body.name);
    utils.logSuccess("Data pushed successfully");
    logger_1.logger.info();
    logger_1.logger.info(clc.bold("View data at:"), consoleUrl);
    return { key: res.body.name };
});
