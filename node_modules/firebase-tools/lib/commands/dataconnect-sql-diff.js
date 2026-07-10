"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const ensureApis_1 = require("../dataconnect/ensureApis");
const requirePermissions_1 = require("../requirePermissions");
const load_1 = require("../dataconnect/load");
const schemaMigration_1 = require("../dataconnect/schemaMigration");
const requireAuth_1 = require("../requireAuth");
const types_1 = require("../dataconnect/types");
exports.command = new command_1.Command("dataconnect:sql:diff")
    .description("display the differences between the local SQL Connect schema and your CloudSQL database's schema")
    .option("--service <serviceId>", "the serviceId of the SQL Connect service")
    .option("--location <location>", "the location of the SQL Connect service. Only needed if service ID is used in multiple locations.")
    .before(requirePermissions_1.requirePermissions, [
    "firebasedataconnect.services.list",
    "firebasedataconnect.schemas.list",
    "firebasedataconnect.schemas.update",
])
    .before(requireAuth_1.requireAuth)
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    await (0, ensureApis_1.ensureApis)(projectId);
    const serviceInfo = await (0, load_1.pickOneService)(projectId, options.config, options.service, options.location);
    const diffs = await (0, schemaMigration_1.diffSchema)(options, (0, types_1.mainSchema)(serviceInfo.schemas), (0, types_1.mainSchemaYaml)(serviceInfo.dataConnectYaml).datasource.postgresql?.schemaValidation);
    return { projectId, diffs };
});
