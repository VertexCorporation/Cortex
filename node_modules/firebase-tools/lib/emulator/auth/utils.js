"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isValidEmailAddress = isValidEmailAddress;
exports.isValidPhoneNumber = isValidPhoneNumber;
exports.canonicalizeEmailAddress = canonicalizeEmailAddress;
exports.parseAbsoluteUri = parseAbsoluteUri;
exports.randomId = randomId;
exports.randomBase64UrlStr = randomBase64UrlStr;
exports.randomDigits = randomDigits;
exports.toUnixTimestamp = toUnixTimestamp;
exports.logError = logError;
exports.authEmulatorUrl = authEmulatorUrl;
exports.mirrorFieldTo = mirrorFieldTo;
const url_1 = require("url");
const registry_1 = require("../registry");
const types_1 = require("../types");
const emulatorLogger_1 = require("../emulatorLogger");
function isValidEmailAddress(email) {
    return /^[^@]+@[^@]+$/.test(email);
}
function isValidPhoneNumber(phoneNumber) {
    return /^\+/.test(phoneNumber);
}
function canonicalizeEmailAddress(email) {
    return email.toLowerCase();
}
function parseAbsoluteUri(uri) {
    try {
        return new url_1.URL(uri);
    }
    catch {
        return undefined;
    }
}
function randomId(len) {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";
    let autoId = "";
    for (let i = 0; i < len; i++) {
        autoId += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return autoId;
}
function randomBase64UrlStr(len) {
    const chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-";
    let autoId = "";
    for (let i = 0; i < len; i++) {
        autoId += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return autoId;
}
function randomDigits(len) {
    let digits = "";
    for (let i = 0; i < len; i++) {
        digits += Math.floor(Math.random() * 10);
    }
    return digits;
}
function toUnixTimestamp(date) {
    return Math.floor(date.getTime() / 1000);
}
function logError(err) {
    if (!registry_1.EmulatorRegistry.isRunning(types_1.Emulators.AUTH)) {
        console.error(err);
    }
    emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.AUTH).log("WARN", err.stack || err.message || err.constructor.name);
}
function authEmulatorUrl(req) {
    if (registry_1.EmulatorRegistry.isRunning(types_1.Emulators.AUTH)) {
        return registry_1.EmulatorRegistry.url(types_1.Emulators.AUTH);
    }
    else {
        return registry_1.EmulatorRegistry.url(types_1.Emulators.AUTH, req);
    }
}
function mirrorFieldTo(dest, field, source) {
    const value = source[field];
    if (value === undefined) {
        delete dest[field];
    }
    else {
        dest[field] = value;
    }
}
