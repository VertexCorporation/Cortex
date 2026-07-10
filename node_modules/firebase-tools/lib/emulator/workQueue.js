"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.WorkQueue = void 0;
const utils = require("../utils");
const error_1 = require("../error");
const emulatorLogger_1 = require("./emulatorLogger");
const types_1 = require("./types");
class WorkQueue {
    constructor(mode = types_1.FunctionsExecutionMode.AUTO, maxParallelWork = WorkQueue.DEFAULT_MAX_PARALLEL) {
        this.mode = mode;
        this.maxParallelWork = maxParallelWork;
        this.logger = emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.FUNCTIONS);
        this.queue = [];
        this.running = [];
        this.notifyQueue = () => {
        };
        this.notifyWorkFinish = () => {
        };
        this.stopped = true;
        if (maxParallelWork < 1) {
            throw new error_1.FirebaseError(`Cannot run Functions emulator with less than 1 parallel worker (${WorkQueue.MAX_PARALLEL_ENV}=${process.env[WorkQueue.MAX_PARALLEL_ENV]})`);
        }
    }
    submit(entry) {
        this.queue.push(entry);
        this.notifyQueue();
        this.logState();
    }
    async start() {
        if (!this.stopped) {
            return;
        }
        this.stopped = false;
        while (!this.stopped) {
            if (!this.queue.length) {
                await new Promise((res) => {
                    this.notifyQueue = res;
                });
            }
            if (this.running.length >= this.maxParallelWork) {
                this.logger.logLabeled("DEBUG", "work-queue", `waiting for work to finish (running=${this.running})`);
                await new Promise((res) => {
                    this.notifyWorkFinish = res;
                });
            }
            const workPromise = this.runNext();
            if (this.mode === types_1.FunctionsExecutionMode.SEQUENTIAL) {
                await workPromise;
            }
        }
    }
    stop() {
        this.stopped = true;
    }
    async flush(timeoutMs = 60000) {
        if (!this.isWorking()) {
            return;
        }
        this.logger.logLabeled("BULLET", "functions", "Waiting for all functions to finish...");
        return new Promise((res, rej) => {
            const delta = 100;
            let elapsed = 0;
            const interval = setInterval(() => {
                elapsed += delta;
                if (elapsed >= timeoutMs) {
                    rej(new Error(`Functions work queue not empty after ${timeoutMs}ms`));
                }
                if (!this.isWorking()) {
                    clearInterval(interval);
                    res();
                }
            }, delta);
        });
    }
    getState() {
        return {
            queuedWork: this.queue.map((work) => work.type),
            queueLength: this.queue.length,
            runningWork: this.running,
            workRunningCount: this.running.length,
        };
    }
    isWorking() {
        const state = this.getState();
        return state.queueLength > 0 || state.workRunningCount > 0;
    }
    async runNext() {
        const next = this.queue.shift();
        if (next) {
            this.running.push(next.type || "anonymous");
            this.logState();
            try {
                await next();
            }
            catch (e) {
                this.logger.log("DEBUG", e);
            }
            finally {
                const index = this.running.indexOf(next.type || "anonymous");
                if (index !== -1) {
                    this.running.splice(index, 1);
                }
                this.notifyWorkFinish();
                this.logState();
            }
        }
    }
    logState() {
        this.logger.logLabeled("DEBUG", "work-queue", JSON.stringify(this.getState()));
    }
}
exports.WorkQueue = WorkQueue;
WorkQueue.MAX_PARALLEL_ENV = "FUNCTIONS_EMULATOR_PARALLEL";
WorkQueue.DEFAULT_MAX_PARALLEL = Number.parseInt(utils.envOverride(WorkQueue.MAX_PARALLEL_ENV, "50"));
