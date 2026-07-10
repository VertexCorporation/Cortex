"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isGraphQLResponseError = exports.isGraphQLResponse = exports.MAIN_SCHEMA_ID = void 0;
exports.requiresVector = requiresVector;
exports.toDatasource = toDatasource;
exports.mainSchemaYaml = mainSchemaYaml;
exports.secondarySchemaYamls = secondarySchemaYamls;
exports.mainSchema = mainSchema;
exports.isMainSchema = isMainSchema;
exports.MAIN_SCHEMA_ID = "main";
function requiresVector(dm) {
    return dm?.primaryDataSource?.postgres?.requiredExtensions?.includes("vector") ?? false;
}
function toDatasource(projectId, locationId, ds) {
    if (ds?.postgresql) {
        return {
            postgresql: {
                database: ds.postgresql.database,
                schema: ds.postgresql.schema,
                cloudSql: {
                    instance: `projects/${projectId}/locations/${locationId}/instances/${ds.postgresql.cloudSql.instanceId}`,
                },
                schemaValidation: ds.postgresql.schemaValidation,
            },
        };
    }
    if (ds?.httpGraphql) {
        return {
            httpGraphql: {
                uri: ds.httpGraphql.uri,
                timeout: ds.httpGraphql.timeout,
            },
        };
    }
    return {};
}
function mainSchemaYaml(dataconnectYaml) {
    if (dataconnectYaml.schema) {
        return dataconnectYaml.schema;
    }
    const mainSch = dataconnectYaml.schemas?.find((s) => s.id === exports.MAIN_SCHEMA_ID || !s.id);
    if (!mainSch) {
        throw new Error(`Service ${dataconnectYaml.serviceId} has no main schema defined`);
    }
    return mainSch;
}
function secondarySchemaYamls(dataconnectYaml) {
    if (dataconnectYaml.schema) {
        return [];
    }
    return (dataconnectYaml.schemas || []).filter((s) => s.id && s.id !== exports.MAIN_SCHEMA_ID);
}
function mainSchema(schemas) {
    const mainSch = schemas.find((s) => isMainSchema(s));
    if (!mainSch) {
        throw new Error(`No main schema is defined`);
    }
    return mainSch;
}
function isMainSchema(schema) {
    return schema.name.endsWith(`/schemas/${exports.MAIN_SCHEMA_ID}`);
}
const isGraphQLResponse = (g) => !!g.data || !!g.errors;
exports.isGraphQLResponse = isGraphQLResponse;
const isGraphQLResponseError = (g) => !!g.error?.message || !!g.message;
exports.isGraphQLResponseError = isGraphQLResponseError;
