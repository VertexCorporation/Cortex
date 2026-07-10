"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ensureTriggerRegions = ensureTriggerRegions;
const backend = require("./backend");
const services_1 = require("./services");
const logger_1 = require("../../logger");
const utils = require("../../utils");
const storage_1 = require("./services/storage");
const firestore_1 = require("./services/firestore");
const database_1 = require("./services/database");
const location_1 = require("../../gcp/location");
async function ensureTriggerRegions(want) {
    const regionLookups = [];
    const triggerRegionMap = new Map();
    for (const ep of backend.allEndpoints(want)) {
        if (!backend.isEventTriggered(ep)) {
            continue;
        }
        if (ep.platform === "gcfv1") {
            const eventType = ep.eventTrigger.eventType || "";
            const resource = ep.eventTrigger.eventFilters?.resource;
            if (eventType.includes("storage")) {
                const bucketName = extractBucketName(resource);
                if (bucketName) {
                    regionLookups.push((0, storage_1.getBucket)(bucketName)
                        .then((bucket) => {
                        triggerRegionMap.set(backend.functionName(ep), bucket.location.toLowerCase());
                    })
                        .catch((err) => {
                        logger_1.logger.debug(`Failed to resolve trigger region for V1 storage function ${ep.id}:`, err);
                    }));
                }
            }
            else if (eventType.includes("firestore")) {
                const dbId = extractDatabaseId(resource);
                regionLookups.push((0, firestore_1.getDatabase)(ep.project, dbId)
                    .then((db) => {
                    triggerRegionMap.set(backend.functionName(ep), db.locationId.toLowerCase());
                })
                    .catch((err) => {
                    logger_1.logger.debug(`Failed to resolve trigger region for V1 firestore function ${ep.id}:`, err);
                }));
            }
            else if (eventType.includes("database")) {
                const instanceName = extractInstanceName(resource);
                if (instanceName) {
                    regionLookups.push((0, database_1.getDatabaseInstanceDetails)(ep.project, instanceName)
                        .then((details) => {
                        if (details.location && details.location !== "-") {
                            triggerRegionMap.set(backend.functionName(ep), details.location.toLowerCase());
                        }
                    })
                        .catch((err) => {
                        logger_1.logger.debug(`Failed to resolve trigger region for V1 database function ${ep.id}:`, err);
                    }));
                }
            }
        }
        else {
            regionLookups.push((0, services_1.serviceForEndpoint)(ep).ensureTriggerRegion(ep));
        }
    }
    await Promise.all(regionLookups);
    if (process.env.FIREBASE_SUPPRESS_REGION_WARNING === "true") {
        return;
    }
    const offendingFunctions = [];
    for (const ep of backend.allEndpoints(want)) {
        if (!backend.isEventTriggered(ep)) {
            continue;
        }
        let triggerRegion;
        if (ep.platform === "gcfv1") {
            triggerRegion = triggerRegionMap.get(backend.functionName(ep));
        }
        else {
            triggerRegion = ep.eventTrigger.region;
        }
        if (ep.region !== "us-central1" || !triggerRegion || triggerRegion === "global") {
            continue;
        }
        if (!(0, location_1.isUSRegion)(triggerRegion)) {
            offendingFunctions.push(`- ${ep.id} (us-central1, Trigger: ${triggerRegion})`);
        }
    }
    if (offendingFunctions.length > 0) {
        utils.logLabeledWarning("functions", `The following functions have triggers in different regions than they are located:\n` +
            offendingFunctions.join("\n") +
            `\nTo avoid unnecessary cross-region network hops, consider assigning these functions to their trigger regions or collocating them. ` +
            `To suppress this warning, set FIREBASE_SUPPRESS_REGION_WARNING=true in your environment variables.`);
    }
}
function extractBucketName(resource) {
    if (!resource)
        return null;
    const match = /buckets\/([^/]+)/.exec(resource);
    if (match)
        return match[1];
    if (!resource.includes("/"))
        return resource;
    return null;
}
function extractDatabaseId(resource) {
    if (!resource)
        return "(default)";
    const match = /databases\/([^/]+)/.exec(resource);
    if (match)
        return match[1];
    if (!resource.includes("/"))
        return resource;
    return "(default)";
}
function extractInstanceName(resource) {
    if (!resource)
        return null;
    const match = /instances\/([^/]+)/.exec(resource);
    if (match)
        return match[1];
    if (!resource.includes("/"))
        return resource;
    return null;
}
