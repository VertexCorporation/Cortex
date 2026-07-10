"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseRolloutIntoTable = void 0;
exports.getRollout = getRollout;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const logger_1 = require("../logger");
const error_1 = require("../error");
const Table = require("cli-table3");
const util = require("util");
const TIMEOUT = 30000;
const TABLE_HEAD = ["Entry Name", "Value"];
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.remoteConfigApiOrigin)(),
    apiVersion: "v1",
});
const parseRolloutIntoTable = (rollout) => {
    const table = new Table({ head: TABLE_HEAD, style: { head: ["green"] } });
    table.push(["Name", rollout.name], ["Display Name", rollout.definition.displayName], ["Description", rollout.definition.description], ["State", rollout.state], ["Create Time", rollout.createTime], ["Start Time", rollout.startTime], ["End Time", rollout.endTime], ["Last Update Time", rollout.lastUpdateTime], [
        "Control Variant",
        util.inspect(rollout.definition.controlVariant, { showHidden: false, depth: null }),
    ], [
        "Enabled Variant",
        util.inspect(rollout.definition.enabledVariant, { showHidden: false, depth: null }),
    ], ["ETag", rollout.etag]);
    return table.toString();
};
exports.parseRolloutIntoTable = parseRolloutIntoTable;
async function getRollout(projectId, namespace, rolloutId) {
    try {
        const res = await apiClient.request({
            method: "GET",
            path: `/projects/${projectId}/namespaces/${namespace}/rollouts/${rolloutId}`,
            timeout: TIMEOUT,
        });
        return res.body;
    }
    catch (err) {
        const error = (0, error_1.getError)(err);
        logger_1.logger.debug(error.message);
        throw new error_1.FirebaseError(`Failed to get Remote Config Rollout with ID ${rolloutId} for project ${projectId}. Error: ${error.message}`, { original: error });
    }
}
