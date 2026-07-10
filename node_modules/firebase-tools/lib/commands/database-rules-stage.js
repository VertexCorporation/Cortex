"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const logger_1 = require("../logger");
const requireDatabaseInstance_1 = require("../requireDatabaseInstance");
const requirePermissions_1 = require("../requirePermissions");
const metadata = require("../database/metadata");
const fs = require("fs-extra");
const path = require("path");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
exports.command = new command_1.Command("database:rules:stage")
    .description("create a new realtime database ruleset")
    .option("--instance <instance>", "use the database <instance>.firebaseio.com (if omitted, uses default database instance)")
    .before(requirePermissions_1.requirePermissions, ["firebasedatabase.instances.update"])
    .before(requireDatabaseInstance_1.requireDatabaseInstance)
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.DATABASE)
    .action(async (options) => {
    const filepath = options.config.data.database.rules;
    logger_1.logger.info(`staging ruleset from ${filepath}`);
    const source = fs.readFileSync(path.resolve(filepath), "utf8");
    const rulesetId = await metadata.createRuleset(options.instance, source);
    logger_1.logger.info(`staged ruleset ${rulesetId}`);
    return rulesetId;
});
