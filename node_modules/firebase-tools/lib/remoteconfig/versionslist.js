"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getVersions = getVersions;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const error_1 = require("../error");
const logger_1 = require("../logger");
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.remoteConfigApiOrigin)(),
    apiVersion: "v1",
});
const TIMEOUT = 30000;
async function getVersions(projectId, maxResults = 10) {
    maxResults = maxResults || 300;
    try {
        const params = new URLSearchParams();
        if (maxResults) {
            params.set("pageSize", `${maxResults}`);
        }
        const response = await apiClient.request({
            method: "GET",
            path: `/projects/${projectId}/remoteConfig:listVersions`,
            queryParams: params,
            timeout: TIMEOUT,
        });
        return response.body;
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to get Remote Config template versions for Firebase project ${projectId}. `, { original: err });
    }
}
