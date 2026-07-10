"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createInstance = createInstance;
exports.deleteInstance = deleteInstance;
exports.getInstance = getInstance;
exports.listInstances = listInstances;
exports.configureInstance = configureInstance;
exports.updateInstance = updateInstance;
exports.updateInstanceFromRegistry = updateInstanceFromRegistry;
exports.populateSpec = populateSpec;
exports.createSource = createSource;
exports.getSource = getSource;
exports.getExtensionVersion = getExtensionVersion;
exports.listExtensions = listExtensions;
exports.listExtensionVersions = listExtensionVersions;
exports.getExtension = getExtension;
exports.refNotFoundError = refNotFoundError;
const yaml = require("yaml");
const clc = require("colorette");
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
const error_1 = require("../error");
const logger_1 = require("../logger");
const operationPoller = require("../operation-poller");
const refs = require("./refs");
const types_1 = require("./types");
const EXTENSIONS_API_VERSION = "v1beta";
const PAGE_SIZE_MAX = 100;
const extensionsApiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.extensionsOrigin)(),
    apiVersion: EXTENSIONS_API_VERSION,
});
async function createInstanceHelper(projectId, instanceId, config, labels, validateOnly = false) {
    const createRes = await extensionsApiClient.post(`/projects/${projectId}/instances/`, {
        name: `projects/${projectId}/instances/${instanceId}`,
        config,
        labels,
    }, {
        queryParams: {
            validateOnly: validateOnly ? "true" : "false",
        },
    });
    if (validateOnly) {
        return createRes.body;
    }
    const pollRes = await operationPoller.pollOperation({
        apiOrigin: (0, api_1.extensionsOrigin)(),
        apiVersion: EXTENSIONS_API_VERSION,
        operationResourceName: createRes.body.name,
        masterTimeout: 3600000,
    });
    return pollRes;
}
async function createInstance(args) {
    const config = {
        params: args.params,
        systemParams: args.systemParams ?? {},
        allowedEventTypes: args.allowedEventTypes,
        eventarcChannel: args.eventarcChannel,
    };
    if (args.extensionSource && args.extensionVersionRef) {
        throw new error_1.FirebaseError("ExtensionSource and ExtensionVersion both provided, but only one should be.");
    }
    else if (args.extensionSource) {
        config.source = { name: args.extensionSource?.name };
    }
    else if (args.extensionVersionRef) {
        const ref = refs.parse(args.extensionVersionRef);
        config.extensionRef = refs.toExtensionRef(ref);
        config.extensionVersion = ref.version ?? "";
    }
    else {
        throw new error_1.FirebaseError("No ExtensionVersion or ExtensionSource provided but one is required.");
    }
    if (args.allowedEventTypes) {
        config.allowedEventTypes = args.allowedEventTypes;
    }
    if (args.eventarcChannel) {
        config.eventarcChannel = args.eventarcChannel;
    }
    return await createInstanceHelper(args.projectId, args.instanceId, config, args.labels, args.validateOnly);
}
async function deleteInstance(projectId, instanceId) {
    const deleteRes = await extensionsApiClient.delete(`/projects/${projectId}/instances/${instanceId}`);
    const pollRes = await operationPoller.pollOperation({
        apiOrigin: (0, api_1.extensionsOrigin)(),
        apiVersion: EXTENSIONS_API_VERSION,
        operationResourceName: deleteRes.body.name,
        masterTimeout: 600000,
    });
    return pollRes;
}
async function getInstance(projectId, instanceId) {
    try {
        const res = await extensionsApiClient.get(`/projects/${projectId}/instances/${instanceId}`);
        if ((0, types_1.isExtensionInstance)(res.body)) {
            return res.body;
        }
    }
    catch (err) {
        if ((0, error_1.getErrStatus)(err) === 404) {
            throw new error_1.FirebaseError(`Extension instance '${clc.bold(instanceId)}' not found in project '${clc.bold(projectId)}'.`, { status: 404 });
        }
        throw err;
    }
}
async function listInstances(projectId) {
    const instances = [];
    const getNextPage = async (pageToken = "") => {
        const res = await extensionsApiClient.get(`/projects/${projectId}/instances`, {
            queryParams: {
                pageSize: PAGE_SIZE_MAX,
                pageToken,
            },
        });
        if (Array.isArray(res.body.instances)) {
            instances.push(...res.body.instances);
        }
        if (res.body.nextPageToken) {
            await getNextPage(res.body.nextPageToken);
        }
    };
    await getNextPage();
    return instances;
}
async function configureInstance(args) {
    const reqBody = {
        projectId: args.projectId,
        instanceId: args.instanceId,
        updateMask: "config.params",
        validateOnly: args.validateOnly ?? false,
        data: {
            config: {
                params: args.params,
            },
        },
    };
    if (args.canEmitEvents) {
        if (args.allowedEventTypes === undefined || args.eventarcChannel === undefined) {
            throw new error_1.FirebaseError(`This instance is configured to emit events, but either allowed event types or eventarc channel is undefined.`);
        }
        reqBody.data.config.allowedEventTypes = args.allowedEventTypes;
        reqBody.data.config.eventarcChannel = args.eventarcChannel;
    }
    reqBody.updateMask += ",config.allowed_event_types,config.eventarc_channel";
    if (args.systemParams) {
        reqBody.data.config.systemParams = args.systemParams;
        reqBody.updateMask += ",config.system_params";
    }
    return patchInstance(reqBody);
}
async function updateInstance(args) {
    const body = {
        config: {
            source: { name: args.extensionSource.name },
        },
    };
    let updateMask = "config.source.name";
    if (args.params) {
        body.config.params = args.params;
        updateMask += ",config.params";
    }
    if (args.systemParams) {
        body.config.systemParams = args.systemParams;
        updateMask += ",config.system_params";
    }
    if (args.canEmitEvents) {
        if (args.allowedEventTypes === undefined || args.eventarcChannel === undefined) {
            throw new error_1.FirebaseError(`This instance is configured to emit events, but either allowed event types or eventarc channel is undefined.`);
        }
        body.config.allowedEventTypes = args.allowedEventTypes;
        body.config.eventarcChannel = args.eventarcChannel;
    }
    updateMask += ",config.allowed_event_types,config.eventarc_channel";
    return patchInstance({
        projectId: args.projectId,
        instanceId: args.instanceId,
        updateMask,
        validateOnly: args.validateOnly ?? false,
        data: body,
    });
}
async function updateInstanceFromRegistry(args) {
    const ref = refs.parse(args.extRef);
    const body = {
        config: {
            extensionRef: refs.toExtensionRef(ref),
            extensionVersion: ref.version,
        },
    };
    let updateMask = "config.extension_ref,config.extension_version";
    if (args.params) {
        body.config.params = args.params;
        updateMask += ",config.params";
    }
    if (args.systemParams) {
        body.config.systemParams = args.systemParams;
        updateMask += ",config.system_params";
    }
    if (args.canEmitEvents) {
        if (args.allowedEventTypes === undefined || args.eventarcChannel === undefined) {
            throw new error_1.FirebaseError(`This instance is configured to emit events, but either allowed event types or eventarc channel is undefined.`);
        }
        body.config.allowedEventTypes = args.allowedEventTypes;
        body.config.eventarcChannel = args.eventarcChannel;
    }
    updateMask += ",config.allowed_event_types,config.eventarc_channel";
    return patchInstance({
        projectId: args.projectId,
        instanceId: args.instanceId,
        updateMask,
        validateOnly: args.validateOnly ?? false,
        data: body,
    });
}
async function patchInstance(args) {
    const updateRes = await extensionsApiClient.patch(`/projects/${args.projectId}/instances/${args.instanceId}`, args.data, {
        queryParams: {
            updateMask: args.updateMask,
            validateOnly: args.validateOnly ? "true" : "false",
        },
    });
    if (args.validateOnly) {
        return updateRes;
    }
    const pollRes = await operationPoller.pollOperation({
        apiOrigin: (0, api_1.extensionsOrigin)(),
        apiVersion: EXTENSIONS_API_VERSION,
        operationResourceName: updateRes.body.name,
        masterTimeout: 600000,
    });
    return pollRes;
}
function populateSpec(spec) {
    if (spec) {
        for (const r of spec.resources) {
            try {
                if (r.propertiesYaml) {
                    r.properties = yaml.parse(r.propertiesYaml);
                }
            }
            catch (err) {
                logger_1.logger.debug(`[ext] failed to parse resource properties yaml: ${(0, error_1.getErrMsg)(err)}`);
            }
        }
        spec.params = spec.params ?? [];
        spec.systemParams = spec.systemParams ?? [];
    }
}
async function createSource(projectId, packageUri, extensionRoot) {
    const createRes = await extensionsApiClient.post(`/projects/${projectId}/sources/`, {
        packageUri,
        extensionRoot,
    });
    const pollRes = await operationPoller.pollOperation({
        apiOrigin: (0, api_1.extensionsOrigin)(),
        apiVersion: EXTENSIONS_API_VERSION,
        operationResourceName: createRes.body.name,
        masterTimeout: 600000,
    });
    if (pollRes.spec) {
        populateSpec(pollRes.spec);
    }
    return pollRes;
}
async function getSource(sourceName) {
    const res = await extensionsApiClient.get(`/${sourceName}`);
    if (res.body.spec) {
        populateSpec(res.body.spec);
    }
    return res.body;
}
async function getExtensionVersion(extensionVersionRef) {
    const ref = refs.parse(extensionVersionRef);
    if (!ref.version) {
        throw new error_1.FirebaseError(`ExtensionVersion ref "${extensionVersionRef}" must supply a version.`);
    }
    try {
        const res = await extensionsApiClient.get(`/${refs.toExtensionVersionName(ref)}`);
        if (res.body.spec) {
            populateSpec(res.body.spec);
        }
        return res.body;
    }
    catch (err) {
        if ((0, error_1.getErrStatus)(err) === 404) {
            throw refNotFoundError(ref);
        }
        else if (err instanceof error_1.FirebaseError) {
            throw err;
        }
        throw new error_1.FirebaseError(`Failed to query the extension version '${clc.bold(extensionVersionRef)}': ${(0, error_1.getErrMsg)(err)}`);
    }
}
async function listExtensions(publisherId) {
    const extensions = [];
    const getNextPage = async (pageToken = "") => {
        const res = await extensionsApiClient.get(`/publishers/${publisherId}/extensions`, {
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
        const res = await extensionsApiClient.get(`/publishers/${publisherId}/extensions/${extensionId}/versions`, {
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
        const res = await extensionsApiClient.get(`/${refs.toExtensionName(ref)}`);
        return res.body;
    }
    catch (err) {
        if ((0, error_1.getErrStatus)(err) === 404) {
            throw refNotFoundError(ref);
        }
        else if (err instanceof error_1.FirebaseError) {
            throw err;
        }
        throw new error_1.FirebaseError(`Failed to query the extension '${clc.bold(extensionRef)}': ${(0, error_1.getErrMsg)(err)}`, {
            status: (0, error_1.getErrStatus)(err),
        });
    }
}
function refNotFoundError(ref) {
    return new error_1.FirebaseError(`The extension reference '${clc.bold(ref.version ? refs.toExtensionVersionRef(ref) : refs.toExtensionRef(ref))}' doesn't exist. This could happen for two reasons:\n` +
        `  -The publisher ID '${clc.bold(ref.publisherId)}' doesn't exist or could be misspelled\n` +
        `  -The name of the ${ref.version ? "extension version" : "extension"} '${clc.bold(ref.version ? `${ref.extensionId}@${ref.version}` : ref.extensionId)}' doesn't exist or could be misspelled\n\n` +
        `Please correct the extension reference and try again. If you meant to reference an extension from a local source, please provide a relative path prefixed with '${clc.bold("./")}', '${clc.bold("../")}', or '${clc.bold("~/")}'.}`, { status: 404 });
}
