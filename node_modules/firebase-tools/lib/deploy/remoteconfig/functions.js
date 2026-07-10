"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getEtag = getEtag;
exports.validateInputRemoteConfigTemplate = validateInputRemoteConfigTemplate;
exports.deployTemplate = deployTemplate;
exports.publishTemplate = publishTemplate;
const api_1 = require("../../api");
const apiv2_1 = require("../../apiv2");
const error_1 = require("../../error");
const TIMEOUT = 30000;
const client = new apiv2_1.Client({ urlPrefix: (0, api_1.remoteConfigApiOrigin)(), apiVersion: "v1" });
async function getEtag(projectNumber, versionNumber) {
    const reqPath = `/projects/${projectNumber}/remoteConfig`;
    const queryParams = {};
    if (versionNumber) {
        queryParams.versionNumber = versionNumber;
    }
    const response = await client.request({
        method: "GET",
        path: reqPath,
        queryParams,
        headers: { "Accept-Encoding": "gzip" },
        timeout: TIMEOUT,
    });
    return response.response.headers.get("etag") || "";
}
function validateInputRemoteConfigTemplate(template) {
    const templateCopy = JSON.parse(JSON.stringify(template));
    if (!templateCopy || templateCopy === "null" || templateCopy === "undefined") {
        throw new error_1.FirebaseError(`Invalid Remote Config template: ${JSON.stringify(templateCopy)}`);
    }
    if (typeof templateCopy.etag !== "string" || templateCopy.etag === "") {
        throw new error_1.FirebaseError("ETag must be a non-empty string");
    }
    if (templateCopy.conditions && !Array.isArray(templateCopy.conditions)) {
        throw new error_1.FirebaseError("Remote Config conditions must be an array");
    }
    return templateCopy;
}
async function deployTemplate(projectNumber, template, etag, options) {
    const reqPath = `/projects/${projectNumber}/remoteConfig`;
    if (options?.force) {
        etag = "*";
    }
    const response = await client.request({
        method: "PUT",
        path: reqPath,
        headers: { "If-Match": etag },
        body: {
            conditions: template.conditions,
            parameters: template.parameters,
            parameterGroups: template.parameterGroups,
        },
        timeout: TIMEOUT,
    });
    return response.body;
}
function publishTemplate(projectNumber, template, etag, options) {
    const temporaryTemplate = {
        conditions: template.conditions,
        parameters: template.parameters,
        parameterGroups: template.parameterGroups,
        etag: etag,
    };
    let validTemplate = temporaryTemplate;
    validTemplate = validateInputRemoteConfigTemplate(template);
    return deployTemplate(projectNumber, validTemplate, etag, options);
}
