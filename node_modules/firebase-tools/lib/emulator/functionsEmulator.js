"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FunctionsEmulator = exports.TCPConn = exports.IPCConn = void 0;
const fs = require("fs");
const path = require("path");
const express = require("express");
const clc = require("colorette");
const http = require("http");
const cors = require("cors");
const semver = require("semver");
const url_1 = require("url");
const events_1 = require("events");
const logger_1 = require("../logger");
const track_1 = require("../track");
const constants_1 = require("./constants");
const types_1 = require("./types");
const chokidar = require("chokidar");
const portfinder = require("portfinder");
const spawn = require("cross-spawn");
const functionsEmulatorShared_1 = require("./functionsEmulatorShared");
const registry_1 = require("./registry");
const emulatorLogger_1 = require("./emulatorLogger");
const functionsRuntimeWorker_1 = require("./functionsRuntimeWorker");
const error_1 = require("../error");
const workQueue_1 = require("./workQueue");
const utils_1 = require("../utils");
const adminSdkConfig_1 = require("./adminSdkConfig");
const validate_1 = require("../deploy/functions/validate");
const secretManager_1 = require("../gcp/secretManager");
const backend = require("../deploy/functions/backend");
const build = require("../deploy/functions/build");
const runtimes = require("../deploy/functions/runtimes");
const functionsEnv = require("../functions/env");
const v1_1 = require("../functions/events/v1");
const build_1 = require("../deploy/functions/build");
const env_1 = require("./env");
const python_1 = require("../functions/python");
const supported_1 = require("../deploy/functions/runtimes/supported");
const dart_1 = require("../deploy/functions/runtimes/dart");
const triggerSupport_1 = require("../deploy/functions/runtimes/dart/triggerSupport");
const EVENT_INVOKE_GA4 = "functions_invoke";
const DATABASE_PATH_PATTERN = new RegExp("^projects/[^/]+/instances/([^/]+)/refs(/.*)$");
class IPCConn {
    constructor(socketPath) {
        this.socketPath = socketPath;
    }
    httpReqOpts() {
        return {
            socketPath: this.socketPath,
        };
    }
}
exports.IPCConn = IPCConn;
class TCPConn {
    constructor(host, port) {
        this.host = host;
        this.port = port;
    }
    httpReqOpts() {
        return {
            host: this.host,
            port: this.port,
        };
    }
}
exports.TCPConn = TCPConn;
class FunctionsEmulator {
    static getHttpFunctionUrl(projectId, name, region, info) {
        let url;
        if (info) {
            url = new url_1.URL("http://" + (0, functionsEmulatorShared_1.formatHost)(info));
        }
        else {
            url = registry_1.EmulatorRegistry.url(types_1.Emulators.FUNCTIONS);
        }
        url.pathname = `/${projectId}/${region}/${name}`;
        return url.toString();
    }
    constructor(args) {
        this.args = args;
        this.triggers = {};
        this.triggerGeneration = 0;
        this.logger = emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.FUNCTIONS);
        this.multicastTriggers = {};
        this.blockingFunctionsConfig = {};
        this.staticBackends = [];
        this.dynamicBackends = [];
        this.watchers = [];
        this.watchCleanups = [];
        this.debugMode = false;
        this.staticBackends = args.emulatableBackends;
        emulatorLogger_1.EmulatorLogger.setVerbosity(this.args.verbosity ? emulatorLogger_1.Verbosity[this.args.verbosity] : emulatorLogger_1.Verbosity["DEBUG"]);
        if (this.args.debugPort) {
            const maybeNodeCodebases = this.staticBackends.filter((b) => !b.runtime || b.runtime.startsWith("node"));
            if (maybeNodeCodebases.length > 1 && typeof this.args.debugPort === "number") {
                throw new error_1.FirebaseError("Cannot debug on a single port with multiple codebases. " +
                    "Use --inspect-functions=true to assign dynamic ports to each codebase");
            }
            this.args.disabledRuntimeFeatures = this.args.disabledRuntimeFeatures || {};
            this.args.disabledRuntimeFeatures.timeout = true;
            this.debugMode = true;
        }
        this.adminSdkConfig = { ...this.args.adminSdkConfig, projectId: this.args.projectId };
        const mode = this.debugMode ? types_1.FunctionsExecutionMode.SEQUENTIAL : types_1.FunctionsExecutionMode.AUTO;
        this.workerPools = {};
        for (const backend of this.staticBackends) {
            const pool = new functionsRuntimeWorker_1.RuntimeWorkerPool(mode);
            this.workerPools[backend.codebase] = pool;
        }
        this.workQueue = new workQueue_1.WorkQueue(mode);
    }
    async loadDynamicExtensionBackends() {
        if (this.args.extensionsEmulator) {
            const unfilteredBackends = this.args.extensionsEmulator.getDynamicExtensionBackends();
            this.dynamicBackends =
                this.args.extensionsEmulator.filterUnemulatedTriggers(unfilteredBackends);
            const mode = this.debugMode ? types_1.FunctionsExecutionMode.SEQUENTIAL : types_1.FunctionsExecutionMode.AUTO;
            const credentialEnv = await (0, env_1.getCredentialsEnvironment)(this.args.account, this.logger, "functions");
            for (const backend of this.dynamicBackends) {
                backend.env = { ...credentialEnv, ...backend.env };
                if (this.workerPools[backend.codebase]) {
                    if (this.debugMode) {
                        this.workerPools[backend.codebase].exit();
                    }
                    else {
                        this.workerPools[backend.codebase].refresh();
                    }
                }
                else {
                    const pool = new functionsRuntimeWorker_1.RuntimeWorkerPool(mode);
                    this.workerPools[backend.codebase] = pool;
                }
                await this.loadTriggers(backend, true);
            }
        }
    }
    createHubServer() {
        this.workQueue.start();
        const hub = express();
        const dataMiddleware = (req, res, next) => {
            const chunks = [];
            req.on("data", (chunk) => {
                chunks.push(chunk);
            });
            req.on("end", () => {
                req.rawBody = Buffer.concat(chunks);
                next();
            });
        };
        const backgroundFunctionRoute = `/functions/projects/:project_id/triggers/:trigger_name(*)`;
        const httpsFunctionRoute = `/${this.args.projectId}/:region/:trigger_name`;
        const multicastFunctionRoute = `/functions/projects/:project_id/trigger_multicast`;
        const httpsFunctionRoutes = [httpsFunctionRoute, `${httpsFunctionRoute}/*`];
        const listBackendsRoute = `/backends`;
        const httpsHandler = (req, res) => {
            const work = () => {
                return this.handleHttpsTrigger(req, res);
            };
            work.type = `${req.path}-${new Date().toISOString()}`;
            this.workQueue.submit(work);
        };
        const multicastHandler = (req, res) => {
            const projectId = req.params.project_id;
            const rawBody = req.rawBody;
            const event = JSON.parse(rawBody.toString());
            let triggerKey;
            if (req.headers["content-type"]?.includes("cloudevent")) {
                triggerKey = `${this.args.projectId}:${event.type}`;
            }
            else {
                triggerKey = `${this.args.projectId}:${event.eventType}`;
            }
            if (event.data.bucket) {
                triggerKey += `:${event.data.bucket}`;
            }
            const triggers = this.multicastTriggers[triggerKey] || [];
            const { host, port } = this.getInfo();
            triggers.forEach((triggerId) => {
                const work = () => {
                    return new Promise((resolve, reject) => {
                        const trigReq = http.request({
                            host: (0, utils_1.connectableHostname)(host),
                            port,
                            method: req.method,
                            path: `/functions/projects/${projectId}/triggers/${triggerId}`,
                            headers: req.headers,
                        });
                        trigReq.on("error", reject);
                        trigReq.write(rawBody);
                        trigReq.end();
                        resolve();
                    });
                };
                work.type = `${triggerId}-${new Date().toISOString()}`;
                this.workQueue.submit(work);
            });
            res.json({ status: "multicast_acknowledged" });
        };
        const listBackendsHandler = (req, res) => {
            res.json({ backends: this.getBackendInfo() });
        };
        hub.get(listBackendsRoute, cors({ origin: true }), listBackendsHandler);
        hub.post(backgroundFunctionRoute, dataMiddleware, httpsHandler);
        hub.post(multicastFunctionRoute, dataMiddleware, multicastHandler);
        hub.all(httpsFunctionRoutes, dataMiddleware, httpsHandler);
        hub.all("*", dataMiddleware, (req, res) => {
            logger_1.logger.debug(`Functions emulator received unknown request at path ${req.path}`);
            res.sendStatus(404);
        });
        return hub;
    }
    async sendRequest(trigger, body) {
        const record = this.getTriggerRecordByKey(this.getTriggerKey(trigger));
        const pool = this.workerPools[record.backend.codebase];
        if (!pool.readyForWork(trigger.id, record.backend.runtime)) {
            try {
                await this.startRuntime(record.backend, trigger);
            }
            catch (e) {
                this.logger.logLabeled("ERROR", `Failed to start runtime for ${trigger.id}: ${e}`);
                return;
            }
        }
        const worker = pool.getIdleWorker(trigger.id, record.backend.runtime);
        if (this.debugMode) {
            await worker.sendDebugMsg({
                functionTarget: trigger.entryPoint,
                functionSignature: (0, functionsEmulatorShared_1.getSignatureType)(trigger),
            });
        }
        const reqBody = JSON.stringify(body);
        const headers = {
            "Content-Type": "application/json",
            "Content-Length": `${reqBody.length}`,
        };
        const isDart = (0, supported_1.runtimeIsLanguage)(record.backend.runtime, "dart");
        const path = isDart ? `/${trigger.entryPoint}` : `/`;
        return new Promise((resolve, reject) => {
            const req = http.request({
                ...worker.runtime.conn.httpReqOpts(),
                method: "POST",
                path: path,
                headers: headers,
            }, resolve);
            req.on("error", reject);
            req.write(reqBody);
            req.end();
        });
    }
    async start() {
        const credentialEnv = await (0, env_1.getCredentialsEnvironment)(this.args.account, this.logger, "functions");
        for (const e of this.staticBackends) {
            e.env = { ...credentialEnv, ...e.env };
        }
        if (Object.keys(this.adminSdkConfig || {}).length <= 1) {
            const adminSdkConfig = await (0, adminSdkConfig_1.getProjectAdminSdkConfigOrCached)(this.args.projectId);
            if (adminSdkConfig) {
                this.adminSdkConfig = adminSdkConfig;
            }
            else {
                this.logger.logLabeled("WARN", "functions", "Unable to fetch project Admin SDK configuration, Admin SDK behavior in Cloud Functions emulator may be incorrect.");
                this.adminSdkConfig = (0, adminSdkConfig_1.constructDefaultAdminSdkConfig)(this.args.projectId);
            }
        }
        const { host, port } = this.getInfo();
        this.workQueue.start();
        const server = this.createHubServer().listen(port, host);
        this.destroyServer = (0, utils_1.createDestroyer)(server);
        return Promise.resolve();
    }
    async connect() {
        for (const backend of this.staticBackends) {
            this.logger.logLabeled("BULLET", "functions", `Watching "${backend.functionsDir}" for Cloud Functions...`);
            await this.loadTriggers(backend, true);
            const isDart = (0, supported_1.runtimeIsLanguage)(backend.runtime, "dart");
            if (isDart) {
                const runtimeDelegateContext = {
                    projectId: this.args.projectId,
                    projectDir: this.args.projectDir,
                    sourceDir: backend.functionsDir,
                    runtime: backend.runtime,
                };
                const delegate = await runtimes.getRuntimeDelegate(runtimeDelegateContext);
                this.logger.logLabeled("BULLET", "functions", `Starting build_runner watch for Dart functions...`);
                const debouncedLoadTriggers = (0, utils_1.debounce)(() => this.loadTriggers(backend), 1000);
                const cleanup = await delegate.watch(() => {
                    this.logger.log("DEBUG", "build_runner rebuilt, reloading triggers");
                    debouncedLoadTriggers();
                });
                this.watchCleanups.push(cleanup);
                this.logger.logLabeled("SUCCESS", "functions", `build_runner initial build completed`);
            }
            else {
                const watcher = chokidar.watch(backend.functionsDir, {
                    ignored: [
                        /(^|[\/\\])\../,
                        /.+\.log/,
                        /.+?[\\\/]node_modules[\\\/].+?/,
                        /.+?[\\\/]venv[\\\/].+?/,
                        ...(backend.ignore?.map((i) => `**/${i}`) ?? []),
                    ],
                    persistent: true,
                });
                this.watchers.push(watcher);
                const debouncedLoadTriggers = (0, utils_1.debounce)(() => this.loadTriggers(backend), 1000);
                watcher.on("change", (filePath) => {
                    this.logger.log("DEBUG", `File ${filePath} changed, reloading triggers`);
                    return debouncedLoadTriggers();
                });
            }
        }
        await this.performPostLoadOperations();
        return;
    }
    async stop() {
        try {
            await this.workQueue.flush();
        }
        catch (e) {
            this.logger.logLabeled("WARN", "functions", "Functions emulator work queue did not empty before stopping");
        }
        this.workQueue.stop();
        for (const pool of Object.values(this.workerPools)) {
            pool.exit();
        }
        for (const watcher of this.watchers) {
            await watcher.close();
        }
        this.watchers = [];
        for (const cleanup of this.watchCleanups) {
            await cleanup();
        }
        this.watchCleanups = [];
        if (this.destroyServer) {
            await this.destroyServer();
        }
    }
    async discoverTriggers(emulatableBackend) {
        if (emulatableBackend.predefinedTriggers) {
            return (0, functionsEmulatorShared_1.emulatedFunctionsByRegion)(emulatableBackend.predefinedTriggers, emulatableBackend.secretEnv);
        }
        else {
            const runtimeConfig = this.getRuntimeConfig(emulatableBackend);
            const runtimeDelegateContext = {
                projectId: this.args.projectId,
                projectDir: this.args.projectDir,
                sourceDir: emulatableBackend.functionsDir,
                runtime: emulatableBackend.runtime,
            };
            const runtimeDelegate = await runtimes.getRuntimeDelegate(runtimeDelegateContext);
            logger_1.logger.debug(`Validating ${runtimeDelegate.language} source`);
            await runtimeDelegate.validate();
            logger_1.logger.debug(`Building ${runtimeDelegate.language} source`);
            await runtimeDelegate.build();
            emulatableBackend.runtime = runtimeDelegate.runtime;
            emulatableBackend.bin = runtimeDelegate.bin;
            const firebaseConfig = this.getFirebaseConfig();
            const environment = {
                ...this.getSystemEnvs(),
                ...this.getEmulatorEnvs(),
                FIREBASE_CONFIG: firebaseConfig,
                ...emulatableBackend.env,
            };
            const userEnvOpt = {
                functionsSource: emulatableBackend.functionsDir,
                projectId: this.args.projectId,
                projectAlias: this.args.projectAlias,
                isEmulator: true,
                configDir: emulatableBackend.configDir,
            };
            const userEnvs = functionsEnv.loadUserEnvs(userEnvOpt);
            const discoveredBuild = await runtimeDelegate.discoverBuild(runtimeConfig, environment);
            if (discoveredBuild.extensions && this.args.extensionsEmulator) {
                await this.args.extensionsEmulator.addDynamicExtensions(emulatableBackend.codebase, discoveredBuild);
                await this.loadDynamicExtensionBackends();
            }
            build.applyPrefix(discoveredBuild, emulatableBackend.prefix || "");
            const resolution = await (0, build_1.resolveBackend)({
                build: discoveredBuild,
                firebaseConfig: JSON.parse(firebaseConfig),
                userEnvs,
                nonInteractive: false,
                isEmulator: true,
            });
            functionsEnv.writeResolvedParams(resolution.envs, userEnvs, userEnvOpt);
            const discoveredBackend = resolution.backend;
            const endpoints = backend.allEndpoints(discoveredBackend);
            (0, functionsEmulatorShared_1.prepareEndpoints)(endpoints);
            for (const e of endpoints) {
                e.codebase = emulatableBackend.codebase;
            }
            this.logDartTriggerSupportWarnings(endpoints);
            return (0, functionsEmulatorShared_1.emulatedFunctionsFromEndpoints)(endpoints);
        }
    }
    async loadTriggers(emulatableBackend, force = false) {
        let triggerDefinitions = [];
        try {
            triggerDefinitions = await this.discoverTriggers(emulatableBackend);
            this.logger.logLabeled("SUCCESS", "functions", `Loaded functions definitions from source: ${triggerDefinitions
                .map((t) => t.entryPoint)
                .join(", ")}.`);
        }
        catch (e) {
            this.logger.logLabeled("ERROR", "functions", `Failed to load function definition from source: ${e}`);
            return;
        }
        if (this.debugMode) {
            this.workerPools[emulatableBackend.codebase].exit();
        }
        else {
            this.workerPools[emulatableBackend.codebase].refresh();
        }
        const toRemove = Object.keys(this.triggers).filter((recordKey) => {
            const record = this.getTriggerRecordByKey(recordKey);
            if (record.backend.codebase !== emulatableBackend.codebase) {
                return false;
            }
            if (force) {
                return true;
            }
            return !triggerDefinitions.some((def) => record.def.entryPoint === def.entryPoint &&
                JSON.stringify(record.def.eventTrigger) === JSON.stringify(def.eventTrigger));
        });
        await this.removeTriggers(toRemove);
        const toSetup = triggerDefinitions.filter((definition) => {
            if (force) {
                return true;
            }
            const anyEnabledMatch = Object.values(this.triggers).some((record) => {
                const sameEntryPoint = record.def.entryPoint === definition.entryPoint;
                const sameEventTrigger = JSON.stringify(record.def.eventTrigger) === JSON.stringify(definition.eventTrigger);
                if (sameEntryPoint && !sameEventTrigger) {
                    this.logger.log("DEBUG", `Definition for trigger ${definition.entryPoint} changed from ${JSON.stringify(record.def.eventTrigger)} to ${JSON.stringify(definition.eventTrigger)}`);
                }
                return record.enabled && sameEntryPoint && sameEventTrigger;
            });
            return !anyEnabledMatch;
        });
        for (const definition of toSetup) {
            try {
                (0, validate_1.functionIdsAreValid)([{ ...definition, id: definition.name }]);
            }
            catch (e) {
                throw new error_1.FirebaseError(`functions[${definition.id}]: Invalid function id: ${e.message}`);
            }
            let added = false;
            let url = undefined;
            if (definition.httpsTrigger) {
                added = true;
                url = FunctionsEmulator.getHttpFunctionUrl(this.args.projectId, definition.name, definition.region);
                if (definition.taskQueueTrigger) {
                    added = await this.addTaskQueueTrigger(this.args.projectId, definition.region, definition.name, url, definition.taskQueueTrigger);
                }
            }
            else if (definition.eventTrigger) {
                const service = (0, functionsEmulatorShared_1.getFunctionService)(definition);
                const key = this.getTriggerKey(definition);
                const signature = (0, functionsEmulatorShared_1.getSignatureType)(definition);
                switch (service) {
                    case constants_1.Constants.SERVICE_FIRESTORE:
                        added = await this.addFirestoreTrigger(this.args.projectId, key, definition.eventTrigger, signature);
                        break;
                    case constants_1.Constants.SERVICE_REALTIME_DATABASE:
                        added = await this.addRealtimeDatabaseTrigger(this.args.projectId, definition.id, key, definition.eventTrigger, signature, definition.region);
                        break;
                    case constants_1.Constants.SERVICE_PUBSUB:
                        added = await this.addPubsubTrigger(definition.name, key, definition.eventTrigger, signature, definition.schedule);
                        break;
                    case constants_1.Constants.SERVICE_EVENTARC:
                        added = await this.addEventarcTrigger(this.args.projectId, key, definition.eventTrigger);
                        break;
                    case constants_1.Constants.SERVICE_AUTH:
                        added = this.addAuthTrigger(this.args.projectId, key, definition.eventTrigger);
                        break;
                    case constants_1.Constants.SERVICE_STORAGE:
                        added = this.addStorageTrigger(this.args.projectId, key, definition.eventTrigger);
                        break;
                    case constants_1.Constants.SERVICE_FIREALERTS:
                        added = await this.addFirealertsTrigger(this.args.projectId, key, definition.eventTrigger);
                        break;
                    default:
                        this.logger.log("DEBUG", `Unsupported trigger: ${JSON.stringify(definition)}`);
                        break;
                }
            }
            else if (definition.blockingTrigger) {
                url = FunctionsEmulator.getHttpFunctionUrl(this.args.projectId, definition.name, definition.region);
                added = this.addBlockingTrigger(url, definition.blockingTrigger);
            }
            else {
                this.logger.log("WARN", `Unsupported function type on ${definition.name}. Expected either an httpsTrigger, eventTrigger, or blockingTrigger.`);
            }
            const ignored = !added;
            this.addTriggerRecord(definition, { backend: emulatableBackend, ignored, url });
            const triggerType = definition.httpsTrigger
                ? "http"
                : constants_1.Constants.getServiceName((0, functionsEmulatorShared_1.getFunctionService)(definition));
            if (ignored) {
                const msg = `function ignored because the ${triggerType} emulator does not exist or is not running.`;
                this.logger.logLabeled("BULLET", `functions[${definition.id}]`, msg);
            }
            else {
                const msg = url
                    ? `${clc.bold(triggerType)} function initialized (${url}).`
                    : `${clc.bold(triggerType)} function initialized.`;
                this.logger.logLabeled("SUCCESS", `functions[${definition.id}]`, msg);
            }
        }
        if (this.debugMode) {
            if (!emulatableBackend.runtime?.startsWith("node")) {
                this.logger.log("WARN", "--inspect-functions only supported for Node.js runtimes.");
            }
            else {
                emulatableBackend.secretEnv = Object.values(triggerDefinitions.reduce((acc, curr) => {
                    for (const secret of curr.secretEnvironmentVariables || []) {
                        acc[secret.key] = secret;
                    }
                    return acc;
                }, {}));
                try {
                    await this.startRuntime(emulatableBackend);
                }
                catch (e) {
                    const message = e instanceof Error ? e.message : String(e);
                    this.logger.logLabeled("ERROR", `Failed to start functions in ${emulatableBackend.functionsDir}: ${message}`);
                }
            }
        }
    }
    logDartTriggerSupportWarnings(endpoints) {
        const dartEndpoints = endpoints.filter(triggerSupport_1.isDartEndpoint);
        if (dartEndpoints.length === 0) {
            return;
        }
        const { emulatorOnly, experimental } = (0, triggerSupport_1.classifyNonProductionEndpoints)(dartEndpoints);
        (0, triggerSupport_1.groupByTriggerLabel)(emulatorOnly).forEach((ids, label) => {
            this.logger.logLabeled("WARN", "functions", `Dart ${clc.bold(label)} triggers work in the emulator but cannot be deployed to production yet: ${ids.join(", ")}`);
        });
        (0, triggerSupport_1.groupByTriggerLabel)(experimental).forEach((ids, label) => {
            this.logger.logLabeled("WARN", "functions", `Dart ${clc.bold(label)} triggers are experimental and not yet fully supported: ${ids.join(", ")}`);
        });
    }
    async removeTriggers(toRemove) {
        for (const triggerKey of toRemove) {
            const definition = this.triggers[triggerKey].def;
            const service = (0, functionsEmulatorShared_1.getFunctionService)(definition);
            const key = this.getTriggerKey(definition);
            switch (service) {
                case constants_1.Constants.SERVICE_EVENTARC:
                    await this.removeEventarcTrigger(this.args.projectId, key, definition.eventTrigger);
                    delete this.triggers[key];
                    break;
                case constants_1.Constants.SERVICE_FIREALERTS:
                    await this.removeFirealertsTrigger(this.args.projectId, key, definition.eventTrigger);
                    delete this.triggers[key];
                    break;
                default:
                    break;
            }
        }
    }
    async addEventarcTrigger(projectId, key, eventTrigger) {
        if (!registry_1.EmulatorRegistry.isRunning(types_1.Emulators.EVENTARC)) {
            return false;
        }
        const bundle = {
            eventTrigger: {
                ...eventTrigger,
                service: "eventarc.googleapis.com",
            },
        };
        logger_1.logger.debug(`addEventarcTrigger`, JSON.stringify(bundle));
        try {
            await registry_1.EmulatorRegistry.client(types_1.Emulators.EVENTARC).post(`/emulator/v1/projects/${projectId}/triggers/${key}`, bundle);
            return true;
        }
        catch (err) {
            this.logger.log("WARN", "Error adding Eventarc function: " + err);
        }
        return false;
    }
    async removeEventarcTrigger(projectId, key, eventTrigger) {
        if (!registry_1.EmulatorRegistry.isRunning(types_1.Emulators.EVENTARC)) {
            return Promise.resolve(false);
        }
        const bundle = {
            eventTrigger: {
                ...eventTrigger,
                service: "eventarc.googleapis.com",
            },
        };
        logger_1.logger.debug(`removeEventarcTrigger`, JSON.stringify(bundle));
        try {
            await registry_1.EmulatorRegistry.client(types_1.Emulators.EVENTARC).post(`/emulator/v1/remove/projects/${projectId}/triggers/${key}`, bundle);
            return true;
        }
        catch (err) {
            this.logger.log("WARN", "Error removing Eventarc function: " + err);
        }
        return false;
    }
    async addFirealertsTrigger(projectId, key, eventTrigger) {
        if (!registry_1.EmulatorRegistry.isRunning(types_1.Emulators.EVENTARC)) {
            return false;
        }
        const bundle = {
            eventTrigger: {
                ...eventTrigger,
                service: "firebasealerts.googleapis.com",
            },
        };
        logger_1.logger.debug(`addFirealertsTrigger`, JSON.stringify(bundle));
        try {
            await registry_1.EmulatorRegistry.client(types_1.Emulators.EVENTARC).post(`/emulator/v1/projects/${projectId}/triggers/${key}`, bundle);
            return true;
        }
        catch (err) {
            this.logger.log("WARN", "Error adding FireAlerts function: " + err);
        }
        return false;
    }
    async removeFirealertsTrigger(projectId, key, eventTrigger) {
        if (!registry_1.EmulatorRegistry.isRunning(types_1.Emulators.EVENTARC)) {
            return false;
        }
        const bundle = {
            eventTrigger: {
                ...eventTrigger,
                service: "firebasealerts.googleapis.com",
            },
        };
        logger_1.logger.debug(`removeFirealertsTrigger`, JSON.stringify(bundle));
        try {
            await registry_1.EmulatorRegistry.client(types_1.Emulators.EVENTARC).post(`/emulator/v1/remove/projects/${projectId}/triggers/${key}`, bundle);
            return true;
        }
        catch (err) {
            this.logger.log("WARN", "Error removing FireAlerts function: " + err);
        }
        return false;
    }
    async performPostLoadOperations() {
        if (!this.blockingFunctionsConfig.triggers &&
            !this.blockingFunctionsConfig.forwardInboundCredentials) {
            return;
        }
        if (!registry_1.EmulatorRegistry.isRunning(types_1.Emulators.AUTH)) {
            return;
        }
        const path = `/identitytoolkit.googleapis.com/v2/projects/${this.getProjectId()}/config?updateMask=blockingFunctions`;
        try {
            const client = registry_1.EmulatorRegistry.client(types_1.Emulators.AUTH);
            await client.patch(path, { blockingFunctions: this.blockingFunctionsConfig }, {
                headers: { Authorization: "Bearer owner" },
            });
        }
        catch (err) {
            this.logger.log("WARN", "Error updating blocking functions config to the auth emulator: " + err);
            throw err;
        }
    }
    getV1DatabaseApiAttributes(projectId, key, eventTrigger) {
        const result = DATABASE_PATH_PATTERN.exec(eventTrigger.resource);
        if (result === null || result.length !== 3) {
            this.logger.log("WARN", `Event function "${key}" has malformed "resource" member. ` + `${eventTrigger.resource}`);
            throw new error_1.FirebaseError(`Event function ${key} has malformed resource member`);
        }
        const instance = result[1];
        const bundle = JSON.stringify({
            name: `projects/${projectId}/locations/_/functions/${key}`,
            path: result[2],
            event: eventTrigger.eventType,
            topic: `projects/${projectId}/topics/${key}`,
        });
        let apiPath = "/.settings/functionTriggers.json";
        if (instance !== "") {
            apiPath += `?ns=${instance}`;
        }
        else {
            this.logger.log("WARN", `No project in use. Registering function for sentinel namespace '${constants_1.Constants.DEFAULT_DATABASE_EMULATOR_NAMESPACE}'`);
        }
        return { bundle, apiPath, instance };
    }
    getV2DatabaseApiAttributes(projectId, id, key, eventTrigger, region) {
        const instance = eventTrigger.eventFilters?.instance || eventTrigger.eventFilterPathPatterns?.instance;
        if (!instance) {
            throw new error_1.FirebaseError("A database instance must be supplied.");
        }
        const ref = eventTrigger.eventFilterPathPatterns?.ref;
        if (!ref) {
            throw new error_1.FirebaseError("A database reference must be supplied.");
        }
        if (region !== "us-central1") {
            this.logger.logLabeled("WARN", `functions[${id}]`, `function region is defined outside the database region, will not trigger.`);
        }
        const bundle = JSON.stringify({
            name: `projects/${projectId}/locations/${region}/triggers/${key}`,
            path: ref,
            event: eventTrigger.eventType,
            topic: `projects/${projectId}/topics/${key}`,
            namespacePattern: instance,
        });
        const apiPath = "/.settings/functionTriggers.json";
        return { bundle, apiPath, instance };
    }
    async addRealtimeDatabaseTrigger(projectId, id, key, eventTrigger, signature, region) {
        if (!registry_1.EmulatorRegistry.isRunning(types_1.Emulators.DATABASE)) {
            return false;
        }
        const { bundle, apiPath, instance } = signature === "cloudevent"
            ? this.getV2DatabaseApiAttributes(projectId, id, key, eventTrigger, region)
            : this.getV1DatabaseApiAttributes(projectId, key, eventTrigger);
        logger_1.logger.debug(`addRealtimeDatabaseTrigger[${instance}]`, JSON.stringify(bundle));
        const client = registry_1.EmulatorRegistry.client(types_1.Emulators.DATABASE);
        try {
            await client.post(apiPath, bundle, { headers: { Authorization: "Bearer owner" } });
        }
        catch (err) {
            this.logger.log("WARN", "Error adding Realtime Database function: " + String(err));
            throw err;
        }
        return true;
    }
    getV1FirestoreAttributes(projectId, key, eventTrigger) {
        const bundle = JSON.stringify({
            eventTrigger: {
                ...eventTrigger,
                service: "firestore.googleapis.com",
            },
        });
        const path = `/emulator/v1/projects/${projectId}/triggers/${key}`;
        return { bundle, path };
    }
    getV2FirestoreAttributes(projectId, key, eventTrigger) {
        logger_1.logger.debug("Found a v2 firestore trigger.");
        const database = eventTrigger.eventFilters?.database;
        if (!database) {
            throw new error_1.FirebaseError(`A database must be supplied for event trigger ${key}`);
        }
        const namespace = eventTrigger.eventFilters?.namespace;
        if (!namespace) {
            throw new error_1.FirebaseError(`A namespace must be supplied for event trigger ${key}`);
        }
        let doc;
        let match;
        if (eventTrigger.eventFilters?.document) {
            doc = eventTrigger.eventFilters?.document;
            match = "EXACT";
        }
        if (eventTrigger.eventFilterPathPatterns?.document) {
            doc = eventTrigger.eventFilterPathPatterns?.document;
            match = "PATH_PATTERN";
        }
        if (!doc) {
            throw new error_1.FirebaseError("A document must be supplied.");
        }
        const bundle = JSON.stringify({
            eventType: eventTrigger.eventType,
            database,
            namespace,
            document: {
                value: doc,
                matchType: match,
            },
        });
        const path = `/emulator/v1/projects/${projectId}/eventarcTrigger?eventarcTriggerId=${key}`;
        return { bundle, path };
    }
    async addFirestoreTrigger(projectId, key, eventTrigger, signature) {
        if (!registry_1.EmulatorRegistry.isRunning(types_1.Emulators.FIRESTORE)) {
            return Promise.resolve(false);
        }
        const { bundle, path } = signature === "cloudevent"
            ? this.getV2FirestoreAttributes(projectId, key, eventTrigger)
            : this.getV1FirestoreAttributes(projectId, key, eventTrigger);
        logger_1.logger.debug(`addFirestoreTrigger`, JSON.stringify(bundle));
        const client = registry_1.EmulatorRegistry.client(types_1.Emulators.FIRESTORE);
        try {
            signature === "cloudevent" ? await client.post(path, bundle) : await client.put(path, bundle);
        }
        catch (err) {
            this.logger.log("WARN", "Error adding firestore function: " + String(err));
            throw err;
        }
        return true;
    }
    async addPubsubTrigger(triggerName, key, eventTrigger, signatureType, schedule) {
        const pubsubEmulator = registry_1.EmulatorRegistry.get(types_1.Emulators.PUBSUB);
        if (!pubsubEmulator) {
            return false;
        }
        logger_1.logger.debug(`addPubsubTrigger`, JSON.stringify({ eventTrigger }));
        const resource = eventTrigger.resource;
        let topic;
        if (schedule) {
            topic = "firebase-schedule-" + triggerName;
        }
        else {
            const resourceParts = resource.split("/");
            topic = resourceParts[resourceParts.length - 1];
        }
        try {
            await pubsubEmulator.addTrigger(topic, key, signatureType);
            return true;
        }
        catch (e) {
            return false;
        }
    }
    addAuthTrigger(projectId, key, eventTrigger) {
        logger_1.logger.debug(`addAuthTrigger`, JSON.stringify({ eventTrigger }));
        const eventTriggerId = `${projectId}:${eventTrigger.eventType}`;
        const triggers = this.multicastTriggers[eventTriggerId] || [];
        triggers.push(key);
        this.multicastTriggers[eventTriggerId] = triggers;
        return true;
    }
    addStorageTrigger(projectId, key, eventTrigger) {
        logger_1.logger.debug(`addStorageTrigger`, JSON.stringify({ eventTrigger }));
        const bucket = eventTrigger.resource.startsWith("projects/_/buckets/")
            ? eventTrigger.resource.split("/")[3]
            : eventTrigger.resource;
        const eventTriggerId = `${projectId}:${eventTrigger.eventType}:${bucket}`;
        const triggers = this.multicastTriggers[eventTriggerId] || [];
        triggers.push(key);
        this.multicastTriggers[eventTriggerId] = triggers;
        return true;
    }
    addBlockingTrigger(url, blockingTrigger) {
        logger_1.logger.debug(`addBlockingTrigger`, JSON.stringify({ blockingTrigger }));
        const eventType = blockingTrigger.eventType;
        if (!v1_1.AUTH_BLOCKING_EVENTS.includes(eventType)) {
            return false;
        }
        if (blockingTrigger.eventType === v1_1.BEFORE_CREATE_EVENT) {
            this.blockingFunctionsConfig.triggers = {
                ...this.blockingFunctionsConfig.triggers,
                beforeCreate: {
                    functionUri: url,
                },
            };
        }
        else {
            this.blockingFunctionsConfig.triggers = {
                ...this.blockingFunctionsConfig.triggers,
                beforeSignIn: {
                    functionUri: url,
                },
            };
        }
        this.blockingFunctionsConfig.forwardInboundCredentials = {
            accessToken: !!blockingTrigger.options.accessToken,
            idToken: !!blockingTrigger.options.idToken,
            refreshToken: !!blockingTrigger.options.refreshToken,
        };
        return true;
    }
    async addTaskQueueTrigger(projectId, location, entryPoint, defaultUri, taskQueueTrigger) {
        logger_1.logger.debug(`addTaskQueueTrigger`, JSON.stringify(taskQueueTrigger));
        if (!registry_1.EmulatorRegistry.isRunning(types_1.Emulators.TASKS)) {
            logger_1.logger.debug(`addTaskQueueTrigger`, "TQ not running");
            return Promise.resolve(false);
        }
        const bundle = {
            ...taskQueueTrigger,
            defaultUri,
        };
        try {
            await registry_1.EmulatorRegistry.client(types_1.Emulators.TASKS).post(`/projects/${projectId}/locations/${location}/queues/${entryPoint}`, bundle);
            return true;
        }
        catch (err) {
            this.logger.log("WARN", "Error adding Task Queue function: " + err);
            return false;
        }
    }
    getProjectId() {
        return this.args.projectId;
    }
    getInfo() {
        const host = this.args.host || constants_1.Constants.getDefaultHost();
        const port = this.args.port || constants_1.Constants.getDefaultPort(types_1.Emulators.FUNCTIONS);
        return {
            name: this.getName(),
            host,
            port,
        };
    }
    getName() {
        return types_1.Emulators.FUNCTIONS;
    }
    getTriggerDefinitions() {
        return Object.values(this.triggers).map((record) => record.def);
    }
    getTriggerRecordByKey(triggerKey) {
        const record = this.triggers[triggerKey];
        if (!record) {
            logger_1.logger.debug(`Could not find key=${triggerKey} in ${JSON.stringify(this.triggers)}`);
            throw new error_1.FirebaseError(`No function with key ${triggerKey}`);
        }
        return record;
    }
    getTriggerKey(def) {
        if (def.eventTrigger) {
            const triggerKey = `${def.id}-${this.triggerGeneration}`;
            return def.eventTrigger.channel ? `${triggerKey}-${def.eventTrigger.channel}` : triggerKey;
        }
        else {
            return def.id;
        }
    }
    getBackendInfo() {
        const cf3Triggers = this.getCF3Triggers();
        const backendInfo = this.staticBackends.map((e) => {
            return (0, functionsEmulatorShared_1.toBackendInfo)(e, cf3Triggers);
        });
        const dynamicInfo = this.dynamicBackends.map((e) => {
            return (0, functionsEmulatorShared_1.toBackendInfo)(e, cf3Triggers, { createdBy: "SDK" });
        });
        backendInfo.push(...dynamicInfo);
        return backendInfo;
    }
    getCF3Triggers() {
        return Object.values(this.triggers)
            .filter((t) => !t.backend.extensionInstanceId)
            .map((t) => t.def);
    }
    addTriggerRecord(def, opts) {
        const key = this.getTriggerKey(def);
        this.triggers[key] = {
            def,
            enabled: true,
            backend: opts.backend,
            ignored: opts.ignored,
            url: opts.url,
        };
    }
    setTriggersForTesting(triggers, backend) {
        this.triggers = {};
        triggers.forEach((def) => this.addTriggerRecord(def, { backend, ignored: false }));
    }
    getRuntimeConfig(backend) {
        const configPath = `${backend.functionsDir}/.runtimeconfig.json`;
        try {
            const configContent = fs.readFileSync(configPath, "utf8");
            return JSON.parse(configContent.toString());
        }
        catch (e) {
        }
        return {};
    }
    getUserEnvs(backend) {
        const projectInfo = {
            functionsSource: backend.functionsDir,
            configDir: backend.configDir,
            projectId: this.args.projectId,
            projectAlias: this.args.projectAlias,
            isEmulator: true,
        };
        if (functionsEnv.hasUserEnvs(projectInfo)) {
            try {
                return functionsEnv.loadUserEnvs(projectInfo);
            }
            catch (e) {
                logger_1.logger.debug("Failed to load local environment variables", e);
            }
        }
        return {};
    }
    getSystemEnvs(trigger) {
        const envs = {};
        envs.GCLOUD_PROJECT = this.args.projectId;
        envs.K_REVISION = "1";
        envs.PORT = "80";
        envs.GOOGLE_CLOUD_QUOTA_PROJECT = this.args.projectId;
        if (trigger) {
            const target = trigger.entryPoint;
            envs.FUNCTION_TARGET = target;
            envs.FUNCTION_SIGNATURE_TYPE = (0, functionsEmulatorShared_1.getSignatureType)(trigger);
            envs.K_SERVICE = trigger.name;
        }
        return envs;
    }
    getEmulatorEnvs() {
        const envs = {};
        envs.FUNCTIONS_EMULATOR = "true";
        envs.TZ = "UTC";
        envs.FIREBASE_DEBUG_MODE = "true";
        envs.FIREBASE_DEBUG_FEATURES = JSON.stringify({
            skipTokenVerification: true,
            enableCors: true,
        });
        let emulatorInfos = registry_1.EmulatorRegistry.listRunningWithInfo();
        if (this.args.remoteEmulators) {
            emulatorInfos = emulatorInfos.concat(Object.values(this.args.remoteEmulators));
        }
        (0, env_1.setEnvVarsForEmulators)(envs, emulatorInfos);
        if (this.debugMode) {
            envs["FUNCTION_DEBUG_MODE"] = "true";
        }
        return envs;
    }
    getFirebaseConfig() {
        const databaseEmulator = this.getEmulatorInfo(types_1.Emulators.DATABASE);
        let emulatedDatabaseURL = undefined;
        if (databaseEmulator) {
            let ns = this.args.projectId;
            if (this.adminSdkConfig.databaseURL) {
                const asUrl = new url_1.URL(this.adminSdkConfig.databaseURL);
                ns = asUrl.hostname.split(".")[0];
            }
            emulatedDatabaseURL = `http://${(0, functionsEmulatorShared_1.formatHost)(databaseEmulator)}/?ns=${ns}`;
        }
        return JSON.stringify({
            storageBucket: this.adminSdkConfig.storageBucket,
            databaseURL: emulatedDatabaseURL || this.adminSdkConfig.databaseURL,
            projectId: this.args.projectId,
        });
    }
    getRuntimeEnvs(backend, trigger) {
        return {
            ...this.getUserEnvs(backend),
            ...this.getSystemEnvs(trigger),
            ...this.getEmulatorEnvs(),
            FIREBASE_CONFIG: this.getFirebaseConfig(),
            ...backend.env,
        };
    }
    async resolveSecretEnvs(backend, trigger) {
        let secretEnvs = {};
        const secretPath = (0, functionsEmulatorShared_1.getSecretLocalPath)(backend, this.args.projectDir);
        try {
            const data = fs.readFileSync(secretPath, "utf8");
            secretEnvs = functionsEnv.parseStrict(data);
        }
        catch (e) {
            if (typeof e === "object" && e !== null && "code" in e) {
                const code = e.code;
                if (code !== "ENOENT") {
                    const message = e instanceof Error ? e.message : String(e);
                    this.logger.logLabeled("ERROR", "functions", `Failed to read local secrets file ${secretPath}: ${message}`);
                }
            }
        }
        const secrets = trigger?.secretEnvironmentVariables || backend.secretEnv;
        const accesses = secrets
            .filter((s) => !secretEnvs[s.key])
            .map(async (s) => {
            this.logger.logLabeled("INFO", "functions", `Trying to access secret ${s.secret}@latest`);
            const value = await (0, secretManager_1.accessSecretVersion)(this.getProjectId(), s.secret, s.version ?? "latest");
            return [s.key, value];
        });
        const accessResults = await (0, utils_1.allSettled)(accesses);
        const errs = [];
        for (const result of accessResults) {
            if (result.status === "rejected") {
                errs.push(result.reason);
            }
            else {
                const [k, v] = result.value;
                secretEnvs[k] = v;
            }
        }
        if (errs.length > 0) {
            this.logger.logLabeled("ERROR", "functions", "Unable to access secret environment variables from Google Cloud Secret Manager. " +
                "Make sure the credential used for the Functions Emulator have access " +
                `or provide override values in ${secretPath}:\n\t` +
                errs.join("\n\t"));
        }
        return secretEnvs;
    }
    async startNode(backend, envs) {
        const args = [path.join(__dirname, "functionsEmulatorRuntime")];
        if (this.debugMode) {
            if (process.env.FIREPIT_VERSION) {
                this.logger.log("WARN", `To enable function inspection, please run "npm i node@${semver.coerce(backend.runtime || "18.0.0")} --save-dev" in your functions directory`);
            }
            else {
                let port;
                if (typeof this.args.debugPort === "number") {
                    port = this.args.debugPort;
                }
                else {
                    port = await portfinder.getPortPromise({ port: 9229 });
                    if (port === 9229) {
                        this.logger.logLabeled("SUCCESS", "functions", `Using debug port 9229 for functions codebase ${backend.codebase}`);
                    }
                    else {
                        this.logger.logLabeled("SUCCESS", "functions", `Using debug port ${port} for functions codebase ${backend.codebase}. ` +
                            "You may need to add manually add this port to your inspector.");
                    }
                }
                const { host } = this.getInfo();
                args.unshift(`--inspect=${(0, utils_1.connectableHostname)(host)}:${port}`);
            }
        }
        const pnpPath = path.join(backend.functionsDir, ".pnp.js");
        if (fs.existsSync(pnpPath)) {
            emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.FUNCTIONS).logLabeled("WARN_ONCE", "functions", "Detected yarn@2 with PnP. " +
                "Cloud Functions for Firebase requires a node_modules folder to work correctly and is therefore incompatible with PnP. " +
                "See https://yarnpkg.com/getting-started/migration#step-by-step for more information.");
        }
        const bin = backend.bin;
        if (!bin) {
            throw new Error(`No binary associated with ${backend.functionsDir}. ` +
                "Make sure function runtime is configured correctly in firebase.json.");
        }
        const socketPath = (0, functionsEmulatorShared_1.getTemporarySocketPath)();
        const childProcess = spawn(bin, args, {
            cwd: backend.functionsDir,
            env: {
                node: backend.bin,
                METADATA_SERVER_DETECTION: "none",
                ...process.env,
                ...envs,
                PORT: socketPath,
            },
            stdio: ["pipe", "pipe", "pipe", "ipc"],
        });
        return Promise.resolve({
            process: childProcess,
            events: new events_1.EventEmitter(),
            cwd: backend.functionsDir,
            conn: new IPCConn(socketPath),
        });
    }
    async startPython(backend, envs) {
        const args = ["functions-framework"];
        if (this.debugMode) {
            this.logger.log("WARN", "--inspect-functions not supported for Python functions. Ignored.");
        }
        const port = await portfinder.getPortPromise({
            port: 8081 + (0, utils_1.randomInt)(0, 1000),
        });
        const childProcess = (0, python_1.runWithVirtualEnv)(args, backend.functionsDir, {
            ...process.env,
            ...envs,
            PYTHONUNBUFFERED: "1",
            DEBUG: "False",
            HOST: "127.0.0.1",
            PORT: port.toString(),
        });
        return {
            process: childProcess,
            events: new events_1.EventEmitter(),
            cwd: backend.functionsDir,
            conn: new TCPConn("127.0.0.1", port),
        };
    }
    async startDart(backend, envs) {
        if (this.debugMode) {
            this.logger.log("WARN", "--inspect-functions not supported for Dart functions. Ignored.");
        }
        const port = await portfinder.getPortPromise({
            port: 8081 + (0, utils_1.randomInt)(0, 1000),
        });
        const args = ["run", "--no-serve-devtools", dart_1.DART_ENTRY_POINT];
        const dartEnvs = { ...envs };
        delete dartEnvs.FUNCTION_TARGET;
        delete dartEnvs.FUNCTION_SIGNATURE_TYPE;
        const bin = backend.bin || "dart";
        logger_1.logger.debug(`Starting Dart runtime with args: ${args.join(" ")} on port ${port}`);
        const childProcess = spawn(bin, args, {
            cwd: backend.functionsDir,
            env: {
                ...process.env,
                ...dartEnvs,
                HOST: "127.0.0.1",
                PORT: port.toString(),
            },
            stdio: ["pipe", "pipe", "pipe"],
        });
        childProcess.stdout?.on("data", (chunk) => {
            this.logger.log("DEBUG", `[dart] ${chunk.toString("utf8")}`);
        });
        childProcess.stderr?.on("data", (chunk) => {
            this.logger.log("DEBUG", `[dart] ${chunk.toString("utf8")}`);
        });
        return {
            process: childProcess,
            events: new events_1.EventEmitter(),
            cwd: backend.functionsDir,
            conn: new TCPConn("127.0.0.1", port),
        };
    }
    async startRuntime(backend, trigger) {
        const runtimeEnv = this.getRuntimeEnvs(backend, trigger);
        const secretEnvs = await this.resolveSecretEnvs(backend, trigger);
        let runtime;
        if ((0, supported_1.runtimeIsLanguage)(backend.runtime, "python")) {
            runtime = await this.startPython(backend, { ...runtimeEnv, ...secretEnvs });
        }
        else if ((0, supported_1.runtimeIsLanguage)(backend.runtime, "dart")) {
            runtime = await this.startDart(backend, { ...runtimeEnv, ...secretEnvs });
        }
        else {
            runtime = await this.startNode(backend, { ...runtimeEnv, ...secretEnvs });
        }
        const extensionLogInfo = {
            instanceId: backend.extensionInstanceId,
            ref: backend.extensionVersion?.ref,
        };
        const pool = this.workerPools[backend.codebase];
        const worker = pool.addWorker(trigger, runtime, extensionLogInfo, backend.runtime);
        await worker.waitForSocketReady();
        return worker;
    }
    async disableBackgroundTriggers() {
        Object.values(this.triggers).forEach((record) => {
            if (record.def.eventTrigger && record.enabled) {
                this.logger.logLabeled("BULLET", `functions[${record.def.entryPoint}]`, "function temporarily disabled.");
                record.enabled = false;
            }
        });
        await this.workQueue.flush();
    }
    async reloadTriggers() {
        this.triggerGeneration++;
        this.blockingFunctionsConfig = {};
        for (const backend of this.staticBackends.concat(this.dynamicBackends)) {
            await this.loadTriggers(backend);
        }
        await this.performPostLoadOperations();
        return;
    }
    getEmulatorInfo(emulator) {
        if (this.args.remoteEmulators?.[emulator]) {
            return this.args.remoteEmulators[emulator];
        }
        return registry_1.EmulatorRegistry.getInfo(emulator);
    }
    async handleHttpsTrigger(req, res) {
        const method = req.method;
        let triggerId = req.params.trigger_name;
        if (req.params.region) {
            triggerId = `${req.params.region}-${triggerId}`;
        }
        if (!this.triggers[triggerId]) {
            res
                .status(404)
                .send(`Function ${triggerId} does not exist, valid functions are: ${Object.keys(this.triggers).join(", ")}`);
            return;
        }
        const record = this.getTriggerRecordByKey(triggerId);
        if (!record.enabled) {
            res.status(204).send("Background triggers are currently disabled.");
            return;
        }
        const trigger = record.def;
        logger_1.logger.debug(`Accepted request ${method} ${req.url} --> ${triggerId}`);
        let reqBody = req.rawBody;
        if ((0, functionsEmulatorShared_1.getSignatureType)(trigger) === "cloudevent") {
            if (req.headers["content-type"]?.includes("application/protobuf")) {
                reqBody = Uint8Array.from(atob(reqBody.toString()), (c) => c.charCodeAt(0));
                req.headers["content-length"] = reqBody.length.toString();
            }
        }
        void (0, track_1.trackEmulator)(EVENT_INVOKE_GA4, {
            function_service: (0, functionsEmulatorShared_1.getFunctionService)(trigger),
        });
        this.logger.log("DEBUG", `[functions] Runtime ready! Sending request!`);
        const url = new url_1.URL(`${req.protocol}://${req.hostname}${req.url}`);
        let path = `${url.pathname}${url.search}`.replace(new RegExp(`\/${this.args.projectId}\/[^\/]*\/${req.params.trigger_name}\/?`), "/");
        if ((0, supported_1.runtimeIsLanguage)(record.backend.runtime, "dart")) {
            const isBackgroundRoute = req.url.startsWith("/functions/projects/");
            if (isBackgroundRoute || path === "/") {
                path = `/${trigger.entryPoint}`;
            }
            else {
                path = `/${trigger.entryPoint}${path}`;
            }
        }
        this.logger.log("DEBUG", `[functions] Got req.url=${req.url}, mapping to path=${path}`);
        const pool = this.workerPools[record.backend.codebase];
        if (!pool.readyForWork(trigger.id, record.backend.runtime)) {
            try {
                await this.startRuntime(record.backend, trigger);
            }
            catch (e) {
                const message = e instanceof Error ? e.message : String(e);
                this.logger.logLabeled("ERROR", `Failed to handle request for function ${trigger.id}`);
                this.logger.logLabeled("ERROR", `Failed to start functions in ${record.backend.functionsDir}: ${message}`);
                return;
            }
        }
        let debugBundle;
        if (this.debugMode) {
            debugBundle = {
                functionTarget: trigger.entryPoint,
                functionSignature: (0, functionsEmulatorShared_1.getSignatureType)(trigger),
            };
        }
        await pool.submitRequest(trigger.id, {
            method,
            path,
            headers: req.headers,
        }, res, reqBody, debugBundle, record.backend.runtime);
    }
}
exports.FunctionsEmulator = FunctionsEmulator;
