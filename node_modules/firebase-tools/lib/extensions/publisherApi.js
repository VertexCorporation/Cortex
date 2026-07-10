"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getPublisherProfile = getPublisherProfile;
exports.registerPublisherProfile = registerPublisherProfile;
exports.deprecateExtensionVersion = deprecateExtensionVersion;
exports.undeprecateExtensionVersion = undeprecateExtensionVersion;
exports.createExtensionVersionFromLocalSource = createExtensionVersionFromLocalSource;
exports.createExtensionVersionFromGitHubSource = createExtensionVersionFromGitHubSource;
exports.getExtensionVersion = getExtensionVersion;
exports.listExtensions = listExtensions;
exports.listExtensionVersions = listExtensionVersions;
exports.getExtension = getExtension;
const clc = require("colorette");
const operationPoller = require("../operation-poller");
const refs = require("./refs");
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const error_1 = require("../error");
const extensionsApi_1 = require("./extensionsApi");
const PUBLISHER_API_VERSION = "v1beta";
const PAGE_SIZE_MAX = 100;
const extensionsPublisherApiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.extensionsPublisherOrigin)(),
    apiVersion: PUBLISHER_API_VERSION,
});
async function getPublisherProfile(projectId, publisherId) {
    const res = await extensionsPublisherApiClient.get(`/projects/${projectId}/publisherProfile`, {
        queryParams: publisherId === undefined
            ? undefined
            : {
                publisherId,
            },
    });
    return res.body;
}
async function registerPublisherProfile(projectId, publisherId) {
    const res = await extensionsPublisherApiClient.patch(`/projects/${projectId}/publisherProfile`, {
        publisherId,
        displayName: publisherId,
    }, {
        queryParams: {
            updateMask: "publisher_id,display_name",
        },
    });
    return res.body;
}
async function deprecateExtensionVersion(extensionRef, deprecationMessage) {
    const ref = refs.parse(extensionRef);
    try {
        const res = await extensionsPublisherApiClient.post(`/${refs.toExtensionVersionName(ref)}:deprecate`, {
            deprecationMessage,
        });
        return res.body;
    }
    catch (err) {
        if (err.status === 403) {
            throw new error_1.FirebaseError(`You are not the owner of extension '${clc.bold(extensionRef)}' and don’t have the correct permissions to deprecate this extension version.` + err, { status: err.status });
        }
        else if (err.status === 404) {
            throw new error_1.FirebaseError(`Extension version ${clc.bold(extensionRef)} was not found.`);
        }
        else if (err instanceof error_1.FirebaseError) {
            throw err;
        }
        throw new error_1.FirebaseError(`Error occurred deprecating extension version '${extensionRef}': ${err}`, {
            status: err.status,
        });
    }
}
async function undeprecateExtensionVersion(extensionRef) {
    const ref = refs.parse(extensionRef);
    try {
        const res = await extensionsPublisherApiClient.post(`/${refs.toExtensionVersionName(ref)}:undeprecate`);
        return res.body;
    }
    catch (err) {
        if (err.status === 403) {
            throw new error_1.FirebaseError(`You are not the owner of extension '${clc.bold(extensionRef)}' and don’t have the correct permissions to undeprecate this extension version.`, { status: err.status });
        }
        else if (err.status === 404) {
            throw new error_1.FirebaseError(`Extension version ${clc.bold(extensionRef)} was not found.`);
        }
        else if (err instanceof error_1.FirebaseError) {
            throw err;
        }
        throw new error_1.FirebaseError(`Error occurred undeprecating extension version '${extensionRef}': ${err}`, {
            status: err.status,
        });
    }
}
async function createExtensionVersionFromLocalSource(args) {
    const ref = refs.parse(args.extensionVersionRef);
    if (!ref.version) {
        throw new error_1.FirebaseError(`Extension version ref "${args.extensionVersionRef}" must supply a version.`);
    }
    const uploadRes = await extensionsPublisherApiClient.post(`/${refs.toExtensionName(ref)}/versions:createFromSource`, {
        versionId: ref.version,
        extensionRoot: args.extensionRoot ?? "/",
        remoteArchiveSource: {
            packageUri: args.packageUri,
        },
    });
    const pollRes = await operationPoller.pollOperation({
        apiOrigin: (0, api_1.extensionsPublisherOrigin)(),
        apiVersion: PUBLISHER_API_VERSION,
        operationResourceName: uploadRes.body.name,
        masterTimeout: 600000,
    });
    return pollRes;
}
async function createExtensionVersionFromGitHubSource(args) {
    const ref = refs.parse(args.extensionVersionRef);
    if (!ref.version) {
        throw new error_1.FirebaseError(`Extension version ref "${args.extensionVersionRef}" must supply a version.`);
    }
    const uploadRes = await extensionsPublisherApiClient.post(`/${refs.toExtensionName(ref)}/versions:createFromSource`, {
        versionId: ref.version,
        extensionRoot: args.extensionRoot || "/",
        githubRepositorySource: {
            uri: args.repoUri,
            sourceRef: args.sourceRef,
        },
    });
    const pollRes = await operationPoller.pollOperation({
        apiOrigin: (0, api_1.extensionsPublisherOrigin)(),
        apiVersion: PUBLISHER_API_VERSION,
        operationResourceName: uploadRes.body.name,
        masterTimeout: 600000,
    });
    return pollRes;
}
async function getExtensionVersion(extensionVersionRef) {
    const ref = refs.parse(extensionVersionRef);
    if (!ref.version) {
        throw new error_1.FirebaseError(`ExtensionVersion ref "${extensionVersionRef}" must supply a version.`);
    }
    try {
        const res = await extensionsPublisherApiClient.get(`/${refs.toExtensionVersionName(ref)}`);
        if (res.body.spec) {
            (0, extensionsApi_1.populateSpec)(res.body.spec);
        }
        return res.body;
    }
    catch (err) {
        if (err.status === 404) {
            throw (0, extensionsApi_1.refNotFoundError)(ref);
        }
        else if (err instanceof error_1.FirebaseError) {
            throw err;
        }
        throw new error_1.FirebaseError(`Failed to query the extension version '${clc.bold(extensionVersionRef)}': ${err}`);
    }
}
async function listExtensions(publisherId) {
    const extensions = [];
    const getNextPage = async (pageToken = "") => {
        const res = await extensionsPublisherApiClient.get(`/publishers/${publisherId}/extensions`, {
            queryParams: {
                pageSize: PAGE_SIZE_MAX,
                pageToken,
            },
        });
        if (Array.isArray(res.body.extensions)) {
            extensions.push(...res.body.extensions);
        }
        if (res.body.nextPageToken) {
            await getNextPage(res.body.nextPageToken);
        }
    };
    await getNextPage();
    return extensions;
}
async function listExtensionVersions(ref, filter = "", showPrereleases = false) {
    const { publisherId, extensionId } = refs.parse(ref);
    const extensionVersions = [];
    const getNextPage = async (pageToken = "") => {
        const res = await extensionsPublisherApiClient.get(`/publishers/${publisherId}/extensions/${extensionId}/versions`, {
            queryParams: {
                filter,
                showPrereleases: String(showPrereleases),
                pageSize: PAGE_SIZE_MAX,
                pageToken,
            },
        });
        if (Array.isArray(res.body.extensionVersions)) {
            extensionVersions.push(...res.body.extensionVersions);
        }
        if (res.body.nextPageToken) {
            await getNextPage(res.body.nextPageToken);
        }
    };
    await getNextPage();
    return extensionVersions;
}
async function getExtension(extensionRef) {
    const ref = refs.parse(extensionRef);
    try {
        const res = await extensionsPublisherApiClient.get(`/${refs.toExtensionName(ref)}`);
        return res.body;
    }
    catch (err) {
        if (err.status === 404) {
            throw (0, extensionsApi_1.refNotFoundError)(ref);
        }
        else if (err instanceof error_1.FirebaseError) {
            throw err;
        }
        throw new error_1.FirebaseError(`Failed to query the extension '${clc.bold(extensionRef)}': ${err}`, {
            status: err.status,
        });
    }
}
