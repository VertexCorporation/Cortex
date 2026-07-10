"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkValidTargetFilters = checkValidTargetFilters;
const deploy_1 = require("./commands/deploy");
const error_1 = require("./error");
function targetsForTypes(only, ...types) {
    return only.filter((t) => {
        if (t.includes(":")) {
            return types.includes(t.split(":")[0]);
        }
        else {
            return types.includes(t);
        }
    });
}
function targetsHaveFilters(...targets) {
    return targets.some((t) => t.includes(":"));
}
function targetsHaveNoFilters(...targets) {
    return targets.some((t) => !t.includes(":"));
}
const FILTERABLE_TARGETS = new Set([
    "hosting",
    "functions",
    "firestore",
    "storage",
    "database",
    "dataconnect",
    "apphosting",
]);
async function checkValidTargetFilters(options) {
    const only = !options.only ? [] : options.only.split(",");
    return new Promise((resolve, reject) => {
        if (!only.length) {
            return resolve();
        }
        if (options.except) {
            return reject(new error_1.FirebaseError("Cannot specify both --only and --except"));
        }
        const nonFilteredTypes = deploy_1.VALID_DEPLOY_TARGETS.filter((t) => !FILTERABLE_TARGETS.has(t));
        const targetsForNonFilteredTypes = targetsForTypes(only, ...nonFilteredTypes);
        if (targetsForNonFilteredTypes.length && targetsHaveFilters(...targetsForNonFilteredTypes)) {
            return reject(new error_1.FirebaseError("Filters specified with colons (e.g. --only functions:func1,functions:func2) are only supported for functions, hosting, storage, and firestore"));
        }
        const targetsForFunctions = targetsForTypes(only, "functions");
        if (targetsForFunctions.length &&
            targetsHaveFilters(...targetsForFunctions) &&
            targetsHaveNoFilters(...targetsForFunctions)) {
            return reject(new error_1.FirebaseError('Cannot specify "--only functions" and "--only functions:<filter>" at the same time'));
        }
        return resolve();
    });
}
