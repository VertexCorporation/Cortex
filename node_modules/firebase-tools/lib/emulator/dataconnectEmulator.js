"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DataConnectEmulatorClient = exports.DataConnectEmulator = exports.dataConnectEmulatorEvents = void 0;
const childProcess = require("child_process");
const pg = require("pg");
const events_1 = require("events");
const clc = require("colorette");
const path = require("path");
const api_1 = require("../api");
const constants_1 = require("./constants");
const downloadableEmulators_1 = require("./downloadableEmulators");
const types_1 = require("./types");
const error_1 = require("../error");
const error_2 = require("../error");
const emulatorLogger_1 = require("./emulatorLogger");
const types_2 = require("../dataconnect/types");
const portUtils_1 = require("./portUtils");
const registry_1 = require("./registry");
const load_1 = require("../dataconnect/load");
const pgliteServer_1 = require("./dataconnect/pgliteServer");
const controller_1 = require("./controller");
const utils_1 = require("../utils");
const ensureApiEnabled_1 = require("../ensureApiEnabled");
const defaultCredentials_1 = require("../defaultCredentials");
exports.dataConnectEmulatorEvents = new events_1.EventEmitter();
class DataConnectEmulator {
    constructor(args) {
        this.args = args;
        this.usingExistingEmulator = false;
        this.logger = emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.DATACONNECT);
        this.emulatorClient = new DataConnectEmulatorClient();
    }
    async start() {
        let resolvedConfigDir;
        try {
            resolvedConfigDir = this.args.config.path(this.args.configDir);
            const info = await DataConnectEmulator.build({
                configDir: resolvedConfigDir,
                account: this.args.account,
            });
            if ((0, types_2.requiresVector)(info.metadata)) {
                if (constants_1.Constants.isDemoProject(this.args.projectId)) {
                    this.logger.logLabeled("WARN", "dataconnect", "Detected a 'demo-' project, but vector embeddings require a real project. Operations that use vector_embed will fail.");
                }
                else {
                    await (0, ensureApiEnabled_1.ensure)(this.args.projectId, (0, api_1.vertexAIOrigin)(), "dataconnect", true);
                    this.logger.logLabeled("WARN", "dataconnect", "Operations that use vector_embed will make calls to production Vertex AI");
                }
            }
        }
        catch (err) {
            this.logger.log("DEBUG", `'fdc build' failed with error: ${(0, error_2.getErrMsg)(err)}`);
        }
        const env = await DataConnectEmulator.getEnv(this.args.account, this.args.extraEnv);
        await (0, downloadableEmulators_1.start)(types_1.Emulators.DATACONNECT, {
            auto_download: this.args.auto_download,
            listen: (0, portUtils_1.listenSpecsToString)(this.args.listen),
            config_dir: resolvedConfigDir,
            enable_output_schema_extensions: this.args.enable_output_schema_extensions,
            enable_output_generated_sdk: this.args.enable_output_generated_sdk,
        }, env);
        this.usingExistingEmulator = false;
        if (this.args.autoconnectToPostgres) {
            const info = await (0, load_1.load)(this.args.projectId, this.args.config, this.args.configDir);
            const dbId = (0, types_2.mainSchemaYaml)(info.dataConnectYaml).datasource.postgresql?.database || "postgres";
            const serviceId = info.dataConnectYaml.serviceId;
            const pgPort = this.args.postgresListen?.[0].port;
            const pgHost = this.args.postgresListen?.[0].address;
            let connStr = (0, api_1.dataConnectLocalConnString)();
            if (connStr) {
                this.logger.logLabeled("INFO", "dataconnect", `FIREBASE_DATACONNECT_POSTGRESQL_STRING is set to ${clc.bold(connStr)} - using that instead of starting a new database`);
            }
            else if (pgHost && pgPort) {
                let dataDirectory = this.args.config.get("emulators.dataconnect.dataDir");
                if (dataDirectory) {
                    dataDirectory = this.args.config.path(dataDirectory);
                }
                const postgresDumpPath = this.args.importPath
                    ? path.join(this.args.importPath, "postgres.tar.gz")
                    : undefined;
                this.postgresServer = new pgliteServer_1.PostgresServer({
                    dataDirectory,
                    importPath: postgresDumpPath,
                    debug: this.args.debug,
                });
                const server = await this.postgresServer.createPGServer(pgHost, pgPort);
                const connectableHost = (0, utils_1.connectableHostname)(pgHost);
                connStr = `postgres://${connectableHost}:${pgPort}/${dbId}?sslmode=disable`;
                server.on("error", (err) => {
                    if (err instanceof error_1.FirebaseError) {
                        this.logger.logLabeled("ERROR", "SQL Connect", `${err}`);
                    }
                    else {
                        this.logger.logLabeled("ERROR", "dataconnect", `Postgres threw an unexpected error, shutting down the SQL Connect emulator: ${err}`);
                    }
                    void (0, controller_1.cleanShutdown)();
                });
                this.logger.logLabeled("INFO", "dataconnect", `Started up Postgres server, listening on ${JSON.stringify(server.address())}`);
            }
            await this.connectToPostgres(new URL(connStr), dbId, serviceId);
        }
        return;
    }
    async connect() {
        const emuInfo = await this.emulatorClient.getInfo();
        if (!emuInfo) {
            this.logger.logLabeled("ERROR", "dataconnect", "Could not connect to SQL Connect emulator. Check dataconnect-debug.log for more details.");
            return Promise.reject();
        }
        return Promise.resolve();
    }
    async stop() {
        if (this.usingExistingEmulator) {
            this.logger.logLabeled("INFO", "dataconnect", "Skipping cleanup of SQL Connect emulator, as it was not started by this process.");
            return;
        }
        if (this.postgresServer) {
            await this.postgresServer.stop();
        }
        return (0, downloadableEmulators_1.stop)(types_1.Emulators.DATACONNECT);
    }
    getInfo() {
        return {
            name: this.getName(),
            listen: this.args.listen,
            host: this.args.listen[0].address,
            port: this.args.listen[0].port,
            pid: (0, downloadableEmulators_1.getPID)(types_1.Emulators.DATACONNECT),
            timeout: 10000,
        };
    }
    getName() {
        return types_1.Emulators.DATACONNECT;
    }
    getVersion() {
        return (0, downloadableEmulators_1.getDownloadDetails)(types_1.Emulators.DATACONNECT).version;
    }
    async clearData() {
        if (this.postgresServer) {
            await this.postgresServer.clearDb();
        }
        else {
            const conn = new pg.Client((0, api_1.dataConnectLocalConnString)());
            await conn.query(pgliteServer_1.TRUNCATE_TABLES_SQL);
            await conn.end();
        }
    }
    async exportData(exportPath) {
        if (this.postgresServer) {
            await this.postgresServer.exportData(path.join(this.args.config.path(exportPath), "postgres.tar.gz"));
        }
        else {
            throw new error_1.FirebaseError("The SQL Connect emulator is currently connected to a separate Postgres instance. Export is not supported.");
        }
    }
    static async generate(args) {
        const commandInfo = await (0, downloadableEmulators_1.downloadIfNecessary)(types_1.Emulators.DATACONNECT);
        const cmd = ["--logtostderr", "-v=2", "sdk", "generate", `--config_dir=${args.configDir}`];
        if (args.watch) {
            cmd.push("--watch");
        }
        const env = await DataConnectEmulator.getEnv(args.account);
        return new Promise((resolve, reject) => {
            try {
                const proc = childProcess.spawn(commandInfo.binary, cmd, { stdio: "inherit", env });
                proc.on("close", (code) => {
                    if (code === 0) {
                        resolve();
                    }
                    else {
                        reject(new Error(`Command failed with exit code ${code}`));
                    }
                });
                proc.on("error", (err) => {
                    reject(err);
                });
            }
            catch (e) {
                if ((0, downloadableEmulators_1.isIncomaptibleArchError)(e)) {
                    reject(new error_1.FirebaseError(`Unknown system error when running the SQL Connect toolkit. ` +
                        `You may be able to fix this by installing Rosetta: ` +
                        `softwareupdate --install-rosetta`));
                }
                else {
                    reject(e);
                }
            }
        });
    }
    static async build(args) {
        const commandInfo = await (0, downloadableEmulators_1.downloadIfNecessary)(types_1.Emulators.DATACONNECT);
        const cmd = ["--logtostderr", "-v=2", "build", `--config_dir=${args.configDir}`];
        if (args.projectId) {
            cmd.push(`--project_id=${args.projectId}`);
        }
        const env = await DataConnectEmulator.getEnv(args.account);
        const res = childProcess.spawnSync(commandInfo.binary, cmd, { encoding: "utf-8", env });
        if ((0, downloadableEmulators_1.isIncomaptibleArchError)(res.error)) {
            throw new error_1.FirebaseError(`Unkown system error when running the SQL Connect toolkit. ` +
                `You may be able to fix this by installing Rosetta: ` +
                `softwareupdate --install-rosetta`);
        }
        if (res.error) {
            throw new error_1.FirebaseError(`Error starting up SQL Connect build: ${res.error.message}`, {
                original: res.error,
            });
        }
        if (res.status !== 0) {
            throw new error_1.FirebaseError(`Unable to build your SQL Connect schema and connectors (exit code ${res.status}): ${res.stderr}`);
        }
        if (res.stderr) {
            emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.DATACONNECT).log("DEBUG", res.stderr);
        }
        try {
            return JSON.parse(res.stdout);
        }
        catch (err) {
            throw new error_1.FirebaseError(`Unable to parse 'fdc build' output: ${res.stdout ?? res.stderr}`);
        }
    }
    async connectToPostgres(connectionString, database, serviceId) {
        if (!connectionString) {
            const msg = `No Postgres connection found. The SQL Connect emulator will not be able to execute operations.`;
            throw new error_1.FirebaseError(msg);
        }
        const MAX_RETRIES = 3;
        for (let i = 1; i <= MAX_RETRIES; i++) {
            try {
                this.logger.logLabeled("DEBUG", "SQL Connect", `Connecting to ${connectionString}}...`);
                connectionString.toString();
                await this.emulatorClient.configureEmulator({
                    connectionString: connectionString.toString(),
                    database,
                    serviceId,
                });
                this.logger.logLabeled("DEBUG", "SQL Connect", `Successfully connected to ${connectionString}}`);
                return true;
            }
            catch (err) {
                if (i === MAX_RETRIES) {
                    throw err;
                }
                this.logger.logLabeled("DEBUG", "SQL Connect", `Retrying connectToPostgress call (${i} of ${MAX_RETRIES} attempts): ${(0, error_2.getErrMsg)(err)}`);
                await new Promise((resolve) => setTimeout(resolve, 2000));
            }
        }
        return false;
    }
    static async getEnv(account, extraEnv = {}) {
        const credsEnv = {};
        if (account) {
            const defaultCredPath = await (0, defaultCredentials_1.getCredentialPathAsync)(account);
            if (defaultCredPath) {
                credsEnv.GOOGLE_APPLICATION_CREDENTIALS = defaultCredPath;
            }
        }
        return { ...process.env, ...extraEnv, ...credsEnv };
    }
}
exports.DataConnectEmulator = DataConnectEmulator;
class DataConnectEmulatorClient {
    constructor() {
        this.client = undefined;
    }
    async configureEmulator(body) {
        if (!this.client) {
            this.client = registry_1.EmulatorRegistry.client(types_1.Emulators.DATACONNECT);
        }
        try {
            const res = await this.client.post("emulator/configure", body);
            return res;
        }
        catch (err) {
            const status = (0, error_2.getErrStatus)(err);
            if (status === 500) {
                const message = err?.context?.body?.message;
                throw new error_1.FirebaseError(`SQL Connect emulator: ${message || String(err)}`);
            }
            throw err;
        }
    }
    async getInfo() {
        if (!this.client) {
            this.client = registry_1.EmulatorRegistry.client(types_1.Emulators.DATACONNECT);
        }
        return getInfo(this.client);
    }
}
exports.DataConnectEmulatorClient = DataConnectEmulatorClient;
async function getInfo(client) {
    try {
        const res = await client.get("emulator/info");
        return res.body;
    }
    catch (err) {
        return;
    }
}
