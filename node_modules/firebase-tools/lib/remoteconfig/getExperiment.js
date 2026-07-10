"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseExperiment = void 0;
exports.getExperiment = getExperiment;
const Table = require("cli-table3");
const util = require("util");
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const logger_1 = require("../logger");
const error_1 = require("../error");
const TIMEOUT = 30000;
const TABLE_HEAD = ["Entry Name", "Value"];
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.remoteConfigApiOrigin)(),
    apiVersion: "v1",
});
const parseExperiment = (experiment) => {
    const table = new Table({ head: TABLE_HEAD, style: { head: ["green"] } });
    table.push(["Name", experiment.name]);
    table.push(["Display Name", experiment.definition.displayName]);
    table.push(["Service", experiment.definition.service]);
    table.push([
        "Objectives",
        util.inspect(experiment.definition.objectives, { showHidden: false, depth: null }),
    ]);
    table.push([
        "Variants",
        util.inspect(experiment.definition.variants, { showHidden: false, depth: null }),
    ]);
    table.push(["State", experiment.state]);
    table.push(["Start Time", experiment.startTime]);
    table.push(["End Time", experiment.endTime]);
    table.push(["Last Update Time", experiment.lastUpdateTime]);
    table.push(["etag", experiment.etag]);
    return table.toString();
};
exports.parseExperiment = parseExperiment;
async function getExperiment(projectId, namespace, experimentId) {
    try {
        const res = await apiClient.request({
            method: "GET",
            path: `projects/${projectId}/namespaces/${namespace}/experiments/${experimentId}`,
            timeout: TIMEOUT,
        });
        return res.body;
    }
    catch (err) {
        const error = (0, error_1.getError)(err);
        logger_1.logger.debug(error.message);
        throw new error_1.FirebaseError(`Failed to get Remote Config experiment with ID ${experimentId} for project ${projectId}. Error: ${error.message}`, { original: error });
    }
}
