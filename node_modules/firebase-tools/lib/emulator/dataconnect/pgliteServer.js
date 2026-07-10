"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PGliteLoggerPatch = exports.PostgresServer = exports.TRUNCATE_TABLES_SQL = void 0;
exports.fromNodeSocket = fromNodeSocket;
const pglite_1 = require("@electric-sql/pglite");
const { dynamicImport } = require(true && "../../dynamicImport");
const net = require("node:net");
const node_stream_1 = require("node:stream");
const fs = require("fs");
const path = require("node:path");
const pg_gateway_1 = require("pg-gateway");
const logger_1 = require("../../logger");
const error_1 = require("../../error");
const fsutils_1 = require("../../fsutils");
const node_string_decoder_1 = require("node:string_decoder");
exports.TRUNCATE_TABLES_SQL = `
DO $do$
DECLARE _clear text;
BEGIN
   SELECT 'TRUNCATE TABLE ' || string_agg(oid::regclass::text, ', ') || ' CASCADE'
    FROM   pg_class
    WHERE  relkind = 'r'
    AND    relnamespace = 'public'::regnamespace
   INTO _clear;
  EXECUTE COALESCE(_clear, 'select now()');
END
$do$;`;
const decoder = new node_string_decoder_1.StringDecoder();
class PostgresServer {
    async createPGServer(host = "127.0.0.1", port) {
        const getDb = this.getDb.bind(this);
        const server = net.createServer(async (socket) => {
            const connection = await fromNodeSocket(socket, {
                serverVersion: "17.4 (PGlite 0.3.3)",
                auth: { method: "trust" },
                async *onMessage(data, { isAuthenticated }) {
                    if (!isAuthenticated) {
                        return;
                    }
                    const db = await getDb();
                    if (data[0] === pg_gateway_1.FrontendMessageCode.Terminate) {
                        await db.query("DEALLOCATE ALL");
                    }
                    const response = await db.execProtocolRaw(data);
                    for await (const message of extendedQueryPatch.getMessages(data, response)) {
                        yield message;
                    }
                },
            });
            const extendedQueryPatch = new PGliteLoggerPatch(connection);
            socket.on("end", () => {
                logger_1.logger.debug("Postgres client disconnected");
            });
            socket.on("error", (err) => {
                server.emit("error", err);
            });
        });
        this.server = server;
        const listeningPromise = new Promise((resolve) => {
            server.listen(port, host, () => {
                resolve();
            });
        });
        await listeningPromise;
        return server;
    }
    async getDb() {
        if (!this.db) {
            this.db = await this.forceCreateDB();
        }
        return this.db;
    }
    async getExtensions() {
        const vector = (await dynamicImport("@electric-sql/pglite/vector")).vector;
        const uuidOssp = (await dynamicImport("@electric-sql/pglite/contrib/uuid_ossp")).uuid_ossp;
        return { vector, uuidOssp };
    }
    async clearDb() {
        const db = await this.getDb();
        await db.query(exports.TRUNCATE_TABLES_SQL);
    }
    async exportData(exportPath) {
        const db = await this.getDb();
        const dump = await db.dumpDataDir();
        const arrayBuff = await dump.arrayBuffer();
        fs.writeFileSync(exportPath, new Uint8Array(arrayBuff));
    }
    async migrateDb(pgliteArgs) {
        if (!this.baseDataDirectory) {
            throw new error_1.FirebaseError("Cannot migrate database without a data directory.");
        }
        const { PGlite: PGlite02 } = await dynamicImport("pglite-2");
        const pgDump = (await dynamicImport("@electric-sql/pglite-tools/pg_dump")).pgDump;
        logger_1.logger.info("Opening database with Postgres 16...");
        const extensions = await this.getExtensions();
        const dataDir = this.baseDataDirectory;
        const oldDb = new PGlite02({ ...pgliteArgs, dataDir });
        await oldDb.waitReady;
        const oldVersion = await oldDb.query("SELECT version();");
        logger_1.logger.debug(`Old database version: ${oldVersion.rows[0].version}`);
        if (!oldVersion.rows[0].version.includes("PostgreSQL 16")) {
            await oldDb.close();
            throw new error_1.FirebaseError("Migration started, but DB version is not PostgreSQL 16.");
        }
        logger_1.logger.info("Dumping data from old database...");
        const dumpDir = await oldDb.dumpDataDir("none");
        const tempOldDb = await PGlite02.create({
            loadDataDir: dumpDir,
            extensions,
        });
        const dumpResult = await pgDump({ pg: tempOldDb, args: ["--verbose", "--verbose"] });
        await tempOldDb.close();
        await oldDb.close();
        logger_1.logger.info(`Moving old database directory to ${this.baseDataDirectory}/pg16...`);
        const pg16Dir = this.getVersionedDataDir(16);
        (0, fsutils_1.moveAll)(this.baseDataDirectory, pg16Dir);
        logger_1.logger.info("If you need to use an older version of the Firebase CLI, you can restore from that directory.");
        logger_1.logger.info("Creating new database with Postgres 17...");
        const pg17Dir = this.getVersionedDataDir(17);
        const newDb = new pglite_1.PGlite({ ...pgliteArgs, dataDir: pg17Dir });
        await newDb.waitReady;
        logger_1.logger.info("Importing data into new database...");
        const dumpText = await dumpResult.text();
        await newDb.exec(dumpText);
        await newDb.exec("SET SEARCH_PATH = public;");
        logger_1.logger.info("Postgres database migration successful.");
        return newDb;
    }
    getVersionedDataDir(version) {
        if (!this.baseDataDirectory) {
            return;
        }
        return path.join(this.baseDataDirectory, `pg${version}`);
    }
    async forceCreateDB() {
        const baseArgs = {
            debug: this.debug,
            extensions: await this.getExtensions(),
        };
        const pg17Dir = this.getVersionedDataDir(17);
        if (pg17Dir && !fs.existsSync(pg17Dir)) {
            fs.mkdirSync(pg17Dir, { recursive: true });
        }
        if (this.importPath) {
            logger_1.logger.debug(`Importing from ${this.importPath}`);
            const rf = fs.readFileSync(this.importPath);
            const file = new File([rf], this.importPath);
            baseArgs.loadDataDir = file;
        }
        if (this.baseDataDirectory && fs.existsSync(this.baseDataDirectory)) {
            const versionFilePath = path.join(this.baseDataDirectory, "PG_VERSION");
            if (fs.existsSync(versionFilePath)) {
                const version = fs.readFileSync(versionFilePath, "utf-8").trim();
                logger_1.logger.debug(`Found Postgres version file with version: ${version}`);
                if (version === "16") {
                    logger_1.logger.info("Detected a Postgres 16 data directory from an older version of firebase-tools. Migrating to Postgres 17...");
                    return this.migrateDb(baseArgs);
                }
            }
        }
        try {
            const db = new pglite_1.PGlite({ ...baseArgs, dataDir: pg17Dir });
            await db.waitReady;
            return db;
        }
        catch (err) {
            if (pg17Dir && (0, error_1.hasMessage)(err) && /Database already exists/.test(err.message)) {
                fs.rmSync(pg17Dir, { force: true, recursive: true });
                const db = new pglite_1.PGlite({ ...baseArgs, dataDir: pg17Dir });
                await db.waitReady;
                return db;
            }
            logger_1.logger.warn(`Error from pglite: ${err}`);
            throw new error_1.FirebaseError("Unexpected error starting up Postgres.");
        }
    }
    async stop() {
        if (this.db) {
            await this.db.close();
        }
        if (this.server) {
            this.server.close();
        }
        return;
    }
    constructor(args) {
        this.db = undefined;
        this.server = undefined;
        this.baseDataDirectory = args.dataDirectory;
        this.importPath = args.importPath;
        this.debug = args.debug ? 1 : 0;
    }
}
exports.PostgresServer = PostgresServer;
async function fromNodeSocket(socket, options) {
    const rs = node_stream_1.Readable.toWeb(socket);
    const ws = node_stream_1.Writable.toWeb(socket);
    const opts = options
        ? {
            ...options,
        }
        : undefined;
    return new pg_gateway_1.PostgresConnection({ readable: rs, writable: ws }, opts);
}
const CODE_TO_FRONTEND_MESSAGE = {};
for (const key in pg_gateway_1.FrontendMessageCode) {
    if (Object.prototype.hasOwnProperty.call(pg_gateway_1.FrontendMessageCode, key)) {
        CODE_TO_FRONTEND_MESSAGE[pg_gateway_1.FrontendMessageCode[key]] = key;
    }
}
const CODE_TO_BACKEND_MESSAGE = {};
for (const key in pg_gateway_1.BackendMessageCode) {
    if (Object.prototype.hasOwnProperty.call(pg_gateway_1.BackendMessageCode, key)) {
        CODE_TO_BACKEND_MESSAGE[pg_gateway_1.BackendMessageCode[key]] = key;
    }
}
function codeToFrontendMessageName(code) {
    return CODE_TO_FRONTEND_MESSAGE[code] || `UNKNOWN_FRONTEND_CODE_${code}`;
}
function codeTogBackendMessageName(code) {
    return CODE_TO_BACKEND_MESSAGE[code] || `UNKNOWN_BACKEND_CODE_${code}`;
}
class PGliteLoggerPatch {
    constructor(connection) {
        this.connection = connection;
        this.pgliteDebugLog = fs.createWriteStream("pglite-debug.log");
    }
    async *getMessages(request, response) {
        this.pgliteDebugLog.write(`\n[-> ${codeToFrontendMessageName(request[0])}] ` + decoder.write(request));
        for await (const bm of (0, pg_gateway_1.getMessages)(response)) {
            this.pgliteDebugLog.write(`\n[<- ${codeTogBackendMessageName(bm[0])}] ${decoder.write(bm)}`);
            yield bm;
        }
    }
}
exports.PGliteLoggerPatch = PGliteLoggerPatch;
