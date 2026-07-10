"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.defaultServiceAccount = defaultServiceAccount;
exports.cloudBuildEnabled = cloudBuildEnabled;
exports.secretAccess = secretAccess;
const clc = require("colorette");
const ensureApiEnabled_1 = require("../../ensureApiEnabled");
const error_1 = require("../../error");
const utils_1 = require("../../utils");
const secretManager_1 = require("../../gcp/secretManager");
const projects_1 = require("../../management/projects");
const functional_1 = require("../../functional");
const api_1 = require("../../api");
const backend = require("./backend");
const computeEngine_1 = require("../../gcp/computeEngine");
const FAQ_URL = "https://firebase.google.com/support/faq#functions-runtime";
const metadataCallCache = new Map();
async function defaultServiceAccount(e) {
    let metadataCall = metadataCallCache.get(e.project);
    if (!metadataCall) {
        metadataCall = (0, projects_1.getProject)(e.project);
        metadataCallCache.set(e.project, metadataCall);
    }
    const metadata = await metadataCall;
    if (e.platform === "gcfv1") {
        return `${metadata.projectId}@appspot.gserviceaccount.com`;
    }
    else if (e.platform === "gcfv2" || e.platform === "run") {
        return await (0, computeEngine_1.getDefaultServiceAccount)(metadata.projectNumber);
    }
    (0, functional_1.assertExhaustive)(e.platform);
}
function nodeBillingError(projectId) {
    return new error_1.FirebaseError(`Cloud Functions deployment requires the pay-as-you-go (Blaze) billing plan. To upgrade your project, visit the following URL:

https://console.firebase.google.com/project/${projectId}/usage/details

For additional information about this requirement, see Firebase FAQs:

${FAQ_URL}`, { exit: 1 });
}
function nodePermissionError(projectId) {
    return new error_1.FirebaseError(`Cloud Functions deployment requires the Cloud Build API to be enabled. The current credentials do not have permission to enable APIs for project ${clc.bold(projectId)}.

Please ask a project owner to visit the following URL to enable Cloud Build:

https://console.cloud.google.com/apis/library/cloudbuild.googleapis.com?project=${projectId}

For additional information about this requirement, see Firebase FAQs:
${FAQ_URL}
`);
}
function isPermissionError(e) {
    return e.context?.body?.error?.status === "PERMISSION_DENIED";
}
async function cloudBuildEnabled(projectId) {
    try {
        await (0, ensureApiEnabled_1.ensure)(projectId, (0, api_1.cloudbuildOrigin)(), "functions");
    }
    catch (e) {
        if ((0, error_1.isBillingError)(e)) {
            throw nodeBillingError(projectId);
        }
        else if (isPermissionError(e)) {
            throw nodePermissionError(projectId);
        }
        throw e;
    }
}
async function secretsToServiceAccounts(b) {
    const secretsToSa = {};
    for (const e of backend.allEndpoints(b)) {
        const sa = e.serviceAccount || (await module.exports.defaultServiceAccount(e));
        for (const s of e.secretEnvironmentVariables || []) {
            const serviceAccounts = secretsToSa[s.secret] || new Set();
            serviceAccounts.add(sa);
            secretsToSa[s.secret] = serviceAccounts;
        }
    }
    return secretsToSa;
}
async function secretAccess(projectId, wantBackend, haveBackend, dryRun) {
    const ensureAccess = async (secret, serviceAccounts) => {
        (0, utils_1.logLabeledBullet)("functions", `ensuring ${clc.bold(serviceAccounts.join(", "))} access to secret ${clc.bold(secret)}.`);
        if (dryRun) {
            const check = await (0, secretManager_1.checkServiceAgentRole)({ name: secret, projectId }, serviceAccounts, "roles/secretmanager.secretAccessor");
            if (check.length) {
                (0, utils_1.logLabeledBullet)("functions", `On your next deploy, ${clc.bold(serviceAccounts.join(", "))} will be granted access to secret ${clc.bold(secret)}.`);
            }
        }
        else {
            await (0, secretManager_1.ensureServiceAgentRole)({ name: secret, projectId }, serviceAccounts, "roles/secretmanager.secretAccessor");
        }
        (0, utils_1.logLabeledSuccess)("functions", `ensured ${clc.bold(serviceAccounts.join(", "))} access to ${clc.bold(secret)}.`);
    };
    const wantSecrets = await secretsToServiceAccounts(wantBackend);
    const haveSecrets = await secretsToServiceAccounts(haveBackend);
    for (const [secret, serviceAccounts] of Object.entries(haveSecrets)) {
        for (const serviceAccount of serviceAccounts) {
            wantSecrets[secret]?.delete(serviceAccount);
        }
        if (wantSecrets[secret]?.size === 0) {
            delete wantSecrets[secret];
        }
    }
    const ensure = [];
    for (const [secret, serviceAccounts] of Object.entries(wantSecrets)) {
        ensure.push(ensureAccess(secret, Array.from(serviceAccounts)));
    }
    await Promise.all(ensure);
}
