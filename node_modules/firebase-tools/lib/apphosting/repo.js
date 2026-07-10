"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseConnectionName = parseConnectionName;
exports.linkGitHubRepository = linkGitHubRepository;
exports.getOrCreateOauthConnection = getOrCreateOauthConnection;
exports.createConnection = createConnection;
exports.getOrCreateConnection = getOrCreateConnection;
exports.getOrCreateRepository = getOrCreateRepository;
exports.listAppHostingConnections = listAppHostingConnections;
exports.fetchAllRepositories = fetchAllRepositories;
const clc = require("colorette");
const gcb = require("../gcp/cloudbuild");
const rm = require("../gcp/resourceManager");
const poller = require("../operation-poller");
const utils = require("../utils");
const api_1 = require("../api");
const error_1 = require("../error");
const prompt_1 = require("../prompt");
const getProjectNumber_1 = require("../getProjectNumber");
const fuzzy = require("fuzzy");
const APPHOSTING_CONN_PATTERN = /.+\/apphosting-github-conn-.+$/;
const APPHOSTING_OAUTH_CONN_NAME = "apphosting-github-oauth";
const CONNECTION_NAME_REGEX = /^projects\/(?<projectId>[^\/]+)\/locations\/(?<location>[^\/]+)\/connections\/(?<id>[^\/]+)$/;
function parseConnectionName(name) {
    const match = CONNECTION_NAME_REGEX.exec(name);
    if (!match || typeof match.groups === "undefined") {
        return;
    }
    const { projectId, location, id } = match.groups;
    return {
        projectId,
        location,
        id,
    };
}
const gcbPollerOptions = {
    apiOrigin: (0, api_1.cloudbuildOrigin)(),
    apiVersion: "v2",
    masterTimeout: 25 * 60 * 1000,
    maxBackoff: 10000,
};
function extractRepoSlugFromUri(remoteUri) {
    const match = /github.com\/(.+).git/.exec(remoteUri);
    if (!match) {
        return undefined;
    }
    return match[1];
}
function generateRepositoryId(remoteUri) {
    return extractRepoSlugFromUri(remoteUri)?.replaceAll("/", "-");
}
function generateConnectionId() {
    const randomHash = Math.random().toString(36).slice(6);
    return `apphosting-github-conn-${randomHash}`;
}
const ADD_CONN_CHOICE = "@ADD_CONN";
async function linkGitHubRepository(projectId, location) {
    utils.logBullet(clc.bold(`${clc.yellow("===")} Import a GitHub repository`));
    const oauthConn = await getOrCreateOauthConnection(projectId, location);
    const existingConns = await listAppHostingConnections(projectId);
    if (existingConns.length === 0) {
        existingConns.push(await createFullyInstalledConnection(projectId, location, generateConnectionId(), oauthConn));
    }
    let repoRemoteUri;
    let connection;
    do {
        if (repoRemoteUri === ADD_CONN_CHOICE) {
            existingConns.push(await createFullyInstalledConnection(projectId, location, generateConnectionId(), oauthConn));
        }
        const selection = await promptRepositoryUri(projectId, existingConns);
        repoRemoteUri = selection.remoteUri;
        connection = selection.connection;
    } while (repoRemoteUri === ADD_CONN_CHOICE);
    const { id: connectionId } = parseConnectionName(connection.name);
    await getOrCreateConnection(projectId, location, connectionId, {
        authorizerCredential: connection.githubConfig?.authorizerCredential,
        appInstallationId: connection.githubConfig?.appInstallationId,
    });
    const repo = await getOrCreateRepository(projectId, location, connectionId, repoRemoteUri);
    utils.logSuccess(`Successfully linked GitHub repository at remote URI`);
    utils.logSuccess(`\t${repoRemoteUri}`);
    return repo;
}
async function createFullyInstalledConnection(projectId, location, connectionId, oauthConn) {
    let conn = await createConnection(projectId, location, connectionId, {
        authorizerCredential: oauthConn.githubConfig?.authorizerCredential,
    });
    while (conn.installationState.stage !== "COMPLETE") {
        utils.logBullet("Install the Cloud Build GitHub app to enable access to GitHub repositories");
        const targetUri = conn.installationState.actionUri;
        utils.logBullet(targetUri);
        await utils.openInBrowser(targetUri);
        await (0, prompt_1.input)("Press Enter once you have installed or configured the Cloud Build GitHub app to access your GitHub repo.");
        conn = await gcb.getConnection(projectId, location, connectionId);
    }
    return conn;
}
async function getOrCreateOauthConnection(projectId, location) {
    let conn;
    try {
        conn = await gcb.getConnection(projectId, location, APPHOSTING_OAUTH_CONN_NAME);
    }
    catch (err) {
        if (err.status === 404) {
            await ensureSecretManagerAdminGrant(projectId);
            conn = await createConnection(projectId, location, APPHOSTING_OAUTH_CONN_NAME);
        }
        else {
            throw err;
        }
    }
    while (conn.installationState.stage === "PENDING_USER_OAUTH") {
        utils.logBullet("You must authorize the Cloud Build GitHub app.");
        utils.logBullet("Sign in to GitHub and authorize Cloud Build GitHub app:");
        const { url, cleanup } = await utils.openInBrowserPopup(conn.installationState.actionUri, "Authorize the GitHub app");
        utils.logBullet(`\t${url}`);
        await (0, prompt_1.input)("Press Enter once you have authorized the app");
        cleanup();
        const { projectId, location, id } = parseConnectionName(conn.name);
        conn = await gcb.getConnection(projectId, location, id);
    }
    return conn;
}
async function promptRepositoryUri(projectId, connections) {
    const { repos, remoteUriToConnection } = await fetchAllRepositories(projectId, connections);
    const remoteUri = await (0, prompt_1.search)({
        message: "Which GitHub repo do you want to deploy?",
        source: (input) => [
            new prompt_1.Separator(),
            {
                name: "Missing a repo? Select this option to configure your GitHub connection settings",
                value: ADD_CONN_CHOICE,
            },
            new prompt_1.Separator(),
            ...fuzzy
                .filter(input ?? "", repos, {
                extract: (repo) => extractRepoSlugFromUri(repo.remoteUri) || "",
            })
                .map((result) => {
                return {
                    name: extractRepoSlugFromUri(result.original.remoteUri) || "",
                    value: result.original.remoteUri,
                };
            }),
        ],
    });
    return { remoteUri, connection: remoteUriToConnection[remoteUri] };
}
async function ensureSecretManagerAdminGrant(projectId) {
    const projectNumber = await (0, getProjectNumber_1.getProjectNumber)({ projectId });
    const cbsaEmail = gcb.getDefaultServiceAgent(projectNumber);
    const alreadyGranted = await rm.serviceAccountHasRoles(projectId, cbsaEmail, ["roles/secretmanager.admin"], true);
    if (alreadyGranted) {
        return;
    }
    utils.logBullet("To create a new GitHub connection, Secret Manager Admin role (roles/secretmanager.admin) is required on the Cloud Build Service Agent.");
    const grant = await (0, prompt_1.confirm)("Grant the required role to the Cloud Build Service Agent?");
    if (!grant) {
        utils.logBullet("You, or your project administrator, should run the following command to grant the required role:\n\n" +
            "You, or your project adminstrator, can run the following command to grant the required role manually:\n\n" +
            `\tgcloud projects add-iam-policy-binding ${projectId} \\\n` +
            `\t  --member="serviceAccount:${cbsaEmail} \\\n` +
            `\t  --role="roles/secretmanager.admin\n`);
        throw new error_1.FirebaseError("Insufficient IAM permissions to create a new connection to GitHub");
    }
    await rm.addServiceAccountToRoles(projectId, cbsaEmail, ["roles/secretmanager.admin"], true);
    utils.logSuccess("Successfully granted the required role to the Cloud Build Service Agent!");
}
async function createConnection(projectId, location, connectionId, githubConfig) {
    const op = await gcb.createConnection(projectId, location, connectionId, githubConfig);
    const conn = await poller.pollOperation({
        ...gcbPollerOptions,
        pollerName: `create-${location}-${connectionId}`,
        operationResourceName: op.name,
    });
    return conn;
}
async function getOrCreateConnection(projectId, location, connectionId, githubConfig) {
    let conn;
    try {
        conn = await gcb.getConnection(projectId, location, connectionId);
    }
    catch (err) {
        if (err.status === 404) {
            conn = await createConnection(projectId, location, connectionId, githubConfig);
        }
        else {
            throw err;
        }
    }
    return conn;
}
async function getOrCreateRepository(projectId, location, connectionId, remoteUri) {
    const repositoryId = generateRepositoryId(remoteUri);
    if (!repositoryId) {
        throw new error_1.FirebaseError(`Failed to generate repositoryId for URI "${remoteUri}".`);
    }
    let repo;
    try {
        repo = await gcb.getRepository(projectId, location, connectionId, repositoryId);
    }
    catch (err) {
        if (err.status === 404) {
            const op = await gcb.createRepository(projectId, location, connectionId, repositoryId, remoteUri);
            repo = await poller.pollOperation({
                ...gcbPollerOptions,
                pollerName: `create-${location}-${connectionId}-${repositoryId}`,
                operationResourceName: op.name,
            });
        }
        else {
            throw err;
        }
    }
    return repo;
}
async function listAppHostingConnections(projectId) {
    const conns = await gcb.listConnections(projectId, "-");
    return conns.filter((conn) => APPHOSTING_CONN_PATTERN.test(conn.name) &&
        conn.installationState.stage === "COMPLETE" &&
        !conn.disabled);
}
async function fetchAllRepositories(projectId, connections) {
    const repos = [];
    const remoteUriToConnection = {};
    const getNextPage = async (conn, pageToken = "") => {
        const { location, id } = parseConnectionName(conn.name);
        const resp = await gcb.fetchLinkableRepositories(projectId, location, id, pageToken);
        if (resp.repositories && resp.repositories.length > 0) {
            for (const repo of resp.repositories) {
                repos.push(repo);
                remoteUriToConnection[repo.remoteUri] = conn;
            }
        }
        if (resp.nextPageToken) {
            await getNextPage(conn, resp.nextPageToken);
        }
    };
    for (const conn of connections) {
        await getNextPage(conn);
    }
    return { repos, remoteUriToConnection };
}
