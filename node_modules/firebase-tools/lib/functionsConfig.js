"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RESERVED_NAMESPACES = void 0;
exports.getFunctionsConfigDeprecationMessage = getFunctionsConfigDeprecationMessage;
exports.logFunctionsConfigDeprecationWarning = logFunctionsConfigDeprecationWarning;
exports.ensureLegacyRuntimeConfigCommandsEnabled = ensureLegacyRuntimeConfigCommandsEnabled;
exports.ensureApi = ensureApi;
exports.varNameToIds = varNameToIds;
exports.idsToVarName = idsToVarName;
exports.getAppEngineLocation = getAppEngineLocation;
exports.getFirebaseConfig = getFirebaseConfig;
exports.setVariablesRecursive = setVariablesRecursive;
exports.materializeConfig = materializeConfig;
exports.materializeAll = materializeAll;
exports.parseSetArgs = parseSetArgs;
exports.parseUnsetArgs = parseUnsetArgs;
const _ = require("lodash");
const clc = require("colorette");
const api_1 = require("./api");
const apiv2_1 = require("./apiv2");
const ensureApiEnabled_1 = require("./ensureApiEnabled");
const error_1 = require("./error");
const projectUtils_1 = require("./projectUtils");
const runtimeconfig = require("./gcp/runtimeconfig");
const experiments = require("./experiments");
const utils_1 = require("./utils");
exports.RESERVED_NAMESPACES = ["firebase"];
const apiClient = new apiv2_1.Client({ urlPrefix: (0, api_1.firebaseApiOrigin)() });
const LEGACY_RUNTIME_CONFIG_EXPERIMENT = "legacyRuntimeConfigCommands";
const FUNCTIONS_CONFIG_DEPRECATION_MESSAGE = `DEPRECATION NOTICE: Action required before March 2027

The functions.config() API and the Cloud Runtime Config service are deprecated. Deploys that rely on functions.config() will fail once Runtime Config shuts down in March 2027.

The legacy functions:config:* CLI commands are deprecated and will be removed before March 2027.

Learn how to migrate from functions.config() to the params package:

https://firebase.google.com/docs/functions/config-env#migrate-config

To convert existing functions.config() values to params, try the interactive migration command:

  firebase functions:config:export
`;
const LEGACY_GUIDANCE_MESSAGE = `${FUNCTIONS_CONFIG_DEPRECATION_MESSAGE}

To run this legacy command temporarily, run the following command and try again:

  firebase experiments:enable ${LEGACY_RUNTIME_CONFIG_EXPERIMENT}
`;
function getFunctionsConfigDeprecationMessage() {
    return FUNCTIONS_CONFIG_DEPRECATION_MESSAGE;
}
function logFunctionsConfigDeprecationWarning() {
    (0, utils_1.logWarningToStderr)(FUNCTIONS_CONFIG_DEPRECATION_MESSAGE);
}
function ensureLegacyRuntimeConfigCommandsEnabled() {
    if (experiments.isEnabled(LEGACY_RUNTIME_CONFIG_EXPERIMENT)) {
        return;
    }
    throw new error_1.FirebaseError(LEGACY_GUIDANCE_MESSAGE, { exit: 1 });
}
function keyToIds(key) {
    const keyParts = key.split(".");
    const variable = keyParts.slice(1).join("/");
    return {
        config: keyParts[0],
        variable: variable,
    };
}
function setVariable(projectId, configId, varPath, val) {
    if (configId === "" || varPath === "") {
        const msg = "Invalid argument, each config value must have a 2-part key (e.g. foo.bar).";
        throw new error_1.FirebaseError(msg);
    }
    return runtimeconfig.variables.set(projectId, configId, varPath, val);
}
function isReservedNamespace(id) {
    return exports.RESERVED_NAMESPACES.some((reserved) => {
        return id.config.toLowerCase().startsWith(reserved);
    });
}
async function ensureApi(options) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    return (0, ensureApiEnabled_1.ensure)(projectId, "runtimeconfig.googleapis.com", "runtimeconfig", true);
}
function varNameToIds(varName) {
    return {
        config: varName.match(new RegExp("/configs/(.+)/variables/"))[1],
        variable: varName.match(new RegExp("/variables/(.+)"))[1],
    };
}
function idsToVarName(projectId, configId, varId) {
    return ["projects", projectId, "configs", configId, "variables", varId].join("/");
}
function getAppEngineLocation(config) {
    let appEngineLocation = config.locationId;
    if (appEngineLocation && appEngineLocation.match(/[^\d]$/)) {
        appEngineLocation = appEngineLocation + "1";
    }
    return appEngineLocation || "us-central1";
}
async function getFirebaseConfig(options) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const response = await apiClient.get(`/v1beta1/projects/${projectId}/adminSdkConfig`);
    return response.body;
}
async function setVariablesRecursive(projectId, configId, varPath, val) {
    let parsed = val;
    if (typeof val === "string") {
        try {
            parsed = JSON.parse(val);
        }
        catch (e) {
        }
    }
    if (typeof parsed === "object" && parsed !== null) {
        return Promise.all(Object.entries(parsed).map(([key, item]) => {
            const newVarPath = varPath ? [varPath, key].join("/") : key;
            return setVariablesRecursive(projectId, configId, newVarPath, item);
        }));
    }
    return setVariable(projectId, configId, varPath, val);
}
async function materializeConfig(configName, output) {
    const materializeVariable = async function (varName) {
        const variable = await runtimeconfig.variables.get(varName);
        const id = varNameToIds(variable.name);
        const key = id.config + "." + id.variable.split("/").join(".");
        _.set(output, key, variable.text);
    };
    const traverseVariables = async function (variables) {
        return Promise.all(variables.map((variable) => {
            return materializeVariable(variable.name);
        }));
    };
    const variables = await runtimeconfig.variables.list(configName);
    await traverseVariables(variables);
    return output;
}
async function materializeAll(projectId) {
    const output = {};
    const configs = await runtimeconfig.configs.list(projectId);
    if (!Array.isArray(configs) || !configs.length) {
        return output;
    }
    await Promise.all(configs.map((config) => {
        if (config.name.match(new RegExp("configs/firebase"))) {
            return;
        }
        return materializeConfig(config.name, output);
    }));
    return output;
}
function parseSetArgs(args) {
    const parsed = [];
    for (const arg of args) {
        const parts = arg.split("=");
        const key = parts[0];
        if (parts.length < 2) {
            throw new error_1.FirebaseError("Invalid argument " + clc.bold(arg) + ", must be in key=val format");
        }
        if (/[A-Z]/.test(key)) {
            throw new error_1.FirebaseError("Invalid config name " + clc.bold(key) + ", cannot use upper case.");
        }
        const id = keyToIds(key);
        if (isReservedNamespace(id)) {
            throw new error_1.FirebaseError("Cannot set to reserved namespace " + clc.bold(id.config));
        }
        const val = parts.slice(1).join("=");
        parsed.push({
            configId: id.config,
            varId: id.variable,
            val: val,
        });
    }
    return parsed;
}
function parseUnsetArgs(args) {
    const parsed = [];
    let splitArgs = [];
    for (const arg of args) {
        splitArgs = Array.from(new Set([...splitArgs, ...arg.split(",")]));
    }
    for (const key of splitArgs) {
        const id = keyToIds(key);
        if (isReservedNamespace(id)) {
            throw new error_1.FirebaseError("Cannot unset reserved namespace " + clc.bold(id.config));
        }
        parsed.push({
            configId: id.config,
            varId: id.variable,
        });
    }
    return parsed;
}
