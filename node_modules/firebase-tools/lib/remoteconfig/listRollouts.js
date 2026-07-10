"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseRolloutList = void 0;
exports.listRollouts = listRollouts;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const logger_1 = require("../logger");
const error_1 = require("../error");
const Table = require("cli-table3");
const TIMEOUT = 30000;
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.remoteConfigApiOrigin)(),
    apiVersion: "v1",
});
const TABLE_HEAD = [
    "Rollout ID",
    "Display Name",
    "Service",
    "Description",
    "State",
    "Start Time",
    "End Time",
    "Last Update Time",
    "ETag",
];
const parseRolloutList = (rollouts) => {
    if (rollouts.length === 0) {
        return "\x1b[33mNo rollouts found.\x1b[0m";
    }
    const table = new Table({ head: TABLE_HEAD, style: { head: ["green"] } });
    for (const rollout of rollouts) {
        table.push([
            rollout.name.split("/").pop() || rollout.name,
            rollout.definition.displayName,
            rollout.definition.service,
            rollout.definition.description,
            rollout.state,
            rollout.startTime,
            rollout.endTime,
            rollout.lastUpdateTime,
            rollout.etag,
        ]);
    }
    return table.toString();
};
exports.parseRolloutList = parseRolloutList;
async function listRollouts(projectId, namespace, listRolloutOptions) {
    try {
        const params = new URLSearchParams();
        if (listRolloutOptions.pageSize) {
            params.set("page_size", listRolloutOptions.pageSize);
        }
        if (listRolloutOptions.filter) {
            params.set("filter", listRolloutOptions.filter);
        }
        if (listRolloutOptions.pageToken) {
            params.set("page_token", listRolloutOptions.pageToken);
        }
        const res = await apiClient.request({
            method: "GET",
            path: `/projects/${projectId}/namespaces/${namespace}/rollouts`,
            queryParams: params,
            timeout: TIMEOUT,
        });
        return res.body;
    }
    catch (err) {
        const error = (0, error_1.getError)(err);
        logger_1.logger.debug(error.message);
        throw new error_1.FirebaseError(`Failed to get Remote Config rollouts for project ${projectId}. Error: ${error.message}`, { original: error });
    }
}
