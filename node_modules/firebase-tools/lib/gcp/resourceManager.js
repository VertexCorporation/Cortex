"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.firebaseRoles = void 0;
exports.getIamPolicy = getIamPolicy;
exports.setIamPolicy = setIamPolicy;
exports.addServiceAccountToRoles = addServiceAccountToRoles;
exports.serviceAccountHasRoles = serviceAccountHasRoles;
const lodash_1 = require("lodash");
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const iam_1 = require("./iam");
const API_VERSION = "v1";
const apiClient = new apiv2_1.Client({ urlPrefix: (0, api_1.resourceManagerOrigin)(), apiVersion: API_VERSION });
exports.firebaseRoles = {
    apiKeysViewer: "roles/serviceusage.apiKeysViewer",
    authAdmin: "roles/firebaseauth.admin",
    functionsDeveloper: "roles/cloudfunctions.developer",
    hostingAdmin: "roles/firebasehosting.admin",
    runViewer: "roles/run.viewer",
    serviceUsageConsumer: "roles/serviceusage.serviceUsageConsumer",
};
async function getIamPolicy(projectIdOrNumber) {
    const response = await apiClient.post(`/projects/${projectIdOrNumber}:getIamPolicy`);
    return response.body;
}
async function setIamPolicy(projectIdOrNumber, newPolicy, updateMask = "") {
    const response = await apiClient.post(`/projects/${projectIdOrNumber}:setIamPolicy`, {
        policy: newPolicy,
        updateMask: updateMask,
    });
    return response.body;
}
async function addServiceAccountToRoles(projectId, serviceAccountName, roles, skipAccountLookup = false) {
    const [{ name: fullServiceAccountName }, projectPolicy] = await Promise.all([
        skipAccountLookup
            ? Promise.resolve({ name: serviceAccountName })
            : (0, iam_1.getServiceAccount)(projectId, serviceAccountName),
        getIamPolicy(projectId),
    ]);
    const newMemberName = `serviceAccount:${fullServiceAccountName.split("/").pop()}`;
    roles.forEach((roleName) => {
        let bindingIndex = (0, lodash_1.findIndex)(projectPolicy.bindings, (binding) => binding.role === roleName);
        if (bindingIndex === -1) {
            bindingIndex =
                projectPolicy.bindings.push({
                    role: roleName,
                    members: [],
                }) - 1;
        }
        const binding = projectPolicy.bindings[bindingIndex];
        if (!binding.members.includes(newMemberName)) {
            binding.members.push(newMemberName);
        }
    });
    return setIamPolicy(projectId, projectPolicy, "bindings");
}
async function serviceAccountHasRoles(projectId, serviceAccountName, roles, skipAccountLookup = false) {
    const [{ name: fullServiceAccountName }, projectPolicy] = await Promise.all([
        skipAccountLookup
            ? Promise.resolve({ name: serviceAccountName })
            : (0, iam_1.getServiceAccount)(projectId, serviceAccountName),
        getIamPolicy(projectId),
    ]);
    const memberName = `serviceAccount:${fullServiceAccountName.split("/").pop()}`;
    for (const roleName of roles) {
        const binding = projectPolicy.bindings.find((b) => b.role === roleName);
        if (!binding) {
            return false;
        }
        if (!binding.members.includes(memberName)) {
            return false;
        }
    }
    return true;
}
