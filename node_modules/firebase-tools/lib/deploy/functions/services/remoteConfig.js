"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ensureRemoteConfigTriggerRegion = ensureRemoteConfigTriggerRegion;
const error_1 = require("../../../error");
function ensureRemoteConfigTriggerRegion(endpoint) {
    if (!endpoint.eventTrigger.region) {
        endpoint.eventTrigger.region = "global";
    }
    if (endpoint.eventTrigger.region !== "global") {
        throw new error_1.FirebaseError("A remote config trigger must specify 'global' trigger location");
    }
    return Promise.resolve();
}
