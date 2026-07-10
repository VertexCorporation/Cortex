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
const error_1 = require("../error");
const permissionsSetup_1 = require("../gcp/cloudsql/permissionsSetup");
const cloudsqladmin_1 = require("../gcp/cloudsql/cloudsqladmin");
const types_1 = require("../dataconnect/types");
const allowedRoles = Object.keys(permissionsSetup_1.fdcSqlRoleMap);
exports.command = new command_1.Command("dataconnect:sql:grant")
    .description("grants the SQL role <role> to the provided user or service account <email>")
    .option("-R, --role <role>", "The SQL role to grant. One of: owner, writer, or reader.")
    .option("-E, --email <email>", "The email of the user or service account we would like to grant the role to.")
    .option("--service <serviceId>", "the serviceId of the SQL Connect service")
    .option("--location <location>", "the location of the SQL Connect service. Only needed if service ID is used in multiple locations.")
    .before(requirePermissions_1.requirePermissions, ["firebasedataconnect.services.list"])
    .before(requireAuth_1.requireAuth)
    .action(async (options) => {
    if (!options.role) {
        throw new error_1.FirebaseError("-R, --role <role> is required. Run the command with -h for more info.");
    }
    if (!options.email) {
        throw new error_1.FirebaseError("-E, --email <email> is required. Run the command with -h for more info.");
    }
    if (!allowedRoles.includes(options.role.toLowerCase())) {
        throw new error_1.FirebaseError(`Role should be one of ${allowedRoles.join(" | ")}.`);
    }
    const projectId = (0, projectUtils_1.needProjectId)(options);
    await (0, ensureApis_1.ensureApis)(projectId);
    const serviceInfo = await (0, load_1.pickOneService)(projectId, options.config, options.service, options.location);
    const userIsCSQLAdmin = await (0, cloudsqladmin_1.iamUserIsCSQLAdmin)(options);
    if (!userIsCSQLAdmin) {
        throw new error_1.FirebaseError(`Only users with 'roles/cloudsql.admin' can grant SQL roles. If you do not have this role, ask your database administrator to run this command or manually grant ${options.role} to ${options.email}`);
    }
    await (0, schemaMigration_1.grantRoleToUserInSchema)(options, (0, types_1.mainSchema)(serviceInfo.schemas));
    return { projectId };
});
