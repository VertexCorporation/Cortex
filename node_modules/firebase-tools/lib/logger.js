"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.logger = exports.vsceLogEmitter = void 0;
exports.findAvailableLogFile = findAvailableLogFile;
exports.tryStringify = tryStringify;
exports.useFileLogger = useFileLogger;
exports.useConsoleLoggers = useConsoleLoggers;
const winston = require("winston");
const events_1 = require("events");
const path = require("path");
const fs = require("fs");
const triple_beam_1 = require("triple-beam");
const util_1 = require("util");
const vsCodeUtils_1 = require("./vsCodeUtils");
exports.vsceLogEmitter = new events_1.EventEmitter();
function expandErrors(logger) {
    const oldLogFunc = logger.log.bind(logger);
    const newLogFunc = function (levelOrEntry, message, ...meta) {
        if (message && message instanceof Error) {
            message = message.stack || message.message;
            return oldLogFunc(levelOrEntry, message, ...meta);
        }
        return oldLogFunc(levelOrEntry, message, ...meta);
    };
    logger.log = newLogFunc;
    return logger;
}
function annotateDebugLines(logger) {
    const debug = logger.debug.bind(logger);
    const newDebug = function (message, ...meta) {
        if (typeof message === "string") {
            message = `[${new Date().toISOString()}] ${message || ""}`;
        }
        return debug(message, ...meta);
    };
    logger.debug = newDebug;
    return logger;
}
function maybeUseVSCodeLogger(logger) {
    if (!(0, vsCodeUtils_1.isVSCodeExtension)()) {
        return logger;
    }
    const oldLogFunc = logger.log.bind(logger);
    const vsceLogger = function (levelOrEntry, message, ...meta) {
        if (message) {
            exports.vsceLogEmitter.emit("log", { level: levelOrEntry, message });
        }
        else {
            exports.vsceLogEmitter.emit("log", levelOrEntry);
        }
        return oldLogFunc(levelOrEntry, message, ...meta);
    };
    logger.log = vsceLogger;
    return logger;
}
function findAvailableLogFile() {
    const candidates = ["firebase-debug.log"];
    for (let i = 1; i < 10; i++) {
        candidates.push(`firebase-debug.${i}.log`);
    }
    for (const c of candidates) {
        const logFilename = path.join(process.cwd(), c);
        try {
            const fd = fs.openSync(logFilename, "r+");
            fs.closeSync(fd);
            return logFilename;
        }
        catch (e) {
            if (e.code === "ENOENT") {
                return logFilename;
            }
        }
    }
    throw new Error("Unable to obtain permissions for firebase-debug.log");
}
function tryStringify(value) {
    if (typeof value === "string") {
        return value;
    }
    try {
        return JSON.stringify(value);
    }
    catch {
        return value;
    }
}
const rawLogger = winston.createLogger();
rawLogger.add(new winston.transports.Console({
    silent: true,
    consoleWarnLevels: ["debug", "warn"],
}));
rawLogger.exitOnError = false;
exports.logger = maybeUseVSCodeLogger(annotateDebugLines(expandErrors(rawLogger)));
function useFileLogger(logFile) {
    const logFileName = logFile ?? findAvailableLogFile();
    exports.logger.add(new winston.transports.File({
        level: "debug",
        filename: logFileName,
        format: winston.format.printf((info) => {
            const segments = [info.message, ...(info[triple_beam_1.SPLAT] || [])].map(tryStringify);
            return `[${info.level}] ${(0, util_1.stripVTControlCharacters)(segments.join(" "))}`;
        }),
    }));
    return logFileName;
}
function useConsoleLoggers() {
    if (process.env.DEBUG) {
        exports.logger.add(new winston.transports.Console({
            level: "debug",
            format: winston.format.printf((info) => {
                const segments = [info.message, ...(info[triple_beam_1.SPLAT] || [])].map(tryStringify);
                return `${(0, util_1.stripVTControlCharacters)(segments.join(" "))}`;
            }),
        }));
    }
    else if (process.env.IS_FIREBASE_CLI) {
        exports.logger.add(new winston.transports.Console({
            level: "info",
            format: winston.format.printf((info) => [info.message, ...(info[triple_beam_1.SPLAT] || [])]
                .filter((chunk) => typeof chunk === "string")
                .join(" ")),
        }));
    }
}
