"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const lodash_1 = require("lodash");
const path_1 = require("path");
const command_1 = require("../command");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const requirePermissions_1 = require("../requirePermissions");
const functionsConfig = require("../functionsConfig");
async function materialize(projectId, path) {
    if (path === undefined) {
        return functionsConfig.materializeAll(projectId);
    }
    const parts = path.split(".");
    const configId = parts[0];
    const configName = (0, path_1.join)("projects", projectId, "configs", configId);
    const result = await functionsConfig.materializeConfig(configName, {});
    const query = parts.join(".");
    return query ? (0, lodash_1.get)(result, query) : result;
}
exports.command = new command_1.Command("functions:config:get [path]")
    .description("fetch environment config stored at the given path")
    .before(requirePermissions_1.requirePermissions, [
    "runtimeconfig.configs.list",
    "runtimeconfig.configs.get",
    "runtimeconfig.variables.list",
    "runtimeconfig.variables.get",
])
    .before(functionsConfig.ensureApi)
    .action(async (path, options) => {
    const result = await materialize((0, projectUtils_1.needProjectId)(options), path);
    logger_1.logger.info(JSON.stringify(result, null, 2));
    functionsConfig.logFunctionsConfigDeprecationWarning();
    return result;
});
