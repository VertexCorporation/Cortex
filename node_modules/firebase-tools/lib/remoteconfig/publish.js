"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.publishTemplate = publishTemplate;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const logger_1 = require("../logger");
const error_1 = require("../error");
const TIMEOUT = 30000;
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.remoteConfigApiOrigin)(),
    apiVersion: "v1",
});
async function publishTemplate(projectId, template, options) {
    try {
        let ifMatch = template.etag;
        if (options && options.force === true) {
            ifMatch = "*";
        }
        const requestBody = {
            conditions: template.conditions,
            parameters: template.parameters,
            parameterGroups: template.parameterGroups,
            version: template.version,
        };
        const res = await apiClient.request({
            method: "PUT",
            path: `/projects/${projectId}/remoteConfig`,
            timeout: TIMEOUT,
            headers: { "If-Match": ifMatch },
            body: JSON.stringify(requestBody),
        });
        return res.body;
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to publish Firebase Remote Config template for project ${projectId}. `, { original: err });
    }
}
