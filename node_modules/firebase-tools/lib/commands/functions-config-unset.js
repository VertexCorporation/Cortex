"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const projectUtils_1 = require("../projectUtils");
const functionsConfig = require("../functionsConfig");
const runtimeconfig = require("../gcp/runtimeconfig");
const utils = require("../utils");
const error_1 = require("../error");
exports.command = new command_1.Command("functions:config:unset [keys...]")
    .description("unset environment config at the specified path(s)")
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
        throw new error_1.FirebaseError("Must supply at least one key");
    }
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const parsed = functionsConfig.parseUnsetArgs(args);
    await Promise.all(parsed.map((item) => {
        if (item.varId === "") {
            return runtimeconfig.configs.delete(projectId, item.configId);
        }
        return runtimeconfig.variables.delete(projectId, item.configId, item.varId);
    }));
    utils.logSuccess("Environment updated.");
    logger_1.logger.info(`\nPlease deploy your functions for the change to take effect by running ${clc.bold("firebase deploy --only functions")}\n`);
    functionsConfig.logFunctionsConfigDeprecationWarning();
});
