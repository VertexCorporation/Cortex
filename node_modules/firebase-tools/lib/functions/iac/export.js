"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getInternalIac = getInternalIac;
const runtimes = require("../../deploy/functions/runtimes");
const supported = require("../../deploy/functions/runtimes/supported");
const functionsConfig = require("../../functionsConfig");
const functionsEnv = require("../../functions/env");
const logger_1 = require("../../logger");
const yaml = require("js-yaml");
const projectUtils_1 = require("../../projectUtils");
const error_1 = require("../../error");
async function getInternalIac(options, codebase) {
    if (!codebase.source) {
        throw new error_1.FirebaseError("Cannot export a codebase with no source");
    }
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const firebaseConfig = await functionsConfig.getFirebaseConfig(options);
    const firebaseEnvs = functionsEnv.loadFirebaseEnvs(firebaseConfig, projectId);
    const delegateContext = {
        projectId,
        sourceDir: options.config.path(codebase.source),
        projectDir: options.config.projectDir,
        runtime: codebase.runtime,
    };
    const runtimeDelegate = await runtimes.getRuntimeDelegate(delegateContext);
    logger_1.logger.debug(`Validating ${runtimeDelegate.language} source`);
    supported.guardVersionSupport(runtimeDelegate.runtime);
    await runtimeDelegate.validate();
    logger_1.logger.debug(`Building ${runtimeDelegate.language} source`);
    await runtimeDelegate.build();
    logger_1.logger.debug(`Discovering ${runtimeDelegate.language} source`);
    const build = await runtimeDelegate.discoverBuild({}, firebaseEnvs);
    return {
        "functions.yaml": yaml.dump(build),
    };
}
