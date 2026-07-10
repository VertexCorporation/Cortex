"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deleteJob = deleteJob;
exports.getJob = getJob;
exports.createOrReplaceJob = createOrReplaceJob;
exports.jobNameForEndpoint = jobNameForEndpoint;
exports.topicNameForEndpoint = topicNameForEndpoint;
exports.jobFromEndpoint = jobFromEndpoint;
const _ = require("lodash");
const error_1 = require("../error");
const logger_1 = require("../logger");
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const functional_1 = require("../functional");
const validate_1 = require("../deploy/functions/validate");
const backend = require("../deploy/functions/backend");
const proto = require("./proto");
const gce = require("../gcp/computeEngine");
const VERSION = "v1";
const DEFAULT_TIME_ZONE_V1 = "America/Los_Angeles";
const DEFAULT_TIME_ZONE_V2 = "UTC";
const apiClient = new apiv2_1.Client({ urlPrefix: (0, api_1.cloudschedulerOrigin)(), apiVersion: VERSION });
function createJob(job) {
    const strippedName = job.name.substring(0, job.name.lastIndexOf("/"));
    const json = job.pubsubTarget
        ? { timeZone: DEFAULT_TIME_ZONE_V1, ...job }
        : { timeZone: DEFAULT_TIME_ZONE_V2, ...job };
    return apiClient.post(`/${strippedName}`, json);
}
function deleteJob(name) {
    return apiClient.delete(`/${name}`);
}
function getJob(name) {
    return apiClient.get(`/${name}`, {
        resolveOnHTTPError: true,
    });
}
function updateJob(job) {
    let fieldMasks;
    let json;
    if (job.pubsubTarget) {
        fieldMasks = proto.fieldMasks(job, "pubsubTarget");
        json = { timeZone: DEFAULT_TIME_ZONE_V1, ...job };
    }
    else {
        fieldMasks = proto.fieldMasks(job, "httpTarget");
        json = { timeZone: DEFAULT_TIME_ZONE_V2, ...job };
    }
    return apiClient.patch(`/${job.name}`, json, {
        queryParams: {
            updateMask: fieldMasks.join(","),
        },
    });
}
async function createOrReplaceJob(job) {
    const jobName = job.name.split("/").pop();
    const existingJob = await getJob(job.name);
    if (existingJob.status === 404) {
        let newJob;
        try {
            newJob = await createJob(job);
        }
        catch (err) {
            if (err?.context?.response?.statusCode === 404) {
                throw new error_1.FirebaseError(`Cloud resource location is not set for this project but scheduled functions require it. ` +
                    `Please see this documentation for more details: https://firebase.google.com/docs/projects/locations.`);
            }
            throw new error_1.FirebaseError(`Failed to create scheduler job ${job.name}: ${err.message}`);
        }
        logger_1.logger.debug(`created scheduler job ${jobName}`);
        return newJob;
    }
    if (!job.timeZone) {
        job.timeZone = job.pubsubTarget ? DEFAULT_TIME_ZONE_V1 : DEFAULT_TIME_ZONE_V2;
    }
    if (!needUpdate(existingJob.body, job)) {
        logger_1.logger.debug(`scheduler job ${jobName} is up to date, no changes required`);
        return;
    }
    const updatedJob = await updateJob(job);
    logger_1.logger.debug(`updated scheduler job ${jobName}`);
    return updatedJob;
}
function needUpdate(existingJob, newJob) {
    if (!existingJob) {
        return true;
    }
    if (!newJob) {
        return true;
    }
    if (existingJob.schedule !== newJob.schedule) {
        return true;
    }
    if (existingJob.timeZone !== newJob.timeZone) {
        return true;
    }
    if (existingJob.attemptDeadline !== newJob.attemptDeadline) {
        return true;
    }
    if (newJob.retryConfig) {
        if (!existingJob.retryConfig) {
            return true;
        }
        if (!_.isMatch(existingJob.retryConfig, newJob.retryConfig)) {
            return true;
        }
    }
    return false;
}
function jobNameForEndpoint(endpoint, location) {
    const id = backend.scheduleIdForFunction(endpoint);
    return `projects/${endpoint.project}/locations/${location}/jobs/${id}`;
}
function topicNameForEndpoint(endpoint) {
    const id = backend.scheduleIdForFunction(endpoint);
    return `projects/${endpoint.project}/topics/${id}`;
}
async function jobFromEndpoint(endpoint, location, projectNumber) {
    const job = {};
    job.name = jobNameForEndpoint(endpoint, location);
    if (endpoint.platform === "gcfv1") {
        job.timeZone = endpoint.scheduleTrigger.timeZone || DEFAULT_TIME_ZONE_V1;
        job.pubsubTarget = {
            topicName: topicNameForEndpoint(endpoint),
            attributes: {
                scheduled: "true",
            },
        };
    }
    else if (endpoint.platform === "gcfv2" || endpoint.platform === "run") {
        job.timeZone = endpoint.scheduleTrigger.timeZone || DEFAULT_TIME_ZONE_V2;
        job.httpTarget = {
            uri: endpoint.uri,
            httpMethod: "POST",
            oidcToken: {
                serviceAccountEmail: endpoint.serviceAccount ?? (await gce.getDefaultServiceAccount(projectNumber)),
            },
        };
    }
    else {
        (0, functional_1.assertExhaustive)(endpoint.platform);
    }
    if (!endpoint.scheduleTrigger.schedule) {
        throw new error_1.FirebaseError("Cannot create a scheduler job without a schedule:" + JSON.stringify(endpoint));
    }
    job.schedule = endpoint.scheduleTrigger.schedule;
    if (endpoint.platform === "gcfv2" || endpoint.platform === "run") {
        proto.convertIfPresent(job, endpoint, "attemptDeadline", "timeoutSeconds", (timeout) => {
            if (timeout === null) {
                return null;
            }
            const attemptDeadlineSeconds = Math.max(Math.min(timeout, validate_1.MAX_V2_SCHEDULE_ATTEMPT_DEADLINE_SECONDS), validate_1.DEFAULT_V2_SCHEDULE_ATTEMPT_DEADLINE_SECONDS);
            return proto.durationFromSeconds(attemptDeadlineSeconds);
        });
    }
    if (endpoint.scheduleTrigger.retryConfig) {
        job.retryConfig = {};
        proto.copyIfPresent(job.retryConfig, endpoint.scheduleTrigger.retryConfig, "maxDoublings", "retryCount");
        proto.convertIfPresent(job.retryConfig, endpoint.scheduleTrigger.retryConfig, "maxBackoffDuration", "maxBackoffSeconds", (0, functional_1.nullsafeVisitor)(proto.durationFromSeconds));
        proto.convertIfPresent(job.retryConfig, endpoint.scheduleTrigger.retryConfig, "minBackoffDuration", "minBackoffSeconds", (0, functional_1.nullsafeVisitor)(proto.durationFromSeconds));
        proto.convertIfPresent(job.retryConfig, endpoint.scheduleTrigger.retryConfig, "maxRetryDuration", "maxRetrySeconds", (0, functional_1.nullsafeVisitor)(proto.durationFromSeconds));
        if (!Object.keys(job.retryConfig).length) {
            delete job.retryConfig;
        }
    }
    return job;
}
