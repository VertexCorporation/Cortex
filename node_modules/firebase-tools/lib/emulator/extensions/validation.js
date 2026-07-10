"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getUnemulatedAPIs = getUnemulatedAPIs;
exports.checkForUnemulatedTriggerTypes = checkForUnemulatedTriggerTypes;
const planner = require("../../deploy/extensions/planner");
const controller_1 = require("../controller");
const constants_1 = require("../constants");
const ensureApiEnabled_1 = require("../../ensureApiEnabled");
const functionsEmulatorShared_1 = require("../functionsEmulatorShared");
const types_1 = require("../types");
const EMULATED_APIS = [
    "storage-component.googleapis.com",
    "firestore.googleapis.com",
    "pubsub.googleapis.com",
    "identitytoolkit.googleapis.com",
];
async function getUnemulatedAPIs(projectId, instances) {
    const unemulatedAPIs = {};
    for (const i of instances) {
        const extensionSpec = await planner.getExtensionSpec(i);
        for (const api of extensionSpec.apis ?? []) {
            if (!EMULATED_APIS.includes(api.apiName)) {
                if (unemulatedAPIs[api.apiName]) {
                    unemulatedAPIs[api.apiName].instanceIds.push(i.instanceId);
                }
                else {
                    const enabled = !constants_1.Constants.isDemoProject(projectId) &&
                        (await (0, ensureApiEnabled_1.check)(projectId, api.apiName, "extensions", true));
                    unemulatedAPIs[api.apiName] = {
                        apiName: api.apiName,
                        instanceIds: [i.instanceId],
                        enabled,
                    };
                }
            }
        }
    }
    return Object.values(unemulatedAPIs);
}
function checkForUnemulatedTriggerTypes(backend, options) {
    const triggers = backend.predefinedTriggers ?? [];
    const unemulatedTriggers = triggers
        .filter((definition) => {
        if (definition.httpsTrigger) {
            return false;
        }
        if (definition.eventTrigger) {
            const service = (0, functionsEmulatorShared_1.getFunctionService)(definition);
            switch (service) {
                case constants_1.Constants.SERVICE_FIRESTORE:
                    return !(0, controller_1.shouldStart)(options, types_1.Emulators.FIRESTORE);
                case constants_1.Constants.SERVICE_REALTIME_DATABASE:
                    return !(0, controller_1.shouldStart)(options, types_1.Emulators.DATABASE);
                case constants_1.Constants.SERVICE_PUBSUB:
                    return !(0, controller_1.shouldStart)(options, types_1.Emulators.PUBSUB);
                case constants_1.Constants.SERVICE_AUTH:
                    return !(0, controller_1.shouldStart)(options, types_1.Emulators.AUTH);
                case constants_1.Constants.SERVICE_STORAGE:
                    return !(0, controller_1.shouldStart)(options, types_1.Emulators.STORAGE);
                case constants_1.Constants.SERVICE_EVENTARC:
                    return !(0, controller_1.shouldStart)(options, types_1.Emulators.EVENTARC);
                default:
                    return true;
            }
        }
    })
        .map((definition) => constants_1.Constants.getServiceName((0, functionsEmulatorShared_1.getFunctionService)(definition)));
    return [...new Set(unemulatedTriggers)];
}
