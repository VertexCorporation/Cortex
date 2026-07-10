"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.client = exports.API_VERSION = void 0;
exports.serviceAgentEmail = serviceAgentEmail;
exports.parseBackendName = parseBackendName;
exports.createBackend = createBackend;
exports.getBackend = getBackend;
exports.getTraffic = getTraffic;
exports.listDomains = listDomains;
exports.listBackends = listBackends;
exports.deleteBackend = deleteBackend;
exports.getBuild = getBuild;
exports.listBuilds = listBuilds;
exports.createBuild = createBuild;
exports.createRollout = createRollout;
exports.listRollouts = listRollouts;
exports.updateTraffic = updateTraffic;
exports.listLocations = listLocations;
exports.listSupportedRuntimes = listSupportedRuntimes;
exports.ensureApiEnabled = ensureApiEnabled;
exports.getNextRolloutId = getNextRolloutId;
const proto = require("../gcp/proto");
const apiv2_1 = require("../apiv2");
const projectUtils_1 = require("../projectUtils");
const api_1 = require("../api");
const ensureApiEnabled_1 = require("../ensureApiEnabled");
const deploymentTool = require("../deploymentTool");
const error_1 = require("../error");
const metaprogramming_1 = require("../metaprogramming");
exports.API_VERSION = "v1beta";
exports.client = new apiv2_1.Client({
    urlPrefix: (0, api_1.apphostingOrigin)(),
    auth: true,
    apiVersion: exports.API_VERSION,
});
(0, metaprogramming_1.assertImplements)();
(0, metaprogramming_1.assertImplements)();
(0, metaprogramming_1.assertImplements)();
(0, metaprogramming_1.assertImplements)();
const P4SA_DOMAIN = (0, api_1.apphostingP4SADomain)();
function serviceAgentEmail(projectNumber) {
    return `service-${projectNumber}@${P4SA_DOMAIN}`;
}
function parseBackendName(backendName) {
    const [, projectName, , location, , id] = backendName.split("/");
    return { projectName, location, id };
}
async function createBackend(projectId, location, backendReqBoby, backendId) {
    const res = await exports.client.post(`projects/${projectId}/locations/${location}/backends`, {
        ...backendReqBoby,
        labels: {
            ...backendReqBoby.labels,
            ...deploymentTool.labels(),
        },
    }, { queryParams: { backendId } });
    return res.body;
}
async function getBackend(projectId, location, backendId) {
    const name = `projects/${projectId}/locations/${location}/backends/${backendId}`;
    const res = await exports.client.get(name);
    return res.body;
}
async function getTraffic(projectId, location, backendId) {
    const name = `projects/${projectId}/locations/${location}/backends/${backendId}/traffic`;
    const res = await exports.client.get(name);
    return res.body;
}
async function listDomains(projectId, location, backendId) {
    const name = `projects/${projectId}/locations/${location}/backends/${backendId}/domains`;
    const res = await exports.client.get(name, { queryParams: { pageSize: 100 } });
    return Array.isArray(res.body.domains) ? res.body.domains : [];
}
async function listBackends(projectId, location) {
    const name = `projects/${projectId}/locations/${location}/backends`;
    let pageToken;
    const res = {
        backends: [],
        unreachable: [],
    };
    do {
        const queryParams = pageToken ? { pageToken } : {};
        const int = await exports.client.get(name, { queryParams });
        res.backends.push(...(int.body.backends || []));
        res.unreachable?.push(...(int.body.unreachable || []));
        pageToken = int.body.nextPageToken;
    } while (pageToken);
    res.unreachable = [...new Set(res.unreachable)];
    return res;
}
async function deleteBackend(projectId, location, backendId) {
    const name = `projects/${projectId}/locations/${location}/backends/${backendId}`;
    const res = await exports.client.delete(name, { queryParams: { force: "true" } });
    return res.body;
}
async function getBuild(projectId, location, backendId, buildId) {
    const name = `projects/${projectId}/locations/${location}/backends/${backendId}/builds/${buildId}`;
    const res = await exports.client.get(name);
    return res.body;
}
async function listBuilds(projectId, location, backendId) {
    const name = `projects/${projectId}/locations/${location}/backends/${backendId}/builds`;
    let pageToken;
    const res = {
        builds: [],
        unreachable: [],
    };
    do {
        const queryParams = pageToken ? { pageToken } : {};
        const int = await exports.client.get(name, { queryParams });
        res.builds.push(...(int.body.builds || []));
        res.unreachable?.push(...(int.body.unreachable || []));
        pageToken = int.body.nextPageToken;
    } while (pageToken);
    res.unreachable = [...new Set(res.unreachable)];
    return res;
}
async function createBuild(projectId, location, backendId, buildId, buildInput) {
    const res = await exports.client.post(`projects/${projectId}/locations/${location}/backends/${backendId}/builds`, {
        ...buildInput,
        labels: {
            ...buildInput.labels,
            ...deploymentTool.labels(),
        },
    }, { queryParams: { buildId } });
    return res.body;
}
async function createRollout(projectId, location, backendId, rolloutId, rollout, validateOnly = false) {
    const res = await exports.client.post(`projects/${projectId}/locations/${location}/backends/${backendId}/rollouts`, {
        ...rollout,
        labels: {
            ...rollout.labels,
            ...deploymentTool.labels(),
        },
    }, { queryParams: { rolloutId, validateOnly: validateOnly ? "true" : "false" } });
    return res.body;
}
async function listRollouts(projectId, location, backendId) {
    const name = `projects/${projectId}/locations/${location}/backends/${backendId}/rollouts`;
    let pageToken = undefined;
    const res = {
        rollouts: [],
        unreachable: [],
    };
    do {
        const queryParams = pageToken ? { pageToken } : {};
        const int = await exports.client.get(name, { queryParams });
        res.rollouts.splice(res.rollouts.length, 0, ...(int.body.rollouts || []));
        res.unreachable.splice(res.unreachable.length, 0, ...(int.body.unreachable || []));
        pageToken = int.body.nextPageToken;
    } while (pageToken);
    res.unreachable = [...new Set(res.unreachable)];
    return res;
}
async function updateTraffic(projectId, location, backendId, traffic) {
    const fieldMasks = proto.fieldMasks(traffic, "rolloutPolicy");
    const queryParams = {
        updateMask: fieldMasks.join(","),
    };
    const name = `projects/${projectId}/locations/${location}/backends/${backendId}/traffic`;
    const res = await exports.client.patch(name, { ...traffic, name }, {
        queryParams,
    });
    return res.body;
}
async function listLocations(projectId) {
    let pageToken = undefined;
    let locations = [];
    do {
        const queryParams = pageToken ? { pageToken } : {};
        const response = await exports.client.get(`projects/${projectId}/locations`, {
            queryParams,
        });
        if (response.body.locations && response.body.locations.length > 0) {
            locations = locations.concat(response.body.locations);
        }
        pageToken = response.body.nextPageToken;
    } while (pageToken);
    return locations;
}
async function listSupportedRuntimes(projectId, location) {
    const name = `projects/${projectId}/locations/${location}/supportedRuntimes`;
    const res = await exports.client.get(name);
    return res.body.supportedRuntimes || [];
}
async function ensureApiEnabled(options) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    return await (0, ensureApiEnabled_1.ensure)(projectId, (0, api_1.apphostingOrigin)(), "app hosting", true);
}
async function getNextRolloutId(projectId, location, backendId, counter) {
    const date = new Date();
    const year = date.getUTCFullYear();
    const month = String(date.getUTCMonth() + 1).padStart(2, "0");
    const day = String(date.getUTCDate()).padStart(2, "0");
    if (counter) {
        return `build-${year}-${month}-${day}-${String(counter).padStart(3, "0")}`;
    }
    const rolloutsPromise = exports.listRollouts(projectId, location, backendId);
    const buildsPromise = exports.listBuilds(projectId, location, backendId);
    const [rollouts, builds] = await Promise.all([rolloutsPromise, buildsPromise]);
    if (builds.unreachable?.includes(location) || rollouts.unreachable?.includes(location)) {
        throw new error_1.FirebaseError(`Firebase App Hosting is currently unreachable in location ${location}`);
    }
    const test = new RegExp(`projects/${projectId}/locations/${location}/backends/${backendId}/(rollouts|builds)/build-${year}-${month}-${day}-(\\d+)`);
    const highestId = (input) => {
        let highest = 0;
        for (const i of input) {
            const match = i.name.match(test);
            if (!match) {
                continue;
            }
            const n = Number(match[2]);
            if (n > highest) {
                highest = n;
            }
        }
        return highest;
    };
    const highest = Math.max(highestId(builds.builds), highestId(rollouts.rollouts));
    return `build-${year}-${month}-${day}-${String(highest + 1).padStart(3, "0")}`;
}
