"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.functionResourceToEmulatedTriggerDefintion = functionResourceToEmulatedTriggerDefintion;
const emulatorLogger_1 = require("../../emulator/emulatorLogger");
const functionsEmulatorShared_1 = require("../../emulator/functionsEmulatorShared");
const types_1 = require("../../emulator/types");
const error_1 = require("../../error");
const types_2 = require("../../extensions/types");
const proto = require("../../gcp/proto");
const SUPPORTED_SYSTEM_PARAMS = {
    "firebaseextensions.v1beta.function": {
        regions: "firebaseextensions.v1beta.function/location",
        timeoutSeconds: "firebaseextensions.v1beta.function/timeoutSeconds",
        availableMemoryMb: "firebaseextensions.v1beta.function/memory",
        labels: "firebaseextensions.v1beta.function/labels",
    },
};
function functionResourceToEmulatedTriggerDefintion(resource, systemParams = {}) {
    const resourceType = resource.type;
    if (resource.type === types_2.FUNCTIONS_RESOURCE_TYPE) {
        const etd = {
            name: resource.name,
            entryPoint: resource.name,
            platform: "gcfv1",
        };
        proto.convertIfPresent(etd, systemParams, "regions", SUPPORTED_SYSTEM_PARAMS[types_2.FUNCTIONS_RESOURCE_TYPE].regions, (str) => [str]);
        proto.convertIfPresent(etd, systemParams, "timeoutSeconds", SUPPORTED_SYSTEM_PARAMS[types_2.FUNCTIONS_RESOURCE_TYPE].timeoutSeconds, (d) => +d);
        proto.convertIfPresent(etd, systemParams, "availableMemoryMb", SUPPORTED_SYSTEM_PARAMS[types_2.FUNCTIONS_RESOURCE_TYPE].availableMemoryMb, (d) => +d);
        proto.convertIfPresent(etd, systemParams, "labels", SUPPORTED_SYSTEM_PARAMS[types_2.FUNCTIONS_RESOURCE_TYPE].labels, (str) => {
            const ret = {};
            for (const [key, value] of str.split(",").map((label) => label.split(":"))) {
                ret[key] = value;
            }
            return ret;
        });
        const properties = resource.properties || {};
        proto.convertIfPresent(etd, properties, "timeoutSeconds", "timeout", proto.secondsFromDuration);
        proto.convertIfPresent(etd, properties, "regions", "location", (str) => [str]);
        proto.copyIfPresent(etd, properties, "availableMemoryMb");
        if (properties.httpsTrigger !== undefined) {
            etd.httpsTrigger = properties.httpsTrigger;
        }
        if (properties.eventTrigger) {
            etd.eventTrigger = {
                eventType: properties.eventTrigger.eventType,
                resource: properties.eventTrigger.resource,
                service: (0, functionsEmulatorShared_1.getServiceFromEventType)(properties.eventTrigger.eventType),
            };
        }
        else if (properties.scheduleTrigger) {
            const schedule = {
                schedule: properties.scheduleTrigger.schedule,
            };
            etd.schedule = schedule;
            etd.eventTrigger = {
                eventType: "google.pubsub.topic.publish",
                resource: "",
            };
        }
        else {
            emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.FUNCTIONS).log("WARN", `Function '${resource.name}' is missing a trigger in extension.yaml. Please add one, as triggers defined in code are ignored.`);
        }
        return etd;
    }
    if (resource.type === types_2.FUNCTIONS_V2_RESOURCE_TYPE) {
        const etd = {
            name: resource.name,
            entryPoint: resource.name,
            platform: "gcfv2",
        };
        const properties = resource.properties || {};
        proto.convertIfPresent(etd, properties, "regions", "location", (str) => [str]);
        if (properties.serviceConfig) {
            proto.copyIfPresent(etd, properties.serviceConfig, "timeoutSeconds");
            proto.convertIfPresent(etd, properties.serviceConfig, "availableMemoryMb", "availableMemory", (mem) => parseInt(mem));
        }
        if (properties.eventTrigger) {
            etd.eventTrigger = {
                eventType: properties.eventTrigger.eventType,
                service: (0, functionsEmulatorShared_1.getServiceFromEventType)(properties.eventTrigger.eventType),
            };
            proto.copyIfPresent(etd.eventTrigger, properties.eventTrigger, "channel");
            if (properties.eventTrigger.eventFilters) {
                const eventFilters = {};
                const eventFilterPathPatterns = {};
                for (const filter of properties.eventTrigger.eventFilters) {
                    if (filter.operator === undefined) {
                        eventFilters[filter.attribute] = filter.value;
                    }
                    else if (filter.operator === "match-path-pattern") {
                        eventFilterPathPatterns[filter.attribute] = filter.value;
                    }
                }
                if (properties.eventTrigger.eventType.includes("google.cloud.firestore")) {
                    eventFilters["database"] = eventFilters["database"] ?? "(default)";
                    eventFilters["namespace"] = eventFilters["namespace"] ?? "(default)";
                }
                etd.eventTrigger.eventFilters = eventFilters;
                etd.eventTrigger.eventFilterPathPatterns = eventFilterPathPatterns;
            }
        }
        else {
            emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.FUNCTIONS).log("WARN", `Function '${resource.name} is missing a trigger in extension.yaml. Please add one, as triggers defined in code are ignored.`);
        }
        return etd;
    }
    throw new error_1.FirebaseError("Unexpected resource type " + resourceType);
}
