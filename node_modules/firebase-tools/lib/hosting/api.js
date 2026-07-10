"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SiteType = void 0;
exports.normalizeName = normalizeName;
exports.getChannel = getChannel;
exports.listChannels = listChannels;
exports.createChannel = createChannel;
exports.updateChannelTtl = updateChannelTtl;
exports.deleteChannel = deleteChannel;
exports.createVersion = createVersion;
exports.updateVersion = updateVersion;
exports.listVersions = listVersions;
exports.cloneVersion = cloneVersion;
exports.createRelease = createRelease;
exports.listSites = listSites;
exports.listDemoSites = listDemoSites;
exports.getSite = getSite;
exports.createSite = createSite;
exports.updateSite = updateSite;
exports.deleteSite = deleteSite;
exports.addAuthDomains = addAuthDomains;
exports.removeAuthDomain = removeAuthDomain;
exports.getCleanDomains = getCleanDomains;
exports.cleanAuthState = cleanAuthState;
exports.getSiteDomains = getSiteDomains;
exports.getAllSiteDomains = getAllSiteDomains;
exports.getDeploymentDomain = getDeploymentDomain;
const error_1 = require("../error");
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const operationPoller = require("../operation-poller");
const expireUtils_1 = require("../hosting/expireUtils");
const auth_1 = require("../gcp/auth");
const proto = require("../gcp/proto");
const utils_1 = require("../utils");
const constants_1 = require("../emulator/constants");
const ONE_WEEK_MS = 604800000;
var ReleaseType;
(function (ReleaseType) {
    ReleaseType["TYPE_UNSPECIFIED"] = "TYPE_UNSPECIFIED";
    ReleaseType["DEPLOY"] = "DEPLOY";
    ReleaseType["ROLLBACK"] = "ROLLBACK";
    ReleaseType["SITE_DISABLE"] = "SITE_DISABLE";
})(ReleaseType || (ReleaseType = {}));
var SiteType;
(function (SiteType) {
    SiteType["TYPE_UNSPECIFIED"] = "TYPE_UNSPECIFIED";
    SiteType["DEFAULT_SITE"] = "DEFAULT_SITE";
    SiteType["USER_SITE"] = "USER_SITE";
})(SiteType || (exports.SiteType = SiteType = {}));
function normalizeName(s) {
    return s.replace(/[/:_#]/g, "-");
}
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.hostingApiOrigin)(),
    apiVersion: "v1beta1",
    auth: true,
});
async function getChannel(project = "-", site, channelId) {
    try {
        const res = await apiClient.get(`/projects/${project}/sites/${site}/channels/${channelId}`);
        return res.body;
    }
    catch (e) {
        if (e instanceof error_1.FirebaseError && e.status === 404) {
            return null;
        }
        throw e;
    }
}
async function listChannels(project = "-", site) {
    const channels = [];
    let nextPageToken = "";
    for (;;) {
        try {
            const res = await apiClient.get(`/projects/${project}/sites/${site}/channels`, { queryParams: { pageToken: nextPageToken, pageSize: 10 } });
            channels.push(...(res.body.channels ?? []));
            nextPageToken = res.body.nextPageToken || "";
            if (!nextPageToken) {
                return channels;
            }
        }
        catch (e) {
            if (e instanceof error_1.FirebaseError && e.status === 404) {
                throw new error_1.FirebaseError(`could not find channels for site "${site}"`, {
                    original: e,
                });
            }
            throw e;
        }
    }
}
async function createChannel(project = "-", site, channelId, ttlMillis = expireUtils_1.DEFAULT_DURATION) {
    const res = await apiClient.post(`/projects/${project}/sites/${site}/channels?channelId=${channelId}`, { ttl: `${ttlMillis / 1000}s` });
    return res.body;
}
async function updateChannelTtl(project = "-", site, channelId, ttlMillis = ONE_WEEK_MS) {
    const res = await apiClient.patch(`/projects/${project}/sites/${site}/channels/${channelId}`, { ttl: `${ttlMillis / 1000}s` }, { queryParams: { updateMask: "ttl" } });
    return res.body;
}
async function deleteChannel(project = "-", site, channelId) {
    await apiClient.delete(`/projects/${project}/sites/${site}/channels/${channelId}`);
}
async function createVersion(siteId, version) {
    const res = await apiClient.post(`projects/-/sites/${siteId}/versions`, version);
    return res.body.name;
}
async function updateVersion(site, versionId, version) {
    const res = await apiClient.patch(`projects/-/sites/${site}/versions/${versionId}`, version, {
        queryParams: {
            updateMask: proto.fieldMasks(version, "labels", "config").join(","),
        },
    });
    return res.body;
}
async function listVersions(site) {
    let pageToken = undefined;
    const versions = [];
    do {
        const queryParams = {};
        if (pageToken) {
            queryParams.pageToken = pageToken;
        }
        const res = await apiClient.get(`projects/-/sites/${site}/versions`, {
            queryParams,
        });
        versions.push(...(res.body.versions ?? []));
        pageToken = res.body.nextPageToken;
    } while (pageToken);
    return versions;
}
async function cloneVersion(site, versionName, finalize = false) {
    const res = await apiClient.post(`/projects/-/sites/${site}/versions:clone`, {
        sourceVersion: versionName,
        finalize,
    });
    const { name: operationName } = res.body;
    const pollRes = await operationPoller.pollOperation({
        apiOrigin: (0, api_1.hostingApiOrigin)(),
        apiVersion: "v1beta1",
        operationResourceName: operationName,
        masterTimeout: 600000,
    });
    return pollRes;
}
async function createRelease(site, channel, version, partialRelease) {
    const res = await apiClient.post(`/projects/-/sites/${site}/channels/${channel}/releases`, partialRelease, { queryParams: { versionName: version } });
    return res.body;
}
async function listSites(project) {
    const sites = [];
    let nextPageToken = "";
    for (;;) {
        try {
            const res = await apiClient.get(`/projects/${project}/sites`, { queryParams: { pageToken: nextPageToken, pageSize: 10 } });
            sites.push(...(res.body.sites ?? []));
            nextPageToken = res.body.nextPageToken || "";
            if (!nextPageToken) {
                return sites;
            }
        }
        catch (e) {
            if (e instanceof error_1.FirebaseError && e.status === 404) {
                throw new error_1.FirebaseError(`could not find sites for project "${project}"`, {
                    original: e,
                });
            }
            throw e;
        }
    }
}
function listDemoSites(projectId) {
    return [
        {
            name: `projects/${projectId}/sites/${projectId}`,
            defaultUrl: `https://${projectId}.firebaseapp.com`,
            appId: "fake-app-id",
            labels: {},
        },
    ];
}
async function getSite(project, site) {
    try {
        const res = await apiClient.get(`/projects/${project}/sites/${site}`);
        return res.body;
    }
    catch (e) {
        if (e instanceof error_1.FirebaseError && e.status === 404) {
            throw new error_1.FirebaseError(`could not find site "${site}" for project "${project}"`, {
                original: e,
                status: e.status,
            });
        }
        throw e;
    }
}
async function createSite(project, site, appId = "", validateOnly = false) {
    const queryParams = { siteId: site };
    if (validateOnly) {
        queryParams.validateOnly = "true";
    }
    const res = await apiClient.post(`/projects/${project}/sites`, { appId: appId }, { queryParams });
    return res.body;
}
async function updateSite(project, site, fields) {
    const res = await apiClient.patch(`/projects/${project}/sites/${site.name}`, site, {
        queryParams: { updateMask: fields.join(",") },
    });
    return res.body;
}
async function deleteSite(project, site) {
    await apiClient.delete(`/projects/${project}/sites/${site}`);
}
async function addAuthDomains(project, urls) {
    const domains = await (0, auth_1.getAuthDomains)(project);
    const authDomains = domains || [];
    for (const url of urls) {
        const domain = url.replace("https://", "");
        if (authDomains.includes(domain)) {
            continue;
        }
        authDomains.push(domain);
    }
    return await (0, auth_1.updateAuthDomains)(project, authDomains);
}
async function removeAuthDomain(project, url) {
    const domains = await (0, auth_1.getAuthDomains)(project);
    if (!domains.length) {
        return domains;
    }
    const targetDomain = url.replace("https://", "");
    const authDomains = domains.filter((domain) => domain !== targetDomain);
    return (0, auth_1.updateAuthDomains)(project, authDomains);
}
async function getCleanDomains(project, site) {
    const channels = await listChannels(project, site);
    const channelMap = channels
        .map((channel) => channel.url.replace("https://", ""))
        .reduce((acc, current) => {
        acc[current] = true;
        return acc;
    }, {});
    const siteMatch = new RegExp(`^${site}--`, "i");
    const firebaseAppMatch = new RegExp(/firebaseapp.com$/);
    const domains = await (0, auth_1.getAuthDomains)(project);
    const authDomains = [];
    domains.forEach((domain) => {
        const endsWithFirebaseApp = firebaseAppMatch.test(domain);
        if (endsWithFirebaseApp) {
            authDomains.push(domain);
            return;
        }
        const domainWithNoChannel = siteMatch.test(domain) && !channelMap[domain];
        if (domainWithNoChannel) {
            return;
        }
        authDomains.push(domain);
    });
    return authDomains;
}
async function cleanAuthState(project, sites) {
    const siteDomainMap = new Map();
    for (const site of sites) {
        const authDomains = await getCleanDomains(project, site);
        const updatedDomains = await (0, auth_1.updateAuthDomains)(project, authDomains);
        siteDomainMap.set(site, updatedDomains);
    }
    return siteDomainMap;
}
async function getSiteDomains(project, site) {
    try {
        const res = await apiClient.get(`/projects/${project}/sites/${site}/domains`);
        return res.body.domains ?? [];
    }
    catch (e) {
        if (e instanceof error_1.FirebaseError && e.status === 404) {
            throw new error_1.FirebaseError(`could not find site "${site}" for project "${project}"`, {
                original: e,
            });
        }
        throw e;
    }
}
async function getAllSiteDomains(projectId, siteId) {
    const [hostingDomains, defaultDomain] = await Promise.all([
        getSiteDomains(projectId, siteId),
        getSite(projectId, siteId),
    ]);
    const defaultDomainWithoutHttp = defaultDomain.defaultUrl.replace(/^https?:\/\//, "");
    const allSiteDomains = new Set([
        ...hostingDomains.map(({ domainName }) => domainName),
        defaultDomainWithoutHttp,
        `${siteId}.web.app`,
        `${siteId}.firebaseapp.com`,
    ]);
    return Array.from(allSiteDomains);
}
async function getDeploymentDomain(projectId, siteId, hostingChannel) {
    if (constants_1.Constants.isDemoProject(projectId)) {
        return null;
    }
    if (hostingChannel) {
        const channel = await getChannel(projectId, siteId, hostingChannel);
        return channel && (0, utils_1.getHostnameFromUrl)(channel?.url);
    }
    const site = await getSite(projectId, siteId).catch((e) => {
        if (e instanceof error_1.FirebaseError &&
            e.original instanceof error_1.FirebaseError &&
            e.original.status === 404) {
            return null;
        }
        throw e;
    });
    return site && (0, utils_1.getHostnameFromUrl)(site?.defaultUrl);
}
