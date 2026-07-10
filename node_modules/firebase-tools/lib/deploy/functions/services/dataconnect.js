"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ensureDataConnectTriggerRegion = ensureDataConnectTriggerRegion;
exports.getDataConnectP4SA = getDataConnectP4SA;
exports.getDefaultRegion = getDefaultRegion;
const api_1 = require("../../../api");
const error_1 = require("../../../error");
const build = require("../build");
const names_1 = require("../../../dataconnect/names");
const AUTOPUSH_DATACONNECT_SA_DOMAIN = "gcp-sa-autopush-dataconnect.iam.gserviceaccount.com";
const STAGING_DATACONNECT_SA_DOMAIN = "gcp-sa-staging-dataconnect.iam.gserviceaccount.com";
const PROD_DATACONNECT_SA_DOMAIN = "gcp-sa-firebasedataconnect.iam.gserviceaccount.com";
function ensureDataConnectTriggerRegion(endpoint) {
    if (!endpoint.eventTrigger.region) {
        endpoint.eventTrigger.region = endpoint.region;
    }
    if (endpoint.eventTrigger.region !== endpoint.region) {
        throw new error_1.FirebaseError("The Firebase SQL Connect trigger location must match the function region.");
    }
    return Promise.resolve();
}
function getDataConnectP4SA(projectNumber) {
    const origin = (0, api_1.dataconnectOrigin)();
    if (origin.includes("autopush")) {
        return `service-${projectNumber}@${AUTOPUSH_DATACONNECT_SA_DOMAIN}`;
    }
    if (origin.includes("staging")) {
        return `service-${projectNumber}@${STAGING_DATACONNECT_SA_DOMAIN}`;
    }
    return `service-${projectNumber}@${PROD_DATACONNECT_SA_DOMAIN}`;
}
async function getDefaultRegion(endpoint) {
    if (!build.isEventTriggered(endpoint)) {
        throw new error_1.FirebaseError("DataConnect getDefaultRegion requires an event-triggered endpoint");
    }
    if (endpoint.eventTrigger.region) {
        return endpoint.eventTrigger.region;
    }
    const service = endpoint.eventTrigger.eventFilters?.service;
    if (service) {
        return (0, names_1.parseServiceName)(service).location;
    }
    const connector = endpoint.eventTrigger.eventFilters?.connector;
    if (connector) {
        return (0, names_1.parseConnectorName)(connector).location;
    }
    throw new error_1.FirebaseError("Could not resolve DataConnect location");
}
