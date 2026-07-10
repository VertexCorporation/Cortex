"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getDefaultCloudBuildServiceAgent = getDefaultCloudBuildServiceAgent;
exports.createServiceAccount = createServiceAccount;
exports.getServiceAccount = getServiceAccount;
exports.createServiceAccountKey = createServiceAccountKey;
exports.deleteServiceAccount = deleteServiceAccount;
exports.listServiceAccountKeys = listServiceAccountKeys;
exports.getRole = getRole;
exports.testResourceIamPermissions = testResourceIamPermissions;
exports.testIamPermissions = testIamPermissions;
exports.mergeBindings = mergeBindings;
exports.printManualIamConfig = printManualIamConfig;
const api_1 = require("../api");
const logger_1 = require("../logger");
const apiv2_1 = require("../apiv2");
const utils = require("../utils");
const apiClient = new apiv2_1.Client({ urlPrefix: (0, api_1.iamOrigin)(), apiVersion: "v1" });
function getDefaultCloudBuildServiceAgent(projectNumber) {
    return `${projectNumber}@cloudbuild.gserviceaccount.com`;
}
async function createServiceAccount(projectId, accountId, description, displayName) {
    const response = await apiClient.post(`/projects/${projectId}/serviceAccounts`, {
        accountId,
        serviceAccount: {
            displayName,
            description,
        },
    }, { skipLog: { resBody: true } });
    return response.body;
}
async function getServiceAccount(projectId, serviceAccountName) {
    const response = await apiClient.get(`/projects/${projectId}/serviceAccounts/${serviceAccountName}@${projectId}.iam.gserviceaccount.com`);
    return response.body;
}
async function createServiceAccountKey(projectId, serviceAccountName) {
    const response = await apiClient.post(`/projects/${projectId}/serviceAccounts/${serviceAccountName}@${projectId}.iam.gserviceaccount.com/keys`, {
        keyAlgorithm: "KEY_ALG_UNSPECIFIED",
        privateKeyType: "TYPE_GOOGLE_CREDENTIALS_FILE",
    });
    return response.body;
}
async function deleteServiceAccount(projectId, accountEmail) {
    await apiClient.delete(`/projects/${projectId}/serviceAccounts/${accountEmail}`, {
        resolveOnHTTPError: true,
    });
}
async function listServiceAccountKeys(projectId, serviceAccountName) {
    const response = await apiClient.get(`/projects/${projectId}/serviceAccounts/${serviceAccountName}@${projectId}.iam.gserviceaccount.com/keys`);
    return response.body.keys;
}
async function getRole(role) {
    const response = await apiClient.get(`/roles/${role}`, {
        retryCodes: [500, 503],
    });
    return response.body;
}
async function testResourceIamPermissions(origin, apiVersion, resourceName, permissions, quotaUser = "") {
    const localClient = new apiv2_1.Client({ urlPrefix: origin, apiVersion });
    if (process.env.FIREBASE_SKIP_INFORMATIONAL_IAM) {
        logger_1.logger.debug(`[iam] skipping informational check of permissions ${JSON.stringify(permissions)} on resource ${resourceName}`);
        return { allowed: Array.from(permissions).sort(), missing: [], passed: true };
    }
    const headers = {};
    if (quotaUser) {
        headers["x-goog-user-project"] = quotaUser;
    }
    const response = await localClient.post(`/${resourceName}:testIamPermissions`, { permissions }, { headers });
    const allowed = new Set(response.body.permissions || []);
    const missing = new Set(permissions);
    for (const p of allowed) {
        missing.delete(p);
    }
    return {
        allowed: Array.from(allowed).sort(),
        missing: Array.from(missing).sort(),
        passed: missing.size === 0,
    };
}
async function testIamPermissions(projectId, permissions) {
    return testResourceIamPermissions((0, api_1.resourceManagerOrigin)(), "v1", `projects/${projectId}`, permissions, `${projectId}`);
}
function mergeBindings(policy, requiredBindings) {
    let updated = false;
    for (const requiredBinding of requiredBindings) {
        const match = policy.bindings.find((b) => b.role === requiredBinding.role);
        if (!match) {
            updated = true;
            policy.bindings.push(requiredBinding);
            continue;
        }
        for (const requiredMember of requiredBinding.members) {
            if (!match.members.find((m) => m === requiredMember)) {
                updated = true;
                match.members.push(requiredMember);
            }
        }
    }
    return updated;
}
function printManualIamConfig(requiredBindings, projectId, prefix) {
    utils.logLabeledBullet(prefix, "Failed to verify the project has the correct IAM bindings for a successful deployment.", "warn");
    utils.logLabeledBullet(prefix, "You can either re-run this command as a project owner or manually run the following set of `gcloud` commands:", "warn");
    for (const binding of requiredBindings) {
        for (const member of binding.members) {
            utils.logLabeledBullet(prefix, `\`gcloud projects add-iam-policy-binding ${projectId} ` +
                `--member=${member} ` +
                `--role=${binding.role}\``, "warn");
        }
    }
}
