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
const functionsConfigClone_1 = require("../functionsConfigClone");
const utils = require("../utils");
exports.command = new command_1.Command("functions:config:clone")
    .description("clone environment config from another project")
    .option("--from <projectId>", "the project from which to clone configuration")
    .option("--only <keys>", "a comma-separated list of keys to clone")
    .option("--except <keys>", "a comma-separated list of keys to not clone")
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
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    if (!options.from) {
        throw new error_1.FirebaseError(`Must specify a source project in ${clc.bold("--from <projectId>")} option.`);
    }
    else if (options.from === projectId) {
        throw new error_1.FirebaseError("From project and destination can't be the same project.");
    }
    else if (options.only && options.except) {
        throw new error_1.FirebaseError("Cannot use both --only and --except at the same time.");
    }
    let only;
    let except = [];
    if (options.only) {
        only = options.only.split(",");
    }
    else if (options.except) {
        except = options.except.split(",");
    }
    await (0, functionsConfigClone_1.functionsConfigClone)(options.from, projectId, only, except);
    utils.logSuccess(`Cloned functions config from ${clc.bold(options.from)} into ${clc.bold(projectId)}`);
    logger_1.logger.info(`\nPlease deploy your functions for the change to take effect by running ${clc.bold("firebase deploy --only functions")}\n`);
    functionsConfig.logFunctionsConfigDeprecationWarning();
});
