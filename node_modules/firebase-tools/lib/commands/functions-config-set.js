"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const error_1 = require("../error");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const requirePermissions_1 = require("../requirePermissions");
const functionsConfig = require("../functionsConfig");
const utils = require("../utils");
exports.command = new command_1.Command("functions:config:set [values...]")
    .description("set environment config with key=value syntax")
    .before(functionsConfig.ensureLegacyRuntimeConfigCommandsEnabled)
    .before(requirePermissions_1.requirePermissions, [
    "runtimeconfig.configs.list",
    "runtimeconfig.configs.create",
    "runtimeconfig.configs.get",
    "runtimeconfig.configs.update",
    "runtimeconfig.configs.delete",
    "runtimeconfig.variables.list",
    "runtimeconfig.variables.create",
    "runtimeconfig.variables.get",
    "runtimeconfig.variables.update",
    "runtimeconfig.variables.delete",
])
    .before(functionsConfig.ensureApi)
    .action(async (args, options) => {
    if (!args.length) {
        throw new error_1.FirebaseError(`Must supply at least one key/value pair, e.g. ${clc.bold('app.name="My App"')}`);
    }
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const parsed = functionsConfig.parseSetArgs(args);
    const promises = [];
    for (const item of parsed) {
        if (item.val === undefined) {
            throw new error_1.FirebaseError(`Unexpected undefined value for varId "${item.varId}`, { exit: 2 });
        }
        promises.push(functionsConfig.setVariablesRecursive(projectId, item.configId, item.varId, item.val));
    }
    await Promise.all(promises);
    utils.logSuccess("Functions config updated.");
    logger_1.logger.info(`\nPlease deploy your functions for the change to take effect by running ${clc.bold("firebase deploy --only functions")}\n`);
    functionsConfig.logFunctionsConfigDeprecationWarning();
});
