"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.functionsConfigClone = functionsConfigClone;
const _ = require("lodash");
const clc = require("colorette");
const error_1 = require("./error");
const functionsConfig = require("./functionsConfig");
const runtimeconfig = require("./gcp/runtimeconfig");
function matchPrefix(short, long) {
    if (short.length > long.length) {
        return false;
    }
    return short.reduce((accum, x, i) => accum && x === long[i], true);
}
function applyExcept(json, except) {
    for (const key of except) {
        _.unset(json, key);
    }
}
function cloneVariable(varName, toProject) {
    return runtimeconfig.variables.get(varName).then((variable) => {
        const id = functionsConfig.varNameToIds(variable.name);
        return runtimeconfig.variables.set(toProject, id.config, id.variable, variable.text);
    });
}
function cloneConfig(configName, toProject) {
    return runtimeconfig.variables.list(configName).then((variables) => {
        return Promise.all(variables.map((variable) => {
            return cloneVariable(variable.name, toProject);
        }));
    });
}
async function cloneConfigOrVariable(key, fromProject, toProject) {
    const parts = key.split(".");
    if (functionsConfig.RESERVED_NAMESPACES.includes(parts[0])) {
        throw new error_1.FirebaseError("Cannot clone reserved namespace " + clc.bold(parts[0]));
    }
    const configName = ["projects", fromProject, "configs", parts[0]].join("/");
    if (parts.length === 1) {
        return cloneConfig(configName, toProject);
    }
    return runtimeconfig.variables.list(configName).then((variables) => {
        const promises = [];
        for (const variable of variables) {
            const varId = functionsConfig.varNameToIds(variable.name).variable;
            const variablePrefixFilter = parts.slice(1);
            if (matchPrefix(variablePrefixFilter, varId.split("/"))) {
                promises.push(cloneVariable(variable.name, toProject));
            }
        }
        return Promise.all(promises);
    });
}
async function functionsConfigClone(fromProject, toProject, only, except = []) {
    if (only) {
        return Promise.all(only.map((key) => {
            return cloneConfigOrVariable(key, fromProject, toProject);
        }));
    }
    return functionsConfig.materializeAll(fromProject).then((toClone) => {
        _.unset(toClone, "firebase");
        applyExcept(toClone, except);
        return Promise.all(Object.entries(toClone).map(([configId, val]) => {
            return functionsConfig.setVariablesRecursive(toProject, configId, "", val);
        }));
    });
}
