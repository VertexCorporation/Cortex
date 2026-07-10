"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseServiceName = parseServiceName;
exports.parseConnectorName = parseConnectorName;
exports.parseCloudSQLInstanceName = parseCloudSQLInstanceName;
exports.isGraphqlName = isGraphqlName;
const error_1 = require("../error");
const serviceNameRegex = /projects\/(?<projectId>[^\/]+)\/locations\/(?<location>[^\/]+)\/services\/(?<serviceId>[^\/]+)/;
function parseServiceName(serviceName) {
    const res = serviceNameRegex.exec(serviceName);
    const projectId = res?.groups?.projectId;
    const location = res?.groups?.location;
    const serviceId = res?.groups?.serviceId;
    if (!projectId || !location || !serviceId) {
        throw new error_1.FirebaseError(`${serviceName} is not a valid service name`);
    }
    const toString = () => {
        return `projects/${projectId}/locations/${location}/services/${serviceId}`;
    };
    return {
        projectId,
        location,
        serviceId,
        toString,
    };
}
const connectorNameRegex = /projects\/(?<projectId>[^\/]+)\/locations\/(?<location>[^\/]+)\/services\/(?<serviceId>[^\/]+)\/connectors\/(?<connectorId>[^\/]+)/;
function parseConnectorName(connectorName) {
    const res = connectorNameRegex.exec(connectorName);
    const projectId = res?.groups?.projectId;
    const location = res?.groups?.location;
    const serviceId = res?.groups?.serviceId;
    const connectorId = res?.groups?.connectorId;
    if (!projectId || !location || !serviceId || !connectorId) {
        throw new error_1.FirebaseError(`${connectorName} is not a valid connector name`);
    }
    const toString = () => {
        return `projects/${projectId}/locations/${location}/services/${serviceId}/connectors/${connectorId}`;
    };
    return {
        projectId,
        location,
        serviceId,
        connectorId,
        toString,
    };
}
const cloudSQLInstanceNameRegex = /projects\/(?<projectId>[^\/]+)\/locations\/(?<location>[^\/]+)\/instances\/(?<instanceId>[^\/]+)/;
function parseCloudSQLInstanceName(cloudSQLInstanceName) {
    const res = cloudSQLInstanceNameRegex.exec(cloudSQLInstanceName);
    const projectId = res?.groups?.projectId;
    const location = res?.groups?.location;
    const instanceId = res?.groups?.instanceId;
    if (!projectId || !location || !instanceId) {
        throw new error_1.FirebaseError(`${cloudSQLInstanceName} is not a valid cloudSQL instance name`);
    }
    const toString = () => {
        return `projects/${projectId}/locations/${location}/instances/${instanceId}`;
    };
    return {
        projectId,
        location,
        instanceId,
        toString,
    };
}
const graphqlNameRegex = /^[A-Za-z_][A-Za-z0-9_]*$/;
function isGraphqlName(name) {
    return graphqlNameRegex.test(name);
}
