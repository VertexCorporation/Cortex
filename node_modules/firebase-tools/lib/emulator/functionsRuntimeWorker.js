"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RuntimeWorkerPool = exports.RuntimeWorker = exports.RuntimeWorkerState = void 0;
const http = require("http");
const crypto_1 = require("crypto");
const types_1 = require("./types");
const events_1 = require("events");
const emulatorLogger_1 = require("./emulatorLogger");
const error_1 = require("../error");
const discovery_1 = require("../deploy/functions/runtimes/discovery");
const supported_1 = require("../deploy/functions/runtimes/supported");
var RuntimeWorkerState;
(function (RuntimeWorkerState) {
    RuntimeWorkerState["CREATED"] = "CREATED";
    RuntimeWorkerState["IDLE"] = "IDLE";
    RuntimeWorkerState["BUSY"] = "BUSY";
    RuntimeWorkerState["FINISHING"] = "FINISHING";
    RuntimeWorkerState["FINISHED"] = "FINISHED";
})(RuntimeWorkerState || (exports.RuntimeWorkerState = RuntimeWorkerState = {}));
const FREE_WORKER_KEY = "~free~";
class RuntimeWorker {
    constructor(triggerId, runtime, extensionLogInfo, timeoutSeconds) {
        this.runtime = runtime;
        this.extensionLogInfo = extensionLogInfo;
        this.timeoutSeconds = timeoutSeconds;
        this.stateEvents = new events_1.EventEmitter();
        this.logListeners = [];
        this._state = RuntimeWorkerState.CREATED;
        this.id = (0, crypto_1.randomUUID)();
        this.triggerKey = triggerId || FREE_WORKER_KEY;
        this.runtime = runtime;
        const childProc = this.runtime.process;
        let msgBuffer = "";
        childProc.on("message", (msg) => {
            msgBuffer = this.processStream(msg, msgBuffer);
        });
        let stdBuffer = "";
        if (childProc.stdout) {
            childProc.stdout.on("data", (data) => {
                stdBuffer = this.processStream(data, stdBuffer);
            });
        }
        if (childProc.stderr) {
            childProc.stderr.on("data", (data) => {
                stdBuffer = this.processStream(data, stdBuffer);
            });
        }
        this.logger = triggerId
            ? emulatorLogger_1.EmulatorLogger.forFunction(triggerId, extensionLogInfo)
            : emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.FUNCTIONS);
        this.onLogs((log) => {
            this.logger.handleRuntimeLog(log);
        }, true);
        childProc.on("exit", () => {
            this.logDebug("exited");
            this.state = RuntimeWorkerState.FINISHED;
        });
    }
    processStream(s, buf) {
        buf += s.toString();
        const lines = buf.split("\n");
        if (lines.length > 1) {
            lines.slice(0, -1).forEach((line) => {
                const log = types_1.EmulatorLog.fromJSON(line);
                this.runtime.events.emit("log", log);
                if (log.level === "FATAL") {
                    this.runtime.events.emit("log", new types_1.EmulatorLog("SYSTEM", "runtime-status", "killed"));
                    this.runtime.process.kill();
                }
            });
        }
        return lines[lines.length - 1];
    }
    readyForWork() {
        this.state = RuntimeWorkerState.IDLE;
    }
    sendDebugMsg(debug) {
        return new Promise((resolve, reject) => {
            this.runtime.process.send(JSON.stringify(debug), (err) => {
                if (err) {
                    reject(err);
                }
                else {
                    resolve();
                }
            });
        });
    }
    request(req, resp, body, debug) {
        if (this.triggerKey !== FREE_WORKER_KEY) {
            this.logInfo(`Beginning execution of "${this.triggerKey}"`);
        }
        const startHrTime = process.hrtime();
        this.state = RuntimeWorkerState.BUSY;
        const onFinish = () => {
            if (this.triggerKey !== FREE_WORKER_KEY) {
                const elapsedHrTime = process.hrtime(startHrTime);
                this.logInfo(`Finished "${this.triggerKey}" in ${elapsedHrTime[0] * 1000 + elapsedHrTime[1] / 1000000}ms`);
            }
            if (this.state === RuntimeWorkerState.BUSY) {
                this.state = RuntimeWorkerState.IDLE;
            }
            else if (this.state === RuntimeWorkerState.FINISHING) {
                this.logDebug(`IDLE --> FINISHING`);
                this.runtime.process.kill();
            }
        };
        return new Promise((resolve) => {
            const reqOpts = {
                ...this.runtime.conn.httpReqOpts(),
                method: req.method,
                path: req.path,
                headers: req.headers,
            };
            if (this.timeoutSeconds) {
                reqOpts.timeout = this.timeoutSeconds * 1000;
            }
            const proxy = http.request(reqOpts, (_resp) => {
                resp.writeHead(_resp.statusCode || 200, _resp.headers);
                let finished = false;
                const finishReq = (event) => {
                    this.logger.log("DEBUG", `Finishing up request with event=${event}`);
                    if (!finished) {
                        finished = true;
                        onFinish();
                        resolve();
                    }
                };
                _resp.on("pause", () => finishReq("pause"));
                _resp.on("close", () => finishReq("close"));
                const piped = _resp.pipe(resp);
                piped.on("finish", () => finishReq("finish"));
            });
            if (debug) {
                proxy.setSocketKeepAlive(false);
                proxy.setTimeout(0);
            }
            proxy.on("timeout", () => {
                this.logger.log("ERROR", `Your function timed out after ~${this.timeoutSeconds}s. To configure this timeout, see
      https://firebase.google.com/docs/functions/manage-functions#set_timeout_and_memory_allocation.`);
                proxy.destroy();
            });
            proxy.on("error", (err) => {
                this.logger.log("ERROR", `Request to function failed: ${err}`);
                resp.writeHead(500);
                resp.write(JSON.stringify(err));
                resp.end();
                this.runtime.process.kill();
                resolve();
            });
            if (body) {
                proxy.write(body);
            }
            proxy.end();
        });
    }
    get state() {
        return this._state;
    }
    set state(state) {
        if (state === RuntimeWorkerState.IDLE) {
            for (const l of this.logListeners) {
                this.runtime.events.removeListener("log", l);
            }
            this.logListeners = [];
        }
        if (state === RuntimeWorkerState.FINISHED) {
            this.runtime.events.removeAllListeners();
        }
        this.logDebug(state);
        this._state = state;
        this.stateEvents.emit(this._state);
    }
    onLogs(listener, forever = false) {
        if (!forever) {
            this.logListeners.push(listener);
        }
        this.runtime.events.on("log", listener);
    }
    isSocketReady() {
        return new Promise((resolve, reject) => {
            const req = http.request({
                ...this.runtime.conn.httpReqOpts(),
                method: "GET",
                path: "/__/health",
            }, () => {
                this.readyForWork();
                resolve();
            });
            req.end();
            req.on("error", (error) => {
                reject(error);
            });
        });
    }
    async waitForSocketReady() {
        const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
        const timeout = new Promise((resolve, reject) => {
            setTimeout(() => {
                reject(new error_1.FirebaseError("Failed to load function."));
            }, (0, discovery_1.getFunctionDiscoveryTimeout)() || 30000);
        });
        while (true) {
            try {
                await Promise.race([this.isSocketReady(), timeout]);
                break;
            }
            catch (err) {
                if (typeof err === "object" && err !== null && "code" in err) {
                    const code = err.code;
                    if (typeof code === "string" && ["ECONNREFUSED", "ENOENT"].includes(code)) {
                        await sleep(100);
                        continue;
                    }
                }
                throw err;
            }
        }
    }
    logDebug(msg) {
        this.logger.log("DEBUG", `[worker-${this.triggerKey}-${this.id}]: ${msg}`);
    }
    logInfo(msg) {
        this.logger.logLabeled("BULLET", "functions", msg);
    }
}
exports.RuntimeWorker = RuntimeWorker;
class RuntimeWorkerPool {
    constructor(mode = types_1.FunctionsExecutionMode.AUTO) {
        this.mode = mode;
        this.workers = new Map();
    }
    getKey(triggerId, runtime) {
        if (this.mode === types_1.FunctionsExecutionMode.SEQUENTIAL) {
            return "~shared~";
        }
        if ((0, supported_1.runtimeIsLanguage)(runtime, "dart")) {
            return "~dart-shared~";
        }
        return triggerId || "~diagnostic~";
    }
    refresh() {
        for (const arr of this.workers.values()) {
            arr.forEach((w) => {
                if (w.state === RuntimeWorkerState.IDLE) {
                    this.log(`Shutting down IDLE worker (${w.triggerKey})`);
                    w.state = RuntimeWorkerState.FINISHING;
                    w.runtime.process.kill();
                }
                else if (w.state === RuntimeWorkerState.BUSY) {
                    this.log(`Marking BUSY worker to finish (${w.triggerKey})`);
                    w.state = RuntimeWorkerState.FINISHING;
                }
            });
        }
    }
    exit() {
        for (const arr of this.workers.values()) {
            arr.forEach((w) => {
                if (w.state === RuntimeWorkerState.IDLE) {
                    w.runtime.process.kill();
                }
                else {
                    w.runtime.process.kill();
                }
            });
        }
    }
    readyForWork(triggerId, runtime) {
        const idleWorker = this.getIdleWorker(triggerId, runtime);
        return !!idleWorker;
    }
    async submitRequest(triggerId, req, resp, body, debug, runtime) {
        this.log(`submitRequest(triggerId=${triggerId})`);
        const worker = this.getIdleWorker(triggerId, runtime);
        if (!worker) {
            throw new error_1.FirebaseError("Internal Error: can't call submitRequest without checking for idle workers");
        }
        if (debug) {
            await worker.sendDebugMsg(debug);
        }
        return worker.request(req, resp, body, !!debug);
    }
    getIdleWorker(triggerId, runtime) {
        this.cleanUpWorkers();
        const triggerWorkers = this.getTriggerWorkers(triggerId, runtime);
        if (!triggerWorkers.length) {
            this.setTriggerWorkers(triggerId, [], runtime);
            return;
        }
        for (const worker of triggerWorkers) {
            if (worker.state === RuntimeWorkerState.IDLE) {
                return worker;
            }
        }
        return;
    }
    addWorker(trigger, runtime, extensionLogInfo, runtimeType) {
        const key = this.getKey(trigger?.id, runtimeType);
        this.log(`addWorker(${key})`);
        const disableTimeout = !trigger?.id || this.mode === types_1.FunctionsExecutionMode.SEQUENTIAL;
        const worker = new RuntimeWorker(trigger?.id, runtime, extensionLogInfo, disableTimeout ? undefined : trigger?.timeoutSeconds);
        const keyWorkers = this.getTriggerWorkers(trigger?.id, runtimeType);
        keyWorkers.push(worker);
        this.setTriggerWorkers(trigger?.id, keyWorkers, runtimeType);
        this.log(`Adding worker with key ${worker.triggerKey}, total=${keyWorkers.length}`);
        return worker;
    }
    getTriggerWorkers(triggerId, runtime) {
        return this.workers.get(this.getKey(triggerId, runtime)) || [];
    }
    setTriggerWorkers(triggerId, workers, runtime) {
        this.workers.set(this.getKey(triggerId, runtime), workers);
    }
    cleanUpWorkers() {
        for (const [key, keyWorkers] of this.workers.entries()) {
            const notDoneWorkers = keyWorkers.filter((worker) => {
                return worker.state !== RuntimeWorkerState.FINISHED;
            });
            if (notDoneWorkers.length !== keyWorkers.length) {
                this.log(`Cleaned up workers for ${key}: ${keyWorkers.length} --> ${notDoneWorkers.length}`);
            }
            this.setTriggerWorkers(key, notDoneWorkers);
        }
    }
    log(msg) {
        emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.FUNCTIONS).log("DEBUG", `[worker-pool] ${msg}`);
    }
}
exports.RuntimeWorkerPool = RuntimeWorkerPool;
