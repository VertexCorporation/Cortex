"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const logger_1 = require("../logger");
const prepare_1 = require("../deploy/functions/prepare");
const projectConfig_1 = require("../functions/projectConfig");
const adminSdkConfig_1 = require("../emulator/adminSdkConfig");
const projectUtils_1 = require("../projectUtils");
const error_1 = require("../error");
const ensureApiEnabled = require("../ensureApiEnabled");
const api_1 = require("../api");
const prepareFunctionsUpload_1 = require("../deploy/functions/prepareFunctionsUpload");
exports.command = new command_1.Command("internaltesting:functions:discover")
    .description("discover function triggers defined in the current project directory")
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const fnConfig = (0, projectConfig_1.normalizeAndValidate)(options.config.src.functions);
    const firebaseConfig = await (0, adminSdkConfig_1.getProjectAdminSdkConfigOrCached)(projectId);
    if (!firebaseConfig) {
        throw new error_1.FirebaseError("Admin SDK config unexpectedly undefined - have you run firebase init?");
    }
    let runtimeConfig = { firebase: firebaseConfig };
    if (fnConfig.some(projectConfig_1.shouldUseRuntimeConfig)) {
        try {
            const runtimeConfigApiEnabled = await ensureApiEnabled.check(projectId, (0, api_1.runtimeconfigOrigin)(), "runtimeconfig", true);
            if (runtimeConfigApiEnabled) {
                runtimeConfig = { ...runtimeConfig, ...(await (0, prepareFunctionsUpload_1.getFunctionsConfig)(projectId)) };
            }
        }
        catch (err) {
            logger_1.logger.debug("Could not check Runtime Config API status, assuming disabled:", err);
        }
    }
    const wantBuilds = await (0, prepare_1.loadCodebases)(fnConfig, options, firebaseConfig, runtimeConfig, undefined);
    logger_1.logger.info(JSON.stringify(wantBuilds, null, 2));
    return wantBuilds;
});
