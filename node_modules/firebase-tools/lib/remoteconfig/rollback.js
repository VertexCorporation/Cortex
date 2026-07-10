"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.rollbackTemplate = rollbackTemplate;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.remoteConfigApiOrigin)(),
    apiVersion: "v1",
});
const TIMEOUT = 30000;
async function rollbackTemplate(projectId, versionNumber) {
    const params = new URLSearchParams();
    params.set("versionNumber", `${versionNumber}`);
    const res = await apiClient.request({
        method: "POST",
        path: `/projects/${projectId}/remoteConfig:rollback`,
        queryParams: params,
        timeout: TIMEOUT,
    });
    return res.body;
}
