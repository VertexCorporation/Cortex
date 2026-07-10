"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.EmulatedTrigger = exports.EVENTARC_SOURCE_ENV = void 0;
exports.eventServiceImplemented = eventServiceImplemented;
exports.prepareEndpoints = prepareEndpoints;
exports.emulatedFunctionsFromEndpoints = emulatedFunctionsFromEndpoints;
exports.emulatedFunctionsByRegion = emulatedFunctionsByRegion;
exports.getEmulatedTriggersFromDefinitions = getEmulatedTriggersFromDefinitions;
exports.getTemporarySocketPath = getTemporarySocketPath;
exports.getFunctionService = getFunctionService;
exports.getServiceFromEventType = getServiceFromEventType;
exports.waitForBody = waitForBody;
exports.findModuleRoot = findModuleRoot;
exports.formatHost = formatHost;
exports.getSignatureType = getSignatureType;
exports.getSecretLocalPath = getSecretLocalPath;
exports.toBackendInfo = toBackendInfo;
const os = require("os");
const path = require("path");
const fs = require("fs");
const crypto_1 = require("crypto");
const _ = require("lodash");
const backend = require("../deploy/functions/backend");
const build = require("../deploy/functions/build");
const constants_1 = require("./constants");
const manifest_1 = require("../extensions/manifest");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const postinstall_1 = require("./extensions/postinstall");
const services_1 = require("../deploy/functions/services");
const prepare_1 = require("../deploy/functions/prepare");
const events = require("../functions/events");
const utils_1 = require("../utils");
const V2_EVENTS = [
    events.v2.PUBSUB_PUBLISH_EVENT,
    events.v2.FIREALERTS_EVENT,
    ...events.v2.STORAGE_EVENTS,
    ...events.v2.DATABASE_EVENTS,
    ...events.v2.FIRESTORE_EVENTS,
];
exports.EVENTARC_SOURCE_ENV = "EVENTARC_CLOUD_EVENT_SOURCE";
class EmulatedTrigger {
    constructor(definition, module) {
        this.definition = definition;
        this.module = module;
    }
    get memoryLimitBytes() {
        return (this.definition.availableMemoryMb || 128) * 1024 * 1024;
    }
    get timeoutMs() {
        return (this.definition.timeoutSeconds || 60) * 1000;
    }
    getRawFunction() {
        if (!this.module) {
            throw new Error("EmulatedTrigger has not been provided a module.");
        }
        const func = _.get(this.module, this.definition.entryPoint);
        return func.__emulator_func || func;
    }
}
exports.EmulatedTrigger = EmulatedTrigger;
function eventServiceImplemented(eventType) {
    return V2_EVENTS.includes(eventType);
}
function prepareEndpoints(endpoints) {
    const bkend = backend.of(...endpoints);
    for (const ep of endpoints) {
        (0, services_1.serviceForEndpoint)(ep).validateTrigger(ep, bkend);
    }
    (0, prepare_1.inferBlockingDetails)(bkend);
}
function emulatedFunctionsFromEndpoints(endpoints) {
    const regionDefinitions = [];
    for (const endpoint of endpoints) {
        if (!endpoint.region || endpoint.region === build.REGION_TBD) {
            endpoint.region = "us-central1";
        }
        const def = {
            entryPoint: endpoint.entryPoint,
            platform: endpoint.platform,
            region: endpoint.region,
            name: endpoint.id,
            id: `${endpoint.region}-${endpoint.id}`,
            codebase: endpoint.codebase,
        };
        def.availableMemoryMb = endpoint.availableMemoryMb || 256;
        def.labels = endpoint.labels || {};
        if (endpoint.platform === "gcfv1") {
            def.labels[exports.EVENTARC_SOURCE_ENV] =
                "cloudfunctions-emulated.googleapis.com" +
                    `/projects/${endpoint.project || "project"}/locations/${endpoint.region}/functions/${endpoint.id}`;
        }
        else if (endpoint.platform === "gcfv2") {
            def.labels[exports.EVENTARC_SOURCE_ENV] =
                "run-emulated.googleapis.com" +
                    `/projects/${endpoint.project || "project"}/locations/${endpoint.region}/services/${endpoint.id}`;
        }
        def.timeoutSeconds = endpoint.timeoutSeconds || 60;
        def.secretEnvironmentVariables = endpoint.secretEnvironmentVariables || [];
        def.platform = endpoint.platform;
        if (backend.isHttpsTriggered(endpoint)) {
            def.httpsTrigger = endpoint.httpsTrigger;
        }
        else if (backend.isDataConnectGraphqlTriggered(endpoint)) {
            def.httpsTrigger = endpoint.dataConnectGraphqlTrigger;
        }
        else if (backend.isCallableTriggered(endpoint)) {
            def.httpsTrigger = {};
            def.labels = { ...def.labels, "deployment-callable": "true" };
        }
        else if (backend.isEventTriggered(endpoint)) {
            const eventTrigger = endpoint.eventTrigger;
            if (endpoint.platform === "gcfv1") {
                def.eventTrigger = {
                    eventType: eventTrigger.eventType,
                    resource: eventTrigger.eventFilters.resource,
                };
            }
            else {
                if (!eventServiceImplemented(eventTrigger.eventType) && !eventTrigger.channel) {
                    continue;
                }
                const { resource, topic, bucket } = endpoint.eventTrigger.eventFilters;
                const eventResource = resource || topic || bucket;
                def.eventTrigger = {
                    eventType: eventTrigger.eventType,
                    resource: eventResource,
                    channel: eventTrigger.channel,
                    eventFilters: eventTrigger.eventFilters,
                    eventFilterPathPatterns: eventTrigger.eventFilterPathPatterns,
                };
            }
        }
        else if (backend.isScheduleTriggered(endpoint)) {
            def.eventTrigger = { eventType: "pubsub", resource: "" };
            def.schedule = endpoint.scheduleTrigger;
        }
        else if (backend.isBlockingTriggered(endpoint)) {
            def.blockingTrigger = {
                eventType: endpoint.blockingTrigger.eventType,
                options: endpoint.blockingTrigger.options || {},
            };
        }
        else if (backend.isTaskQueueTriggered(endpoint)) {
            def.httpsTrigger = {};
            def.taskQueueTrigger = {
                retryConfig: {
                    maxAttempts: endpoint.taskQueueTrigger.retryConfig?.maxAttempts,
                    maxRetrySeconds: endpoint.taskQueueTrigger.retryConfig?.maxRetrySeconds,
                    maxBackoffSeconds: endpoint.taskQueueTrigger.retryConfig?.maxBackoffSeconds,
                    maxDoublings: endpoint.taskQueueTrigger.retryConfig?.maxDoublings,
                    minBackoffSeconds: endpoint.taskQueueTrigger.retryConfig?.minBackoffSeconds,
                },
                rateLimits: {
                    maxConcurrentDispatches: endpoint.taskQueueTrigger.rateLimits?.maxConcurrentDispatches,
                    maxDispatchesPerSecond: endpoint.taskQueueTrigger.rateLimits?.maxDispatchesPerSecond,
                },
            };
        }
        else {
        }
        regionDefinitions.push(def);
    }
    return regionDefinitions;
}
function emulatedFunctionsByRegion(definitions, secretEnvVariables = []) {
    const regionDefinitions = [];
    for (const def of definitions) {
        if (!def.regions) {
            def.regions = ["us-central1"];
        }
        for (const region of def.regions) {
            const defDeepCopy = JSON.parse(JSON.stringify(def));
            defDeepCopy.regions = [region];
            defDeepCopy.region = region;
            defDeepCopy.id = `${region}-${defDeepCopy.name}`;
            defDeepCopy.platform = defDeepCopy.platform || "gcfv1";
            defDeepCopy.secretEnvironmentVariables = secretEnvVariables;
            regionDefinitions.push(defDeepCopy);
        }
    }
    return regionDefinitions;
}
function getEmulatedTriggersFromDefinitions(definitions, module) {
    return definitions.reduce((obj, definition) => {
        obj[definition.id] = new EmulatedTrigger(definition, module);
        return obj;
    }, {});
}
function getTemporarySocketPath() {
    const rand = (0, crypto_1.randomBytes)(8).toString("hex");
    if (process.platform === "win32") {
        return path.join("\\\\?\\pipe", `fire_emu_${rand}`);
    }
    else {
        return path.join(os.tmpdir(), `fire_emu_${rand}.sock`);
    }
}
function getFunctionService(def) {
    if (def.eventTrigger) {
        if (def.eventTrigger.channel) {
            return constants_1.Constants.SERVICE_EVENTARC;
        }
        return def.eventTrigger.service ?? getServiceFromEventType(def.eventTrigger.eventType);
    }
    if (def.blockingTrigger) {
        return def.blockingTrigger.eventType;
    }
    if (def.httpsTrigger) {
        return "https";
    }
    if (def.taskQueueTrigger) {
        return constants_1.Constants.SERVICE_CLOUD_TASKS;
    }
    return "unknown";
}
function getServiceFromEventType(eventType) {
    if (eventType.includes("firestore")) {
        return constants_1.Constants.SERVICE_FIRESTORE;
    }
    if (eventType.includes("database")) {
        return constants_1.Constants.SERVICE_REALTIME_DATABASE;
    }
    if (eventType.includes("pubsub")) {
        return constants_1.Constants.SERVICE_PUBSUB;
    }
    if (eventType.includes("storage")) {
        return constants_1.Constants.SERVICE_STORAGE;
    }
    if (eventType.includes("firebasealerts")) {
        return constants_1.Constants.SERVICE_FIREALERTS;
    }
    if (eventType.includes("analytics")) {
        return constants_1.Constants.SERVICE_ANALYTICS;
    }
    if (eventType.includes("auth")) {
        return constants_1.Constants.SERVICE_AUTH;
    }
    if (eventType.includes("crashlytics")) {
        return constants_1.Constants.SERVICE_CRASHLYTICS;
    }
    if (eventType.includes("remoteconfig")) {
        return constants_1.Constants.SERVICE_REMOTE_CONFIG;
    }
    if (eventType.includes("testing")) {
        return constants_1.Constants.SERVICE_TEST_LAB;
    }
    return "";
}
function waitForBody(req) {
    let data = "";
    return new Promise((resolve) => {
        req.on("data", (chunk) => {
            data += chunk;
        });
        req.on("end", () => {
            resolve(data);
        });
    });
}
function findModuleRoot(moduleName, filepath) {
    const hierarchy = filepath.split(path.sep);
    for (let i = 0; i < hierarchy.length; i++) {
        try {
            let chunks = [];
            if (i) {
                chunks = hierarchy.slice(0, -i);
            }
            else {
                chunks = hierarchy;
            }
            const packagePath = path.join(chunks.join(path.sep), "package.json");
            const serializedPackage = fs.readFileSync(packagePath, "utf8").toString();
            if (JSON.parse(serializedPackage).name === moduleName) {
                return chunks.join("/");
            }
            break;
        }
        catch (err) {
        }
    }
    return "";
}
function formatHost(info) {
    const host = (0, utils_1.connectableHostname)(info.host);
    if (host.includes(":")) {
        return `[${host}]:${info.port}`;
    }
    else {
        return `${host}:${info.port}`;
    }
}
function getSignatureType(def) {
    if (def.httpsTrigger || def.blockingTrigger) {
        return "http";
    }
    if (def.platform === "gcfv2" && def.schedule) {
        return "http";
    }
    return def.platform === "gcfv2" ? "cloudevent" : "event";
}
const LOCAL_SECRETS_FILE = ".secret.local";
function getSecretLocalPath(backend, projectDir) {
    const secretsFile = backend.extensionInstanceId
        ? `${backend.extensionInstanceId}${LOCAL_SECRETS_FILE}`
        : LOCAL_SECRETS_FILE;
    const secretDirectory = backend.extensionInstanceId
        ? path.join(projectDir, manifest_1.ENV_DIRECTORY)
        : backend.functionsDir;
    return path.join(secretDirectory, secretsFile);
}
function toBackendInfo(e, cf3Triggers, labels) {
    const envWithSecrets = Object.assign({}, e.env);
    for (const s of e.secretEnv) {
        envWithSecrets[s.key] = backend.secretVersionName(s);
    }
    let extensionVersion = e.extensionVersion;
    if (extensionVersion) {
        extensionVersion = (0, extensionsHelper_1.substituteParams)(extensionVersion, e.env);
        if (extensionVersion.spec?.postinstallContent) {
            extensionVersion.spec.postinstallContent = (0, postinstall_1.replaceConsoleLinks)(extensionVersion.spec.postinstallContent);
        }
    }
    let extensionSpec = e.extensionSpec;
    if (extensionSpec) {
        extensionSpec = (0, extensionsHelper_1.substituteParams)(extensionSpec, e.env);
        if (extensionSpec?.postinstallContent) {
            extensionSpec.postinstallContent = (0, postinstall_1.replaceConsoleLinks)(extensionSpec.postinstallContent);
        }
    }
    return JSON.parse(JSON.stringify({
        directory: e.functionsDir,
        env: envWithSecrets,
        extensionInstanceId: e.extensionInstanceId,
        extension: e.extension,
        extensionVersion: extensionVersion,
        extensionSpec: extensionSpec,
        labels,
        functionTriggers: e.predefinedTriggers ?? cf3Triggers.filter((t) => t.codebase === e.codebase),
    }));
}
