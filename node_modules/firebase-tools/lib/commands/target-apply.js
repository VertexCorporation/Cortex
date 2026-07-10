"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const logger_1 = require("../logger");
const requireConfig_1 = require("../requireConfig");
const utils = require("../utils");
const error_1 = require("../error");
exports.command = new command_1.Command("target:apply <type> <name> <resources...>")
    .description("apply a deploy target to a resource")
    .before(requireConfig_1.requireConfig)
    .action((type, name, resources, options) => {
    if (!options.project) {
        throw new error_1.FirebaseError(`Must have an active project to set deploy targets. Try ${clc.bold("firebase use --add")}`);
    }
    const changes = options.rc.applyTarget(options.project, type, name, resources);
    utils.logSuccess(`Applied ${type} target ${clc.bold(name)} to ${clc.bold(resources.join(", "))}`);
    for (const change of changes) {
        utils.logWarning(`Previous target ${clc.bold(change.target)} removed from ${clc.bold(change.resource)}`);
    }
    logger_1.logger.info();
    logger_1.logger.info(`Updated: ${name} (${options.rc.target(options.project, type, name).join(",")})`);
});
