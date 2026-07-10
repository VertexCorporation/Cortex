"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEFAULT_DATABASE_VERSION = void 0;
exports.iamUserIsCSQLAdmin = iamUserIsCSQLAdmin;
exports.listInstances = listInstances;
exports.getInstance = getInstance;
exports.instanceConsoleLink = instanceConsoleLink;
exports.createInstance = createInstance;
exports.updateInstanceForDataConnect = updateInstanceForDataConnect;
exports.listDatabases = listDatabases;
exports.getDatabase = getDatabase;
exports.createDatabase = createDatabase;
exports.deleteDatabase = deleteDatabase;
exports.createUser = createUser;
exports.getUser = getUser;
exports.deleteUser = deleteUser;
exports.listUsers = listUsers;
const apiv2_1 = require("../../apiv2");
const api_1 = require("../../api");
const clc = require("colorette");
const operationPoller = require("../../operation-poller");
const projectUtils_1 = require("../../projectUtils");
const logger_1 = require("../../logger");
const iam_1 = require("../iam");
const error_1 = require("../../error");
const freeTrial_1 = require("../../dataconnect/freeTrial");
const API_VERSION = "v1";
const client = new apiv2_1.Client({
    urlPrefix: (0, api_1.cloudSQLAdminOrigin)(),
    auth: true,
    apiVersion: API_VERSION,
});
async function iamUserIsCSQLAdmin(options) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const requiredPermissions = [
        "cloudsql.instances.connect",
        "cloudsql.instances.get",
        "cloudsql.users.create",
        "cloudsql.users.update",
    ];
    try {
        const iamResult = await (0, iam_1.testIamPermissions)(projectId, requiredPermissions);
        return iamResult.passed;
    }
    catch (err) {
        logger_1.logger.debug(`[iam] error while checking permissions, command may fail: ${err}`);
        return false;
    }
}
async function listInstances(projectId) {
    const res = await client.get(`projects/${projectId}/instances`);
    return res.body.items ?? [];
}
async function getInstance(projectId, instanceId) {
    const res = await client.get(`projects/${projectId}/instances/${instanceId}`);
    if (res.body.state === "FAILED") {
        throw new error_1.FirebaseError(`Cloud SQL instance ${clc.bold(instanceId)} is in a failed state.\nGo to ${instanceConsoleLink(projectId, instanceId)} to repair or delete it.`);
    }
    return res.body;
}
function instanceConsoleLink(projectId, instanceId) {
    return `https://console.cloud.google.com/sql/instances/${instanceId}/overview?project=${projectId}`;
}
exports.DEFAULT_DATABASE_VERSION = "POSTGRES_18";
async function createInstance(args) {
    const databaseFlags = [{ name: "cloudsql.iam_authentication", value: "on" }];
    if (args.enableGoogleMlIntegration) {
        databaseFlags.push({ name: "cloudsql.enable_google_ml_integration", value: "on" });
    }
    try {
        await client.post(`projects/${args.projectId}/instances`, {
            name: args.instanceId,
            region: args.location,
            databaseVersion: exports.DEFAULT_DATABASE_VERSION,
            settings: {
                tier: "db-f1-micro",
                edition: "ENTERPRISE",
                ipConfiguration: {
                    authorizedNetworks: [],
                },
                enableGoogleMlIntegration: args.enableGoogleMlIntegration,
                databaseFlags,
                storageAutoResize: false,
                userLabels: { "firebase-data-connect": args.freeTrialLabel },
                insightsConfig: {
                    queryInsightsEnabled: true,
                    queryPlansPerMinute: 5,
                    queryStringLength: 1024,
                },
            },
        });
        return;
    }
    catch (err) {
        await handleCreateInstanceError(err, args.location, args.projectId);
        throw err;
    }
}
async function updateInstanceForDataConnect(instance, enableGoogleMlIntegration) {
    let dbFlags = setDatabaseFlag({ name: "cloudsql.iam_authentication", value: "on" }, instance.settings.databaseFlags);
    if (enableGoogleMlIntegration) {
        dbFlags = setDatabaseFlag({ name: "cloudsql.enable_google_ml_integration", value: "on" }, dbFlags);
    }
    const op = await client.patch(`projects/${instance.project}/instances/${instance.name}`, {
        settings: {
            ipConfiguration: {
                enablePrivatePathForGoogleCloudServices: !!instance?.settings?.ipConfiguration?.privateNetwork,
            },
            databaseFlags: dbFlags,
            enableGoogleMlIntegration,
        },
    });
    const opName = `projects/${instance.project}/operations/${op.body.name}`;
    const pollRes = await operationPoller.pollOperation({
        apiOrigin: (0, api_1.cloudSQLAdminOrigin)(),
        apiVersion: API_VERSION,
        operationResourceName: opName,
        doneFn: (op) => op.status === "DONE",
        masterTimeout: 1200000,
    });
    return pollRes;
}
async function handleCreateInstanceError(err, region, projectId) {
    if (err?.message?.includes("Not allowed to set system label: firebase-data-connect")) {
        throw new error_1.FirebaseError(`Cloud SQL free trial instances are not yet available in ${region}. Please check https://firebase.google.com/docs/data-connect/ for a full list of available regions.`);
    }
    if (err?.message?.includes("The billing account is not in good standing") &&
        (await (0, freeTrial_1.checkFreeTrialInstanceUsed)(projectId))) {
        throw new error_1.FirebaseError(`You have already used your Cloud SQL free trial. To create more instances, you need to attach a billing account to project ${projectId}.`);
    }
}
function setDatabaseFlag(flag, flags = []) {
    const temp = flags.filter((f) => f.name !== flag.name);
    temp.push(flag);
    return temp;
}
async function listDatabases(projectId, instanceId) {
    const res = await client.get(`projects/${projectId}/instances/${instanceId}/databases`);
    return res.body.items;
}
async function getDatabase(projectId, instanceId, databaseId) {
    const res = await client.get(`projects/${projectId}/instances/${instanceId}/databases/${databaseId}`);
    return res.body;
}
async function createDatabase(projectId, instanceId, databaseId) {
    const op = await client.post(`projects/${projectId}/instances/${instanceId}/databases`, {
        project: projectId,
        instance: instanceId,
        name: databaseId,
    });
    const opName = `projects/${projectId}/operations/${op.body.name}`;
    const pollRes = await operationPoller.pollOperation({
        apiOrigin: (0, api_1.cloudSQLAdminOrigin)(),
        apiVersion: API_VERSION,
        operationResourceName: opName,
        doneFn: (op) => op.status === "DONE",
    });
    return pollRes;
}
async function deleteDatabase(projectId, instanceId, databaseId) {
    const res = await client.delete(`projects/${projectId}/instances/${instanceId}/databases/${databaseId}`);
    return res.body;
}
async function createUser(projectId, instanceId, type, username, password, retryTimeout) {
    const maxRetries = 3;
    let retries = 0;
    while (true) {
        try {
            const op = await client.post(`projects/${projectId}/instances/${instanceId}/users`, {
                name: username,
                instance: instanceId,
                project: projectId,
                password: password,
                sqlserverUserDetails: {
                    disabled: false,
                    serverRoles: ["cloudsqlsuperuser"],
                },
                type,
            });
            const opName = `projects/${projectId}/operations/${op.body.name}`;
            const pollRes = await operationPoller.pollOperation({
                apiOrigin: (0, api_1.cloudSQLAdminOrigin)(),
                apiVersion: API_VERSION,
                operationResourceName: opName,
                doneFn: (op) => op.status === "DONE",
            });
            return pollRes;
        }
        catch (err) {
            if (builtinRoleNotReady(err.message) && retries < maxRetries) {
                retries++;
                await new Promise((resolve) => {
                    setTimeout(resolve, retryTimeout ?? 1000 * retries);
                });
            }
            else {
                throw err;
            }
        }
    }
}
function builtinRoleNotReady(message) {
    return message.includes("cloudsqliamuser");
}
async function getUser(projectId, instanceId, username) {
    const res = await client.get(`projects/${projectId}/instances/${instanceId}/users/${username}`);
    return res.body;
}
async function deleteUser(projectId, instanceId, username) {
    const res = await client.delete(`projects/${projectId}/instances/${instanceId}/users`, {
        queryParams: {
            name: username,
        },
    });
    return res.body;
}
async function listUsers(projectId, instanceId) {
    const res = await client.get(`projects/${projectId}/instances/${instanceId}/users`);
    return res.body.items;
}
