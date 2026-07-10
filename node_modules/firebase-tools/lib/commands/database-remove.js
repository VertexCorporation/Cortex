"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const requireDatabaseInstance_1 = require("../requireDatabaseInstance");
const requirePermissions_1 = require("../requirePermissions");
const remove_1 = require("../database/remove");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const database_1 = require("../management/database");
const api_1 = require("../database/api");
const utils = require("../utils");
const prompt_1 = require("../prompt");
const clc = require("colorette");
exports.command = new command_1.Command("database:remove <path>")
    .description("remove data from your Firebase at the specified path")
    .option("-f, --force", "pass this option to bypass confirmation prompt")
    .option("--instance <instance>", "use the database <instance>.firebaseio.com (if omitted, use default database instance)")
    .option("--disable-triggers", "suppress any Cloud functions triggered by this operation")
    .before(requirePermissions_1.requirePermissions, ["firebasedatabase.instances.update"])
    .before(requireDatabaseInstance_1.requireDatabaseInstance)
    .before(database_1.populateInstanceDetails)
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.DATABASE)
    .action(async (path, options) => {
    if (!path.startsWith("/")) {
        return utils.reject("Path must begin with /", { exit: 1 });
    }
    const origin = (0, api_1.realtimeOriginOrEmulatorOrCustomUrl)(options.instanceDetails.databaseUrl);
    const databaseUrl = utils.getDatabaseUrl(origin, options.instance, path);
    const areYouSure = await (0, prompt_1.confirm)({
        message: "You are about to remove all data at " + clc.cyan(databaseUrl) + ". Are you sure?",
        force: options.force,
    });
    if (!areYouSure) {
        return utils.reject("Command aborted.", { exit: 1 });
    }
    const removeOps = new remove_1.default(options.instance, path, origin, !!options.disableTriggers);
    await removeOps.execute();
    utils.logSuccess("Data removed successfully");
});
