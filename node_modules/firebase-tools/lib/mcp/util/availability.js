"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getDefaultFeatureAvailabilityCheck = getDefaultFeatureAvailabilityCheck;
const util_1 = require("../util");
const availability_1 = require("./crashlytics/availability");
const availability_2 = require("./apptesting/availability");
const DEFAULT_AVAILABILITY_CHECKS = {
    core: async () => true,
    developerknowledge: async () => true,
    firestore: (ctx) => (0, util_1.checkFeatureActive)("firestore", ctx.projectId, { config: ctx.config }),
    storage: (ctx) => (0, util_1.checkFeatureActive)("storage", ctx.projectId, { config: ctx.config }),
    dataconnect: (ctx) => (0, util_1.checkFeatureActive)("dataconnect", ctx.projectId, { config: ctx.config }),
    auth: (ctx) => (0, util_1.checkFeatureActive)("auth", ctx.projectId, { config: ctx.config }),
    messaging: (ctx) => (0, util_1.checkFeatureActive)("messaging", ctx.projectId, { config: ctx.config }),
    functions: (ctx) => (0, util_1.checkFeatureActive)("functions", ctx.projectId, { config: ctx.config }),
    remoteconfig: (ctx) => (0, util_1.checkFeatureActive)("remoteconfig", ctx.projectId, { config: ctx.config }),
    crashlytics: availability_1.isCrashlyticsAvailable,
    apphosting: (ctx) => (0, util_1.checkFeatureActive)("apphosting", ctx.projectId, { config: ctx.config }),
    apptesting: availability_2.isAppTestingAvailable,
    database: (ctx) => (0, util_1.checkFeatureActive)("database", ctx.projectId, { config: ctx.config }),
};
function getDefaultFeatureAvailabilityCheck(feature) {
    return DEFAULT_AVAILABILITY_CHECKS[feature];
}
