"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FunctionsServer = void 0;
const path = require("path");
const functionsEmulator_1 = require("../emulator/functionsEmulator");
const projectUtils_1 = require("../projectUtils");
const auth_1 = require("../auth");
const projectConfig = require("../functions/projectConfig");
const utils = require("../utils");
const registry_1 = require("../emulator/registry");
const commandUtils_1 = require("../emulator/commandUtils");
class FunctionsServer {
    assertServer() {
        if (!this.emulator || !this.backends) {
            throw new Error("Must call start() before calling any other operation!");
        }
        return this.emulator;
    }
    async start(options, partialArgs) {
        const projectId = (0, projectUtils_1.needProjectId)(options);
        const config = projectConfig.normalizeAndValidate(options.config.src.functions);
        const backends = [];
        for (const cfg of config) {
            const localCfg = projectConfig.requireLocal(cfg, "Remote sources are not supported in the Functions emulator.");
            const functionsDir = path.join(options.config.projectDir, localCfg.source);
            backends.push({
                functionsDir,
                codebase: localCfg.codebase,
                runtime: localCfg.runtime,
                env: {},
                secretEnv: [],
            });
        }
        this.backends = backends;
        const account = (0, auth_1.getProjectDefaultAccount)(options.config.projectDir);
        const args = {
            projectId,
            projectDir: options.config.projectDir,
            emulatableBackends: this.backends,
            projectAlias: options.projectAlias,
            account,
            ...partialArgs,
            debugPort: (0, commandUtils_1.parseInspectionPort)(options),
        };
        if (options.host) {
            utils.assertIsStringOrUndefined(options.host);
            args.host = options.host;
        }
        if (options.port) {
            utils.assertIsNumber(options.port);
            const targets = options.targets;
            const port = options.port;
            const hostingRunning = targets && targets.includes("hosting");
            if (hostingRunning) {
                args.port = port + 1;
            }
            else {
                args.port = port;
            }
        }
        this.emulator = new functionsEmulator_1.FunctionsEmulator(args);
        return registry_1.EmulatorRegistry.start(this.emulator);
    }
    async connect() {
        await this.assertServer().connect();
    }
    async stop() {
        await this.assertServer().stop();
    }
    get() {
        return this.assertServer();
    }
}
exports.FunctionsServer = FunctionsServer;
