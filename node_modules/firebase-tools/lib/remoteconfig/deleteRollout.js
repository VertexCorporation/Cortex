"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteRollout = deleteRollout;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const error_1 = require("../error");
const utils_1 = require("../utils");
const clc = require("colorette");
const TIMEOUT = 30000;
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.remoteConfigApiOrigin)(),
    apiVersion: "v1",
});
async function deleteRollout(projectId, namespace, rolloutId) {
    try {
        await apiClient.request({
            method: "DELETE",
            path: `/projects/${projectId}/namespaces/${namespace}/rollouts/${rolloutId}`,
            timeout: TIMEOUT,
        });
        return clc.bold(`Successfully deleted rollout ${clc.yellow(rolloutId)}`);
    }
    catch (err) {
        const originalError = (0, error_1.getError)(err);
        const errorMessage = (0, error_1.getErrMsg)(err);
        if (errorMessage.includes("is running and cannot be deleted")) {
            const rcConsoleUrl = (0, utils_1.consoleUrl)(projectId, `/config/env/firebase/rollout/${rolloutId}`);
            throw new error_1.FirebaseError(`Rollout '${rolloutId}' is currently running and cannot be deleted. If you want to delete this rollout, stop it at ${rcConsoleUrl}`, { original: originalError });
        }
        throw new error_1.FirebaseError(`Failed to delete Remote Config rollout with ID ${rolloutId} for project ${projectId}. Error: ${errorMessage}`, { original: originalError });
    }
}
