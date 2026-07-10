"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = default_1;
const client = require("../../dataconnect/client");
const utils = require("../../utils");
const types_1 = require("../../dataconnect/types");
const projectUtils_1 = require("../../projectUtils");
const provisionCloudSql_1 = require("../../dataconnect/provisionCloudSql");
const names_1 = require("../../dataconnect/names");
const api_1 = require("../../api");
const ensureApiEnabled = require("../../ensureApiEnabled");
async function default_1(context, options) {
    const dataconnect = context.dataconnect;
    if (!dataconnect) {
        throw new Error("dataconnect.prepare must be run before dataconnect.deploy");
    }
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const serviceInfos = dataconnect.serviceInfos;
    const services = await client.listAllServices(projectId);
    const filters = dataconnect.filters;
    if (serviceInfos.some((si) => {
        return (0, types_1.requiresVector)(si.deploymentMetadata);
    })) {
        await ensureApiEnabled.ensure(projectId, (0, api_1.vertexAIOrigin)(), "dataconnect");
    }
    const servicesToCreate = serviceInfos
        .filter((si) => !services.some((s) => matches(si, s)))
        .filter((si) => {
        return (!filters ||
            filters?.some((f) => si.dataConnectYaml.serviceId === f.serviceId));
    });
    dataconnect.deployStats.numServiceCreated = servicesToCreate.length;
    await Promise.all(servicesToCreate.map(async (s) => {
        const { projectId, locationId, serviceId } = splitName(s.serviceName);
        await client.createService(projectId, locationId, serviceId);
        utils.logLabeledSuccess("dataconnect", `Created service ${s.serviceName}`);
    }));
    utils.logLabeledBullet("dataconnect", "Checking for CloudSQL resources...");
    await Promise.all(serviceInfos
        .filter((si) => {
        return (!filters ||
            filters?.some((f) => si.dataConnectYaml.serviceId === f.serviceId));
    })
        .map(async (s) => {
        const postgresDatasource = (0, types_1.mainSchema)(s.schemas).datasources.find((d) => d.postgresql);
        if (postgresDatasource) {
            const instanceId = postgresDatasource.postgresql?.cloudSql?.instance.split("/").pop();
            const databaseId = postgresDatasource.postgresql?.database;
            if (!instanceId || !databaseId) {
                return Promise.resolve();
            }
            return (0, provisionCloudSql_1.setupCloudSql)({
                projectId,
                location: (0, names_1.parseServiceName)(s.serviceName).location,
                instanceId,
                databaseId,
                requireGoogleMlIntegration: (0, types_1.requiresVector)(s.deploymentMetadata),
                source: "deploy",
            });
        }
    }));
    return;
}
function matches(si, s) {
    return si.serviceName === s.name;
}
function splitName(serviceName) {
    const parts = serviceName.split("/");
    return {
        projectId: parts[1],
        locationId: parts[3],
        serviceId: parts[5],
    };
}
