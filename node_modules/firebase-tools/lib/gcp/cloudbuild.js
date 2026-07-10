"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createConnection = createConnection;
exports.getConnection = getConnection;
exports.listConnections = listConnections;
exports.deleteConnection = deleteConnection;
exports.fetchLinkableRepositories = fetchLinkableRepositories;
exports.createRepository = createRepository;
exports.getRepository = getRepository;
exports.deleteRepository = deleteRepository;
exports.getDefaultServiceAccount = getDefaultServiceAccount;
exports.getDefaultServiceAgent = getDefaultServiceAgent;
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
const PAGE_SIZE_MAX = 100;
const client = new apiv2_1.Client({
    urlPrefix: (0, api_1.cloudbuildOrigin)(),
    auth: true,
    apiVersion: "v2",
});
async function createConnection(projectId, location, connectionId, githubConfig = {}) {
    const res = await client.post(`projects/${projectId}/locations/${location}/connections`, { githubConfig }, { queryParams: { connectionId } });
    return res.body;
}
async function getConnection(projectId, location, connectionId) {
    const name = `projects/${projectId}/locations/${location}/connections/${connectionId}`;
    const res = await client.get(name);
    return res.body;
}
async function listConnections(projectId, location) {
    const conns = [];
    const getNextPage = async (pageToken = "") => {
        const res = await client.get(`/projects/${projectId}/locations/${location}/connections`, {
            queryParams: {
                pageSize: PAGE_SIZE_MAX,
                pageToken,
            },
        });
        if (Array.isArray(res.body.connections)) {
            conns.push(...res.body.connections);
        }
        if (res.body.nextPageToken) {
            await getNextPage(res.body.nextPageToken);
        }
    };
    await getNextPage();
    return conns;
}
async function deleteConnection(projectId, location, connectionId) {
    const name = `projects/${projectId}/locations/${location}/connections/${connectionId}`;
    const res = await client.delete(name);
    return res.body;
}
async function fetchLinkableRepositories(projectId, location, connectionId, pageToken = "", pageSize = 1000) {
    const name = `projects/${projectId}/locations/${location}/connections/${connectionId}:fetchLinkableRepositories`;
    const res = await client.get(name, {
        queryParams: {
            pageSize,
            pageToken,
        },
    });
    return res.body;
}
async function createRepository(projectId, location, connectionId, repositoryId, remoteUri) {
    const res = await client.post(`projects/${projectId}/locations/${location}/connections/${connectionId}/repositories`, { remoteUri }, { queryParams: { repositoryId } });
    return res.body;
}
async function getRepository(projectId, location, connectionId, repositoryId) {
    const name = `projects/${projectId}/locations/${location}/connections/${connectionId}/repositories/${repositoryId}`;
    const res = await client.get(name);
    return res.body;
}
async function deleteRepository(projectId, location, connectionId, repositoryId) {
    const name = `projects/${projectId}/locations/${location}/connections/${connectionId}/repositories/${repositoryId}`;
    const res = await client.delete(name);
    return res.body;
}
function getDefaultServiceAccount(projectNumber) {
    return `${projectNumber}@cloudbuild.gserviceaccount.com`;
}
function getDefaultServiceAgent(projectNumber) {
    return `service-${projectNumber}@gcp-sa-cloudbuild.iam.gserviceaccount.com`;
}
