"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getExtensionFunctionInfo = getExtensionFunctionInfo;
exports.getNonSecretEnv = getNonSecretEnv;
exports.getSecretEnvVars = getSecretEnvVars;
exports.getParams = getParams;
const paramHelper = require("../paramHelper");
const specHelper = require("./specHelper");
const triggerHelper = require("./triggerHelper");
const types_1 = require("../types");
const extensionsHelper = require("../extensionsHelper");
const planner = require("../../deploy/extensions/planner");
const projectUtils_1 = require("../../projectUtils");
async function getExtensionFunctionInfo(instance, paramValues) {
    const spec = await planner.getExtensionSpec(instance);
    const functionResources = specHelper.getFunctionResourcesWithParamSubstitution(spec, paramValues);
    const extensionTriggers = functionResources
        .map((r) => triggerHelper.functionResourceToEmulatedTriggerDefintion(r, instance.systemParams))
        .map((trigger) => {
        trigger.name = `ext-${instance.instanceId}-${trigger.name}`;
        return trigger;
    });
    const runtime = specHelper.getRuntime(functionResources);
    const nonSecretEnv = getNonSecretEnv(spec.params ?? [], paramValues);
    const secretEnvVariables = getSecretEnvVars(spec.params ?? [], paramValues);
    return {
        extensionTriggers,
        runtime,
        nonSecretEnv,
        secretEnvVariables,
    };
}
const isSecretParam = (p) => p.type === extensionsHelper.SpecParamType.SECRET || p.type === types_1.ParamType.SECRET;
function getNonSecretEnv(params, paramValues) {
    const getNonSecretEnv = Object.assign({}, paramValues);
    const secretParams = params.filter(isSecretParam);
    for (const p of secretParams) {
        delete getNonSecretEnv[p.param];
    }
    return getNonSecretEnv;
}
function getSecretEnvVars(params, paramValues) {
    const secretEnvVar = [];
    const secretParams = params.filter(isSecretParam);
    for (const s of secretParams) {
        if (paramValues[s.param]) {
            const [, projectId, , secret, , version] = paramValues[s.param].split("/");
            secretEnvVar.push({
                key: s.param,
                secret,
                projectId,
                version,
            });
        }
    }
    return secretEnvVar;
}
function getParams(options, extensionSpec) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const userParams = paramHelper.readEnvFile(options.testParams);
    const autoParams = {
        PROJECT_ID: projectId,
        EXT_INSTANCE_ID: extensionSpec.name,
        DATABASE_INSTANCE: projectId,
        DATABASE_URL: `https://${projectId}.firebaseio.com`,
        STORAGE_BUCKET: `${projectId}.appspot.com`,
    };
    const unsubbedParamsWithoutDefaults = Object.assign(autoParams, userParams);
    const unsubbedParams = extensionsHelper.populateDefaultParams(unsubbedParamsWithoutDefaults, extensionSpec.params);
    return extensionsHelper.substituteParams(unsubbedParams, unsubbedParams);
}
