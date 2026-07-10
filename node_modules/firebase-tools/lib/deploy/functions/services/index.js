"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FALLBACK_DEPLOYMENT_REGION = exports.DEFAULT_GLOBAL_TRIGGER_REGION = exports.noopProjectBindings = exports.noop = void 0;
exports.serviceForEndpoint = serviceForEndpoint;
const auth_1 = require("./auth");
const storage_1 = require("./storage");
const firebaseAlerts_1 = require("./firebaseAlerts");
const database_1 = require("./database");
const remoteConfig_1 = require("./remoteConfig");
const testLab_1 = require("./testLab");
const firestore_1 = require("./firestore");
const dataconnect_1 = require("./dataconnect");
const ailogic_1 = require("./ailogic");
const authEventarc_1 = require("./authEventarc");
const noop = () => Promise.resolve();
exports.noop = noop;
const noopProjectBindings = () => Promise.resolve([]);
exports.noopProjectBindings = noopProjectBindings;
exports.DEFAULT_GLOBAL_TRIGGER_REGION = "us-east1";
exports.FALLBACK_DEPLOYMENT_REGION = "us-central1";
const noOpService = {
    name: "noop",
    api: "",
    ensureTriggerRegion: exports.noop,
    validateTrigger: exports.noop,
    registerTrigger: exports.noop,
    unregisterTrigger: exports.noop,
    getDefaultRegion: () => Promise.resolve(exports.FALLBACK_DEPLOYMENT_REGION),
};
const pubSubService = {
    name: "pubsub",
    api: "pubsub.googleapis.com",
    requiredProjectBindings: exports.noopProjectBindings,
    ensureTriggerRegion: exports.noop,
    validateTrigger: exports.noop,
    registerTrigger: exports.noop,
    unregisterTrigger: exports.noop,
    getDefaultRegion: () => Promise.resolve(exports.DEFAULT_GLOBAL_TRIGGER_REGION),
};
const storageService = {
    name: "storage",
    api: "storage.googleapis.com",
    requiredProjectBindings: storage_1.obtainStorageBindings,
    ensureTriggerRegion: storage_1.ensureStorageTriggerRegion,
    validateTrigger: exports.noop,
    registerTrigger: exports.noop,
    unregisterTrigger: exports.noop,
    getDefaultRegion: storage_1.getDefaultRegion,
};
const firebaseAlertsService = {
    name: "firebasealerts",
    api: "firebasealerts.googleapis.com",
    requiredProjectBindings: exports.noopProjectBindings,
    ensureTriggerRegion: firebaseAlerts_1.ensureFirebaseAlertsTriggerRegion,
    validateTrigger: exports.noop,
    registerTrigger: exports.noop,
    unregisterTrigger: exports.noop,
    getDefaultRegion: () => Promise.resolve(exports.DEFAULT_GLOBAL_TRIGGER_REGION),
};
const authBlockingService = new auth_1.AuthBlockingService();
const aiLogicService = new ailogic_1.AILogicService();
const databaseService = {
    name: "database",
    api: "firebasedatabase.googleapis.com",
    requiredProjectBindings: exports.noopProjectBindings,
    ensureTriggerRegion: database_1.ensureDatabaseTriggerRegion,
    validateTrigger: exports.noop,
    registerTrigger: exports.noop,
    unregisterTrigger: exports.noop,
    getDefaultRegion: database_1.getDefaultRegion,
};
const remoteConfigService = {
    name: "remoteconfig",
    api: "firebaseremoteconfig.googleapis.com",
    requiredProjectBindings: exports.noopProjectBindings,
    ensureTriggerRegion: remoteConfig_1.ensureRemoteConfigTriggerRegion,
    validateTrigger: exports.noop,
    registerTrigger: exports.noop,
    unregisterTrigger: exports.noop,
    getDefaultRegion: () => Promise.resolve(exports.DEFAULT_GLOBAL_TRIGGER_REGION),
};
const testLabService = {
    name: "testlab",
    api: "testing.googleapis.com",
    requiredProjectBindings: exports.noopProjectBindings,
    ensureTriggerRegion: testLab_1.ensureTestLabTriggerRegion,
    validateTrigger: exports.noop,
    registerTrigger: exports.noop,
    unregisterTrigger: exports.noop,
    getDefaultRegion: () => Promise.resolve(exports.DEFAULT_GLOBAL_TRIGGER_REGION),
};
const firestoreService = {
    name: "firestore",
    api: "firestore.googleapis.com",
    requiredProjectBindings: exports.noopProjectBindings,
    ensureTriggerRegion: firestore_1.ensureFirestoreTriggerRegion,
    validateTrigger: exports.noop,
    registerTrigger: exports.noop,
    unregisterTrigger: exports.noop,
    getDefaultRegion: firestore_1.getDefaultRegion,
};
const dataconnectService = {
    name: "dataconnect",
    api: "firebasedataconnect.googleapis.com",
    requiredProjectBindings: exports.noopProjectBindings,
    ensureTriggerRegion: dataconnect_1.ensureDataConnectTriggerRegion,
    validateTrigger: exports.noop,
    registerTrigger: exports.noop,
    unregisterTrigger: exports.noop,
    getDefaultRegion: dataconnect_1.getDefaultRegion,
};
const authEventarcService = {
    name: "autheventarc",
    api: "eventarc.googleapis.com",
    requiredProjectBindings: exports.noopProjectBindings,
    ensureTriggerRegion: authEventarc_1.ensureAuthEventarcTriggerRegion,
    validateTrigger: exports.noop,
    registerTrigger: exports.noop,
    unregisterTrigger: exports.noop,
    getDefaultRegion: () => Promise.resolve(exports.DEFAULT_GLOBAL_TRIGGER_REGION),
};
const EVENT_SERVICE_MAPPING = {
    "google.cloud.pubsub.topic.v1.messagePublished": pubSubService,
    "google.cloud.storage.object.v1.finalized": storageService,
    "google.cloud.storage.object.v1.archived": storageService,
    "google.cloud.storage.object.v1.deleted": storageService,
    "google.cloud.storage.object.v1.metadataUpdated": storageService,
    "google.firebase.firebasealerts.alerts.v1.published": firebaseAlertsService,
    "providers/cloud.auth/eventTypes/user.beforeCreate": authBlockingService,
    "providers/cloud.auth/eventTypes/user.beforeSignIn": authBlockingService,
    "providers/cloud.auth/eventTypes/user.beforeSendEmail": authBlockingService,
    "providers/cloud.auth/eventTypes/user.beforeSendSms": authBlockingService,
    "google.firebase.database.ref.v1.written": databaseService,
    "google.firebase.database.ref.v1.created": databaseService,
    "google.firebase.database.ref.v1.updated": databaseService,
    "google.firebase.database.ref.v1.deleted": databaseService,
    "google.firebase.remoteconfig.remoteConfig.v1.updated": remoteConfigService,
    "google.firebase.testlab.testMatrix.v1.completed": testLabService,
    "google.cloud.firestore.document.v1.written": firestoreService,
    "google.cloud.firestore.document.v1.created": firestoreService,
    "google.cloud.firestore.document.v1.updated": firestoreService,
    "google.cloud.firestore.document.v1.deleted": firestoreService,
    "google.cloud.firestore.document.v1.written.withAuthContext": firestoreService,
    "google.cloud.firestore.document.v1.created.withAuthContext": firestoreService,
    "google.cloud.firestore.document.v1.updated.withAuthContext": firestoreService,
    "google.cloud.firestore.document.v1.deleted.withAuthContext": firestoreService,
    "google.firebase.dataconnect.connector.v1.mutationExecuted": dataconnectService,
    "google.firebase.ailogic.v1.beforeGenerate": aiLogicService,
    "google.firebase.ailogic.v1.afterGenerate": aiLogicService,
    "google.firebase.auth.user.v2.created": authEventarcService,
    "google.firebase.auth.user.v2.deleted": authEventarcService,
};
function serviceForEndpoint(endpoint) {
    let eventType;
    if ("eventTrigger" in endpoint && endpoint.eventTrigger?.eventType) {
        eventType = endpoint.eventTrigger.eventType;
    }
    else if ("blockingTrigger" in endpoint && endpoint.blockingTrigger?.eventType) {
        eventType = endpoint.blockingTrigger.eventType;
    }
    return eventType ? EVENT_SERVICE_MAPPING[eventType] || noOpService : noOpService;
}
