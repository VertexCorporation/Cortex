"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseExperimentList = void 0;
exports.listExperiments = listExperiments;
const Table = require("cli-table3");
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const logger_1 = require("../logger");
const error_1 = require("../error");
const TIMEOUT = 30000;
const TABLE_HEAD = [
    "Experiment ID",
    "Display Name",
    "Service",
    "Description",
    "State",
    "Start Time",
    "End Time",
    "Last Update Time",
    "etag",
];
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.remoteConfigApiOrigin)(),
    apiVersion: "v1",
});
const parseExperimentList = (experiments) => {
    if (experiments.length === 0)
        return "\x1b[33mNo experiments found\x1b[0m";
    const table = new Table({ head: TABLE_HEAD, style: { head: ["green"] } });
    for (const experiment of experiments) {
        table.push([
            experiment.name.split("/").pop(),
            experiment.definition.displayName,
            experiment.definition.service,
            experiment.definition.description,
            experiment.state,
            experiment.startTime,
            experiment.endTime,
            experiment.lastUpdateTime,
            experiment.etag,
        ]);
    }
    return table.toString();
};
exports.parseExperimentList = parseExperimentList;
async function listExperiments(projectId, namespace, listExperimentOptions) {
    try {
        const params = new URLSearchParams();
        if (listExperimentOptions.pageSize) {
            params.set("page_size", listExperimentOptions.pageSize);
        }
        if (listExperimentOptions.filter) {
            params.set("filter", listExperimentOptions.filter);
        }
        if (listExperimentOptions.pageToken) {
            params.set("page_token", listExperimentOptions.pageToken);
        }
        logger_1.logger.debug(`Query parameters for listExperiments: ${params.toString()}`);
        const res = await apiClient.request({
            method: "GET",
            path: `projects/${projectId}/namespaces/${namespace}/experiments`,
            queryParams: params,
            timeout: TIMEOUT,
        });
        return res.body;
    }
    catch (err) {
        const error = (0, error_1.getError)(err);
        logger_1.logger.debug(error.message);
        throw new error_1.FirebaseError(`Failed to get Remote Config experiments for project ${projectId}. Error: ${error.message}`, { original: error });
    }
}
