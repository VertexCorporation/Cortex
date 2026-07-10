"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listAllRulesets = listAllRulesets;
exports.getRuleset = getRuleset;
exports.getRulesetLabels = getRulesetLabels;
exports.createRuleset = createRuleset;
exports.setRulesetLabels = setRulesetLabels;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const logger_1 = require("../logger");
const utils = require("../utils");
function handleErrorResponse(response) {
    if (response.body && response.body.error) {
        return utils.reject(response.body.error, { code: 2 });
    }
    logger_1.logger.debug("[rules] error:", response.status, response.body);
    return utils.reject("Unexpected error encountered with database.", {
        code: 2,
    });
}
const apiClient = new apiv2_1.Client({ urlPrefix: (0, api_1.rtdbMetadataOrigin)() });
async function listAllRulesets(databaseName) {
    const response = await apiClient.get(`/namespaces/${databaseName}/rulesets`, { resolveOnHTTPError: true });
    if (response.status === 200) {
        return response.body.rulesets;
    }
    return handleErrorResponse(response);
}
async function getRuleset(databaseName, rulesetId) {
    const response = await apiClient.get(`/namespaces/${databaseName}/rulesets/${rulesetId}`, { resolveOnHTTPError: true });
    if (response.status === 200) {
        return response.body;
    }
    return handleErrorResponse(response);
}
async function getRulesetLabels(databaseName) {
    const response = await apiClient.get(`/namespaces/${databaseName}/ruleset_labels`, {
        resolveOnHTTPError: true,
    });
    if (response.status === 200) {
        return response.body;
    }
    return handleErrorResponse(response);
}
async function createRuleset(databaseName, source) {
    const localApiClient = new apiv2_1.Client({
        urlPrefix: utils.addSubdomain((0, api_1.realtimeOrigin)(), databaseName),
    });
    const response = await localApiClient.post(`/.settings/rulesets.json`, source, { resolveOnHTTPError: true });
    if (response.status === 200) {
        return response.body.id;
    }
    return handleErrorResponse(response);
}
async function setRulesetLabels(databaseName, labels) {
    const localApiClient = new apiv2_1.Client({
        urlPrefix: utils.addSubdomain((0, api_1.realtimeOrigin)(), databaseName),
    });
    const response = await localApiClient.put(`/.settings/ruleset_labels.json`, labels, {
        resolveOnHTTPError: true,
    });
    if (response.status === 200) {
        return response.body;
    }
    return handleErrorResponse(response);
}
