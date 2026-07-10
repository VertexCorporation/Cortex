"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.realtimeOriginOrEmulatorOrCustomUrl = realtimeOriginOrEmulatorOrCustomUrl;
exports.realtimeOriginOrCustomUrl = realtimeOriginOrCustomUrl;
const utils_1 = require("../utils");
const constants_1 = require("../emulator/constants");
function realtimeOriginOrEmulatorOrCustomUrl(host) {
    return (0, utils_1.envOverride)(constants_1.Constants.FIREBASE_DATABASE_EMULATOR_HOST, (0, utils_1.envOverride)("FIREBASE_REALTIME_URL", host), addHttpIfRequired);
}
function realtimeOriginOrCustomUrl(host) {
    return (0, utils_1.envOverride)("FIREBASE_REALTIME_URL", host);
}
function addHttpIfRequired(val) {
    if (val.startsWith("http")) {
        return val;
    }
    return `http://${val}`;
}
