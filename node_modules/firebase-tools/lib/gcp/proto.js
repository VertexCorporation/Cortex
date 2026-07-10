"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.secondsFromDuration = secondsFromDuration;
exports.durationFromSeconds = durationFromSeconds;
exports.assertOneOf = assertOneOf;
exports.copyIfPresent = copyIfPresent;
exports.convertIfPresent = convertIfPresent;
exports.renameIfPresent = renameIfPresent;
exports.fieldMasks = fieldMasks;
exports.getInvokerMembers = getInvokerMembers;
exports.formatServiceAccount = formatServiceAccount;
exports.pruneUndefiends = pruneUndefiends;
const error_1 = require("../error");
function secondsFromDuration(d) {
    return +d.slice(0, d.length - 1);
}
function durationFromSeconds(s) {
    return `${s}s`;
}
function assertOneOf(typename, obj, oneof, ...fields) {
    const defined = [];
    for (const key of fields) {
        const value = obj[key];
        if (typeof value !== "undefined" && value != null) {
            defined.push(key);
        }
    }
    if (defined.length > 1) {
        throw new error_1.FirebaseError(`Invalid ${typename} definition. ${oneof} can only have one field defined, but found ${defined.join(",")}`);
    }
}
function copyIfPresent(dest, src, ...fields) {
    for (const field of fields) {
        if (!Object.prototype.hasOwnProperty.call(src, field)) {
            continue;
        }
        dest[field] = src[field];
    }
}
function convertIfPresent(...args) {
    if (args.length === 4) {
        const [dest, src, key, converter] = args;
        if (Object.prototype.hasOwnProperty.call(src, key)) {
            dest[key] = converter(src[key]);
        }
        return;
    }
    const [dest, src, destKey, srcKey, converter] = args;
    if (Object.prototype.hasOwnProperty.call(src, srcKey)) {
        dest[destKey] = converter(src[srcKey]);
    }
}
function renameIfPresent(dest, src, destKey, srcKey) {
    if (!Object.prototype.hasOwnProperty.call(src, srcKey)) {
        return;
    }
    dest[destKey] = src[srcKey];
}
function fieldMasks(object, ...doNotRecurseIn) {
    const masks = [];
    fieldMasksHelper([], object, doNotRecurseIn, masks);
    return masks;
}
function fieldMasksHelper(prefixes, cursor, doNotRecurseIn, masks) {
    if (Array.isArray(cursor) && !cursor.length) {
        return;
    }
    if (typeof cursor !== "object" || (Array.isArray(cursor) && cursor.length) || cursor === null) {
        masks.push(prefixes.join("."));
        return;
    }
    const entries = Object.entries(cursor);
    if (entries.length === 0) {
        masks.push(prefixes.join("."));
        return;
    }
    for (const [key, value] of entries) {
        const newPrefixes = [...prefixes, key];
        if (doNotRecurseIn.includes(newPrefixes.join("."))) {
            masks.push(newPrefixes.join("."));
            continue;
        }
        fieldMasksHelper(newPrefixes, value, doNotRecurseIn, masks);
    }
}
function getInvokerMembers(invoker, projectId) {
    if (invoker.includes("private")) {
        return [];
    }
    if (invoker.includes("public")) {
        return ["allUsers"];
    }
    return invoker.map((inv) => formatServiceAccount(inv, projectId));
}
function formatServiceAccount(serviceAccount, projectId, removeTypePrefix = false) {
    if (serviceAccount.length === 0) {
        throw new error_1.FirebaseError("Service account cannot be an empty string");
    }
    if (!serviceAccount.includes("@")) {
        throw new error_1.FirebaseError("Service account must be of the form 'service-account@' or 'service-account@{project-id}.iam.gserviceaccount.com'");
    }
    const prefix = removeTypePrefix ? "" : "serviceAccount:";
    if (serviceAccount.endsWith("@")) {
        const suffix = `${projectId}.iam.gserviceaccount.com`;
        return `${prefix}${serviceAccount}${suffix}`;
    }
    return `${prefix}${serviceAccount}`;
}
function pruneUndefiends(obj) {
    if (typeof obj !== "object" || obj === null) {
        return;
    }
    const keyable = obj;
    for (const key of Object.keys(keyable)) {
        if (keyable[key] === undefined) {
            delete keyable[key];
        }
        else if (typeof keyable[key] === "object") {
            if (Array.isArray(keyable[key])) {
                for (const sub of keyable[key]) {
                    pruneUndefiends(sub);
                }
                keyable[key] = keyable[key].filter((e) => e !== undefined);
            }
            else {
                pruneUndefiends(keyable[key]);
            }
        }
    }
}
