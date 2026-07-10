"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getLatestRulesetName = getLatestRulesetName;
exports.listReleases = listReleases;
exports.listAllReleases = listAllReleases;
exports.getRulesetContent = getRulesetContent;
exports.listRulesets = listRulesets;
exports.listAllRulesets = listAllRulesets;
exports.getRulesetId = getRulesetId;
exports.deleteRuleset = deleteRuleset;
exports.createRuleset = createRuleset;
exports.createRelease = createRelease;
exports.updateRelease = updateRelease;
exports.updateOrCreateRelease = updateOrCreateRelease;
exports.testRuleset = testRuleset;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const logger_1 = require("../logger");
const utils = require("../utils");
const API_VERSION = "v1";
const apiClient = new apiv2_1.Client({ urlPrefix: (0, api_1.rulesOrigin)(), apiVersion: API_VERSION });
function _handleErrorResponse(response) {
    if (response.body && response.body.error) {
        return utils.reject(response.body.error, { code: 2 });
    }
    logger_1.logger.debug("[rules] error:", response.status, response.body);
    return utils.reject("Unexpected error encountered with rules.", {
        code: 2,
    });
}
async function getLatestRulesetName(projectId, service, releases, resourceName) {
    let prefix = `projects/${projectId}/releases/${service}`;
    if (resourceName) {
        prefix += `/${resourceName}`;
    }
    const release = releases.find((r) => r.name.startsWith(prefix));
    if (!release) {
        return null;
    }
    return release.rulesetName;
}
const MAX_RELEASES_PAGE_SIZE = 10;
async function listReleases(projectId, pageToken = "") {
    const response = await apiClient.get(`/projects/${projectId}/releases`, {
        queryParams: {
            pageSize: MAX_RELEASES_PAGE_SIZE,
            pageToken,
        },
    });
    if (response.status === 200) {
        return response.body;
    }
    return _handleErrorResponse(response);
}
async function listAllReleases(projectId) {
    let pageToken;
    let releases = [];
    do {
        const response = await listReleases(projectId, pageToken);
        if (response.releases && response.releases.length > 0) {
            releases = releases.concat(response.releases);
        }
        pageToken = response.nextPageToken;
    } while (pageToken);
    return releases.sort((a, b) => b.createTime.localeCompare(a.createTime));
}
async function getRulesetContent(name) {
    const response = await apiClient.get(`/${name}`, {
        skipLog: { resBody: true },
    });
    if (response.status === 200) {
        const source = response.body.source;
        return source.files;
    }
    return _handleErrorResponse(response);
}
const MAX_RULESET_PAGE_SIZE = 100;
async function listRulesets(projectId, pageToken = "") {
    const response = await apiClient.get(`/projects/${projectId}/rulesets`, {
        queryParams: {
            pageSize: MAX_RULESET_PAGE_SIZE,
            pageToken,
        },
        skipLog: { resBody: true },
    });
    if (response.status === 200) {
        return response.body;
    }
    return _handleErrorResponse(response);
}
async function listAllRulesets(projectId) {
    let pageToken;
    let rulesets = [];
    do {
        const response = await listRulesets(projectId, pageToken);
        if (response.rulesets) {
            rulesets = rulesets.concat(response.rulesets);
        }
        pageToken = response.nextPageToken;
    } while (pageToken);
    return rulesets.sort((a, b) => b.createTime.localeCompare(a.createTime));
}
function getRulesetId(ruleset) {
    return ruleset.name.split("/").pop();
}
async function deleteRuleset(projectId, id) {
    const response = await apiClient.delete(`/projects/${projectId}/rulesets/${id}`);
    if (response.status === 200) {
        return;
    }
    return _handleErrorResponse(response);
}
async function createRuleset(projectId, files, attachmentPoint) {
    const payload = {
        source: { files },
    };
    if (attachmentPoint) {
        payload.attachment_point = attachmentPoint;
    }
    const response = await apiClient.post(`/projects/${projectId}/rulesets`, payload, { skipLog: { body: true } });
    if (response.status === 200) {
        logger_1.logger.debug("[rules] created ruleset", response.body.name);
        return response.body.name;
    }
    return _handleErrorResponse(response);
}
async function createRelease(projectId, rulesetName, releaseName) {
    const payload = {
        name: `projects/${projectId}/releases/${releaseName}`,
        rulesetName,
    };
    const response = await apiClient.post(`/projects/${projectId}/releases`, payload);
    if (response.status === 200) {
        logger_1.logger.debug("[rules] created release", response.body.name);
        return response.body.name;
    }
    return _handleErrorResponse(response);
}
async function updateRelease(projectId, rulesetName, releaseName) {
    const payload = {
        release: {
            name: `projects/${projectId}/releases/${releaseName}`,
            rulesetName,
        },
    };
    const response = await apiClient.patch(`/projects/${projectId}/releases/${releaseName}`, payload);
    if (response.status === 200) {
        logger_1.logger.debug("[rules] updated release", response.body.name);
        return response.body.name;
    }
    return _handleErrorResponse(response);
}
async function updateOrCreateRelease(projectId, rulesetName, releaseName) {
    logger_1.logger.debug("[rules] releasing", releaseName, "with ruleset", rulesetName);
    return updateRelease(projectId, rulesetName, releaseName).catch(() => {
        logger_1.logger.debug("[rules] ruleset update failed, attempting to create instead");
        return createRelease(projectId, rulesetName, releaseName);
    });
}
function testRuleset(projectId, files) {
    return apiClient.post(`/projects/${encodeURIComponent(projectId)}:test`, { source: { files } }, { skipLog: { body: true } });
}
