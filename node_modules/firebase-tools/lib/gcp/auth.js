"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getAuthDomains = getAuthDomains;
exports.updateAuthDomains = updateAuthDomains;
exports.findUser = findUser;
exports.listUsers = listUsers;
exports.toggleUserEnablement = toggleUserEnablement;
exports.setCustomClaim = setCustomClaim;
exports.setAllowSmsRegionPolicy = setAllowSmsRegionPolicy;
exports.setDenySmsRegionPolicy = setDenySmsRegionPolicy;
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
const apiClient = new apiv2_1.Client({ urlPrefix: (0, api_1.identityOrigin)(), auth: true });
async function getAuthDomains(project) {
    const res = await apiClient.get(`/admin/v2/projects/${project}/config`, { headers: { "x-goog-user-project": project } });
    return res.body.authorizedDomains;
}
async function updateAuthDomains(project, authDomains) {
    const res = await apiClient.patch(`/admin/v2/projects/${project}/config`, { authorizedDomains: authDomains }, {
        queryParams: { update_mask: "authorizedDomains" },
        headers: { "x-goog-user-project": project },
    });
    return res.body.authorizedDomains;
}
async function findUser(project, email, phone, uid) {
    const expression = {
        email,
        phoneNumber: phone,
        userId: uid,
    };
    const res = await apiClient.post(`/v1/projects/${project}/accounts:query`, {
        expression: [expression],
        limit: "1",
    });
    if (!res.body.userInfo?.length) {
        throw new Error("No users found");
    }
    const modifiedUserInfo = res.body.userInfo.map((ui) => {
        ui.uid = ui.localId;
        delete ui.localId;
        return ui;
    });
    return modifiedUserInfo[0];
}
async function listUsers(project, limit) {
    let queryLimit = limit;
    let offset = 0;
    if (limit > 500) {
        queryLimit = 500;
    }
    const userInfo = [];
    while (offset < limit) {
        if (queryLimit + offset > limit) {
            queryLimit = limit - offset;
        }
        const res = await apiClient.post(`/v1/projects/${project}/accounts:query`, {
            offset: offset.toString(),
            limit: queryLimit.toString(),
        });
        if (res.body.recordsCount === "0") {
            break;
        }
        offset += Number(res.body.recordsCount);
        const modifiedUserInfo = res.body.userInfo.map((ui) => {
            ui.uid = ui.localId;
            delete ui.localId;
            return ui;
        });
        userInfo.push(...modifiedUserInfo);
    }
    return userInfo;
}
async function toggleUserEnablement(project, uid, disabled) {
    const res = await apiClient.post("/v1/accounts:update", {
        disableUser: disabled,
        targetProjectId: project,
        localId: uid,
    });
    return res.status === 200;
}
async function setCustomClaim(project, uid, claim, options) {
    let user = await findUser(project, undefined, undefined, uid);
    if (user.uid !== uid) {
        throw new Error(`Could not find ${uid} in the auth db, please check the uid again.`);
    }
    let reqClaim = JSON.stringify(claim);
    if (options?.merge) {
        let attributeJson = new Map();
        if (user.customAttributes !== undefined && user.customAttributes !== "") {
            attributeJson = JSON.parse(user.customAttributes);
        }
        reqClaim = JSON.stringify({ ...attributeJson, ...claim });
    }
    const res = await apiClient.post("/v1/accounts:update", {
        customAttributes: reqClaim,
        targetProjectId: project,
        localId: uid,
    });
    if (res.status !== 200) {
        throw new Error("something went wrong in the request");
    }
    user = await findUser(project, undefined, undefined, uid);
    return user;
}
async function setAllowSmsRegionPolicy(project, countryCodes) {
    const res = await apiClient.patch(`/admin/v2/projects/${project}/config?updateMask=sms_region_config`, {
        sms_region_config: {
            allowlist_only: {
                allowed_regions: countryCodes,
            },
        },
    });
    if (res.status !== 200) {
        throw new Error("SMS Region Policy failed to be configured");
    }
    return true;
}
async function setDenySmsRegionPolicy(project, countryCodes) {
    const res = await apiClient.patch(`/admin/v2/projects/${project}/config?updateMask=sms_region_config`, {
        sms_region_config: {
            allow_by_default: {
                disallowed_regions: countryCodes,
            },
        },
    });
    if (res.status !== 200) {
        throw new Error("SMS Region Policy failed to be configured");
    }
    return true;
}
