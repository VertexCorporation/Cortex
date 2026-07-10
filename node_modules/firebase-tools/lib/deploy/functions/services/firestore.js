"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.clearCache = clearCache;
exports.getDatabase = getDatabase;
exports.ensureFirestoreTriggerRegion = ensureFirestoreTriggerRegion;
exports.getDefaultRegion = getDefaultRegion;
const firestore = require("../../../gcp/firestore");
const error_1 = require("../../../error");
const build = require("../build");
const location_1 = require("../../../gcp/location");
const dbCache = new Map();
const dbPromiseCache = new Map();
function clearCache() {
    dbCache.clear();
    dbPromiseCache.clear();
}
async function getDatabase(project, databaseId) {
    const key = `${project}/${databaseId}`;
    if (dbCache.has(key)) {
        return dbCache.get(key);
    }
    if (dbPromiseCache.has(key)) {
        return dbPromiseCache.get(key);
    }
    const dbPromise = firestore
        .getDatabase(project, databaseId)
        .then((db) => {
        dbCache.set(key, db);
        dbPromiseCache.delete(key);
        return db;
    })
        .catch((error) => {
        dbPromiseCache.delete(key);
        throw error;
    });
    dbPromiseCache.set(key, dbPromise);
    return dbPromise;
}
async function ensureFirestoreTriggerRegion(endpoint) {
    const db = await getDatabase(endpoint.project, endpoint.eventTrigger.eventFilters?.database || "(default)");
    const dbRegion = db.locationId;
    if (!endpoint.eventTrigger.region) {
        endpoint.eventTrigger.region = dbRegion;
    }
    if (endpoint.eventTrigger.region !== dbRegion) {
        throw new error_1.FirebaseError("A firestore trigger location must match the firestore database region.");
    }
}
async function getDefaultRegion(endpoint) {
    if (!build.isEventTriggered(endpoint)) {
        throw new error_1.FirebaseError("Firestore getDefaultRegion requires an event-triggered endpoint");
    }
    const databaseId = endpoint.eventTrigger.eventFilters?.database || "(default)";
    const db = await getDatabase(endpoint.project, databaseId);
    const locationId = db.locationId.toLowerCase();
    return location_1.FIRESTORE_DUAL_REGION_TO_REGION_MAPPING[locationId] || locationId;
}
