"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteExperiment = deleteExperiment;
const clc = require("colorette");
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const error_1 = require("../error");
const utils_1 = require("../utils");
const TIMEOUT = 30000;
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.remoteConfigApiOrigin)(),
    apiVersion: "v1",
});
async function deleteExperiment(projectId, namespace, experimentId) {
    try {
        await apiClient.request({
            method: "DELETE",
            path: `projects/${projectId}/namespaces/${namespace}/experiments/${experimentId}`,
            timeout: TIMEOUT,
        });
        return clc.bold(`Successfully deleted experiment ${clc.yellow(experimentId)}`);
    }
    catch (err) {
        const error = (0, error_1.getError)(err);
        if (error.message.includes("is running and cannot be deleted")) {
            const rcConsoleUrl = (0, utils_1.consoleUrl)(projectId, `/config/experiment/results/${experimentId}`);
            throw new error_1.FirebaseError(`Experiment ${experimentId} is currently running and cannot be deleted. If you want to delete this experiment, stop it at ${rcConsoleUrl}`, { original: error });
        }
        throw new error_1.FirebaseError(`Failed to delete Remote Config experiment with ID ${experimentId} for project ${projectId}. Error: ${(0, error_1.getErrMsg)(err)}`, { original: error });
    }
}
