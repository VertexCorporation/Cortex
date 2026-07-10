"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.endpointSupportLevel = endpointSupportLevel;
exports.isDartEndpoint = isDartEndpoint;
exports.classifyNonProductionEndpoints = classifyNonProductionEndpoints;
exports.triggerTypeLabel = triggerTypeLabel;
exports.groupByTriggerLabel = groupByTriggerLabel;
const backend = require("../../backend");
const supported = require("../supported");
const constants_1 = require("../../../../emulator/constants");
const EMULATOR_ONLY_SERVICES = new Set([
    constants_1.Constants.SERVICE_FIRESTORE,
    constants_1.Constants.SERVICE_REALTIME_DATABASE,
    constants_1.Constants.SERVICE_STORAGE,
]);
const EXPERIMENTAL_SERVICES = new Set([
    constants_1.Constants.SERVICE_PUBSUB,
    constants_1.Constants.SERVICE_EVENTARC,
    constants_1.Constants.SERVICE_AUTH,
    constants_1.Constants.SERVICE_FIREALERTS,
    constants_1.Constants.SERVICE_REMOTE_CONFIG,
    constants_1.Constants.SERVICE_TEST_LAB,
    constants_1.Constants.SERVICE_CLOUD_TASKS,
]);
function endpointSupportLevel(ep) {
    if (backend.isHttpsTriggered(ep) || backend.isCallableTriggered(ep)) {
        if (backend.isTaskQueueTriggered(ep)) {
            return "experimental";
        }
        return "production";
    }
    if (backend.isScheduleTriggered(ep)) {
        return "experimental";
    }
    if (backend.isBlockingTriggered(ep)) {
        return "experimental";
    }
    if (backend.isEventTriggered(ep)) {
        if (ep.eventTrigger.channel) {
            return "experimental";
        }
        const service = ep.eventTrigger.eventType
            ? serviceFromEventType(ep.eventTrigger.eventType)
            : undefined;
        if (service && EMULATOR_ONLY_SERVICES.has(service)) {
            return "emulatorOnly";
        }
        if (service && EXPERIMENTAL_SERVICES.has(service)) {
            return "experimental";
        }
    }
    return "experimental";
}
function isDartEndpoint(ep) {
    return supported.runtimeIsLanguage(ep.runtime, "dart");
}
function classifyNonProductionEndpoints(endpoints) {
    const emulatorOnly = [];
    const experimental = [];
    for (const ep of endpoints) {
        switch (endpointSupportLevel(ep)) {
            case "production":
                break;
            case "emulatorOnly":
                emulatorOnly.push(ep);
                break;
            case "experimental":
                experimental.push(ep);
                break;
        }
    }
    return { emulatorOnly, experimental };
}
function triggerTypeLabel(ep) {
    if (backend.isScheduleTriggered(ep))
        return "scheduler";
    if (backend.isTaskQueueTriggered(ep))
        return "tasks";
    if (backend.isBlockingTriggered(ep))
        return "identity";
    if (backend.isCallableTriggered(ep))
        return "callable";
    if (backend.isHttpsTriggered(ep))
        return "https";
    if (backend.isEventTriggered(ep)) {
        if (ep.eventTrigger.channel)
            return "eventarc";
        const svc = serviceFromEventType(ep.eventTrigger.eventType);
        return svc ? constants_1.Constants.getServiceName(svc) : ep.eventTrigger.eventType;
    }
    return "unknown";
}
function groupByTriggerLabel(endpoints) {
    const groups = new Map();
    for (const ep of endpoints) {
        const label = triggerTypeLabel(ep);
        const ids = groups.get(label) ?? [];
        ids.push(ep.id);
        groups.set(label, ids);
    }
    return groups;
}
function serviceFromEventType(eventType) {
    if (eventType.includes("firestore"))
        return constants_1.Constants.SERVICE_FIRESTORE;
    if (eventType.includes("database"))
        return constants_1.Constants.SERVICE_REALTIME_DATABASE;
    if (eventType.includes("pubsub"))
        return constants_1.Constants.SERVICE_PUBSUB;
    if (eventType.includes("storage"))
        return constants_1.Constants.SERVICE_STORAGE;
    if (eventType.includes("eventarc"))
        return constants_1.Constants.SERVICE_EVENTARC;
    if (eventType.includes("firebasealerts"))
        return constants_1.Constants.SERVICE_FIREALERTS;
    if (eventType.includes("auth"))
        return constants_1.Constants.SERVICE_AUTH;
    if (eventType.includes("remoteconfig"))
        return constants_1.Constants.SERVICE_REMOTE_CONFIG;
    if (eventType.includes("testlab") || eventType.includes("testing"))
        return constants_1.Constants.SERVICE_TEST_LAB;
    return undefined;
}
