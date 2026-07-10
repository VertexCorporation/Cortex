"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.apiClient = void 0;
exports.generateServiceIdentity = generateServiceIdentity;
exports.generateServiceIdentityAndPoll = generateServiceIdentityAndPoll;
const colorette_1 = require("colorette");
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const error_1 = require("../error");
const utils = require("../utils");
const poller = require("../operation-poller");
const API_VERSION = "v1beta1";
const SERVICE_USAGE_ORIGIN = (0, api_1.serviceUsageOrigin)();
exports.apiClient = new apiv2_1.Client({
    urlPrefix: SERVICE_USAGE_ORIGIN,
    apiVersion: API_VERSION,
});
const serviceUsagePollerOptions = {
    apiOrigin: SERVICE_USAGE_ORIGIN,
    apiVersion: API_VERSION,
};
async function generateServiceIdentity(projectNumber, service, prefix) {
    utils.logLabeledBullet(prefix, `generating the service identity for ${(0, colorette_1.bold)(service)}...`);
    try {
        const res = await exports.apiClient.post(`projects/${projectNumber}/services/${service}:generateServiceIdentity`, {}, { headers: { "x-goog-user-project": `${projectNumber}` } });
        return res.body;
    }
    catch (err) {
        throw new error_1.FirebaseError(`Error generating the service identity for ${service}.`, {
            original: err,
        });
    }
}
async function generateServiceIdentityAndPoll(projectNumber, service, prefix) {
    const op = await generateServiceIdentity(projectNumber, service, prefix);
    if (op.done) {
        return;
    }
    await poller.pollOperation({
        ...serviceUsagePollerOptions,
        operationResourceName: op.name,
        headers: { "x-goog-user-project": `${projectNumber}` },
    });
}
