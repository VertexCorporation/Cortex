"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseTemplateForTable = parseTemplateForTable;
exports.getTemplate = getTemplate;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const logger_1 = require("../logger");
const error_1 = require("../error");
const TIMEOUT = 30000;
const MAX_DISPLAY_ITEMS = 50;
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.remoteConfigApiOrigin)(),
    apiVersion: "v1",
});
function parseTemplateForTable(templateItems) {
    let outputStr = "";
    let counter = 0;
    for (const item in templateItems) {
        if (Object.prototype.hasOwnProperty.call(templateItems, item)) {
            outputStr = outputStr.concat(item, "\n");
            counter++;
            if (counter === MAX_DISPLAY_ITEMS) {
                outputStr += "+more..." + "\n";
                break;
            }
        }
    }
    return outputStr;
}
async function getTemplate(projectId, versionNumber) {
    try {
        const params = new URLSearchParams();
        if (versionNumber) {
            params.set("versionNumber", versionNumber);
        }
        const res = await apiClient.request({
            method: "GET",
            path: `/projects/${projectId}/remoteConfig`,
            queryParams: params,
            timeout: TIMEOUT,
        });
        return res.body;
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to get Firebase Remote Config template for project ${projectId}. `, { original: err });
    }
}
