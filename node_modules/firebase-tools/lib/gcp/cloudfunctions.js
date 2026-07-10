"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.API_VERSION = void 0;
exports.captureRuntimeValidationError = captureRuntimeValidationError;
exports.generateUploadUrl = generateUploadUrl;
exports.createFunction = createFunction;
exports.setIamPolicy = setIamPolicy;
exports.getIamPolicy = getIamPolicy;
exports.setInvokerCreate = setInvokerCreate;
exports.setInvokerUpdate = setInvokerUpdate;
exports.updateFunction = updateFunction;
exports.deleteFunction = deleteFunction;
exports.listAllFunctions = listAllFunctions;
exports.endpointFromFunction = endpointFromFunction;
exports.functionFromEndpoint = functionFromEndpoint;
const clc = require("colorette");
const error_1 = require("../error");
const logger_1 = require("../logger");
const backend = require("../deploy/functions/backend");
const utils = require("../utils");
const proto = require("./proto");
const supported = require("../deploy/functions/runtimes/supported");
const projectConfig = require("../functions/projectConfig");
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
const constants_1 = require("../functions/constants");
exports.API_VERSION = "v1";
const client = new apiv2_1.Client({ urlPrefix: (0, api_1.functionsOrigin)(), apiVersion: exports.API_VERSION });
function captureRuntimeValidationError(errMessage) {
    const regex = /message: "((?:\\.|[^"\\])*)"/;
    const match = errMessage.match(regex);
    if (match && match[1]) {
        const capturedMessage = match[1].replace(/\\"/g, '"');
        return capturedMessage;
    }
    return "invalid runtime detected, please see https://cloud.google.com/functions/docs/runtime-support for the latest supported runtimes";
}
function functionsOpLogReject(funcName, type, err) {
    if ((err?.message).includes("Runtime validation errors")) {
        const capturedMessage = captureRuntimeValidationError(err.message);
        utils.logWarning(clc.bold(clc.yellow("functions:")) + " " + capturedMessage + " for function " + funcName);
    }
    if (err?.context?.response?.statusCode === 429) {
        utils.logWarning(`${clc.bold(clc.yellow("functions:"))} got "Quota Exceeded" error while trying to ${type} ${funcName}. Waiting to retry...`);
    }
    else {
        utils.logWarning(clc.bold(clc.yellow("functions:")) + " failed to " + type + " function " + funcName);
    }
    throw new error_1.FirebaseError(`Failed to ${type} function ${funcName}`, {
        original: err,
        status: err?.context?.response?.statusCode,
        context: { function: funcName },
    });
}
async function generateUploadUrl(projectId, location) {
    const parent = "projects/" + projectId + "/locations/" + location;
    const endpoint = `/${parent}/functions:generateUploadUrl`;
    try {
        const res = await client.post(endpoint, {}, { retryCodes: [503] });
        return res.body.uploadUrl;
    }
    catch (err) {
        logger_1.logger.info("\n\nThere was an issue deploying your functions. Verify that your project has a Google App Engine instance setup at https://console.cloud.google.com/appengine and try again. If this issue persists, please contact support.");
        throw err;
    }
}
async function createFunction(cloudFunction) {
    const apiPath = cloudFunction.name.substring(0, cloudFunction.name.lastIndexOf("/"));
    const endpoint = `/${apiPath}`;
    cloudFunction.buildEnvironmentVariables = {
        ...cloudFunction.buildEnvironmentVariables,
        GOOGLE_NODE_RUN_SCRIPTS: "",
    };
    try {
        const res = await client.post(endpoint, cloudFunction);
        return {
            name: res.body.name,
            type: "create",
            done: false,
        };
    }
    catch (err) {
        throw functionsOpLogReject(cloudFunction.name, "create", err);
    }
}
async function setIamPolicy(options) {
    const endpoint = `/${options.name}:setIamPolicy`;
    try {
        await client.post(endpoint, {
            policy: options.policy,
            updateMask: Object.keys(options.policy).join(","),
        });
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to set the IAM Policy on the function ${options.name}`, {
            original: err,
            status: err?.context?.response?.statusCode,
        });
    }
}
async function getIamPolicy(fnName) {
    const endpoint = `/${fnName}:getIamPolicy`;
    try {
        const res = await client.get(endpoint);
        return res.body;
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to get the IAM Policy on the function ${fnName}`, {
            original: err,
        });
    }
}
async function setInvokerCreate(projectId, fnName, invoker) {
    if (invoker.length === 0) {
        throw new error_1.FirebaseError("Invoker cannot be an empty array");
    }
    const invokerMembers = proto.getInvokerMembers(invoker, projectId);
    const invokerRole = "roles/cloudfunctions.invoker";
    const bindings = [{ role: invokerRole, members: invokerMembers }];
    const policy = {
        bindings: bindings,
        etag: "",
        version: 3,
    };
    await setIamPolicy({ name: fnName, policy: policy });
}
async function setInvokerUpdate(projectId, fnName, invoker) {
    if (invoker.length === 0) {
        throw new error_1.FirebaseError("Invoker cannot be an empty array");
    }
    const invokerMembers = proto.getInvokerMembers(invoker, projectId);
    const invokerRole = "roles/cloudfunctions.invoker";
    const currentPolicy = await getIamPolicy(fnName);
    const currentInvokerBinding = currentPolicy.bindings?.find((binding) => binding.role === invokerRole);
    if (currentInvokerBinding &&
        JSON.stringify(currentInvokerBinding.members.sort()) === JSON.stringify(invokerMembers.sort())) {
        return;
    }
    const bindings = (currentPolicy.bindings || []).filter((binding) => binding.role !== invokerRole);
    bindings.push({
        role: invokerRole,
        members: invokerMembers,
    });
    const policy = {
        bindings: bindings,
        etag: currentPolicy.etag || "",
        version: 3,
    };
    await setIamPolicy({ name: fnName, policy: policy });
}
async function updateFunction(cloudFunction) {
    const endpoint = `/${cloudFunction.name}`;
    cloudFunction.buildEnvironmentVariables = {
        ...cloudFunction.buildEnvironmentVariables,
        GOOGLE_NODE_RUN_SCRIPTS: "",
    };
    const fieldMasks = proto.fieldMasks(cloudFunction, "labels", "environmentVariables", "secretEnvironmentVariables", "buildEnvironmentVariables");
    try {
        const res = await client.patch(endpoint, cloudFunction, {
            queryParams: {
                updateMask: fieldMasks.join(","),
            },
        });
        return {
            done: false,
            name: res.body.name,
            type: "update",
        };
    }
    catch (err) {
        throw functionsOpLogReject(cloudFunction.name, "update", err);
    }
}
async function deleteFunction(name) {
    const endpoint = `/${name}`;
    try {
        const res = await client.delete(endpoint);
        return {
            done: false,
            name: res.body.name,
            type: "delete",
        };
    }
    catch (err) {
        throw functionsOpLogReject(name, "delete", err);
    }
}
async function list(projectId, region) {
    const endpoint = "/projects/" + projectId + "/locations/" + region + "/functions";
    try {
        const res = await client.get(endpoint);
        if (res.body.unreachable && res.body.unreachable.length > 0) {
            logger_1.logger.debug(`[functions] unable to reach the following regions: ${res.body.unreachable.join(", ")}`);
        }
        return {
            functions: res.body.functions || [],
            unreachable: res.body.unreachable || [],
        };
    }
    catch (err) {
        logger_1.logger.debug(`[functions] failed to list functions for ${projectId}`);
        logger_1.logger.debug(`[functions] ${err?.message}`);
        throw new error_1.FirebaseError(`Failed to list functions for ${projectId}`, {
            original: err,
            status: err instanceof error_1.FirebaseError ? err.status : undefined,
        });
    }
}
async function listAllFunctions(projectId) {
    return list(projectId, "-");
}
function endpointFromFunction(gcfFunction) {
    const [, project, , region, , id] = gcfFunction.name.split("/");
    let trigger;
    let uri;
    let securityLevel;
    if (gcfFunction.labels?.["deployment-scheduled"]) {
        trigger = {
            scheduleTrigger: {},
        };
    }
    else if (gcfFunction.labels?.["deployment-taskqueue"]) {
        trigger = {
            taskQueueTrigger: {},
        };
    }
    else if (gcfFunction.labels?.["deployment-callable"] ||
        gcfFunction.labels?.["deployment-callabled"]) {
        trigger = {
            callableTrigger: {},
        };
    }
    else if (gcfFunction.labels?.[constants_1.BLOCKING_LABEL]) {
        trigger = {
            blockingTrigger: {
                eventType: constants_1.BLOCKING_LABEL_KEY_TO_EVENT[gcfFunction.labels[constants_1.BLOCKING_LABEL]],
            },
        };
    }
    else if (gcfFunction.httpsTrigger) {
        trigger = { httpsTrigger: {} };
    }
    else {
        trigger = {
            eventTrigger: {
                eventType: gcfFunction.eventTrigger.eventType,
                eventFilters: { resource: gcfFunction.eventTrigger.resource },
                retry: !!gcfFunction.eventTrigger.failurePolicy?.retry,
            },
        };
    }
    if (gcfFunction.httpsTrigger) {
        uri = gcfFunction.httpsTrigger.url;
        securityLevel = gcfFunction.httpsTrigger.securityLevel;
    }
    if (!supported.isRuntime(gcfFunction.runtime)) {
        logger_1.logger.debug("GCF 1st gen function has unsupported runtime:", JSON.stringify(gcfFunction, null, 2));
    }
    const endpoint = {
        platform: "gcfv1",
        id,
        project,
        region,
        ...trigger,
        entryPoint: gcfFunction.entryPoint,
        runtime: gcfFunction.runtime,
    };
    if (uri) {
        endpoint.uri = uri;
    }
    if (securityLevel) {
        endpoint.securityLevel = securityLevel;
    }
    proto.copyIfPresent(endpoint, gcfFunction, "minInstances", "maxInstances", "ingressSettings", "labels", "environmentVariables", "secretEnvironmentVariables", "sourceUploadUrl");
    proto.renameIfPresent(endpoint, gcfFunction, "serviceAccount", "serviceAccountEmail");
    proto.convertIfPresent(endpoint, gcfFunction, "availableMemoryMb", (raw) => raw);
    proto.convertIfPresent(endpoint, gcfFunction, "timeoutSeconds", "timeout", (dur) => dur === null ? null : proto.secondsFromDuration(dur));
    if (gcfFunction.vpcConnector) {
        endpoint.vpc = { connector: gcfFunction.vpcConnector };
        proto.convertIfPresent(endpoint.vpc, gcfFunction, "egressSettings", "vpcConnectorEgressSettings", (raw) => raw);
    }
    endpoint.codebase = gcfFunction.labels?.[constants_1.CODEBASE_LABEL] || projectConfig.DEFAULT_CODEBASE;
    if (gcfFunction.labels?.[constants_1.HASH_LABEL]) {
        endpoint.hash = gcfFunction.labels[constants_1.HASH_LABEL];
    }
    proto.convertIfPresent(endpoint, gcfFunction, "state", "status", (status) => {
        if (status === "ACTIVE") {
            return "ACTIVE";
        }
        else if (status === "OFFLINE") {
            return "FAILED";
        }
        else if (status === "DEPLOY_IN_PROGRESS") {
            return "DEPLOYING";
        }
        else if (status === "DELETE_IN_PROGRESS") {
            return "DELETING";
        }
        return "UNKONWN";
    });
    return endpoint;
}
function functionFromEndpoint(endpoint, sourceUploadUrl) {
    if (endpoint.platform !== "gcfv1") {
        throw new error_1.FirebaseError("Trying to create a v1 CloudFunction with v2 API. This should never happen");
    }
    if (!endpoint.runtime || !supported.isRuntime(endpoint.runtime)) {
        throw new error_1.FirebaseError("Failed internal assertion. Trying to deploy a new function with a deprecated runtime." +
            " This should never happen", { exit: 1 });
    }
    const gcfFunction = {
        name: backend.functionName(endpoint),
        sourceUploadUrl: sourceUploadUrl,
        entryPoint: endpoint.entryPoint,
        runtime: endpoint.runtime,
        dockerRegistry: "ARTIFACT_REGISTRY",
    };
    if (typeof endpoint.labels !== "undefined") {
        gcfFunction.labels = { ...endpoint.labels };
    }
    if (backend.isEventTriggered(endpoint)) {
        if (!endpoint.eventTrigger.eventFilters?.resource) {
            throw new error_1.FirebaseError("Cannot create v1 function from an eventTrigger without a resource");
        }
        gcfFunction.eventTrigger = {
            eventType: endpoint.eventTrigger.eventType,
            resource: endpoint.eventTrigger.eventFilters.resource,
        };
        gcfFunction.eventTrigger.failurePolicy = endpoint.eventTrigger.retry
            ? { retry: {} }
            : undefined;
    }
    else if (backend.isScheduleTriggered(endpoint)) {
        const id = backend.scheduleIdForFunction(endpoint);
        gcfFunction.eventTrigger = {
            eventType: "google.pubsub.topic.publish",
            resource: `projects/${endpoint.project}/topics/${id}`,
        };
        gcfFunction.labels = { ...gcfFunction.labels, "deployment-scheduled": "true" };
    }
    else if (backend.isTaskQueueTriggered(endpoint)) {
        gcfFunction.httpsTrigger = {};
        gcfFunction.labels = { ...gcfFunction.labels, "deployment-taskqueue": "true" };
    }
    else if (backend.isBlockingTriggered(endpoint)) {
        gcfFunction.httpsTrigger = {};
        gcfFunction.labels = {
            ...gcfFunction.labels,
            [constants_1.BLOCKING_LABEL]: constants_1.BLOCKING_EVENT_TO_LABEL_KEY[endpoint.blockingTrigger.eventType],
        };
    }
    else {
        gcfFunction.httpsTrigger = {};
        if (backend.isCallableTriggered(endpoint)) {
            gcfFunction.labels = { ...gcfFunction.labels, "deployment-callable": "true" };
        }
        if (endpoint.securityLevel) {
            gcfFunction.httpsTrigger.securityLevel = endpoint.securityLevel;
        }
    }
    proto.copyIfPresent(gcfFunction, endpoint, "minInstances", "maxInstances", "ingressSettings", "environmentVariables", "secretEnvironmentVariables");
    proto.convertIfPresent(gcfFunction, endpoint, "serviceAccountEmail", "serviceAccount", (from) => !from ? null : proto.formatServiceAccount(from, endpoint.project, true));
    proto.convertIfPresent(gcfFunction, endpoint, "availableMemoryMb", (mem) => mem);
    proto.convertIfPresent(gcfFunction, endpoint, "timeout", "timeoutSeconds", (sec) => sec ? proto.durationFromSeconds(sec) : null);
    if (endpoint.vpc) {
        proto.renameIfPresent(gcfFunction, endpoint.vpc, "vpcConnector", "connector");
        proto.renameIfPresent(gcfFunction, endpoint.vpc, "vpcConnectorEgressSettings", "egressSettings");
    }
    else if (endpoint.vpc === null) {
        gcfFunction.vpcConnector = null;
        gcfFunction.vpcConnectorEgressSettings = null;
    }
    const codebase = endpoint.codebase || projectConfig.DEFAULT_CODEBASE;
    if (codebase !== projectConfig.DEFAULT_CODEBASE) {
        gcfFunction.labels = {
            ...gcfFunction.labels,
            [constants_1.CODEBASE_LABEL]: codebase,
        };
    }
    else {
        delete gcfFunction.labels?.[constants_1.CODEBASE_LABEL];
    }
    if (endpoint.hash) {
        gcfFunction.labels = {
            ...gcfFunction.labels,
            [constants_1.HASH_LABEL]: endpoint.hash,
        };
    }
    return gcfFunction;
}
