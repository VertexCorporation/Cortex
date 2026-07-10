"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LOCATION_LABEL = void 0;
exports.gcpIds = gcpIds;
exports.getService = getService;
exports.updateService = updateService;
exports.serviceIsResolved = serviceIsResolved;
exports.replaceService = replaceService;
exports.setIamPolicy = setIamPolicy;
exports.getIamPolicy = getIamPolicy;
exports.setInvokerCreate = setInvokerCreate;
exports.setInvokerUpdate = setInvokerUpdate;
exports.fetchServiceLogs = fetchServiceLogs;
const apiv2_1 = require("../apiv2");
const error_1 = require("../error");
const api_1 = require("../api");
const proto = require("./proto");
const throttler_1 = require("../throttler/throttler");
const logger_1 = require("../logger");
const cloudlogging_1 = require("./cloudlogging");
const API_VERSION = "v1";
const client = new apiv2_1.Client({
    urlPrefix: (0, api_1.runOrigin)(),
    auth: true,
    apiVersion: API_VERSION,
});
exports.LOCATION_LABEL = "cloud.googleapis.com/location";
function gcpIds(service) {
    return {
        serviceId: service.metadata.name,
        projectNumber: service.metadata.namespace,
        region: service.metadata.labels?.[exports.LOCATION_LABEL] || "unknown-region",
    };
}
async function getService(name) {
    try {
        const response = await client.get(name);
        return response.body;
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to fetch Run service ${name}`, {
            original: err,
            status: err?.context?.response?.statusCode,
        });
    }
}
async function updateService(name, service) {
    delete service.status;
    service = await exports.replaceService(name, service);
    let retry = 0;
    while (!exports.serviceIsResolved(service)) {
        await (0, throttler_1.backoff)(retry, 2, 30);
        retry = retry + 1;
        service = await exports.getService(name);
    }
    return service;
}
function serviceIsResolved(service) {
    if (service.status?.observedGeneration !== service.metadata.generation) {
        logger_1.logger.debug(`Service ${service.metadata.name} is not resolved because` +
            `observed generation ${service.status?.observedGeneration} does not ` +
            `match spec generation ${service.metadata.generation}`);
        return false;
    }
    const readyCondition = service.status?.conditions?.find((condition) => {
        return condition.type === "Ready";
    });
    if (readyCondition?.status === "Unknown") {
        logger_1.logger.debug(`Waiting for service ${service.metadata.name} to be ready. ` +
            `Status is ${JSON.stringify(service.status?.conditions)}`);
        return false;
    }
    else if (readyCondition?.status === "True") {
        return true;
    }
    logger_1.logger.debug(`Service ${service.metadata.name} has unexpected ready status ${JSON.stringify(readyCondition)}. It may have failed rollout.`);
    throw new error_1.FirebaseError(`Unexpected Status ${readyCondition?.status} for service ${service.metadata.name}`);
}
async function replaceService(name, service) {
    try {
        const response = await client.put(name, service);
        return response.body;
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to replace Run service ${name}`, {
            original: err,
            status: err?.context?.response?.statusCode,
        });
    }
}
async function setIamPolicy(name, policy, httpClient = client) {
    try {
        await httpClient.post(`${name}:setIamPolicy`, {
            policy,
            updateMask: proto.fieldMasks(policy).join(","),
        });
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to set the IAM Policy on the Service ${name}`, {
            original: err,
            status: err?.context?.response?.statusCode,
        });
    }
}
async function getIamPolicy(serviceName, httpClient = client) {
    try {
        const response = await httpClient.get(`${serviceName}:getIamPolicy`);
        return response.body;
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to get the IAM Policy on the Service ${serviceName}`, {
            original: err,
        });
    }
}
async function setInvokerCreate(projectId, serviceName, invoker, httpClient = client) {
    if (invoker.length === 0) {
        throw new error_1.FirebaseError("Invoker cannot be an empty array");
    }
    const invokerMembers = proto.getInvokerMembers(invoker, projectId);
    const invokerRole = "roles/run.invoker";
    const bindings = [{ role: invokerRole, members: invokerMembers }];
    const policy = {
        bindings: bindings,
        etag: "",
        version: 3,
    };
    await setIamPolicy(serviceName, policy, httpClient);
}
async function setInvokerUpdate(projectId, serviceName, invoker, httpClient = client) {
    if (invoker.length === 0) {
        throw new error_1.FirebaseError("Invoker cannot be an empty array");
    }
    const invokerMembers = proto.getInvokerMembers(invoker, projectId);
    const invokerRole = "roles/run.invoker";
    const currentPolicy = await getIamPolicy(serviceName, httpClient);
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
    await setIamPolicy(serviceName, policy, httpClient);
}
async function fetchServiceLogs(projectId, serviceId) {
    const filter = `resource.type="cloud_run_revision" AND resource.labels.service_name="${serviceId}"`;
    const pageSize = 100;
    const order = "desc";
    try {
        const { entries } = await (0, cloudlogging_1.listEntries)(projectId, filter, pageSize, order);
        return entries;
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to fetch logs for Cloud Run service ${serviceId}`, {
            original: err,
            status: err?.context?.response?.statusCode,
        });
    }
}
