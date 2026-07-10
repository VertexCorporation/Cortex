"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const url_1 = require("url");
const apiv2_1 = require("../apiv2");
const command_1 = require("../command");
const settings_1 = require("../database/settings");
const types_1 = require("../emulator/types");
const error_1 = require("../error");
const database_1 = require("../management/database");
const api_1 = require("../database/api");
const requirePermissions_1 = require("../requirePermissions");
const commandUtils_1 = require("../emulator/commandUtils");
const requireDatabaseInstance_1 = require("../requireDatabaseInstance");
const utils = require("../utils");
exports.command = new command_1.Command("database:settings:set <path> <value>")
    .description("set the Realtime Database setting at path")
    .option("--instance <instance>", "use the database <instance>.firebaseio.com (if omitted, use default database instance)")
    .help(settings_1.HELP_TEXT)
    .before(requirePermissions_1.requirePermissions, ["firebasedatabase.instances.update"])
    .before(requireDatabaseInstance_1.requireDatabaseInstance)
    .before(database_1.populateInstanceDetails)
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.DATABASE)
    .action(async (path, value, options) => {
    const setting = settings_1.DATABASE_SETTINGS.get(path);
    if (setting === undefined) {
        return utils.reject(settings_1.INVALID_PATH_ERROR, { exit: 1 });
    }
    const parsedValue = setting.parseInput(value);
    if (parsedValue === undefined) {
        return utils.reject(setting.parseInputErrorMessge, { exit: 1 });
    }
    const u = new url_1.URL(utils.getDatabaseUrl((0, api_1.realtimeOriginOrCustomUrl)(options.instanceDetails.databaseUrl), options.instance, `/.settings/${path}.json`));
    const c = new apiv2_1.Client({ urlPrefix: u.origin, auth: true });
    try {
        await c.put(u.pathname, JSON.stringify(parsedValue));
    }
    catch (err) {
        throw new error_1.FirebaseError(`Unexpected error fetching configs at ${path}`, {
            exit: 2,
            original: (0, error_1.getError)(err),
        });
    }
    utils.logSuccess("Successfully set setting.");
    utils.logSuccess(`For database instance ${options.instance}\n\t ${path} = ${JSON.stringify(parsedValue)}`);
});
