"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.AI_LOGIC_TRIGGERS_TO_EVENTS = exports.AI_LOGIC_EVENTS_TO_TRIGGER = exports.CONVERTABLE_EVENTS = exports.AUTH_EVENTS = exports.DATACONNECT_EVENT = exports.FIREALERTS_EVENT = exports.FIRESTORE_EVENTS = exports.TEST_LAB_EVENT = exports.REMOTE_CONFIG_EVENT = exports.DATABASE_EVENTS = exports.FIREBASE_ALERTS_PUBLISH_EVENT = exports.STORAGE_EVENTS = exports.PUBSUB_PUBLISH_EVENT = void 0;
const ailogic_1 = require("../../deploy/functions/services/ailogic");
exports.PUBSUB_PUBLISH_EVENT = "google.cloud.pubsub.topic.v1.messagePublished";
exports.STORAGE_EVENTS = [
    "google.cloud.storage.object.v1.finalized",
    "google.cloud.storage.object.v1.archived",
    "google.cloud.storage.object.v1.deleted",
    "google.cloud.storage.object.v1.metadataUpdated",
];
exports.FIREBASE_ALERTS_PUBLISH_EVENT = "google.firebase.firebasealerts.alerts.v1.published";
exports.DATABASE_EVENTS = [
    "google.firebase.database.ref.v1.written",
    "google.firebase.database.ref.v1.created",
    "google.firebase.database.ref.v1.updated",
    "google.firebase.database.ref.v1.deleted",
];
exports.REMOTE_CONFIG_EVENT = "google.firebase.remoteconfig.remoteConfig.v1.updated";
exports.TEST_LAB_EVENT = "google.firebase.testlab.testMatrix.v1.completed";
exports.FIRESTORE_EVENTS = [
    "google.cloud.firestore.document.v1.written",
    "google.cloud.firestore.document.v1.created",
    "google.cloud.firestore.document.v1.updated",
    "google.cloud.firestore.document.v1.deleted",
    "google.cloud.firestore.document.v1.written.withAuthContext",
    "google.cloud.firestore.document.v1.created.withAuthContext",
    "google.cloud.firestore.document.v1.updated.withAuthContext",
    "google.cloud.firestore.document.v1.deleted.withAuthContext",
];
exports.FIREALERTS_EVENT = "google.firebase.firebasealerts.alerts.v1.published";
exports.DATACONNECT_EVENT = "google.firebase.dataconnect.connector.v1.mutationExecuted";
exports.AUTH_EVENTS = [
    "google.firebase.auth.user.v2.created",
    "google.firebase.auth.user.v2.deleted",
];
exports.CONVERTABLE_EVENTS = {
    "google.cloud.firestore.document.v1.created": "google.cloud.firestore.document.v1.created.withAuthContext",
    "google.cloud.firestore.document.v1.updated": "google.cloud.firestore.document.v1.updated.withAuthContext",
    "google.cloud.firestore.document.v1.deleted": "google.cloud.firestore.document.v1.deleted.withAuthContext",
    "google.cloud.firestore.document.v1.written": "google.cloud.firestore.document.v1.written.withAuthContext",
};
exports.AI_LOGIC_EVENTS_TO_TRIGGER = {
    [ailogic_1.AI_LOGIC_BEFORE_GENERATE_CONTENT]: "before-generate-content",
    [ailogic_1.AI_LOGIC_AFTER_GENERATE_CONTENT]: "after-generate-content",
};
exports.AI_LOGIC_TRIGGERS_TO_EVENTS = {
    "before-generate-content": ailogic_1.AI_LOGIC_BEFORE_GENERATE_CONTENT,
    "after-generate-content": ailogic_1.AI_LOGIC_AFTER_GENERATE_CONTENT,
};
