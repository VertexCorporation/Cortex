"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.diffSchema = diffSchema;
exports.migrateSchema = migrateSchema;
exports.upsertSecondarySchema = upsertSecondarySchema;
exports.grantRoleToUserInSchema = grantRoleToUserInSchema;
exports.getIdentifiers = getIdentifiers;
exports.serviceNameFromSchema = serviceNameFromSchema;
exports.ensureServiceIsConnectedToCloudSql = ensureServiceIsConnectedToCloudSql;
const clc = require("colorette");
const sql_formatter_1 = require("sql-formatter");
const types_1 = require("./types");
const client_1 = require("./client");
const connect_1 = require("../gcp/cloudsql/connect");
const projectUtils_1 = require("../projectUtils");
const permissionsSetup_1 = require("../gcp/cloudsql/permissionsSetup");
const permissions_1 = require("../gcp/cloudsql/permissions");
const prompt_1 = require("../prompt");
const logger_1 = require("../logger");
const error_1 = require("../error");
const utils_1 = require("../utils");
const cloudsqladmin_1 = require("../gcp/cloudsql/cloudsqladmin");
const cloudSqlAdminClient = require("../gcp/cloudsql/cloudsqladmin");
const errors = require("./errors");
const provisionCloudSql_1 = require("./provisionCloudSql");
const requireAuth_1 = require("../requireAuth");
const cloudbilling_1 = require("../gcp/cloudbilling");
async function setupSchemaIfNecessary(instanceId, databaseId, schemaName, options) {
    try {
        await (0, connect_1.setupIAMUsers)(instanceId, options);
        const schemaInfo = await (0, permissionsSetup_1.getSchemaMetadata)(instanceId, databaseId, schemaName, options);
        switch (schemaInfo.setupStatus) {
            case permissionsSetup_1.SchemaSetupStatus.BrownField:
            case permissionsSetup_1.SchemaSetupStatus.GreenField:
                logger_1.logger.debug(`Cloud SQL Database ${instanceId}:${databaseId} is already set up in ${schemaInfo.setupStatus}`);
                return schemaInfo.setupStatus;
            case permissionsSetup_1.SchemaSetupStatus.NotSetup:
            case permissionsSetup_1.SchemaSetupStatus.NotFound:
                (0, utils_1.logLabeledBullet)("dataconnect", "Setting up Cloud SQL Database SQL permissions...");
                return await (0, permissionsSetup_1.setupSQLPermissions)(instanceId, databaseId, schemaInfo, options, true);
            default:
                throw new error_1.FirebaseError(`Unexpected schema setup status: ${schemaInfo.setupStatus}`);
        }
    }
    catch (err) {
        throw new error_1.FirebaseError(`Cannot setup Postgres SQL permissions of Cloud SQL database ${instanceId}:${databaseId}\n${err}`);
    }
}
async function diffSchema(options, schema, schemaValidation) {
    let validationMode = schemaValidation ?? "STRICT";
    setSchemaValidationMode(schema, validationMode);
    displayStartSchemaDiff(validationMode);
    const { serviceName, instanceName, databaseId, instanceId, schemaName } = getIdentifiers(schema);
    await ensureServiceIsConnectedToCloudSql(serviceName, instanceName, databaseId, false, schemaName);
    let incompatible = undefined;
    try {
        await (0, client_1.upsertSchema)(schema, true);
        displayNoSchemaDiff(instanceId, databaseId, validationMode);
    }
    catch (err) {
        if (err?.status !== 400) {
            throw err;
        }
        incompatible = errors.getIncompatibleSchemaError(err);
        const invalidConnectors = errors.getInvalidConnectors(err);
        if (!incompatible && !invalidConnectors.length) {
            const gqlErrs = errors.getGQLErrors(err);
            if (gqlErrs) {
                throw new error_1.FirebaseError(`There are errors in your schema files:\n${gqlErrs}`);
            }
            throw err;
        }
        if (invalidConnectors.length) {
            displayInvalidConnectors(invalidConnectors);
        }
    }
    if (!incompatible) {
        return [];
    }
    if (schemaValidation) {
        displaySchemaChanges(incompatible, validationMode);
        return incompatible.diffs;
    }
    const strictIncompatible = incompatible;
    let compatibleIncompatible = undefined;
    validationMode = "COMPATIBLE";
    setSchemaValidationMode(schema, validationMode);
    try {
        displayStartSchemaDiff(validationMode);
        await (0, client_1.upsertSchema)(schema, true);
        displayNoSchemaDiff(instanceId, databaseId, validationMode);
    }
    catch (err) {
        if (err?.status !== 400) {
            throw err;
        }
        compatibleIncompatible = errors.getIncompatibleSchemaError(err);
    }
    if (!compatibleIncompatible) {
        displaySchemaChanges(strictIncompatible, "STRICT");
    }
    else if (diffsEqual(strictIncompatible.diffs, compatibleIncompatible.diffs)) {
        displaySchemaChanges(strictIncompatible, "STRICT");
    }
    else {
        displaySchemaChanges(compatibleIncompatible, "COMPATIBLE");
        displaySchemaChanges(strictIncompatible, "STRICT_AFTER_COMPATIBLE");
    }
    return incompatible.diffs;
}
async function migrateSchema(args) {
    const { options, schema, validateOnly, schemaValidation, stats } = args;
    let validationMode = schemaValidation ?? "COMPATIBLE";
    setSchemaValidationMode(schema, validationMode);
    displayStartSchemaDiff(validationMode);
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const { serviceName, instanceId, instanceName, databaseId, schemaName } = getIdentifiers(schema);
    await ensureServiceIsConnectedToCloudSql(serviceName, instanceName, databaseId, true, schemaName);
    const existingInstance = await cloudSqlAdminClient.getInstance(projectId, instanceId);
    if (existingInstance.state === "PENDING_CREATE") {
        if (stats) {
            stats.numSchemaSkippedDueToPendingCreate++;
        }
        const postgresql = schema.datasources.find((d) => d.postgresql)?.postgresql;
        if (!postgresql) {
            throw new error_1.FirebaseError(`Cannot find Postgres datasource in the schema to deploy: ${serviceName}/schemas/${types_1.MAIN_SCHEMA_ID}.\nIts datasources: ${JSON.stringify(schema.datasources)}`);
        }
        postgresql.schemaValidation = "NONE";
        postgresql.schemaMigration = undefined;
        await (0, client_1.upsertSchema)(schema, validateOnly);
        postgresql.schemaValidation = undefined;
        postgresql.schemaMigration = "MIGRATE_COMPATIBLE";
        await (0, client_1.upsertSchema)(schema, validateOnly, true);
        (0, utils_1.logLabeledWarning)("dataconnect", `Skip SQL schema migration because Cloud SQL is still being created`);
        return [];
    }
    await setupSchemaIfNecessary(instanceId, databaseId, schemaName, options);
    let diffs = [];
    try {
        await (0, client_1.upsertSchema)(schema, validateOnly);
        displayNoSchemaDiff(instanceId, databaseId, validationMode);
    }
    catch (err) {
        if (err?.status !== 400) {
            throw err;
        }
        const incompatible = errors.getIncompatibleSchemaError(err);
        const invalidConnectors = errors.getInvalidConnectors(err);
        if (!incompatible && !invalidConnectors.length) {
            const gqlErrs = errors.getGQLErrors(err);
            if (gqlErrs) {
                throw new error_1.FirebaseError(`There are errors in your schema files:\n${gqlErrs}`);
            }
            throw err;
        }
        if (stats) {
            if (incompatible) {
                stats.numSchemaSqlDiffs += incompatible.diffs.length;
            }
            if (invalidConnectors.length) {
                stats.numSchemaInvalidConnectors += invalidConnectors.length;
            }
        }
        const migrationMode = await promptForSchemaMigration(options, instanceId, databaseId, incompatible, validateOnly, validationMode);
        const shouldDeleteInvalidConnectors = await promptForInvalidConnectorError(options, serviceName, invalidConnectors, validateOnly);
        if (incompatible) {
            diffs = await handleIncompatibleSchemaError({
                options,
                databaseId,
                instanceId,
                schemaName,
                incompatibleSchemaError: incompatible,
                choice: migrationMode,
            });
        }
        if (shouldDeleteInvalidConnectors) {
            await deleteInvalidConnectors(invalidConnectors);
        }
        if (!validateOnly) {
            await (0, client_1.upsertSchema)(schema, validateOnly);
        }
    }
    if (!schemaValidation) {
        validationMode = "STRICT";
        setSchemaValidationMode(schema, validationMode);
        try {
            await (0, client_1.upsertSchema)(schema, validateOnly);
        }
        catch (err) {
            if (err.status !== 400) {
                throw err;
            }
            const incompatible = errors.getIncompatibleSchemaError(err);
            if (!incompatible) {
                throw err;
            }
            if (stats && incompatible) {
                stats.numSchemaSqlDiffs += incompatible.diffs.length;
            }
            const migrationMode = await promptForSchemaMigration(options, instanceId, databaseId, incompatible, validateOnly, "STRICT_AFTER_COMPATIBLE");
            if (incompatible) {
                const maybeDiffs = await handleIncompatibleSchemaError({
                    options,
                    databaseId,
                    instanceId,
                    schemaName,
                    incompatibleSchemaError: incompatible,
                    choice: migrationMode,
                });
                diffs = diffs.concat(maybeDiffs);
            }
        }
    }
    return diffs;
}
async function upsertSecondarySchema(args) {
    const { options, schema, stats } = args;
    const serviceName = serviceNameFromSchema(schema);
    try {
        await (0, client_1.upsertSchema)(schema, false);
    }
    catch (err) {
        if (err?.status !== 400) {
            throw err;
        }
        const invalidConnectors = errors.getInvalidConnectors(err);
        if (!invalidConnectors.length) {
            const gqlErrs = errors.getGQLErrors(err);
            if (gqlErrs) {
                throw new error_1.FirebaseError(`There are errors in your schema files:\n${gqlErrs}`);
            }
            throw err;
        }
        if (stats) {
            stats.numSchemaInvalidConnectors += invalidConnectors.length;
        }
        const shouldDeleteInvalidConnectors = await promptForInvalidConnectorError(options, serviceName, invalidConnectors, false);
        if (shouldDeleteInvalidConnectors) {
            await deleteInvalidConnectors(invalidConnectors);
        }
        await (0, client_1.upsertSchema)(schema, false);
    }
}
async function grantRoleToUserInSchema(options, schema) {
    const role = options.role;
    const email = options.email;
    const { serviceName, instanceId, instanceName, databaseId, schemaName } = getIdentifiers(schema);
    await ensureServiceIsConnectedToCloudSql(serviceName, instanceName, databaseId, false, schemaName);
    const schemaSetupStatus = await setupSchemaIfNecessary(instanceId, databaseId, schemaName, options);
    if (schemaSetupStatus !== permissionsSetup_1.SchemaSetupStatus.GreenField && role === "owner") {
        throw new error_1.FirebaseError(`Owner rule isn't available in ${schemaSetupStatus} databases. If you would like SQL Connect to manage and own your database schema, run 'firebase dataconnect:sql:setup'`);
    }
    await (0, permissionsSetup_1.grantRoleTo)(options, instanceId, databaseId, role, email, schemaName);
}
function diffsEqual(x, y) {
    if (x.length !== y.length) {
        return false;
    }
    for (let i = 0; i < x.length; i++) {
        if (x[i].description !== y[i].description ||
            x[i].destructive !== y[i].destructive ||
            x[i].sql !== y[i].sql) {
            return false;
        }
    }
    return true;
}
function setSchemaValidationMode(schema, schemaValidation) {
    const postgresDatasource = schema.datasources.find((d) => d.postgresql);
    if (postgresDatasource?.postgresql) {
        postgresDatasource.postgresql.schemaValidation = schemaValidation;
    }
}
function getIdentifiers(schema) {
    const postgresDatasource = schema.datasources.find((d) => d.postgresql);
    const databaseId = postgresDatasource?.postgresql?.database;
    if (!databaseId) {
        throw new error_1.FirebaseError("SQL Connect schema must have a postgres datasource with a database name.");
    }
    const instanceName = postgresDatasource?.postgresql?.cloudSql?.instance;
    if (!instanceName) {
        throw new error_1.FirebaseError("SQL Connect schema must have a postgres datasource with a CloudSQL instance.");
    }
    const instanceId = instanceName.split("/").pop();
    const schemaName = postgresDatasource?.postgresql?.schema || permissions_1.DEFAULT_SCHEMA;
    const serviceName = serviceNameFromSchema(schema);
    return {
        databaseId,
        instanceId,
        instanceName,
        schemaName,
        serviceName,
    };
}
function serviceNameFromSchema(schema) {
    const regex = /\/schemas\/[^/]*$/;
    return schema.name.replace(regex, "");
}
function suggestedCommand(serviceName, invalidConnectorNames) {
    const serviceId = serviceName.split("/")[5];
    const connectorIds = invalidConnectorNames.map((i) => i.split("/")[7]);
    const onlys = connectorIds.map((c) => `dataconnect:${serviceId}:${c}`).join(",");
    return `firebase deploy --only ${onlys}`;
}
async function handleIncompatibleSchemaError(args) {
    const { incompatibleSchemaError, options, instanceId, databaseId, schemaName, choice } = args;
    const commandsToExecute = incompatibleSchemaError.diffs.filter((d) => {
        switch (choice) {
            case "all":
                return true;
            case "safe":
                return !d.destructive;
            case "none":
                return false;
        }
    });
    if (commandsToExecute.length) {
        const commandsToExecuteBySuperUser = commandsToExecute.filter(requireSuperUser);
        const commandsToExecuteByOwner = commandsToExecute.filter((sql) => !requireSuperUser(sql));
        const userIsCSQLAdmin = await (0, cloudsqladmin_1.iamUserIsCSQLAdmin)(options);
        if (!userIsCSQLAdmin && commandsToExecuteBySuperUser.length) {
            throw new error_1.FirebaseError(`Some SQL commands required for this migration require Admin permissions.\n 
        Please ask a user with 'roles/cloudsql.admin' to apply the following commands.\n
        ${diffsToString(commandsToExecuteBySuperUser)}`);
        }
        const schemaInfo = await (0, permissionsSetup_1.getSchemaMetadata)(instanceId, databaseId, schemaName, options);
        if (schemaInfo.setupStatus !== permissionsSetup_1.SchemaSetupStatus.GreenField) {
            throw new error_1.FirebaseError(`Brownfield database are protected from SQL changes by SQL Connect.\n` +
                `You can use the SQL diff generated by 'firebase dataconnect:sql:diff' to assist you in applying the required changes to your CloudSQL database. Connector deployment will succeed when there is no required diff changes.\n` +
                `If you would like SQL Connect to manage your database schema, run 'firebase dataconnect:sql:setup'`);
        }
        if (!(await (0, permissionsSetup_1.checkSQLRoleIsGranted)(options, instanceId, databaseId, (0, permissions_1.firebaseowner)(databaseId, schemaName), (await (0, connect_1.getIAMUser)(options)).user))) {
            if (!userIsCSQLAdmin) {
                throw new error_1.FirebaseError(`Command aborted. Only users granted firebaseowner SQL role can run migrations.`);
            }
            const account = (await (0, requireAuth_1.requireAuth)(options));
            (0, utils_1.logLabeledBullet)("dataconnect", `Granting firebaseowner role to myself ${account}...`);
            await (0, permissionsSetup_1.grantRoleTo)(options, instanceId, databaseId, "owner", account, schemaName);
        }
        if (commandsToExecuteBySuperUser.length) {
            (0, utils_1.logLabeledBullet)("dataconnect", `Executing admin SQL commands as superuser...`);
            await (0, connect_1.executeSqlCmdsAsSuperUser)(options, instanceId, databaseId, commandsToExecuteBySuperUser.map((d) => d.sql), false);
        }
        if (commandsToExecuteByOwner.length) {
            await (0, connect_1.executeSqlCmdsAsIamUser)(options, instanceId, databaseId, [
                `SET ROLE "${(0, permissions_1.firebaseowner)(databaseId, schemaName)}"`,
                ...commandsToExecuteByOwner.map((d) => d.sql),
            ], false);
            return incompatibleSchemaError.diffs;
        }
    }
    return [];
}
async function promptForSchemaMigration(options, instanceId, databaseId, err, validateOnly, validationMode) {
    if (!err) {
        return "none";
    }
    const defaultChoice = validationMode === "STRICT_AFTER_COMPATIBLE" ? "none" : "all";
    displaySchemaChanges(err, validationMode);
    if (!options.nonInteractive) {
        if (validateOnly && options.force) {
            return defaultChoice;
        }
        let choices = [
            { name: "Execute all", value: "all" },
        ];
        if (err.destructive) {
            choices = [{ name: `Execute all ${clc.red("(including destructive)")}`, value: "all" }];
            if (err.diffs.some((d) => !d.destructive)) {
                choices.push({ name: "Execute safe only", value: "safe" });
            }
        }
        if (validationMode === "STRICT_AFTER_COMPATIBLE") {
            choices.push({ name: "Skip them", value: "none" });
        }
        else {
            choices.push({ name: "Abort", value: "abort" });
        }
        const ans = await (0, prompt_1.select)({
            message: `Do you want to execute these SQL against ${instanceId}:${databaseId}?`,
            choices: choices,
            default: defaultChoice,
        });
        if (ans === "abort") {
            throw new error_1.FirebaseError("Command aborted.");
        }
        return ans;
    }
    if (!validateOnly) {
        throw new error_1.FirebaseError("Command aborted. Your database schema is incompatible with your SQL Connect schema. Run `firebase dataconnect:sql:migrate` to migrate your database schema");
    }
    else if (options.force) {
        return defaultChoice;
    }
    else if (!err.destructive) {
        return defaultChoice;
    }
    else {
        throw new error_1.FirebaseError("Command aborted. This schema migration includes potentially destructive changes. If you'd like to execute it anyway, rerun this command with --force");
    }
}
async function promptForInvalidConnectorError(options, serviceName, invalidConnectors, validateOnly) {
    if (!invalidConnectors.length) {
        return false;
    }
    displayInvalidConnectors(invalidConnectors);
    if (validateOnly) {
        return false;
    }
    if (options.force) {
        return true;
    }
    if (!options.nonInteractive &&
        (await (0, prompt_1.confirm)({
            ...options,
            message: `Would you like to delete and recreate these connectors? This will cause ${clc.red(`downtime`)}.`,
        }))) {
        return true;
    }
    const cmd = suggestedCommand(serviceName, invalidConnectors);
    throw new error_1.FirebaseError(`Command aborted. Try deploying those connectors first with ${clc.bold(cmd)}`);
}
async function deleteInvalidConnectors(invalidConnectors) {
    return Promise.all(invalidConnectors.map(client_1.deleteConnector));
}
function displayInvalidConnectors(invalidConnectors) {
    const connectorIds = invalidConnectors.map((i) => i.split("/").pop()).join(", ");
    (0, utils_1.logLabeledWarning)("dataconnect", `The schema you are deploying is incompatible with the following existing connectors: ${clc.bold(connectorIds)}.`);
    (0, utils_1.logLabeledWarning)("dataconnect", `This is a ${clc.red("breaking")} change and may break existing apps.`);
}
async function ensureServiceIsConnectedToCloudSql(serviceName, instanceName, databaseId, linkIfNotConnected, schemaName) {
    let currentSchema = await (0, client_1.getSchema)(serviceName);
    let postgresql = currentSchema?.datasources?.find((d) => d.postgresql)?.postgresql;
    if (currentSchema?.reconciling &&
        postgresql?.ephemeral &&
        postgresql?.cloudSql?.instance &&
        postgresql?.schemaValidation === "NONE") {
        const [, , , , , serviceId] = serviceName.split("/");
        const [, projectId, , , , instanceId] = postgresql.cloudSql.instance.split("/");
        let isFreeTrial = false;
        let billingEnabled = false;
        try {
            const instance = await cloudSqlAdminClient.getInstance(projectId, instanceId);
            isFreeTrial = instance.settings?.userLabels?.["firebase-data-connect"] === "ft";
            billingEnabled = await (0, cloudbilling_1.checkBillingEnabled)(projectId);
        }
        catch (err) {
        }
        throw new error_1.FirebaseError(`While checking the service ${serviceId}, ` +
            (0, provisionCloudSql_1.cloudSQLBeingCreated)(projectId, instanceId, isFreeTrial, billingEnabled));
    }
    if (!currentSchema || !postgresql) {
        if (!linkIfNotConnected) {
            (0, utils_1.logLabeledWarning)("dataconnect", `Not yet linked to the Cloud SQL instance.`);
            return;
        }
        (0, utils_1.logLabeledBullet)("dataconnect", `Linking the Cloud SQL instance...`);
        currentSchema = {
            name: `${serviceName}/schemas/${types_1.MAIN_SCHEMA_ID}`,
            source: {
                files: [],
            },
            datasources: [
                {
                    postgresql: { ephemeral: true },
                },
            ],
        };
    }
    if (!postgresql) {
        postgresql = currentSchema.datasources[0].postgresql;
    }
    let alreadyConnected = !postgresql.ephemeral || false;
    if (postgresql.cloudSql?.instance && postgresql.cloudSql.instance !== instanceName) {
        alreadyConnected = false;
        (0, utils_1.logLabeledWarning)("dataconnect", `Switching connected Cloud SQL instance\n From ${postgresql.cloudSql.instance}\n To ${instanceName}`);
    }
    if (postgresql.database && postgresql.database !== databaseId) {
        alreadyConnected = false;
        (0, utils_1.logLabeledWarning)("dataconnect", `Switching connected Postgres database from ${postgresql.database} to ${databaseId}`);
    }
    if (alreadyConnected) {
        return;
    }
    try {
        postgresql.schemaValidation = "STRICT";
        postgresql.database = databaseId;
        postgresql.schema = schemaName;
        postgresql.cloudSql = { instance: instanceName };
        await (0, client_1.upsertSchema)(currentSchema, false);
    }
    catch (err) {
        if (err?.status >= 500) {
            throw err;
        }
        logger_1.logger.debug(`Failed to ensure service is connected to Cloud SQL: ${err.message}`);
    }
}
function displayStartSchemaDiff(validationMode) {
    switch (validationMode) {
        case "COMPATIBLE":
            (0, utils_1.logLabeledBullet)("dataconnect", `Generating SQL schema migrations to be compatible...`);
            break;
        case "STRICT":
            (0, utils_1.logLabeledBullet)("dataconnect", `Generating SQL schema migrations to match exactly...`);
            break;
    }
}
function displayNoSchemaDiff(instanceId, databaseId, validationMode) {
    switch (validationMode) {
        case "COMPATIBLE":
            (0, utils_1.logLabeledSuccess)("dataconnect", `Database schema of ${instanceId}:${databaseId} is compatible with SQL Connect Schema.`);
            break;
        case "STRICT":
            (0, utils_1.logLabeledSuccess)("dataconnect", `Database schema of ${instanceId}:${databaseId} matches SQL Connect Schema exactly.`);
            break;
    }
}
function displaySchemaChanges(error, validationMode) {
    switch (error.violationType) {
        case "INCOMPATIBLE_SCHEMA":
            {
                switch (validationMode) {
                    case "COMPATIBLE":
                        (0, utils_1.logLabeledWarning)("dataconnect", `PostgreSQL schema is incompatible with the SQL Connect Schema.
Those SQL statements will migrate it to be compatible:

${diffsToString(error.diffs)}
`);
                        break;
                    case "STRICT_AFTER_COMPATIBLE":
                        (0, utils_1.logLabeledBullet)("dataconnect", `PostgreSQL schema contains unused SQL objects not part of the SQL Connect Schema.
Those SQL statements will migrate it to match exactly:

${diffsToString(error.diffs)}
`);
                        break;
                    case "STRICT":
                        (0, utils_1.logLabeledWarning)("dataconnect", `PostgreSQL schema does not match the SQL Connect Schema.
Those SQL statements will migrate it to match exactly:

${diffsToString(error.diffs)}
`);
                        break;
                }
            }
            break;
        case "INACCESSIBLE_SCHEMA":
            {
                (0, utils_1.logLabeledWarning)("dataconnect", `Cannot access CloudSQL database to validate schema.
Here is the complete expected SQL schema:
${diffsToString(error.diffs)}
`);
                (0, utils_1.logLabeledWarning)("dataconnect", "Some SQL resources may already exist.");
            }
            break;
        default:
            throw new error_1.FirebaseError(`Unknown schema violation type: ${error.violationType}, IncompatibleSqlSchemaError: ${error}`);
    }
}
function requireSuperUser(diff) {
    return diff.sql.startsWith("CREATE EXTENSION") || diff.sql.startsWith("CREATE SCHEMA");
}
function diffsToString(diffs) {
    return diffs.map(diffToString).join("\n\n");
}
function diffToString(diff) {
    return `\/** ${diff.destructive ? clc.red("Destructive: ") : ""}${diff.description}*\/\n${(0, sql_formatter_1.format)(diff.sql, { language: "postgresql" })}`;
}
