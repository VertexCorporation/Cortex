"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const logger_1 = require("../logger");
const requireConfig_1 = require("../requireConfig");
const utils = require("../utils");
function logTargets(type, targets) {
    logger_1.logger.info(clc.cyan("[ " + type + " ]"));
    for (const [name, resources] of Object.entries(targets)) {
        logger_1.logger.info(name, "(" + (resources || []).join(",") + ")");
    }
}
exports.command = new command_1.Command("target [type]")
    .description("display configured deploy targets for the current project")
    .before(requireConfig_1.requireConfig)
    .action((type, options) => {
    if (!options.project) {
        return utils.reject("No active project, cannot list deploy targets.");
    }
    logger_1.logger.info("Resource targets for", clc.bold(options.project) + ":");
    logger_1.logger.info();
    if (type) {
        const targets = options.rc.targets(options.project, type);
        logTargets(type, targets);
        return targets;
    }
    const allTargets = options.rc.allTargets(options.project);
    for (const [targetType, targetName] of Object.entries(allTargets)) {
        logTargets(targetType, targetName);
    }
    return allTargets;
});
