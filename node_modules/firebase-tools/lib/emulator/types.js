"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Severity = exports.EmulatorLog = exports.FunctionsExecutionMode = exports.ALL_EMULATORS = exports.EMULATORS_SUPPORTED_BY_USE_EMULATOR = exports.EMULATORS_SUPPORTED_BY_UI = exports.EMULATORS_SUPPORTED_BY_FUNCTIONS = exports.ALL_SERVICE_EMULATORS = exports.IMPORT_EXPORT_EMULATORS = exports.DOWNLOADABLE_EMULATORS = exports.Emulators = void 0;
exports.isDownloadableEmulator = isDownloadableEmulator;
exports.isEmulator = isEmulator;
var Emulators;
(function (Emulators) {
    Emulators["AUTH"] = "auth";
    Emulators["HUB"] = "hub";
    Emulators["FUNCTIONS"] = "functions";
    Emulators["FIRESTORE"] = "firestore";
    Emulators["DATABASE"] = "database";
    Emulators["HOSTING"] = "hosting";
    Emulators["APPHOSTING"] = "apphosting";
    Emulators["PUBSUB"] = "pubsub";
    Emulators["UI"] = "ui";
    Emulators["LOGGING"] = "logging";
    Emulators["STORAGE"] = "storage";
    Emulators["EXTENSIONS"] = "extensions";
    Emulators["EVENTARC"] = "eventarc";
    Emulators["DATACONNECT"] = "dataconnect";
    Emulators["TASKS"] = "tasks";
})(Emulators || (exports.Emulators = Emulators = {}));
exports.DOWNLOADABLE_EMULATORS = [
    Emulators.FIRESTORE,
    Emulators.DATABASE,
    Emulators.PUBSUB,
    Emulators.UI,
    Emulators.STORAGE,
    Emulators.DATACONNECT,
];
exports.IMPORT_EXPORT_EMULATORS = [
    Emulators.FIRESTORE,
    Emulators.DATABASE,
    Emulators.AUTH,
    Emulators.STORAGE,
    Emulators.DATACONNECT,
];
exports.ALL_SERVICE_EMULATORS = [
    Emulators.APPHOSTING,
    Emulators.AUTH,
    Emulators.FUNCTIONS,
    Emulators.FIRESTORE,
    Emulators.DATABASE,
    Emulators.HOSTING,
    Emulators.PUBSUB,
    Emulators.STORAGE,
    Emulators.EVENTARC,
    Emulators.DATACONNECT,
    Emulators.TASKS,
].filter((v) => v);
exports.EMULATORS_SUPPORTED_BY_FUNCTIONS = [
    Emulators.FIRESTORE,
    Emulators.DATABASE,
    Emulators.PUBSUB,
    Emulators.STORAGE,
    Emulators.EVENTARC,
    Emulators.TASKS,
];
exports.EMULATORS_SUPPORTED_BY_UI = [
    Emulators.AUTH,
    Emulators.DATABASE,
    Emulators.FIRESTORE,
    Emulators.FUNCTIONS,
    Emulators.STORAGE,
    Emulators.EXTENSIONS,
];
exports.EMULATORS_SUPPORTED_BY_USE_EMULATOR = [
    Emulators.AUTH,
    Emulators.DATABASE,
    Emulators.FIRESTORE,
    Emulators.FUNCTIONS,
    Emulators.STORAGE,
];
exports.ALL_EMULATORS = [
    Emulators.HUB,
    Emulators.UI,
    Emulators.LOGGING,
    Emulators.EXTENSIONS,
    ...exports.ALL_SERVICE_EMULATORS,
];
function isDownloadableEmulator(value) {
    return isEmulator(value) && exports.DOWNLOADABLE_EMULATORS.includes(value);
}
function isEmulator(value) {
    return Object.values(Emulators).includes(value);
}
var FunctionsExecutionMode;
(function (FunctionsExecutionMode) {
    FunctionsExecutionMode["AUTO"] = "auto";
    FunctionsExecutionMode["SEQUENTIAL"] = "sequential";
})(FunctionsExecutionMode || (exports.FunctionsExecutionMode = FunctionsExecutionMode = {}));
class EmulatorLog {
    get date() {
        if (!this.timestamp) {
            return new Date(0);
        }
        return new Date(this.timestamp);
    }
    static waitForFlush() {
        return new Promise((resolve) => {
            const interval = setInterval(() => {
                if (!EmulatorLog.WAITING_FOR_FLUSH) {
                    resolve();
                    clearInterval(interval);
                }
            }, 10);
        });
    }
    static waitForLog(emitter, level, type, filter) {
        return new Promise((resolve) => {
            const listener = (el) => {
                const levelTypeMatch = el.level === level && el.type === type;
                let filterMatch = true;
                if (filter) {
                    filterMatch = filter(el);
                }
                if (levelTypeMatch && filterMatch) {
                    emitter.removeListener("log", listener);
                    resolve(el);
                }
            };
            emitter.on("log", listener);
        });
    }
    static fromJSON(json) {
        let parsedLog;
        let isNotJSON = false;
        try {
            parsedLog = JSON.parse(json);
        }
        catch (err) {
            isNotJSON = true;
        }
        parsedLog = parsedLog || {};
        if (isNotJSON ||
            parsedLog.level === undefined ||
            parsedLog.type === undefined ||
            parsedLog.text === undefined) {
            parsedLog = {
                level: "USER",
                type: "function-log",
                text: json,
            };
        }
        return new EmulatorLog(parsedLog.level, parsedLog.type, parsedLog.text, parsedLog.data, parsedLog.timestamp);
    }
    constructor(level, type, text, data, timestamp) {
        this.level = level;
        this.type = type;
        this.text = text;
        this.data = data;
        this.timestamp = timestamp;
        this.timestamp = this.timestamp || new Date().toISOString();
        this.data = this.data || {};
    }
    toString() {
        return this.toStringCore(false);
    }
    toPrettyString() {
        return this.toStringCore(true);
    }
    log() {
        const msg = `${this.toString()}\n`;
        this.bufferMessage(msg);
        this.flush();
    }
    bufferMessage(msg) {
        EmulatorLog.LOG_BUFFER.push(msg);
    }
    flush() {
        const nextMsg = EmulatorLog.LOG_BUFFER.shift();
        if (!nextMsg) {
            return;
        }
        EmulatorLog.WAITING_FOR_FLUSH = true;
        if (process.send) {
            process.send(nextMsg, undefined, {}, (err) => {
                if (err) {
                    process.stderr.write(err);
                }
                EmulatorLog.WAITING_FOR_FLUSH = EmulatorLog.LOG_BUFFER.length > 0;
                this.flush();
            });
        }
        else {
            process.stderr.write("subprocess.send() is undefined, cannot communicate with Functions Runtime.");
        }
    }
    toStringCore(pretty = false) {
        return JSON.stringify({
            timestamp: this.timestamp,
            level: this.level,
            text: this.text,
            data: this.data,
            type: this.type,
        }, undefined, pretty ? 2 : 0);
    }
}
exports.EmulatorLog = EmulatorLog;
EmulatorLog.WAITING_FOR_FLUSH = false;
EmulatorLog.LOG_BUFFER = [];
var Severity;
(function (Severity) {
    Severity[Severity["SEVERITY_UNSPECIFIED"] = 0] = "SEVERITY_UNSPECIFIED";
    Severity[Severity["DEPRECATION"] = 1] = "DEPRECATION";
    Severity[Severity["WARNING"] = 2] = "WARNING";
    Severity[Severity["ERROR"] = 3] = "ERROR";
})(Severity || (exports.Severity = Severity = {}));
