"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.constructDefaultAdminSdkConfig = constructDefaultAdminSdkConfig;
exports.getProjectAdminSdkConfigOrCached = getProjectAdminSdkConfigOrCached;
const api_1 = require("../api");
const apiv2 = require("../apiv2");
const configstore_1 = require("../configstore");
const error_1 = require("../error");
const error_2 = require("../error");
const logger_1 = require("../logger");
const constants_1 = require("./constants");
const _CONFIGSTORE_KEY = "adminsdkconfig";
function constructDefaultAdminSdkConfig(projectId) {
    return {
        projectId: projectId,
        databaseURL: process.env.DATABASE_URL || `https://${projectId}.firebaseio.com`,
        storageBucket: process.env.STORAGE_BUCKET_URL || `${projectId}.appspot.com`,
    };
}
async function getProjectAdminSdkConfigOrCached(projectId) {
    if (constants_1.Constants.isDemoProject(projectId)) {
        return constructDefaultAdminSdkConfig(projectId);
    }
    try {
        const config = await getProjectAdminSdkConfig(projectId);
        setCacheAdminSdkConfig(projectId, config);
        return config;
    }
    catch (e) {
        logger_1.logger.debug(`Failed to get Admin SDK config for ${projectId}, falling back to cache`, e);
        return getCachedAdminSdkConfig(projectId);
    }
}
async function getProjectAdminSdkConfig(projectId) {
    const apiClient = new apiv2.Client({
        auth: true,
        apiVersion: "v1beta1",
        urlPrefix: (0, api_1.firebaseApiOrigin)(),
    });
    if (projectId.startsWith("demo-")) {
        logger_1.logger.debug(`Detected demo- project: ${projectId}. Using default adminSdkConfig instead of calling firebase API.`);
        return {
            projectId,
            databaseURL: `${projectId}-default-rtdb.firebaseio.com`,
            storageBucket: `${projectId}.appspot.com`,
        };
    }
    try {
        const res = await apiClient.get(`projects/${projectId}/adminSdkConfig`);
        return res.body;
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to get Admin SDK for Firebase project ${projectId}. ` +
            "Please make sure the project exists and your account has permission to access it.", { exit: 2, original: (0, error_2.getError)(err) });
    }
}
function setCacheAdminSdkConfig(projectId, config) {
    const allConfigs = configstore_1.configstore.get(_CONFIGSTORE_KEY) || {};
    allConfigs[projectId] = config;
    configstore_1.configstore.set(_CONFIGSTORE_KEY, allConfigs);
}
function getCachedAdminSdkConfig(projectId) {
    const allConfigs = configstore_1.configstore.get(_CONFIGSTORE_KEY) || {};
    return allConfigs[projectId];
}
