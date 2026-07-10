"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.pickOneService = pickOneService;
exports.pickServices = pickServices;
exports.loadAll = loadAll;
exports.load = load;
exports.readFirebaseJson = readFirebaseJson;
exports.readDataConnectYaml = readDataConnectYaml;
exports.inferClientCache = inferClientCache;
exports.readConnectorYaml = readConnectorYaml;
exports.readGQLFiles = readGQLFiles;
exports.squashGraphQL = squashGraphQL;
const path = require("path");
const fs = require("fs-extra");
const clc = require("colorette");
const glob_1 = require("glob");
const error_1 = require("../error");
const types_1 = require("./types");
const utils_1 = require("../utils");
const experiments = require("../experiments");
async function pickOneService(projectId, config, service, location) {
    const services = await pickServices(projectId, config, service, location);
    if (services.length > 1) {
        const serviceIds = services.map((i) => `${i.dataConnectYaml.location}:${i.dataConnectYaml.serviceId}`);
        throw new error_1.FirebaseError(`Multiple services matched. Please specify a service and location. Matched services: ${serviceIds.join(", ")}`);
    }
    return services[0];
}
async function pickServices(projectId, config, serviceId, location) {
    const serviceInfos = await loadAll(projectId, config);
    if (serviceInfos.length === 0) {
        throw new error_1.FirebaseError("No SQL Connect services found in firebase.json. " +
            `\nYou can run ${clc.bold("firebase init dataconnect")} to add a SQL Connect service.`);
    }
    const matchingServices = serviceInfos.filter((i) => (!serviceId || i.dataConnectYaml.serviceId === serviceId) &&
        (!location || i.dataConnectYaml.location === location));
    if (matchingServices.length === 0) {
        const serviceIds = serviceInfos.map((i) => `${i.dataConnectYaml.location}:${i.dataConnectYaml.serviceId}`);
        throw new error_1.FirebaseError(`No service matched service in firebase.json. Available services: ${serviceIds.join(", ")}`);
    }
    return matchingServices;
}
async function loadAll(projectId, config) {
    const serviceCfgs = readFirebaseJson(config);
    return await Promise.all(serviceCfgs.map((c) => load(projectId, config, c.source)));
}
async function load(projectId, config, sourceDirectory) {
    const resolvedDir = config.path(sourceDirectory);
    const dataConnectYaml = await readDataConnectYaml(resolvedDir);
    const serviceName = `projects/${projectId}/locations/${dataConnectYaml.location}/services/${dataConnectYaml.serviceId}`;
    const schemaYamls = dataConnectYaml.schema ? [dataConnectYaml.schema] : dataConnectYaml.schemas;
    const schemas = await Promise.all(schemaYamls.map(async (yaml) => {
        const schemaDir = path.join(resolvedDir, yaml.source);
        const schemaGQLs = await readGQLFiles(schemaDir);
        return {
            name: `${serviceName}/schemas/${yaml.id || types_1.MAIN_SCHEMA_ID}`,
            datasources: [(0, types_1.toDatasource)(projectId, dataConnectYaml.location, yaml.datasource)],
            source: {
                files: schemaGQLs,
            },
        };
    }));
    const connectorInfo = await Promise.all(dataConnectYaml.connectorDirs.map(async (dir) => {
        const connectorDir = path.join(resolvedDir, dir);
        const connectorYaml = await readConnectorYaml(connectorDir);
        const connectorGqls = await readGQLFiles(connectorDir);
        const clientCache = inferClientCache(connectorYaml);
        return {
            directory: connectorDir,
            connectorYaml,
            connector: {
                name: `${serviceName}/connectors/${connectorYaml.connectorId}`,
                source: {
                    files: connectorGqls,
                },
                client_cache: clientCache,
            },
        };
    }));
    return {
        serviceName,
        sourceDirectory: resolvedDir,
        schemas: schemas,
        dataConnectYaml,
        connectorInfo,
    };
}
function readFirebaseJson(config) {
    if (!config?.has("dataconnect")) {
        return [];
    }
    const validator = (cfg) => {
        if (!cfg["source"]) {
            throw new error_1.FirebaseError("Invalid firebase.json: DataConnect requires `source`");
        }
        return {
            source: cfg["source"],
        };
    };
    const configs = config.get("dataconnect");
    if (typeof configs === "object" && !Array.isArray(configs)) {
        return [validator(configs)];
    }
    else if (Array.isArray(configs)) {
        return configs.map(validator);
    }
    else {
        throw new error_1.FirebaseError("Invalid firebase.json: dataconnect should be of the form { source: string }");
    }
}
async function readDataConnectYaml(sourceDirectory) {
    const file = await (0, utils_1.readFileFromDirectory)(sourceDirectory, "dataconnect.yaml");
    const dataconnectYaml = await (0, utils_1.wrappedSafeLoad)(file.source);
    return validateDataConnectYaml(dataconnectYaml);
}
function validateDataConnectYaml(unvalidated) {
    if (!unvalidated["location"]) {
        throw new error_1.FirebaseError("Missing required field 'location' in dataconnect.yaml");
    }
    if (!experiments.isEnabled("fdcwebhooks") && unvalidated["schemas"]) {
        throw new error_1.FirebaseError("Unsupported field 'schemas' in dataconnect.yaml");
    }
    if (!unvalidated["schema"] && !unvalidated["schemas"]) {
        throw new error_1.FirebaseError("Either 'schema' or 'schemas' is required in dataconnect.yaml");
    }
    return unvalidated;
}
function inferClientCache(connectorYaml) {
    const platforms = [
        connectorYaml.generate?.javascriptSdk,
        connectorYaml.generate?.swiftSdk,
        connectorYaml.generate?.kotlinSdk,
        connectorYaml.generate?.dartSdk,
    ];
    for (const sdk of platforms) {
        if (sdk) {
            const sdkList = Array.isArray(sdk) ? sdk : [sdk];
            if (sdkList.some((s) => s.clientCache)) {
                return {
                    strict_validation_enabled: true,
                    entity_id_included: true,
                };
            }
        }
    }
    return undefined;
}
async function readConnectorYaml(sourceDirectory) {
    const file = await (0, utils_1.readFileFromDirectory)(sourceDirectory, "connector.yaml");
    const connectorYaml = await (0, utils_1.wrappedSafeLoad)(file.source);
    return validateConnectorYaml(connectorYaml);
}
function validateConnectorYaml(unvalidated) {
    return unvalidated;
}
async function readGQLFiles(sourceDir) {
    if (!fs.existsSync(sourceDir)) {
        return [];
    }
    const files = await (0, glob_1.glob)("**/*.{gql,graphql}", { cwd: sourceDir, absolute: true, nodir: true });
    return files.map((f) => toFile(sourceDir, f));
}
function toFile(sourceDir, fullPath) {
    const relPath = path.relative(sourceDir, fullPath);
    if (!fs.existsSync(fullPath)) {
        throw new error_1.FirebaseError(`file ${fullPath} not found`);
    }
    const content = fs.readFileSync(fullPath).toString();
    return {
        path: relPath,
        content,
    };
}
function squashGraphQL(source) {
    if (!source.files || !source.files.length) {
        return "";
    }
    if (source.files.length === 1) {
        return source.files[0].content;
    }
    let query = "";
    for (const f of source.files) {
        if (!f.content || !/\S/.test(f.content)) {
            continue;
        }
        query += `### Begin file ${f.path}\n`;
        query += f.content;
        query += `### End file ${f.path}\n`;
    }
    return query;
}
