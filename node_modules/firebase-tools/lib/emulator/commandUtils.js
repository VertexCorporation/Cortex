"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.JAVA_DEPRECATION_WARNING = exports.MIN_SUPPORTED_JAVA_MAJOR_VERSION = exports.DEFAULT_CONFIG = exports.DESC_TEST_PARAMS = exports.FLAG_TEST_PARAMS = exports.DESC_TEST_CONFIG = exports.FLAG_TEST_CONFIG = exports.DESC_UI = exports.FLAG_UI = exports.DESC_VERBOSITY = exports.FLAG_VERBOSITY = exports.FLAG_VERBOSITY_NAME = exports.EXPORT_ON_EXIT_CWD_DANGER = exports.EXPORT_ON_EXIT_USAGE_ERROR = exports.DESC_EXPORT_ON_EXIT = exports.FLAG_EXPORT_ON_EXIT = exports.FLAG_EXPORT_ON_EXIT_NAME = exports.DESC_IMPORT = exports.FLAG_IMPORT = exports.DESC_INSPECT_FUNCTIONS = exports.FLAG_INSPECT_FUNCTIONS = exports.DESC_ONLY = exports.FLAG_ONLY = void 0;
exports.printNoticeIfEmulated = printNoticeIfEmulated;
exports.warnEmulatorNotSupported = warnEmulatorNotSupported;
exports.errorMissingProject = errorMissingProject;
exports.beforeEmulatorCommand = beforeEmulatorCommand;
exports.parseInspectionPort = parseInspectionPort;
exports.setExportOnExitOptions = setExportOnExitOptions;
exports.shutdownWhenKilled = shutdownWhenKilled;
exports.getListenOverview = getListenOverview;
exports.emulatorExec = emulatorExec;
exports.checkJavaMajorVersion = checkJavaMajorVersion;
const clc = require("colorette");
const childProcess = require("child_process");
const controller = require("../emulator/controller");
const config_1 = require("../config");
const utils = require("../utils");
const logger_1 = require("../logger");
const path = require("path");
const constants_1 = require("./constants");
const requireAuth_1 = require("../requireAuth");
const requireConfig_1 = require("../requireConfig");
const types_1 = require("./types");
const error_1 = require("../error");
const error_2 = require("../error");
const registry_1 = require("./registry");
const projectUtils_1 = require("../projectUtils");
const prompt_1 = require("../prompt");
const fsutils = require("../fsutils");
const Table = require("cli-table3");
const track_1 = require("../track");
const env_1 = require("./env");
const webhook_1 = require("../dataconnect/webhook");
exports.FLAG_ONLY = "--only <emulators>";
exports.DESC_ONLY = "only specific emulators. " +
    "This is a comma separated list of emulator names. " +
    "Valid options are: " +
    JSON.stringify(types_1.ALL_SERVICE_EMULATORS);
exports.FLAG_INSPECT_FUNCTIONS = "--inspect-functions [port]";
exports.DESC_INSPECT_FUNCTIONS = "emulate Cloud Functions in debug mode with the node inspector on the given port (9229 if not specified)";
exports.FLAG_IMPORT = "--import [dir]";
exports.DESC_IMPORT = "import emulator data from a previous export (see emulators:export)";
exports.FLAG_EXPORT_ON_EXIT_NAME = "--export-on-exit";
exports.FLAG_EXPORT_ON_EXIT = `${exports.FLAG_EXPORT_ON_EXIT_NAME} [dir]`;
exports.DESC_EXPORT_ON_EXIT = "automatically export emulator data (emulators:export) " +
    "when the emulators make a clean exit (SIGINT), " +
    `when no dir is provided the location of ${exports.FLAG_IMPORT} is used`;
exports.EXPORT_ON_EXIT_USAGE_ERROR = `"${exports.FLAG_EXPORT_ON_EXIT_NAME}" must be used with "${exports.FLAG_IMPORT}"` +
    ` or provide a dir directly to "${exports.FLAG_EXPORT_ON_EXIT}"`;
exports.EXPORT_ON_EXIT_CWD_DANGER = `"${exports.FLAG_EXPORT_ON_EXIT_NAME}" must not point to the current directory or parents. Please choose a new/dedicated directory for exports.`;
exports.FLAG_VERBOSITY_NAME = "--log-verbosity";
exports.FLAG_VERBOSITY = `${exports.FLAG_VERBOSITY_NAME} <verbosity>`;
exports.DESC_VERBOSITY = "One of: DEBUG, INFO, QUIET, SILENT. ";
exports.FLAG_UI = "--ui";
exports.DESC_UI = "run the Emulator UI";
exports.FLAG_TEST_CONFIG = "--test-config <firebase.json file>";
exports.DESC_TEST_CONFIG = "A firebase.json style file. Used to configure the Firestore and Realtime Database emulators.";
exports.FLAG_TEST_PARAMS = "--test-params <params.env file>";
exports.DESC_TEST_PARAMS = "A .env file containing test param values for your emulated extension.";
exports.DEFAULT_CONFIG = new config_1.Config({
    eventarc: {},
    database: {},
    firestore: {},
    functions: {},
    hosting: {},
    emulators: { auth: {}, pubsub: {} },
}, {});
function printNoticeIfEmulated(options, emulator) {
    if (emulator !== types_1.Emulators.DATABASE && emulator !== types_1.Emulators.FIRESTORE) {
        return;
    }
    const emuName = constants_1.Constants.description(emulator);
    const envKey = emulator === types_1.Emulators.DATABASE
        ? constants_1.Constants.FIREBASE_DATABASE_EMULATOR_HOST
        : constants_1.Constants.FIRESTORE_EMULATOR_HOST;
    const envVal = process.env[envKey];
    if (envVal) {
        utils.logBullet(`You have set ${clc.bold(`${envKey}=${envVal}`)}, this command will execute against the ${emuName} running at that address.`);
    }
}
async function warnEmulatorNotSupported(options, emulator) {
    if (emulator !== types_1.Emulators.DATABASE && emulator !== types_1.Emulators.FIRESTORE) {
        return;
    }
    const emuName = constants_1.Constants.description(emulator);
    const envKey = emulator === types_1.Emulators.DATABASE
        ? constants_1.Constants.FIREBASE_DATABASE_EMULATOR_HOST
        : constants_1.Constants.FIRESTORE_EMULATOR_HOST;
    const envVal = process.env[envKey];
    if (envVal) {
        utils.logWarning(`You have set ${clc.bold(`${envKey}=${envVal}`)}, however this command does not support running against the ${emuName} so this action will affect production.`);
        if (!(await (0, prompt_1.confirm)("Do you want to continue?"))) {
            throw new error_1.FirebaseError("Command aborted.", { exit: 1 });
        }
    }
}
async function errorMissingProject(options) {
    if (!options.project) {
        throw new error_1.FirebaseError("Project is not defined. Either use `--project` or use `firebase use` to set your active project.");
    }
}
async function beforeEmulatorCommand(options) {
    const optionsWithDefaultConfig = {
        ...options,
        config: exports.DEFAULT_CONFIG,
    };
    const optionsWithConfig = options.config ? options : optionsWithDefaultConfig;
    const canStartWithoutConfig = options.only &&
        !controller.shouldStart(optionsWithConfig, types_1.Emulators.FUNCTIONS) &&
        !controller.shouldStart(optionsWithConfig, types_1.Emulators.HOSTING);
    if (!constants_1.Constants.isDemoProject(options.project) ||
        controller.shouldStart(optionsWithConfig, types_1.Emulators.EXTENSIONS)) {
        try {
            await (0, requireAuth_1.requireAuth)(options);
        }
        catch (e) {
            logger_1.logger.debug(e);
            utils.logLabeledWarning("emulators", `You are not currently authenticated so some features may not work correctly. Please run ${clc.bold("firebase login")} to authenticate the CLI.`);
        }
    }
    if (canStartWithoutConfig && !options.config) {
        utils.logWarning("Could not find config (firebase.json) so using defaults.");
        options.config = exports.DEFAULT_CONFIG;
    }
    else {
        await (0, requireConfig_1.requireConfig)(options);
    }
}
function parseInspectionPort(options) {
    const port = options.inspectFunctions;
    if (typeof port === "undefined") {
        return false;
    }
    else if (typeof port === "boolean") {
        return port;
    }
    const parsed = Number(port);
    if (isNaN(parsed) || parsed < 1024 || parsed > 65535) {
        throw new error_1.FirebaseError(`"${port}" is not a valid port for debugging, please pass an integer between 1024 and 65535 or true for a dynamic port.`);
    }
    return parsed;
}
function setExportOnExitOptions(options) {
    if (options.exportOnExit || typeof options.exportOnExit === "string") {
        if (options.import) {
            options.exportOnExit =
                typeof options.exportOnExit === "string" ? options.exportOnExit : options.import;
            const importPath = path.resolve(options.import);
            if (!fsutils.dirExistsSync(importPath) && options.import === options.exportOnExit) {
                options.exportOnExit = options.import;
                delete options.import;
            }
        }
        if (options.exportOnExit === true || !options.exportOnExit) {
            throw new error_1.FirebaseError(exports.EXPORT_ON_EXIT_USAGE_ERROR);
        }
        if (path.resolve(".").startsWith(path.resolve(options.exportOnExit))) {
            throw new error_1.FirebaseError(exports.EXPORT_ON_EXIT_CWD_DANGER);
        }
    }
    return;
}
function processKillSignal(signal, res, rej, options) {
    let lastSignal = new Date().getTime();
    let signalCount = 0;
    return async () => {
        try {
            const now = new Date().getTime();
            const diff = now - lastSignal;
            if (diff < 100) {
                logger_1.logger.debug(`Ignoring signal ${signal} due to short delay of ${diff}ms`);
                return;
            }
            signalCount = signalCount + 1;
            lastSignal = now;
            const signalDisplay = signal === "SIGINT" ? `SIGINT (Ctrl-C)` : signal;
            logger_1.logger.debug(`Received signal ${signalDisplay} ${signalCount}`);
            logger_1.logger.info(" ");
            if (signalCount === 1) {
                utils.logLabeledBullet("emulators", `Received ${signalDisplay} for the first time. Starting a clean shutdown.`);
                utils.logLabeledBullet("emulators", `Please wait for a clean shutdown or send the ${signalDisplay} signal again to stop right now.`);
                await controller.onExit(options);
                await controller.cleanShutdown();
            }
            else {
                logger_1.logger.debug(`Skipping clean onExit() and cleanShutdown()`);
                const runningEmulatorsInfosWithPid = registry_1.EmulatorRegistry.listRunningWithInfo().filter((i) => Boolean(i.pid));
                utils.logLabeledWarning("emulators", `Received ${signalDisplay} ${signalCount} times. You have forced the Emulator Suite to exit without waiting for ${runningEmulatorsInfosWithPid.length} subprocess${runningEmulatorsInfosWithPid.length > 1 ? "es" : ""} to finish. These processes ${clc.bold("may")} still be running on your machine: `);
                const pids = [];
                const emulatorsTable = new Table({
                    head: ["Emulator", "Host:Port", "PID"],
                    style: {
                        head: ["yellow"],
                    },
                });
                for (const emulatorInfo of runningEmulatorsInfosWithPid) {
                    pids.push(emulatorInfo.pid);
                    emulatorsTable.push([
                        constants_1.Constants.description(emulatorInfo.name),
                        getListenOverview(emulatorInfo.name) ?? "unknown",
                        emulatorInfo.pid,
                    ]);
                }
                logger_1.logger.info(`\n${emulatorsTable}\n\nTo force them to exit run:\n`);
                if (process.platform === "win32") {
                    logger_1.logger.info(clc.bold(`TASKKILL ${pids.map((pid) => "/PID " + pid).join(" ")} /T\n`));
                }
                else {
                    logger_1.logger.info(clc.bold(`kill ${pids.join(" ")}\n`));
                }
            }
            res();
        }
        catch (e) {
            logger_1.logger.debug(e);
            rej();
        }
    };
}
function shutdownWhenKilled(options) {
    return new Promise((res, rej) => {
        ["SIGINT", "SIGTERM", "SIGHUP", "SIGQUIT"].forEach((signal) => {
            process.on(signal, processKillSignal(signal, res, rej, options));
        });
    }).catch((e) => {
        logger_1.logger.debug(e);
        utils.logLabeledWarning("emulators", "emulators failed to shut down cleanly, see firebase-debug.log for details.");
        throw e;
    });
}
async function runScript(script, extraEnv) {
    utils.logBullet(`Running script: ${clc.bold(script)}`);
    const env = { ...process.env, ...extraEnv };
    if (env.GCLOUD_PROJECT && !env.FIREBASE_CONFIG) {
        env.FIREBASE_CONFIG = JSON.stringify({
            projectId: env.GCLOUD_PROJECT,
            storageBucket: `${env.GCLOUD_PROJECT}.appspot.com`,
            databaseURL: `https://${env.GCLOUD_PROJECT}.firebaseio.com`,
        });
    }
    const emulatorInfos = registry_1.EmulatorRegistry.listRunningWithInfo();
    (0, env_1.setEnvVarsForEmulators)(env, emulatorInfos);
    const proc = childProcess.spawn(script, {
        stdio: ["inherit", "inherit", "inherit"],
        shell: true,
        windowsHide: true,
        env,
    });
    logger_1.logger.debug(`Running ${script} with environment ${JSON.stringify(env)}`);
    return new Promise((resolve, reject) => {
        proc.on("error", (err) => {
            utils.logWarning(`There was an error running the script: ${JSON.stringify(err)}`);
            reject();
        });
        const exitDelayMs = 500;
        proc.once("exit", (code, signal) => {
            if (signal) {
                utils.logWarning(`Script exited with signal: ${signal}`);
                setTimeout(reject, exitDelayMs);
                return;
            }
            const exitCode = code || 0;
            if (code === 0) {
                utils.logSuccess(`Script exited successfully (code 0)`);
            }
            else {
                utils.logWarning(`Script exited unsuccessfully (code ${code})`);
            }
            setTimeout(() => {
                resolve(exitCode);
            }, exitDelayMs);
        });
    });
}
function getListenOverview(emulator) {
    const info = registry_1.EmulatorRegistry.get(emulator)?.getInfo();
    if (!info) {
        return undefined;
    }
    if (info.host.includes(":")) {
        return `[${info.host}]:${info.port}`;
    }
    else {
        return `${info.host}:${info.port}`;
    }
}
async function emulatorExec(script, options) {
    const projectId = (0, projectUtils_1.getProjectId)(options);
    const extraEnv = {};
    if (projectId) {
        extraEnv.GCLOUD_PROJECT = projectId;
    }
    const session = (0, track_1.emulatorSession)();
    if (session && session.debugMode) {
        extraEnv[constants_1.Constants.FIREBASE_GA_SESSION] = JSON.stringify(session);
    }
    let exitCode = 0;
    let deprecationNotices = [];
    try {
        const showUI = !!options.ui;
        ({ deprecationNotices } = await controller.startAll(options, showUI, true));
        await (0, webhook_1.sendVSCodeMessage)({ message: webhook_1.VSCODE_MESSAGE.EMULATORS_STARTED });
        exitCode = await runScript(script, extraEnv);
        await controller.onExit(options);
    }
    catch (err) {
        await (0, webhook_1.sendVSCodeMessage)({ message: webhook_1.VSCODE_MESSAGE.EMULATORS_START_ERRORED });
        throw err;
    }
    finally {
        await controller.cleanShutdown();
    }
    for (const notice of deprecationNotices) {
        utils.logLabeledWarning("emulators", notice, "warn");
    }
    if (exitCode !== 0) {
        throw new error_1.FirebaseError(`Script "${clc.bold(script)}" exited with code ${exitCode}`, {
            exit: exitCode,
        });
    }
}
const JAVA_VERSION_REGEX = /version "([1-9][0-9]*)/;
const JAVA_HINT = "Please make sure Java is installed and on your system PATH.";
async function checkJavaMajorVersion() {
    return new Promise((resolve, reject) => {
        let child;
        try {
            child = childProcess.spawn("java", ["-Duser.language=en", "-Dfile.encoding=UTF-8", "-version"], {
                stdio: ["inherit", "pipe", "pipe"],
            });
        }
        catch (err) {
            return reject(new error_1.FirebaseError(`Could not spawn \`java -version\`. ${JAVA_HINT}`, {
                original: (0, error_2.getError)(err),
            }));
        }
        let output = "";
        let error = "";
        child.stdout?.on("data", (data) => {
            const str = data.toString("utf8");
            logger_1.logger.debug(str);
            output += str;
        });
        child.stderr?.on("data", (data) => {
            const str = data.toString("utf8");
            logger_1.logger.debug(str);
            error += str;
        });
        child.once("error", (err) => {
            reject(new error_1.FirebaseError(`Could not spawn \`java -version\`. ${JAVA_HINT}`, { original: err }));
        });
        child.once("exit", (code, signal) => {
            if (signal) {
                reject(new error_1.FirebaseError(`Process \`java -version\` was killed by signal ${signal}.`));
            }
            else if (code && code !== 0) {
                reject(new error_1.FirebaseError(`Process \`java -version\` has exited with code ${code}. ${JAVA_HINT}\n` +
                    `-----Original stdout-----\n${output}` +
                    `-----Original stderr-----\n${error}`));
            }
            else {
                resolve(`${output}\n${error}`);
            }
        });
    }).then((output) => {
        let versionInt = -1;
        const match = JAVA_VERSION_REGEX.exec(output);
        if (match) {
            const version = match[1];
            versionInt = parseInt(version, 10);
            if (!versionInt) {
                utils.logLabeledWarning("emulators", `Failed to parse Java version. Got "${match[0]}".`, "warn");
            }
            else {
                logger_1.logger.debug(`Parsed Java major version: ${versionInt}`);
            }
        }
        else {
            logger_1.logger.debug("java -version outputs:", output);
            logger_1.logger.warn(`Failed to parse Java version.`);
        }
        const session = (0, track_1.emulatorSession)();
        if (session) {
            session.javaMajorVersion = versionInt;
        }
        return versionInt;
    });
}
exports.MIN_SUPPORTED_JAVA_MAJOR_VERSION = 21;
exports.JAVA_DEPRECATION_WARNING = "firebase-tools no longer supports Java version before 21. " +
    "Please install a JDK at version 21 or above to get a compatible runtime.";
