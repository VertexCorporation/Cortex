"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.POLL_SETTINGS = void 0;
exports.check = check;
exports.ensure = ensure;
exports.bestEffortEnsure = bestEffortEnsure;
exports.enableApiURI = enableApiURI;
const colorette_1 = require("colorette");
const track_1 = require("./track");
const api_1 = require("./api");
const apiv2_1 = require("./apiv2");
const utils = require("./utils");
const error_1 = require("./error");
const logger_1 = require("./logger");
const configstore_1 = require("./configstore");
exports.POLL_SETTINGS = {
    pollInterval: 10000,
    pollsBeforeRetry: 12,
};
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.serviceUsageOrigin)(),
    apiVersion: "v1",
});
async function check(projectId, apiUri, prefix, silent = false) {
    const apiName = apiUri.startsWith("http") ? new URL(apiUri).hostname : apiUri;
    if (checkAPIEnablementCache(projectId, apiName)) {
        return true;
    }
    const res = await apiClient.get(`/projects/${projectId}/services/${apiName}`, {
        headers: { "x-goog-user-project": `${projectId}` },
        skipLog: { resBody: true },
    });
    const isEnabled = res.body.state === "ENABLED";
    if (isEnabled && !silent) {
        utils.logLabeledSuccess(prefix, `required API ${(0, colorette_1.bold)(apiName)} is enabled`);
    }
    if (isEnabled) {
        cacheEnabledAPI(projectId, apiName);
    }
    return isEnabled;
}
function isPermissionError(e) {
    return e.context?.body?.error?.status === "PERMISSION_DENIED";
}
async function enable(projectId, apiName) {
    try {
        await apiClient.post(`/projects/${projectId}/services/${apiName}:enable`, undefined, {
            headers: { "x-goog-user-project": `${projectId}` },
            skipLog: { resBody: true },
        });
        cacheEnabledAPI(projectId, apiName);
    }
    catch (err) {
        if ((0, error_1.isBillingError)(err)) {
            throw new error_1.FirebaseError(`Your project ${(0, colorette_1.bold)(projectId)} must be on the Blaze (pay-as-you-go) plan to complete this command. Required API ${(0, colorette_1.bold)(apiName)} can't be enabled until the upgrade is complete. To upgrade, visit the following URL:

https://console.firebase.google.com/project/${projectId}/usage/details`);
        }
        else if (isPermissionError(err)) {
            const apiPermissionDeniedRegex = new RegExp(/Permission denied to enable service \[([.a-zA-Z]+)\]/);
            const permissionsError = apiPermissionDeniedRegex.exec(err.message);
            if (permissionsError && permissionsError[1]) {
                const serviceUrl = permissionsError[1];
                err.message = `Permissions denied enabling ${serviceUrl}.
        Please ask a project owner to visit the following URL to enable this service:
        
        https://console.cloud.google.com/apis/library/${serviceUrl}?project=${projectId}`;
                throw err;
            }
            else {
                throw err;
            }
        }
        else {
            throw err;
        }
    }
}
async function pollCheckEnabled(projectId, apiName, prefix, silent, enablementRetries, pollRetries = 0) {
    if (pollRetries > exports.POLL_SETTINGS.pollsBeforeRetry) {
        return enableApiWithRetries(projectId, apiName, prefix, silent, enablementRetries + 1);
    }
    await new Promise((resolve) => {
        setTimeout(resolve, exports.POLL_SETTINGS.pollInterval);
    });
    const isEnabled = await check(projectId, apiName, prefix, silent);
    if (isEnabled) {
        void (0, track_1.trackGA4)("api_enabled", {
            api_name: apiName,
        });
        return;
    }
    if (!silent) {
        utils.logLabeledBullet(prefix, `waiting for API ${(0, colorette_1.bold)(apiName)} to activate...`);
    }
    return pollCheckEnabled(projectId, apiName, prefix, silent, enablementRetries, pollRetries + 1);
}
async function enableApiWithRetries(projectId, apiName, prefix, silent, enablementRetries = 0) {
    if (enablementRetries > 1) {
        throw new error_1.FirebaseError(`Timed out waiting for API ${(0, colorette_1.bold)(apiName)} to enable. Please try again in a few minutes.`);
    }
    await enable(projectId, apiName);
    return pollCheckEnabled(projectId, apiName, prefix, silent, enablementRetries);
}
async function ensure(projectId, apiUri, prefix, silent = false) {
    const hostname = apiUri.startsWith("http") ? new URL(apiUri).hostname : apiUri;
    if (!silent) {
        utils.logLabeledBullet(prefix, `ensuring required API ${(0, colorette_1.bold)(hostname)} is enabled...`);
    }
    const isEnabled = await check(projectId, hostname, prefix, silent);
    if (isEnabled) {
        return;
    }
    if (!silent) {
        utils.logLabeledWarning(prefix, `missing required API ${(0, colorette_1.bold)(hostname)}. Enabling now...`);
    }
    return enableApiWithRetries(projectId, hostname, prefix, silent);
}
async function bestEffortEnsure(projectId, apiUri, prefix, silent = false) {
    try {
        await ensure(projectId, apiUri, prefix, silent);
    }
    catch (err) {
        logger_1.logger.debug(`Unable to check that ${apiUri} is enabled on ${projectId}. Calls to it will fail if it is not enabled`);
    }
}
function enableApiURI(projectId, apiName) {
    return `https://console.cloud.google.com/apis/library/${apiName}?project=${projectId}`;
}
const API_ENABLEMENT_CACHE_KEY = "apiEnablementCache";
function checkAPIEnablementCache(projectId, apiName) {
    const cache = configstore_1.configstore.get(API_ENABLEMENT_CACHE_KEY);
    return !!cache?.[projectId]?.[apiName];
}
function cacheEnabledAPI(projectId, apiName) {
    const cache = (configstore_1.configstore.get(API_ENABLEMENT_CACHE_KEY) || {});
    if (!cache[projectId]) {
        cache[projectId] = {};
    }
    cache[projectId][apiName] = true;
    configstore_1.configstore.set(API_ENABLEMENT_CACHE_KEY, cache);
}
