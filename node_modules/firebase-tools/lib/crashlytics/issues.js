"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getIssue = getIssue;
exports.updateIssue = updateIssue;
const logger_1 = require("../logger");
const utils_1 = require("./utils");
async function getIssue(appId, issueId) {
    const requestProjectNumber = (0, utils_1.parseProjectNumber)(appId);
    logger_1.logger.debug(`[crashlytics] getIssue called with appId: ${appId}, issueId: ${issueId}`);
    const response = await utils_1.CRASHLYTICS_API_CLIENT.request({
        method: "GET",
        headers: {
            "Content-Type": "application/json",
        },
        path: `/projects/${requestProjectNumber}/apps/${appId}/issues/${issueId}`,
        timeout: utils_1.TIMEOUT,
    });
    return response.body;
}
async function updateIssue(appId, issueId, state) {
    const requestProjectNumber = (0, utils_1.parseProjectNumber)(appId);
    logger_1.logger.debug(`[crashlytics] updateIssue called with appId: ${appId}, issueId: ${issueId}, state: ${state}`);
    const response = await utils_1.CRASHLYTICS_API_CLIENT.request({
        method: "PATCH",
        headers: {
            "Content-Type": "application/json",
        },
        path: `/projects/${requestProjectNumber}/apps/${appId}/issues/${issueId}`,
        queryParams: { updateMask: "state" },
        body: { state },
        timeout: utils_1.TIMEOUT,
    });
    return response.body;
}
