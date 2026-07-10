"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.EmulatorHub = void 0;
const os = require("os");
const fs = require("fs");
const path = require("path");
const utils = require("../utils");
const logger_1 = require("../logger");
const types_1 = require("./types");
const hubExport_1 = require("./hubExport");
const registry_1 = require("./registry");
const ExpressBasedEmulator_1 = require("./ExpressBasedEmulator");
const pkg = require("../../package.json");
class EmulatorHub extends ExpressBasedEmulator_1.ExpressBasedEmulator {
    static readLocatorFile(projectId) {
        const locatorPath = this.getLocatorFilePath(projectId);
        if (!fs.existsSync(locatorPath)) {
            return undefined;
        }
        const data = fs.readFileSync(locatorPath, "utf8").toString();
        const locator = JSON.parse(data);
        logger_1.logger.debug(`Found emulator hub locator: ${JSON.stringify(locator)}`);
        return locator;
    }
    static getLocatorFilePath(projectId) {
        const dir = os.tmpdir();
        if (!projectId) {
            projectId = EmulatorHub.MISSING_PROJECT_PLACEHOLDER;
        }
        const filename = `hub-${projectId}.json`;
        const locatorPath = path.join(dir, filename);
        return locatorPath;
    }
    constructor(args) {
        super({
            listen: args.listen,
        });
        this.args = args;
    }
    async start() {
        await super.start();
        await this.writeLocatorFile();
    }
    getRunningEmulatorsMapping() {
        const emulators = {};
        for (const info of registry_1.EmulatorRegistry.listRunningWithInfo()) {
            emulators[info.name] = {
                listen: this.args.listenForEmulator[info.name],
                ...info,
            };
        }
        return emulators;
    }
    async createExpressApp() {
        const app = await super.createExpressApp();
        app.get("/", (req, res) => {
            res.json({
                ...this.buildLocator(),
                host: utils.connectableHostname(this.args.listen[0].address),
                port: this.args.listen[0].port,
            });
        });
        app.get(EmulatorHub.PATH_EMULATORS, (req, res) => {
            res.json(this.getRunningEmulatorsMapping());
        });
        app.post(EmulatorHub.PATH_EXPORT, async (req, res) => {
            if (req.headers.origin) {
                res.status(403).json({
                    message: `Export cannot be triggered by external callers.`,
                });
            }
            const path = req.body.path;
            const initiatedBy = req.body.initiatedBy || "unknown";
            const targets = req.body.targets;
            utils.logLabeledBullet("emulators", `Received export request. Exporting data to ${path}.`);
            try {
                await new hubExport_1.HubExport(this.args.projectId, {
                    path,
                    initiatedBy,
                    targets,
                }).exportAll();
                utils.logLabeledSuccess("emulators", "Export complete.");
                res.status(200).send({
                    message: "OK",
                });
            }
            catch (e) {
                const errorString = e.message || JSON.stringify(e);
                utils.logLabeledWarning("emulators", `Export failed: ${errorString}`);
                res.status(500).json({
                    message: errorString,
                });
            }
        });
        app.put(EmulatorHub.PATH_DISABLE_FUNCTIONS, async (req, res) => {
            utils.logLabeledBullet("emulators", `Disabling Cloud Functions triggers, non-HTTP functions will not execute.`);
            const instance = registry_1.EmulatorRegistry.get(types_1.Emulators.FUNCTIONS);
            if (!instance) {
                res.status(400).json({ error: "The Cloud Functions emulator is not running." });
                return;
            }
            const emu = instance;
            await emu.disableBackgroundTriggers();
            res.status(200).json({ enabled: false });
        });
        app.put(EmulatorHub.PATH_ENABLE_FUNCTIONS, async (req, res) => {
            utils.logLabeledBullet("emulators", `Enabling Cloud Functions triggers, non-HTTP functions will execute.`);
            const instance = registry_1.EmulatorRegistry.get(types_1.Emulators.FUNCTIONS);
            if (!instance) {
                res.status(400).send("The Cloud Functions emulator is not running.");
                return;
            }
            const emu = instance;
            await emu.reloadTriggers();
            res.status(200).json({ enabled: true });
        });
        app.post(EmulatorHub.PATH_CLEAR_DATA_CONNECT, async (req, res) => {
            if (req.headers.origin) {
                res.status(403).json({
                    message: `Clear SQL Connect cannot be triggered by external callers.`,
                });
            }
            utils.logLabeledBullet("emulators", `Clearing data from SQL Connect data sources.`);
            const instance = registry_1.EmulatorRegistry.get(types_1.Emulators.DATACONNECT);
            if (!instance) {
                res.status(400).json({ error: "The SQL Connect emulator is not running." });
                return;
            }
            await instance.clearData();
            res.status(200).json({ success: true });
        });
        return app;
    }
    async stop() {
        await super.stop();
    }
    getName() {
        return types_1.Emulators.HUB;
    }
    buildLocator() {
        const version = pkg.version;
        const origins = [];
        for (const spec of this.args.listen) {
            if (spec.family === "IPv6") {
                origins.push(`http://[${utils.connectableHostname(spec.address)}]:${spec.port}`);
            }
            else {
                origins.push(`http://${utils.connectableHostname(spec.address)}:${spec.port}`);
            }
        }
        return {
            version,
            origins,
            pid: process.pid,
        };
    }
    async writeLocatorFile() {
        const projectId = this.args.projectId;
        const prevLocator = EmulatorHub.readLocatorFile(projectId);
        if (prevLocator && prevLocator.pid && isProcessLive(prevLocator.pid)) {
            utils.logLabeledWarning("emulators", `It seems that you are running multiple instances of the emulator suite for project ${projectId}. This may result in unexpected behavior.`);
            return;
        }
        const locatorPath = EmulatorHub.getLocatorFilePath(projectId);
        logger_1.logger.debug(`Write emulator hub locator at ${locatorPath}`);
        fs.writeFileSync(locatorPath, JSON.stringify(this.buildLocator()));
        const cleanup = () => {
            try {
                const curLocator = EmulatorHub.readLocatorFile(projectId);
                if (curLocator && curLocator.pid === process.pid) {
                    fs.unlinkSync(locatorPath);
                    logger_1.logger.debug(`Delete emulator hub locator file: ${locatorPath}`);
                }
            }
            catch (e) {
                logger_1.logger.debug(`Cannot delete emulator hub locator file`, e);
            }
        };
        process.on("SIGINT", cleanup);
        process.on("SIGTERM", cleanup);
        process.on("exit", cleanup);
    }
}
exports.EmulatorHub = EmulatorHub;
EmulatorHub.MISSING_PROJECT_PLACEHOLDER = "demo-no-project";
EmulatorHub.CLI_VERSION = pkg.version;
EmulatorHub.PATH_EXPORT = "/_admin/export";
EmulatorHub.PATH_DISABLE_FUNCTIONS = "/functions/disableBackgroundTriggers";
EmulatorHub.PATH_ENABLE_FUNCTIONS = "/functions/enableBackgroundTriggers";
EmulatorHub.PATH_EMULATORS = "/emulators";
EmulatorHub.PATH_CLEAR_DATA_CONNECT = "/dataconnect/clearData";
function isProcessLive(pid) {
    try {
        process.kill(pid, 0);
        return true;
    }
    catch (error) {
        return error.code === "EPERM";
    }
}
