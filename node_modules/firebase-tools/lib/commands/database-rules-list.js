"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const logger_1 = require("../logger");
const requireDatabaseInstance_1 = require("../requireDatabaseInstance");
const requirePermissions_1 = require("../requirePermissions");
const metadata = require("../database/metadata");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
exports.command = new command_1.Command("database:rules:list")
    .description("list realtime database rulesets")
    .option("--instance <instance>", "use the database <instance>.firebaseio.com (if omitted, uses default database instance)")
    .before(requirePermissions_1.requirePermissions, ["firebasedatabase.instances.get"])
    .before(requireDatabaseInstance_1.requireDatabaseInstance)
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.DATABASE)
    .action(async (options) => {
    const labeled = await metadata.getRulesetLabels(options.instance);
    const rulesets = await metadata.listAllRulesets(options.instance);
    for (const ruleset of rulesets) {
        const labels = [];
        if (ruleset.id === labeled.stable) {
            labels.push("stable");
        }
        if (ruleset.id === labeled.canary) {
            labels.push("canary");
        }
        logger_1.logger.info(`${ruleset.id}  ${ruleset.createdAt}  ${labels.join(",")}`);
    }
    logger_1.logger.info("Labels:");
    logger_1.logger.info(`  stable: ${labeled.stable}`);
    if (labeled.canary) {
        logger_1.logger.info(`  canary: ${labeled.canary}`);
    }
    return { rulesets, labeled };
});
