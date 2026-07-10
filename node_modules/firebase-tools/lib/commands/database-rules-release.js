"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const requireDatabaseInstance_1 = require("../requireDatabaseInstance");
const requirePermissions_1 = require("../requirePermissions");
const metadata = require("../database/metadata");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
exports.command = new command_1.Command("database:rules:release <rulesetId>")
    .description("mark a staged ruleset as the stable ruleset")
    .option("--instance <instance>", "use the database <instance>.firebaseio.com (if omitted, uses default database instance)")
    .before(requirePermissions_1.requirePermissions, ["firebasedatabase.instances.update"])
    .before(requireDatabaseInstance_1.requireDatabaseInstance)
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.DATABASE)
    .action(async (rulesetId, options) => {
    const oldLabels = await metadata.getRulesetLabels(options.instance);
    const newLabels = {
        stable: rulesetId,
        canary: oldLabels.canary,
    };
    await metadata.setRulesetLabels(options.instance, newLabels);
    return newLabels;
});
