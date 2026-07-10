"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AILogicService = exports.AI_LOGIC_EVENTS = exports.AI_LOGIC_AFTER_GENERATE_CONTENT = exports.AI_LOGIC_BEFORE_GENERATE_CONTENT = void 0;
exports.isAILogicEvent = isAILogicEvent;
exports.isGlobalAILogicTrigger = isGlobalAILogicTrigger;
const backend = require("../backend");
const build = require("../build");
const error_1 = require("../../../error");
const ailogicApi = require("../../../gcp/ailogic");
const ailogic_1 = require("../../../gcp/ailogic");
Object.defineProperty(exports, "AI_LOGIC_BEFORE_GENERATE_CONTENT", { enumerable: true, get: function () { return ailogic_1.AI_LOGIC_BEFORE_GENERATE_CONTENT; } });
Object.defineProperty(exports, "AI_LOGIC_AFTER_GENERATE_CONTENT", { enumerable: true, get: function () { return ailogic_1.AI_LOGIC_AFTER_GENERATE_CONTENT; } });
const utils_1 = require("../../../utils");
exports.AI_LOGIC_EVENTS = [
    ailogic_1.AI_LOGIC_BEFORE_GENERATE_CONTENT,
    ailogic_1.AI_LOGIC_AFTER_GENERATE_CONTENT,
];
function isAILogicEvent(endpoint) {
    if (!backend.isBlockingTriggered(endpoint)) {
        return false;
    }
    return exports.AI_LOGIC_EVENTS.includes(endpoint.blockingTrigger.eventType);
}
function isGlobalAILogicTrigger(blockingTrigger) {
    return (exports.AI_LOGIC_EVENTS.includes(blockingTrigger.eventType) &&
        !blockingTrigger.options?.regionalWebhook);
}
class AILogicService {
    constructor() {
        this.ensureTriggerRegion = () => Promise.resolve();
        this.requiredProjectBindings = async (projectNumber) => {
            return [
                {
                    role: "roles/run.invoker",
                    members: [
                        `serviceAccount:service-${projectNumber}@gcp-sa-firebasevertexai.iam.gserviceaccount.com`,
                    ],
                },
            ];
        };
        this.name = "ailogic";
        this.api = "firebasevertexai.googleapis.com";
    }
    validateTrigger(endpoint, wantBackend) {
        if (!isAILogicEvent(endpoint)) {
            return;
        }
        const eventType = endpoint.blockingTrigger.eventType;
        const regionalWebhook = !!endpoint.blockingTrigger.options?.regionalWebhook;
        const conflict = backend.allEndpoints(wantBackend).some((ep) => {
            if (!isAILogicEvent(ep)) {
                return false;
            }
            if (ep.blockingTrigger.eventType !== eventType || ep.id === endpoint.id) {
                return false;
            }
            if (regionalWebhook) {
                return ep.blockingTrigger.options?.regionalWebhook && ep.region === endpoint.region;
            }
            else {
                return !ep.blockingTrigger.options?.regionalWebhook;
            }
        });
        if (conflict) {
            if (regionalWebhook) {
                throw new error_1.FirebaseError(`Can only create at most one regional AI Logic Trigger for ${eventType} in region ${endpoint.region}`);
            }
            else {
                throw new error_1.FirebaseError(`Can only create at most one global AI Logic Trigger for ${eventType}`);
            }
        }
    }
    async registerTrigger(ep) {
        if (!isAILogicEvent(ep)) {
            return;
        }
        await ailogicApi.upsertBlockingFunction(ep);
    }
    async unregisterTrigger(ep) {
        if (!isAILogicEvent(ep)) {
            return;
        }
        try {
            await ailogicApi.deleteBlockingFunction(ep);
        }
        catch (err) {
            if ((0, error_1.getErrStatus)(err) === 404) {
                (0, utils_1.logLabeledWarning)("functions", `Tried deleting trigger registration for function ${ep.id} but it is not currently registered`);
            }
            else {
                throw err;
            }
        }
    }
    async getDefaultRegion(endpoint) {
        if (build.isBlockingTriggered(endpoint) && isGlobalAILogicTrigger(endpoint.blockingTrigger)) {
            return "us-east1";
        }
        return "us-central1";
    }
}
exports.AILogicService = AILogicService;
