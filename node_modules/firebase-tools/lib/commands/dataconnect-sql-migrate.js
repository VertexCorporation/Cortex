"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const load_1 = require("../dataconnect/load");
const error_1 = require("../error");
const schemaMigration_1 = require("../dataconnect/schemaMigration");
const requireAuth_1 = require("../requireAuth");
const requirePermissions_1 = require("../requirePermissions");
const ensureApis_1 = require("../dataconnect/ensureApis");
const utils_1 = require("../utils");
const types_1 = require("../dataconnect/types");
exports.command = new command_1.Command("dataconnect:sql:migrate")
    .description("migrate your CloudSQL database's schema to match your local SQL Connect schema")
    .option("--service <serviceId>", "the serviceId of the SQL Connect service")
    .option("--location <location>", "the location of the SQL Connect service. Only needed if service ID is used in multiple locations.")
    .before(requirePermissions_1.requirePermissions, [
    "firebasedataconnect.services.list",
    "firebasedataconnect.schemas.list",
    "firebasedataconnect.schemas.update",
    "cloudsql.instances.connect",
])
    .before(requireAuth_1.requireAuth)
    .withForce("execute any required database changes without prompting")
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    await (0, ensureApis_1.ensureApis)(projectId);
    const serviceInfo = await (0, load_1.pickOneService)(projectId, options.config, options.service, options.location);
    const instanceId = (0, types_1.mainSchemaYaml)(serviceInfo.dataConnectYaml).datasource.postgresql?.cloudSql
        .instanceId;
    if (!instanceId) {
        throw new error_1.FirebaseError("dataconnect.yaml is missing field schema.datasource.postgresql.cloudsql.instanceId");
    }
    const diffs = await (0, schemaMigration_1.migrateSchema)({
        options,
        schema: (0, types_1.mainSchema)(serviceInfo.schemas),
        validateOnly: true,
        schemaValidation: (0, types_1.mainSchemaYaml)(serviceInfo.dataConnectYaml).datasource.postgresql
            ?.schemaValidation,
    });
    if (diffs.length) {
        (0, utils_1.logLabeledSuccess)("dataconnect", `Database schema sucessfully migrated! Run 'firebase deploy' to deploy your new schema to your SQL Connect service.`);
    }
    else {
        (0, utils_1.logLabeledSuccess)("dataconnect", "Database schema is already up to date!");
    }
    return { projectId, diffs };
});
