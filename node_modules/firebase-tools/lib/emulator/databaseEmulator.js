"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DatabaseEmulator = void 0;
const chokidar = require("chokidar");
const clc = require("colorette");
const fs = require("fs");
const path = require("path");
const http = require("http");
const downloadableEmulators = require("./downloadableEmulators");
const types_1 = require("../emulator/types");
const constants_1 = require("./constants");
const registry_1 = require("./registry");
const emulatorLogger_1 = require("./emulatorLogger");
const error_1 = require("../error");
const utils_1 = require("../utils");
class DatabaseEmulator {
    constructor(args) {
        this.args = args;
        this.importedNamespaces = [];
        this.logger = emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.DATABASE);
    }
    async start() {
        const functionsInfo = registry_1.EmulatorRegistry.getInfo(types_1.Emulators.FUNCTIONS);
        if (functionsInfo) {
            this.args.functions_emulator_host = functionsInfo.host;
            this.args.functions_emulator_port = functionsInfo.port;
        }
        if (this.args.rules) {
            for (const c of this.args.rules) {
                if (!c.instance) {
                    this.logger.log("DEBUG", `args.rules=${JSON.stringify(this.args.rules)}`);
                    this.logger.logLabeled("WARN_ONCE", "database", "Could not determine your Realtime Database instance name, so rules hot reloading is disabled.");
                    continue;
                }
                this.rulesWatcher = chokidar.watch(c.rules, { persistent: true, ignoreInitial: true });
                this.rulesWatcher.on("change", async () => {
                    await new Promise((res) => setTimeout(res, 5));
                    this.logger.logLabeled("BULLET", "database", `Change detected, updating rules for ${c.instance}...`);
                    try {
                        await this.updateRules(c.instance, c.rules);
                        this.logger.logLabeled("SUCCESS", "database", "Rules updated.");
                    }
                    catch (e) {
                        this.logger.logLabeled("WARN", "database", this.prettyPrintRulesError(c.rules, e));
                        this.logger.logLabeled("WARN", "database", "Failed to update rules");
                    }
                });
            }
        }
        return downloadableEmulators.start(types_1.Emulators.DATABASE, this.args);
    }
    async connect() {
        if (this.args.rules) {
            for (const c of this.args.rules) {
                if (!c.instance) {
                    continue;
                }
                try {
                    await this.updateRules(c.instance, c.rules);
                }
                catch (e) {
                    const rulesError = this.prettyPrintRulesError(c.rules, e);
                    this.logger.logLabeled("WARN", "database", rulesError);
                    this.logger.logLabeled("WARN", "database", "Failed to update rules");
                    throw new error_1.FirebaseError(`Failed to load initial ${constants_1.Constants.description(this.getName())} rules:\n${rulesError}`);
                }
            }
        }
    }
    stop() {
        return downloadableEmulators.stop(types_1.Emulators.DATABASE);
    }
    getInfo() {
        const host = this.args.host || constants_1.Constants.getDefaultHost();
        const port = this.args.port || constants_1.Constants.getDefaultPort(types_1.Emulators.DATABASE);
        return {
            name: this.getName(),
            host,
            port,
            pid: downloadableEmulators.getPID(types_1.Emulators.DATABASE),
        };
    }
    getName() {
        return types_1.Emulators.DATABASE;
    }
    getImportedNamespaces() {
        return this.importedNamespaces;
    }
    async importData(ns, fPath) {
        this.logger.logLabeled("BULLET", "database", `Importing data from ${fPath}`);
        const readStream = fs.createReadStream(fPath);
        const { host, port } = this.getInfo();
        await new Promise((resolve, reject) => {
            const req = http.request({
                method: "PUT",
                host: (0, utils_1.connectableHostname)(host),
                port,
                path: `/.json?ns=${ns}&disableTriggers=true&writeSizeLimit=unlimited`,
                headers: {
                    Authorization: "Bearer owner",
                    "Content-Type": "application/json",
                },
            }, (response) => {
                if (response.statusCode === 200) {
                    this.importedNamespaces.push(ns);
                    resolve();
                }
                else {
                    this.logger.log("DEBUG", "Database import failed: " + response.statusCode);
                    response
                        .on("data", (d) => {
                        this.logger.log("DEBUG", d.toString());
                    })
                        .on("end", reject);
                }
            });
            req.on("error", reject);
            readStream.pipe(req, { end: true });
        }).catch((e) => {
            throw new error_1.FirebaseError("Error during database import.", { original: e, exit: 1 });
        });
    }
    async updateRules(instance, rulesPath) {
        const content = fs.readFileSync(rulesPath, "utf8");
        try {
            await registry_1.EmulatorRegistry.client(types_1.Emulators.DATABASE).put(`/.settings/rules.json`, content, {
                headers: { Authorization: "Bearer owner" },
                queryParams: { ns: instance },
            });
        }
        catch (e) {
            if (e.context && e.context.body) {
                throw e.context.body.error;
            }
            throw e.original ?? e;
        }
    }
    prettyPrintRulesError(filePath, error) {
        let errStr;
        switch (typeof error) {
            case "string":
                errStr = error;
                break;
            case "object":
                if (error != null && "message" in error) {
                    const message = error.message;
                    errStr = `${message}`;
                    if (typeof message === "string") {
                        try {
                            const parsed = JSON.parse(message);
                            if (typeof parsed === "object" && parsed.error) {
                                errStr = `${parsed.error}`;
                            }
                        }
                        catch (_) {
                        }
                    }
                    break;
                }
            default:
                errStr = `Unknown error: ${JSON.stringify(error)}`;
        }
        const relativePath = path.relative(process.cwd(), filePath);
        return `${clc.cyan(relativePath)}:${errStr.trim()}`;
    }
}
exports.DatabaseEmulator = DatabaseEmulator;
