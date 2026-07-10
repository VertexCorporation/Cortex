"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FIREBASE_MANAGED = exports.secretManagerConsoleUri = void 0;
exports.getSecret = getSecret;
exports.listSecrets = listSecrets;
exports.getSecretMetadata = getSecretMetadata;
exports.listSecretVersions = listSecretVersions;
exports.getSecretVersion = getSecretVersion;
exports.accessSecretVersion = accessSecretVersion;
exports.destroySecretVersion = destroySecretVersion;
exports.secretExists = secretExists;
exports.parseSecretResourceName = parseSecretResourceName;
exports.parseSecretVersionResourceName = parseSecretVersionResourceName;
exports.toSecretVersionResourceName = toSecretVersionResourceName;
exports.createSecret = createSecret;
exports.patchSecret = patchSecret;
exports.deleteSecret = deleteSecret;
exports.addVersion = addVersion;
exports.getIamPolicy = getIamPolicy;
exports.setIamPolicy = setIamPolicy;
exports.ensureServiceAgentRole = ensureServiceAgentRole;
exports.checkServiceAgentRole = checkServiceAgentRole;
exports.isFunctionsManaged = isFunctionsManaged;
exports.isAppHostingManaged = isAppHostingManaged;
exports.ensureApi = ensureApi;
exports.labels = labels;
const utils_1 = require("../utils");
const error_1 = require("../error");
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
const ensureApiEnabled = require("../ensureApiEnabled");
const projectUtils_1 = require("../projectUtils");
const SECRET_NAME_REGEX = new RegExp("projects\\/" +
    "(?<project>(?:\\d+)|(?:[A-Za-z]+[A-Za-z\\d-]*[A-Za-z\\d]?))\\/" +
    "secrets\\/" +
    "(?<secret>[A-Za-z\\d\\-_]+)");
const SECRET_VERSION_NAME_REGEX = new RegExp(SECRET_NAME_REGEX.source + "\\/versions\\/" + "(?<version>latest|[0-9]+)");
const secretManagerConsoleUri = (projectId) => `https://console.cloud.google.com/security/secret-manager?project=${projectId}`;
exports.secretManagerConsoleUri = secretManagerConsoleUri;
const API_VERSION = "v1";
const client = new apiv2_1.Client({ urlPrefix: (0, api_1.secretManagerOrigin)(), apiVersion: API_VERSION });
async function getSecret(projectId, name) {
    const getRes = await client.get(`projects/${projectId}/secrets/${name}`);
    const secret = parseSecretResourceName(getRes.body.name);
    secret.labels = getRes.body.labels ?? {};
    secret.replication = getRes.body.replication ?? {};
    return secret;
}
async function listSecrets(projectId, filter) {
    const secrets = [];
    const path = `projects/${projectId}/secrets`;
    const baseOpts = filter ? { queryParams: { filter } } : {};
    let pageToken = "";
    while (true) {
        const opts = pageToken === ""
            ? baseOpts
            : { ...baseOpts, queryParams: { ...baseOpts?.queryParams, pageToken } };
        const res = await client.get(path, opts);
        for (const s of res.body.secrets || []) {
            secrets.push({
                ...parseSecretResourceName(s.name),
                labels: s.labels ?? {},
                replication: s.replication ?? {},
            });
        }
        if (!res.body.nextPageToken) {
            break;
        }
        pageToken = res.body.nextPageToken;
    }
    return secrets;
}
async function getSecretMetadata(projectId, secretName, version) {
    const secretInfo = {};
    try {
        secretInfo.secret = await getSecret(projectId, secretName);
        secretInfo.secretVersion = await getSecretVersion(projectId, secretName, version);
    }
    catch (err) {
        if (err.status !== 404) {
            throw err;
        }
    }
    return secretInfo;
}
async function listSecretVersions(projectId, name, filter) {
    const secrets = [];
    const path = `projects/${projectId}/secrets/${name}/versions`;
    const baseOpts = filter ? { queryParams: { filter } } : {};
    let pageToken = "";
    while (true) {
        const opts = pageToken === ""
            ? baseOpts
            : { ...baseOpts, queryParams: { ...baseOpts?.queryParams, pageToken } };
        const res = await client.get(path, opts);
        for (const s of res.body.versions || []) {
            secrets.push({
                ...parseSecretVersionResourceName(s.name),
                state: s.state,
                createTime: s.createTime,
            });
        }
        if (!res.body.nextPageToken) {
            break;
        }
        pageToken = res.body.nextPageToken;
    }
    return secrets;
}
async function getSecretVersion(projectId, name, version) {
    const getRes = await client.get(`projects/${projectId}/secrets/${name}/versions/${version}`);
    return {
        ...parseSecretVersionResourceName(getRes.body.name),
        state: getRes.body.state,
        createTime: getRes.body.createTime,
    };
}
async function accessSecretVersion(projectId, name, version) {
    const res = await client.get(`projects/${projectId}/secrets/${name}/versions/${version}:access`);
    return Buffer.from(res.body.payload.data, "base64").toString();
}
async function destroySecretVersion(projectId, name, version) {
    if (version === "latest") {
        const sv = await getSecretVersion(projectId, name, "latest");
        version = sv.versionId;
    }
    await client.post(`projects/${projectId}/secrets/${name}/versions/${version}:destroy`);
}
async function secretExists(projectId, name) {
    try {
        await getSecret(projectId, name);
        return true;
    }
    catch (err) {
        if (err.status === 404) {
            return false;
        }
        throw err;
    }
}
function parseSecretResourceName(resourceName) {
    const match = SECRET_NAME_REGEX.exec(resourceName);
    if (!match?.groups) {
        throw new error_1.FirebaseError(`Invalid secret resource name [${resourceName}].`);
    }
    return {
        projectId: match.groups.project,
        name: match.groups.secret,
        labels: {},
        replication: {},
    };
}
function parseSecretVersionResourceName(resourceName) {
    const match = resourceName.match(SECRET_VERSION_NAME_REGEX);
    if (!match?.groups) {
        throw new error_1.FirebaseError(`Invalid secret version resource name [${resourceName}].`);
    }
    return {
        secret: {
            projectId: match.groups.project,
            name: match.groups.secret,
            labels: {},
            replication: {},
        },
        versionId: match.groups.version,
        createTime: "",
    };
}
function toSecretVersionResourceName(secretVersion) {
    return `projects/${secretVersion.secret.projectId}/secrets/${secretVersion.secret.name}/versions/${secretVersion.versionId}`;
}
async function createSecret(projectId, name, labels, location) {
    let replication;
    if (location) {
        replication = {
            userManaged: {
                replicas: [
                    {
                        location,
                    },
                ],
            },
        };
    }
    else {
        replication = { automatic: {} };
    }
    const createRes = await client.post(`projects/${projectId}/secrets`, {
        name,
        replication,
        labels,
    }, { queryParams: { secretId: name } });
    return {
        ...parseSecretResourceName(createRes.body.name),
        labels,
        replication,
    };
}
async function patchSecret(projectId, name, labels) {
    const fullName = `projects/${projectId}/secrets/${name}`;
    const res = await client.patch(fullName, { name: fullName, labels }, { queryParams: { updateMask: "labels" } });
    return {
        ...parseSecretResourceName(res.body.name),
        labels: res.body.labels,
        replication: res.body.replication,
    };
}
async function deleteSecret(projectId, name) {
    const path = `projects/${projectId}/secrets/${name}`;
    await client.delete(path);
}
async function addVersion(projectId, name, payloadData) {
    const res = await client.post(`projects/${projectId}/secrets/${name}:addVersion`, {
        payload: {
            data: Buffer.from(payloadData).toString("base64"),
        },
    });
    return {
        ...parseSecretVersionResourceName(res.body.name),
        state: res.body.state,
        createTime: "",
    };
}
async function getIamPolicy(secret) {
    const res = await client.get(`projects/${secret.projectId}/secrets/${secret.name}:getIamPolicy`);
    return res.body;
}
async function setIamPolicy(secret, bindings) {
    await client.post(`projects/${secret.projectId}/secrets/${secret.name}:setIamPolicy`, {
        policy: {
            bindings,
        },
        updateMask: "bindings",
    });
}
async function ensureServiceAgentRole(secret, serviceAccountEmails, role) {
    const bindings = await checkServiceAgentRole(secret, serviceAccountEmails, role);
    if (bindings.length) {
        await module.exports.setIamPolicy(secret, bindings);
    }
    (0, utils_1.logLabeledSuccess)("secretmanager", `Granted ${role} on projects/${secret.projectId}/secrets/${secret.name} to ${serviceAccountEmails.join(", ")}`);
}
async function checkServiceAgentRole(secret, serviceAccountEmails, role) {
    const policy = await module.exports.getIamPolicy(secret);
    const bindings = policy.bindings || [];
    let binding = bindings.find((b) => b.role === role);
    if (!binding) {
        binding = { role, members: [] };
        bindings.push(binding);
    }
    let shouldShortCircuit = true;
    for (const serviceAccount of serviceAccountEmails) {
        if (!binding.members.find((m) => m === `serviceAccount:${serviceAccount}`)) {
            binding.members.push(`serviceAccount:${serviceAccount}`);
            shouldShortCircuit = false;
        }
    }
    if (shouldShortCircuit)
        return [];
    return bindings;
}
exports.FIREBASE_MANAGED = "firebase-managed";
function isFunctionsManaged(secret) {
    return (secret.labels[exports.FIREBASE_MANAGED] === "true" || secret.labels[exports.FIREBASE_MANAGED] === "functions");
}
function isAppHostingManaged(secret) {
    return secret.labels[exports.FIREBASE_MANAGED] === "apphosting";
}
function ensureApi(options) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    return ensureApiEnabled.ensure(projectId, (0, api_1.secretManagerOrigin)(), "secretmanager", true);
}
function labels(product = "functions") {
    return { [exports.FIREBASE_MANAGED]: product };
}
