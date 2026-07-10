"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ensureAuthEventarcTriggerRegion = ensureAuthEventarcTriggerRegion;
const error_1 = require("../../../error");
function ensureAuthEventarcTriggerRegion(endpoint) {
    if (!endpoint.eventTrigger.region) {
        endpoint.eventTrigger.region = "global";
    }
    if (endpoint.eventTrigger.region !== "global") {
        throw new error_1.FirebaseError("A Firebase Auth Eventarc trigger must specify 'global' trigger location");
    }
    return Promise.resolve();
}
