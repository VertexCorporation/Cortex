"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const pg = require("pg");
const clc = require("colorette");
const cloud_sql_connector_1 = require("@google-cloud/cloud-sql-connector");
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const ensureApis_1 = require("../dataconnect/ensureApis");
const requirePermissions_1 = require("../requirePermissions");
const load_1 = require("../dataconnect/load");
const schemaMigration_1 = require("../dataconnect/schemaMigration");
const requireAuth_1 = require("../requireAuth");
const connect_1 = require("../gcp/cloudsql/connect");
const cloudSqlAdminClient = require("../gcp/cloudsql/cloudsqladmin");
const prompt_1 = require("../prompt");
const logger_1 = require("../logger");
const error_1 = require("../error");
const fbToolsAuthClient_1 = require("../gcp/cloudsql/fbToolsAuthClient");
const interactive_1 = require("../gcp/cloudsql/interactive");
const types_1 = require("../dataconnect/types");
const sqlKeywords = [
    "SELECT",
    "FROM",
    "WHERE",
    "INSERT",
    "UPDATE",
    "DELETE",
    "JOIN",
    "GROUP",
    "ORDER",
    "LIMIT",
    "GRANT",
    "CREATE",
    "DROP",
];
async function promptForQuery() {
    let query = "";
    const line = "";
    do {
        let line = await (0, prompt_1.input)({
            message: query ? "> " : "Enter your SQL query (or '.exit'):",
            transformer: (input) => {
                return input
                    .split(" ")
                    .map((word) => (sqlKeywords.includes(word.toUpperCase()) ? clc.cyan(word) : word))
                    .join(" ");
            },
            nonInteractive: false,
        });
        line = line.trimEnd();
        if (line.toLowerCase() === ".exit") {
            return ".exit";
        }
        query += (query ? "\n" : "") + line;
    } while (line !== "" && !query.endsWith(";"));
    return query;
}
async function mainShellLoop(conn) {
    while (true) {
        const query = await promptForQuery();
        if (query.toLowerCase() === ".exit") {
            break;
        }
        if (query === "") {
            continue;
        }
        if (await (0, interactive_1.confirmDangerousQuery)(query)) {
            await (0, interactive_1.interactiveExecuteQuery)(query, conn);
        }
        else {
            logger_1.logger.info(clc.yellow("Query cancelled."));
        }
    }
}
exports.command = new command_1.Command("dataconnect:sql:shell")
    .description("start a shell connected directly to your SQL Connect service's linked CloudSQL instance")
    .option("--service <serviceId>", "the serviceId of the SQL Connect service")
    .option("--location <location>", "the location of the SQL Connect service. Only needed if service ID is used in multiple locations.")
    .before(requirePermissions_1.requirePermissions, ["firebasedataconnect.services.list", "cloudsql.instances.connect"])
    .before(requireAuth_1.requireAuth)
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    await (0, ensureApis_1.ensureApis)(projectId);
    const serviceInfo = await (0, load_1.pickOneService)(projectId, options.config, options.service, options.location);
    const { instanceId, databaseId, schemaName } = (0, schemaMigration_1.getIdentifiers)((0, types_1.mainSchema)(serviceInfo.schemas));
    const { user: username } = await (0, connect_1.getIAMUser)(options);
    const instance = await cloudSqlAdminClient.getInstance(projectId, instanceId);
    const connectionName = instance.connectionName;
    if (!connectionName) {
        throw new error_1.FirebaseError(`Could not get instance connection string for ${options.instanceId}:${options.databaseId}`);
    }
    const connector = new cloud_sql_connector_1.Connector({
        auth: new fbToolsAuthClient_1.FBToolsAuthClient(),
    });
    const clientOpts = await connector.getOptions({
        instanceConnectionName: connectionName,
        ipType: cloud_sql_connector_1.IpAddressTypes.PUBLIC,
        authType: cloud_sql_connector_1.AuthTypes.IAM,
    });
    const pool = new pg.Pool({
        ...clientOpts,
        user: username,
        database: databaseId,
    });
    pool.on("error", (err) => {
        logger_1.logger.debug("PostgreSQL pool error:", err);
    });
    const conn = await pool.connect();
    await conn.query(`SET search_path TO "${schemaName}"`);
    logger_1.logger.info(`Logged in as ${username}`);
    logger_1.logger.info(clc.cyan("Welcome to SQL Connect Cloud SQL Shell"));
    logger_1.logger.info(clc.gray("Type your your SQL query or '.exit' to quit, queries should end with ';' or add empty line to execute."));
    await mainShellLoop(conn);
    logger_1.logger.info(clc.yellow("Exiting shell..."));
    try {
        conn.release();
    }
    catch (err) {
        logger_1.logger.debug("Error releasing pg connection:", err);
    }
    try {
        connector.close();
    }
    catch (err) {
        logger_1.logger.debug("Error closing Cloud SQL connector:", err);
    }
    try {
        await pool.end();
    }
    catch (err) {
        logger_1.logger.debug("Error ending pg pool:", err);
    }
    return { projectId };
});
