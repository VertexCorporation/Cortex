"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listLocations = listLocations;
exports.getService = getService;
exports.listAllServices = listAllServices;
exports.createService = createService;
exports.deleteService = deleteService;
exports.getSchema = getSchema;
exports.listSchemas = listSchemas;
exports.upsertSchema = upsertSchema;
exports.deleteSchema = deleteSchema;
exports.getConnector = getConnector;
exports.deleteConnector = deleteConnector;
exports.listConnectors = listConnectors;
exports.upsertConnector = upsertConnector;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const operationPoller = require("../operation-poller");
const types = require("./types");
const DATACONNECT_API_VERSION = "v1";
const PAGE_SIZE_MAX = 100;
const dataconnectClient = () => new apiv2_1.Client({
    urlPrefix: (0, api_1.dataconnectOrigin)(),
    apiVersion: DATACONNECT_API_VERSION,
    auth: true,
});
async function listLocations(projectId) {
    const res = await dataconnectClient().get(`/projects/${projectId}/locations`);
    return res.body?.locations?.map((l) => l.locationId) ?? [];
}
async function getService(serviceName) {
    const res = await dataconnectClient().get(serviceName);
    return res.body;
}
async function listAllServices(projectId) {
    const res = await dataconnectClient().get(`/projects/${projectId}/locations/-/services`);
    return res.body.services ?? [];
}
async function createService(projectId, locationId, serviceId) {
    try {
        const op = await dataconnectClient().post(`/projects/${projectId}/locations/${locationId}/services`, {
            name: `projects/${projectId}/locations/${locationId}/services/${serviceId}`,
        }, {
            queryParams: {
                service_id: serviceId,
            },
        });
        const pollRes = await operationPoller.pollOperation({
            apiOrigin: (0, api_1.dataconnectOrigin)(),
            apiVersion: DATACONNECT_API_VERSION,
            operationResourceName: op.body.name,
        });
        return pollRes;
    }
    catch (err) {
        if (err.status !== 409) {
            throw err;
        }
        return undefined;
    }
}
async function deleteService(serviceName) {
    const op = await dataconnectClient().delete(serviceName, {
        queryParams: { force: "true" },
    });
    const pollRes = await operationPoller.pollOperation({
        apiOrigin: (0, api_1.dataconnectOrigin)(),
        apiVersion: DATACONNECT_API_VERSION,
        operationResourceName: op.body.name,
    });
    return pollRes;
}
async function getSchema(serviceName, schemaId = types.MAIN_SCHEMA_ID) {
    try {
        const res = await dataconnectClient().get(`${serviceName}/schemas/${schemaId}`);
        return res.body;
    }
    catch (err) {
        if (err.status !== 404) {
            throw err;
        }
        return undefined;
    }
}
async function listSchemas(serviceName, fields = []) {
    const schemas = [];
    const getNextPage = async (pageToken = "") => {
        const res = await dataconnectClient().get(`${serviceName}/schemas`, {
            queryParams: {
                pageSize: PAGE_SIZE_MAX,
                pageToken,
                fields: fields.join(","),
            },
        });
        schemas.push(...(res.body.schemas || []));
        if (res.body.nextPageToken) {
            await getNextPage(res.body.nextPageToken);
        }
    };
    await getNextPage();
    return schemas;
}
async function upsertSchema(schema, validateOnly = false, async = false) {
    const op = await dataconnectClient().patch(`${schema.name}`, schema, {
        queryParams: {
            allowMissing: "true",
            validateOnly: validateOnly ? "true" : "false",
        },
    });
    if (validateOnly || async) {
        return;
    }
    return operationPoller.pollOperation({
        apiOrigin: (0, api_1.dataconnectOrigin)(),
        apiVersion: DATACONNECT_API_VERSION,
        operationResourceName: op.body.name,
        masterTimeout: 60000,
    });
}
async function deleteSchema(name) {
    const op = await dataconnectClient().delete(name);
    await operationPoller.pollOperation({
        apiOrigin: (0, api_1.dataconnectOrigin)(),
        apiVersion: DATACONNECT_API_VERSION,
        operationResourceName: op.body.name,
    });
    return;
}
async function getConnector(name) {
    const res = await dataconnectClient().get(name);
    return res.body;
}
async function deleteConnector(name) {
    const op = await dataconnectClient().delete(name);
    await operationPoller.pollOperation({
        apiOrigin: (0, api_1.dataconnectOrigin)(),
        apiVersion: DATACONNECT_API_VERSION,
        operationResourceName: op.body.name,
    });
    return;
}
async function listConnectors(serviceName, fields = []) {
    const connectors = [];
    const getNextPage = async (pageToken = "") => {
        const res = await dataconnectClient().get(`${serviceName}/connectors`, {
            queryParams: {
                pageSize: PAGE_SIZE_MAX,
                pageToken,
                fields: fields.join(","),
            },
        });
        connectors.push(...(res.body.connectors || []));
        if (res.body.nextPageToken) {
            await getNextPage(res.body.nextPageToken);
        }
    };
    await getNextPage();
    return connectors;
}
async function upsertConnector(connector) {
    const op = await dataconnectClient().patch(`${connector.name}?allow_missing=true`, connector);
    const pollRes = await operationPoller.pollOperation({
        apiOrigin: (0, api_1.dataconnectOrigin)(),
        apiVersion: DATACONNECT_API_VERSION,
        operationResourceName: op.body.name,
        masterTimeout: 60000,
    });
    return pollRes;
}
