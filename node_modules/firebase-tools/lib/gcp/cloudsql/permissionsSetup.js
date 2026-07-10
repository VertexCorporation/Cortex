"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fdcSqlRoleMap = exports.SchemaSetupStatus = void 0;
exports.checkSQLRoleIsGranted = checkSQLRoleIsGranted;
exports.setupSQLPermissions = setupSQLPermissions;
exports.greenFieldSchemaSetup = greenFieldSchemaSetup;
exports.getSchemaMetadata = getSchemaMetadata;
exports.setupBrownfieldAsGreenfield = setupBrownfieldAsGreenfield;
exports.brownfieldSqlSetup = brownfieldSqlSetup;
exports.grantRoleTo = grantRoleTo;
const clc = require("colorette");
const permissions_1 = require("./permissions");
const cloudsqladmin_1 = require("./cloudsqladmin");
const logger_1 = require("../../logger");
const prompt_1 = require("../../prompt");
const error_1 = require("../../error");
const projectUtils_1 = require("../../projectUtils");
const connect_1 = require("./connect");
const lodash_1 = require("lodash");
const connect_2 = require("./connect");
const utils = require("../../utils");
const cloudSqlAdminClient = require("./cloudsqladmin");
var SchemaSetupStatus;
(function (SchemaSetupStatus) {
    SchemaSetupStatus["NotSetup"] = "not-setup";
    SchemaSetupStatus["GreenField"] = "greenfield";
    SchemaSetupStatus["BrownField"] = "brownfield";
    SchemaSetupStatus["NotFound"] = "not-found";
})(SchemaSetupStatus || (exports.SchemaSetupStatus = SchemaSetupStatus = {}));
exports.fdcSqlRoleMap = {
    owner: permissions_1.firebaseowner,
    writer: permissions_1.firebasewriter,
    reader: permissions_1.firebasereader,
};
async function checkSQLRoleIsGranted(options, instanceId, databaseId, grantedRole, granteeRole) {
    const checkCmd = `
    DO $$
    DECLARE
        role_count INTEGER;
    BEGIN
        -- Count the number of rows matching the criteria
        SELECT COUNT(*)
        INTO role_count
        FROM
          pg_auth_members m
        JOIN
          pg_roles grantee ON grantee.oid = m.member
        JOIN
          pg_roles granted ON granted.oid = m.roleid
        JOIN
          pg_roles grantor ON grantor.oid = m.grantor
        WHERE
          granted.rolname = '${grantedRole}'
          AND grantee.rolname = '${granteeRole}';

        -- If no rows were found, raise an exception
        IF role_count = 0 THEN
            RAISE EXCEPTION 'Role "%", is not granted to role "%".', '${grantedRole}', '${granteeRole}';
        END IF;
    END $$;
`;
    try {
        await (0, connect_1.executeSqlCmdsAsIamUser)(options, instanceId, databaseId, [checkCmd], true);
        return true;
    }
    catch (e) {
        if (e instanceof error_1.FirebaseError && e.message.includes("not granted to role")) {
            return false;
        }
        logger_1.logger.error(`Role Check Failed: ${e}`);
        throw e;
    }
}
async function setupSQLPermissions(instanceId, databaseId, schemaInfo, options, silent = false) {
    const logFn = silent
        ? logger_1.logger.debug
        : (message) => {
            return utils.logLabeledBullet("dataconnect", message);
        };
    const schema = schemaInfo.name;
    logFn(`Detected schema "${schema}" setup status is ${schemaInfo.setupStatus}. Running setup...`);
    const userIsCSQLAdmin = await (0, cloudsqladmin_1.iamUserIsCSQLAdmin)(options);
    if (!userIsCSQLAdmin) {
        throw new error_1.FirebaseError(`Missing required IAM permission to setup SQL schemas. SQL schema setup requires 'roles/cloudsql.admin' or an equivalent role.`);
    }
    let runGreenfieldSetup = false;
    if (schemaInfo.setupStatus === SchemaSetupStatus.GreenField) {
        runGreenfieldSetup = true;
        logFn(`Database ${databaseId} has already been setup as greenfield project. Rerunning setup to repair any missing permissions.`);
    }
    if (schemaInfo.tables.length === 0) {
        runGreenfieldSetup = true;
        logFn(`Found no tables in schema "${schema}", assuming greenfield project.`);
    }
    if (runGreenfieldSetup) {
        const greenfieldSetupCmds = await greenFieldSchemaSetup(instanceId, databaseId, schema, options);
        await (0, connect_1.executeSqlCmdsAsSuperUser)(options, instanceId, databaseId, greenfieldSetupCmds, silent, true);
        logFn(clc.green("Database setup complete."));
        return SchemaSetupStatus.GreenField;
    }
    if (options.nonInteractive || options.force) {
        throw new error_1.FirebaseError(`Schema "${schema}" isn't set up and can only be set up in interactive mode.`);
    }
    const currentTablesOwners = [...new Set(schemaInfo.tables.map((t) => t.owner))];
    logFn(`We found some existing object owners [${currentTablesOwners.join(", ")}] in your cloudsql "${schema}" schema.`);
    const shouldSetupGreenfield = await (0, prompt_1.confirm)({
        message: clc.yellow("Would you like FDC to handle SQL migrations for you moving forward?\n" +
            `This means we will transfer schema and tables ownership to ${(0, permissions_1.firebaseowner)(databaseId, schema)}\n` +
            "Note: your existing migration tools/roles may lose access."),
        default: false,
    });
    if (shouldSetupGreenfield) {
        await setupBrownfieldAsGreenfield(instanceId, databaseId, schemaInfo, options, silent);
        logger_1.logger.info(clc.green("Database setup complete."));
        logFn(clc.yellow("IMPORTANT: please uncomment 'schemaValidation: \"COMPATIBLE\"' in your dataconnect.yaml file to avoid dropping any existing tables by mistake."));
        return SchemaSetupStatus.GreenField;
    }
    else {
        logFn(clc.yellow("Setting up database in brownfield mode.\n" +
            `Note: SQL migrations can't be done through ${clc.bold("firebase dataconnect:sql:migrate")} in this mode.`));
        await brownfieldSqlSetup(instanceId, databaseId, schemaInfo, options, silent);
        logFn(clc.green("Brownfield database setup complete."));
        return SchemaSetupStatus.BrownField;
    }
}
async function greenFieldSchemaSetup(instanceId, databaseId, schema, options) {
    const revokes = [];
    if (await checkSQLRoleIsGranted(options, instanceId, databaseId, "cloudsqlsuperuser", (0, permissions_1.firebaseowner)(databaseId, schema))) {
        logger_1.logger.warn("Detected cloudsqlsuperuser was previously given to firebase owner, revoking to improve database security.");
        revokes.push(`REVOKE "cloudsqlsuperuser" FROM "${(0, permissions_1.firebaseowner)(databaseId, schema)}"`);
    }
    const user = (await (0, connect_1.getIAMUser)(options)).user;
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    const { user: fdcP4SAUser } = (0, connect_2.toDatabaseUser)((0, connect_2.getDataConnectP4SA)(projectNumber));
    const sqlRoleSetupCmds = (0, lodash_1.concat)(revokes, [`CREATE SCHEMA IF NOT EXISTS "${schema}"`], (0, permissions_1.ownerRolePermissions)(databaseId, permissions_1.FIREBASE_SUPER_USER, schema), (0, permissions_1.writerRolePermissions)(databaseId, permissions_1.FIREBASE_SUPER_USER, schema), (0, permissions_1.readerRolePermissions)(databaseId, permissions_1.FIREBASE_SUPER_USER, schema), `GRANT "${(0, permissions_1.firebaseowner)(databaseId, schema)}" TO "${user}"`, `GRANT "${(0, permissions_1.firebasewriter)(databaseId, schema)}" TO "${fdcP4SAUser}"`, (0, permissions_1.defaultPermissions)(databaseId, schema, (0, permissions_1.firebaseowner)(databaseId, schema)));
    return sqlRoleSetupCmds;
}
async function getSchemaMetadata(instanceId, databaseId, schema, options) {
    const checkSchemaExists = await (0, connect_1.executeSqlCmdsAsIamUser)(options, instanceId, databaseId, [
        `SELECT pg_get_userbyid(nspowner) 
          FROM pg_namespace 
          WHERE nspname = '${schema}';`,
    ], true);
    if (!checkSchemaExists[0].rows[0]) {
        return {
            name: schema,
            owner: null,
            setupStatus: SchemaSetupStatus.NotFound,
            tables: [],
        };
    }
    const schemaOwner = checkSchemaExists[0].rows[0].pg_get_userbyid;
    const cmd = `SELECT tablename, tableowner FROM pg_tables WHERE schemaname='${schema}'`;
    const res = await (0, connect_1.executeSqlCmdsAsIamUser)(options, instanceId, databaseId, [cmd], true);
    const tables = res[0].rows.map((row) => {
        return {
            name: row.tablename,
            owner: row.tableowner,
        };
    });
    const checkRoleExists = async (role) => {
        const cmd = [`SELECT to_regrole('"${role}"') IS NOT NULL AS exists;`];
        const result = await (0, connect_1.executeSqlCmdsAsIamUser)(options, instanceId, databaseId, cmd, true);
        return result[0].rows[0].exists;
    };
    let setupStatus;
    if (!(await checkRoleExists((0, permissions_1.firebasewriter)(databaseId, schema)))) {
        setupStatus = SchemaSetupStatus.NotSetup;
    }
    else if (tables.every((table) => table.owner === (0, permissions_1.firebaseowner)(databaseId, schema)) &&
        schemaOwner === (0, permissions_1.firebaseowner)(databaseId, schema)) {
        setupStatus = SchemaSetupStatus.GreenField;
    }
    else {
        setupStatus = SchemaSetupStatus.BrownField;
    }
    return {
        name: schema,
        owner: schemaOwner,
        setupStatus,
        tables: tables,
    };
}
function filterTableOwners(schemaInfo, databaseId) {
    return [...new Set(schemaInfo.tables.map((t) => t.owner))].filter((owner) => owner !== permissions_1.CLOUDSQL_SUPER_USER && owner !== (0, permissions_1.firebaseowner)(databaseId, schemaInfo.name));
}
async function setupBrownfieldAsGreenfield(instanceId, databaseId, schemaInfo, options, silent = false) {
    const schema = schemaInfo.name;
    const firebaseOwnerRole = (0, permissions_1.firebaseowner)(databaseId, schema);
    const uniqueTablesOwners = filterTableOwners(schemaInfo, databaseId);
    const grantOwnersToSuperuserCmds = uniqueTablesOwners.map((owner) => `GRANT "${owner}" TO "${permissions_1.FIREBASE_SUPER_USER}"`);
    const revokeOwnersFromSuperuserCmds = uniqueTablesOwners.map((owner) => `REVOKE "${owner}" FROM "${permissions_1.FIREBASE_SUPER_USER}"`);
    const greenfieldSetupCmds = await greenFieldSchemaSetup(instanceId, databaseId, schema, options);
    const grantCmds = uniqueTablesOwners.map((owner) => `GRANT "${(0, permissions_1.firebasewriter)(databaseId, schema)}" TO "${owner}"`);
    const alterTableCmds = schemaInfo.tables.map((table) => `ALTER TABLE "${schema}"."${table.name}" OWNER TO "${firebaseOwnerRole}";`);
    const setupCmds = [
        ...grantOwnersToSuperuserCmds,
        ...greenfieldSetupCmds,
        ...grantCmds,
        ...alterTableCmds,
        ...revokeOwnersFromSuperuserCmds,
    ];
    await (0, connect_1.executeSqlCmdsAsSuperUser)(options, instanceId, databaseId, setupCmds, silent, true);
}
async function brownfieldSqlSetup(instanceId, databaseId, schemaInfo, options, silent = false) {
    const schema = schemaInfo.name;
    const uniqueTablesOwners = filterTableOwners(schemaInfo, databaseId);
    const grantOwnersToFirebasesuperuser = uniqueTablesOwners.map((owner) => `GRANT "${owner}" TO "${permissions_1.FIREBASE_SUPER_USER}"`);
    const revokeOwnersFromFirebasesuperuser = uniqueTablesOwners.map((owner) => `REVOKE "${owner}" FROM "${permissions_1.FIREBASE_SUPER_USER}"`);
    const iamUser = (await (0, connect_1.getIAMUser)(options)).user;
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    const { user: fdcP4SAUser } = (0, connect_2.toDatabaseUser)((0, connect_2.getDataConnectP4SA)(projectNumber));
    const firebaseDefaultPermissions = uniqueTablesOwners.flatMap((owner) => (0, permissions_1.defaultPermissions)(databaseId, schema, owner));
    const brownfieldSetupCmds = [
        ...grantOwnersToFirebasesuperuser,
        ...(0, permissions_1.writerRolePermissions)(databaseId, permissions_1.FIREBASE_SUPER_USER, schema),
        ...(0, permissions_1.readerRolePermissions)(databaseId, permissions_1.FIREBASE_SUPER_USER, schema),
        `GRANT "${(0, permissions_1.firebasewriter)(databaseId, schema)}" TO "${iamUser}"`,
        `GRANT "${(0, permissions_1.firebasewriter)(databaseId, schema)}" TO "${fdcP4SAUser}"`,
        ...firebaseDefaultPermissions,
        ...revokeOwnersFromFirebasesuperuser,
    ];
    await (0, connect_1.executeSqlCmdsAsSuperUser)(options, instanceId, databaseId, brownfieldSetupCmds, silent, true);
}
async function grantRoleTo(options, instanceId, databaseId, role, email, schema = permissions_1.DEFAULT_SCHEMA) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const { user, mode } = (0, connect_2.toDatabaseUser)(email);
    await cloudSqlAdminClient.createUser(projectId, instanceId, mode, user);
    const fdcSqlRole = exports.fdcSqlRoleMap[role](databaseId, schema);
    await (0, connect_1.executeSqlCmdsAsSuperUser)(options, instanceId, databaseId, [`GRANT "${fdcSqlRole}" TO "${user}"`], false);
}
