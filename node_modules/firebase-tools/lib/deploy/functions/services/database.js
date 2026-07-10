"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.clearCache = clearCache;
exports.getDatabaseInstanceDetails = getDatabaseInstanceDetails;
exports.ensureDatabaseTriggerRegion = ensureDatabaseTriggerRegion;
exports.getDefaultRegion = getDefaultRegion;
const error_1 = require("../../../error");
const build = require("../build");
const database_1 = require("../../../management/database");
const instanceCache = new Map();
function clearCache() {
    instanceCache.clear();
}
async function getDatabaseInstanceDetails(projectId, instanceName) {
    const key = `${projectId}/${instanceName}`;
    if (instanceCache.has(key)) {
        return instanceCache.get(key);
    }
    const details = await (0, database_1.getDatabaseInstanceDetails)(projectId, instanceName);
    instanceCache.set(key, details);
    return details;
}
function ensureDatabaseTriggerRegion(endpoint) {
    if (!endpoint.eventTrigger.region) {
        endpoint.eventTrigger.region = endpoint.region;
    }
    if (endpoint.eventTrigger.region !== endpoint.region) {
        throw new error_1.FirebaseError("A database trigger location must match the function region.");
    }
    return Promise.resolve();
}
async function getDefaultRegion(endpoint) {
    if (!build.isEventTriggered(endpoint)) {
        throw new error_1.FirebaseError("Database getDefaultRegion requires an event-triggered endpoint");
    }
    if (endpoint.eventTrigger.region) {
        return endpoint.eventTrigger.region;
    }
    const instanceName = endpoint.eventTrigger.eventFilters?.instance;
    if (instanceName) {
        const details = await getDatabaseInstanceDetails(endpoint.project, instanceName);
        if (details.location && details.location !== "-") {
            return details.location.toLowerCase();
        }
    }
    throw new error_1.FirebaseError("Could not resolve database instance location");
}
