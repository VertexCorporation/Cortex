"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEFAULT_SETTINGS = void 0;
exports.createQueue = createQueue;
exports.getQueue = getQueue;
exports.updateQueue = updateQueue;
exports.upsertQueue = upsertQueue;
exports.purgeQueue = purgeQueue;
exports.deleteQueue = deleteQueue;
exports.enqueueTask = enqueueTask;
exports.setIamPolicy = setIamPolicy;
exports.getIamPolicy = getIamPolicy;
exports.setEnqueuer = setEnqueuer;
exports.queueNameForEndpoint = queueNameForEndpoint;
exports.queueFromEndpoint = queueFromEndpoint;
exports.triggerFromQueue = triggerFromQueue;
const proto = require("./proto");
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
const functional_1 = require("../functional");
const API_VERSION = "v2";
const client = new apiv2_1.Client({
    urlPrefix: (0, api_1.cloudTasksOrigin)(),
    auth: true,
    apiVersion: API_VERSION,
});
exports.DEFAULT_SETTINGS = {
    rateLimits: {
        maxConcurrentDispatches: 1000,
        maxDispatchesPerSecond: 500,
    },
    state: "RUNNING",
    retryConfig: {
        maxDoublings: 16,
        maxAttempts: 3,
        maxBackoff: "3600s",
        minBackoff: "0.100s",
    },
};
async function createQueue(queue) {
    const path = queue.name.substring(0, queue.name.lastIndexOf("/"));
    const res = await client.post(path, queue);
    return res.body;
}
async function getQueue(name) {
    const res = await client.get(name);
    return res.body;
}
async function updateQueue(queue) {
    const res = await client.patch(queue.name, queue, {
        queryParams: { updateMask: proto.fieldMasks(queue).join(",") },
    });
    return res.body;
}
async function upsertQueue(queue) {
    try {
        const existing = await module.exports.getQueue(queue.name);
        if (JSON.stringify(queue) === JSON.stringify(existing)) {
            return false;
        }
        if (existing.state === "DISABLED") {
            await module.exports.purgeQueue(queue.name);
        }
        await module.exports.updateQueue(queue);
        return false;
    }
    catch (err) {
        if (err?.context?.response?.statusCode === 404) {
            await module.exports.createQueue(queue);
            return true;
        }
        throw err;
    }
}
async function purgeQueue(name) {
    await client.post(`${name}:purge`);
}
async function deleteQueue(name) {
    await client.delete(name);
}
async function enqueueTask(queueName, task) {
    await client.post(`${queueName}/tasks`, { task });
}
async function setIamPolicy(name, policy) {
    const res = await client.post(`${name}:setIamPolicy`, {
        policy,
    });
    return res.body;
}
async function getIamPolicy(name) {
    const res = await client.post(`${name}:getIamPolicy`);
    return res.body;
}
const ENQUEUER_ROLE = "roles/cloudtasks.enqueuer";
async function setEnqueuer(name, invoker, assumeEmpty = false) {
    let existing;
    if (assumeEmpty) {
        existing = {
            bindings: [],
            etag: "",
            version: 3,
        };
    }
    else {
        existing = await module.exports.getIamPolicy(name);
    }
    const [, project] = name.split("/");
    const invokerMembers = proto.getInvokerMembers(invoker, project);
    while (true) {
        const policy = {
            bindings: existing.bindings.filter((binding) => binding.role !== ENQUEUER_ROLE),
            etag: existing.etag,
            version: existing.version,
        };
        if (invokerMembers.length) {
            policy.bindings.push({ role: ENQUEUER_ROLE, members: invokerMembers });
        }
        if (JSON.stringify(policy) === JSON.stringify(existing)) {
            return;
        }
        try {
            await module.exports.setIamPolicy(name, policy);
            return;
        }
        catch (err) {
            if (err?.context?.response?.statusCode === 429) {
                existing = await module.exports.getIamPolicy(name);
                continue;
            }
            throw err;
        }
    }
}
function queueNameForEndpoint(endpoint) {
    return `projects/${endpoint.project}/locations/${endpoint.region}/queues/${endpoint.id}`;
}
function queueFromEndpoint(endpoint) {
    const queue = {
        ...JSON.parse(JSON.stringify(exports.DEFAULT_SETTINGS)),
        name: queueNameForEndpoint(endpoint),
    };
    if (endpoint.taskQueueTrigger.rateLimits) {
        proto.copyIfPresent(queue.rateLimits, endpoint.taskQueueTrigger.rateLimits, "maxConcurrentDispatches", "maxDispatchesPerSecond");
    }
    if (endpoint.taskQueueTrigger.retryConfig) {
        proto.copyIfPresent(queue.retryConfig, endpoint.taskQueueTrigger.retryConfig, "maxAttempts", "maxDoublings");
        proto.convertIfPresent(queue.retryConfig, endpoint.taskQueueTrigger.retryConfig, "maxRetryDuration", "maxRetrySeconds", (0, functional_1.nullsafeVisitor)(proto.durationFromSeconds));
        proto.convertIfPresent(queue.retryConfig, endpoint.taskQueueTrigger.retryConfig, "maxBackoff", "maxBackoffSeconds", (0, functional_1.nullsafeVisitor)(proto.durationFromSeconds));
        proto.convertIfPresent(queue.retryConfig, endpoint.taskQueueTrigger.retryConfig, "minBackoff", "minBackoffSeconds", (0, functional_1.nullsafeVisitor)(proto.durationFromSeconds));
    }
    return queue;
}
function triggerFromQueue(queue) {
    const taskQueueTrigger = {};
    if (queue.rateLimits) {
        taskQueueTrigger.rateLimits = {};
        proto.copyIfPresent(taskQueueTrigger.rateLimits, queue.rateLimits, "maxConcurrentDispatches", "maxDispatchesPerSecond");
    }
    if (queue.retryConfig) {
        taskQueueTrigger.retryConfig = {};
        proto.copyIfPresent(taskQueueTrigger.retryConfig, queue.retryConfig, "maxAttempts", "maxDoublings");
        proto.convertIfPresent(taskQueueTrigger.retryConfig, queue.retryConfig, "maxRetrySeconds", "maxRetryDuration", (0, functional_1.nullsafeVisitor)(proto.secondsFromDuration));
        proto.convertIfPresent(taskQueueTrigger.retryConfig, queue.retryConfig, "maxBackoffSeconds", "maxBackoff", (0, functional_1.nullsafeVisitor)(proto.secondsFromDuration));
        proto.convertIfPresent(taskQueueTrigger.retryConfig, queue.retryConfig, "minBackoffSeconds", "minBackoff", (0, functional_1.nullsafeVisitor)(proto.secondsFromDuration));
    }
    return taskQueueTrigger;
}
