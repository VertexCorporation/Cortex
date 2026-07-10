"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const error_1 = require("../error");
const requireAuth_1 = require("../requireAuth");
const requirePermissions_1 = require("../requirePermissions");
const ensureApis_1 = require("../dataconnect/ensureApis");
const permissionsSetup_1 = require("../gcp/cloudsql/permissionsSetup");
const schemaMigration_1 = require("../dataconnect/schemaMigration");
const connect_1 = require("../gcp/cloudsql/connect");
const load_1 = require("../dataconnect/load");
const types_1 = require("../dataconnect/types");
exports.command = new command_1.Command("dataconnect:sql:setup")
    .description("set up your CloudSQL database")
    .option("--service <serviceId>", "the serviceId of the SQL Connect service")
    .option("--location <location>", "the location of the SQL Connect service. Only needed if service ID is used in multiple locations.")
    .before(requirePermissions_1.requirePermissions, [
    "firebasedataconnect.services.list",
    "firebasedataconnect.schemas.list",
    "firebasedataconnect.schemas.update",
    "cloudsql.instances.connect",
])
    .before(requireAuth_1.requireAuth)
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    await (0, ensureApis_1.ensureApis)(projectId);
    const serviceInfo = await (0, load_1.pickOneService)(projectId, options.config, options.service, options.location);
    const instanceId = (0, types_1.mainSchemaYaml)(serviceInfo.dataConnectYaml).datasource.postgresql?.cloudSql
        .instanceId;
    if (!instanceId) {
        throw new error_1.FirebaseError("dataconnect.yaml is missing field schema.datasource.postgresql.cloudsql.instanceId");
    }
    const { serviceName, instanceName, databaseId, schemaName } = (0, schemaMigration_1.getIdentifiers)((0, types_1.mainSchema)(serviceInfo.schemas));
    await (0, schemaMigration_1.ensureServiceIsConnectedToCloudSql)(serviceName, instanceName, databaseId, true, schemaName);
    await (0, connect_1.setupIAMUsers)(instanceId, options);
    const schemaInfo = await (0, permissionsSetup_1.getSchemaMetadata)(instanceId, databaseId, schemaName, options);
    await (0, permissionsSetup_1.setupSQLPermissions)(instanceId, databaseId, schemaInfo, options);
});
