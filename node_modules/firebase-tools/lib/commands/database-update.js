"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const url_1 = require("url");
const clc = require("colorette");
const fs = require("fs");
const apiv2_1 = require("../apiv2");
const command_1 = require("../command");
const types_1 = require("../emulator/types");
const error_1 = require("../error");
const database_1 = require("../management/database");
const commandUtils_1 = require("../emulator/commandUtils");
const prompt_1 = require("../prompt");
const api_1 = require("../database/api");
const requirePermissions_1 = require("../requirePermissions");
const logger_1 = require("../logger");
const requireDatabaseInstance_1 = require("../requireDatabaseInstance");
const utils = require("../utils");
exports.command = new command_1.Command("database:update <path> [infile]")
    .description("update some of the keys for the defined path in your Realtime Database")
    .option("-d, --data <data>", "specify escaped JSON directly")
    .option("-f, --force", "pass this option to bypass confirmation prompt")
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
    const origin = (0, api_1.realtimeOriginOrEmulatorOrCustomUrl)(options.instanceDetails.databaseUrl);
    const url = utils.getDatabaseUrl(origin, options.instance, path);
    const confirmed = await (0, prompt_1.confirm)({
        message: `You are about to modify data at ${clc.cyan(url)}. Are you sure?`,
        default: false,
        force: options.force,
        nonInteractive: options.nonInteractive,
    });
    if (!confirmed) {
        throw new error_1.FirebaseError("Command aborted.");
    }
    const inStream = utils.stringToStream(options.data) ||
        (infile && fs.createReadStream(infile)) ||
        process.stdin;
    const jsonUrl = new url_1.URL(utils.getDatabaseUrl(origin, options.instance, path + ".json"));
    if (options.disableTriggers) {
        jsonUrl.searchParams.set("disableTriggers", "true");
    }
    if (!infile && !options.data) {
        utils.explainStdin();
    }
    const c = new apiv2_1.Client({ urlPrefix: jsonUrl.origin, auth: true });
    try {
        await c.request({
            method: "PATCH",
            path: jsonUrl.pathname,
            body: inStream,
            queryParams: jsonUrl.searchParams,
        });
    }
    catch (err) {
        throw new error_1.FirebaseError("Unexpected error while setting data");
    }
    utils.logSuccess("Data updated successfully");
    logger_1.logger.info();
    logger_1.logger.info(clc.bold("View data at:"), utils.getDatabaseViewDataUrl(origin, options.project, options.instance, path));
});
