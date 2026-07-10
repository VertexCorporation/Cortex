"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.clearCache = clearCache;
exports.getBucket = getBucket;
exports.obtainStorageBindings = obtainStorageBindings;
exports.ensureStorageTriggerRegion = ensureStorageTriggerRegion;
exports.getDefaultRegion = getDefaultRegion;
const storage = require("../../../gcp/storage");
const logger_1 = require("../../../logger");
const error_1 = require("../../../error");
const location_1 = require("../../../gcp/location");
const build = require("../build");
const PUBSUB_PUBLISHER_ROLE = "roles/pubsub.publisher";
const bucketCache = new Map();
function clearCache() {
    bucketCache.clear();
}
async function getBucket(bucketName) {
    if (bucketCache.has(bucketName)) {
        return bucketCache.get(bucketName);
    }
    const b = await storage.getBucket(bucketName);
    bucketCache.set(bucketName, b);
    return b;
}
async function obtainStorageBindings(projectNumber) {
    const storageResponse = await storage.getServiceAccount(projectNumber);
    const storageServiceAgent = `serviceAccount:${storageResponse.email_address}`;
    const pubsubPublisherBinding = {
        role: PUBSUB_PUBLISHER_ROLE,
        members: [storageServiceAgent],
    };
    return [pubsubPublisherBinding];
}
async function ensureStorageTriggerRegion(endpoint) {
    const { eventTrigger } = endpoint;
    if (!eventTrigger.region) {
        logger_1.logger.debug("Looking up bucket region for the storage event trigger");
        if (!eventTrigger.eventFilters?.bucket) {
            throw new error_1.FirebaseError("Error: storage event trigger is missing bucket filter: " +
                JSON.stringify(eventTrigger, null, 2));
        }
        logger_1.logger.debug(`Looking up bucket region for the storage event trigger on bucket ${eventTrigger.eventFilters.bucket}`);
        try {
            const bucket = await getBucket(eventTrigger.eventFilters.bucket);
            eventTrigger.region = bucket.location.toLowerCase();
            logger_1.logger.debug("Setting the event trigger region to", eventTrigger.region, ".");
        }
        catch (err) {
            throw new error_1.FirebaseError("Can't find the storage bucket region", { original: err });
        }
    }
    if (endpoint.region !== eventTrigger.region &&
        eventTrigger.region !== "us-central1" &&
        !(0, location_1.regionInLocation)(endpoint.region, eventTrigger.region)) {
        throw new error_1.FirebaseError(`A function in region ${endpoint.region} cannot listen to a bucket in region ${eventTrigger.region}`);
    }
}
async function getDefaultRegion(endpoint) {
    if (!build.isEventTriggered(endpoint)) {
        throw new error_1.FirebaseError("Storage getDefaultRegion requires an event-triggered endpoint");
    }
    const bucketName = endpoint.eventTrigger.eventFilters?.bucket;
    if (!bucketName) {
        throw new error_1.FirebaseError("Could not find bucket name in event trigger filters");
    }
    const bucket = await getBucket(bucketName);
    const locationId = bucket.location.toLowerCase();
    return location_1.STORAGE_MULTI_REGION_TO_REGION_MAPPING[locationId] || locationId;
}
