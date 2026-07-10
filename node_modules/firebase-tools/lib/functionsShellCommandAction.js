"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.actionFunction = void 0;
const clc = require("colorette");
const repl = require("repl");
const _ = require("lodash");
const util = require("util");
const shell = require("./emulator/functionsEmulatorShell");
const commandUtils = require("./emulator/commandUtils");
const functions_1 = require("./serve/functions");
const localFunction_1 = require("./localFunction");
const utils = require("./utils");
const logger_1 = require("./logger");
const types_1 = require("./emulator/types");
const hubClient_1 = require("./emulator/hubClient");
const portUtils_1 = require("./emulator/portUtils");
const constants_1 = require("./emulator/constants");
const localFunction_2 = require("./localFunction");
const projectUtils_1 = require("./projectUtils");
const serveFunctions = new functions_1.FunctionsServer();
const actionFunction = async (options) => {
    if (typeof options.port === "string") {
        options.port = parseInt(options.port, 10);
    }
    let debugPort = undefined;
    if (options.inspectFunctions) {
        debugPort = commandUtils.parseInspectionPort(options);
    }
    (0, projectUtils_1.needProjectId)(options);
    const hubClient = new hubClient_1.EmulatorHubClient(options.project);
    let remoteEmulators = {};
    if (hubClient.foundHub()) {
        remoteEmulators = await hubClient.getEmulators();
        logger_1.logger.debug("Running emulators: ", remoteEmulators);
    }
    const runningEmulators = types_1.EMULATORS_SUPPORTED_BY_FUNCTIONS.filter((e) => remoteEmulators[e] !== undefined);
    const otherEmulators = types_1.EMULATORS_SUPPORTED_BY_FUNCTIONS.filter((e) => remoteEmulators[e] === undefined);
    let host = constants_1.Constants.getDefaultHost();
    let port = 5000;
    if (typeof options.port === "number") {
        port = options.port;
    }
    const functionsInfo = remoteEmulators[types_1.Emulators.FUNCTIONS];
    if (functionsInfo) {
        utils.logLabeledWarning("functions", `You are already running the Cloud Functions emulator on port ${functionsInfo.port}. Running the emulator and the Functions shell simultaenously can result in unexpected behavior.`);
    }
    else if (!options.port) {
        port = options.config.src.emulators?.functions?.port ?? port;
        host = options.config.src.emulators?.functions?.host ?? host;
        options.host = host;
    }
    const listen = (await (0, portUtils_1.resolveHostAndAssignPorts)({
        [types_1.Emulators.FUNCTIONS]: { host, port },
    })).functions;
    options.host = listen[0].address;
    options.port = listen[0].port;
    return serveFunctions
        .start(options, {
        verbosity: "QUIET",
        remoteEmulators,
        debugPort,
    })
        .then(() => {
        return serveFunctions.connect();
    })
        .then(() => {
        const instance = serveFunctions.get();
        const emulator = new shell.FunctionsEmulatorShell(instance);
        if (emulator.emulatedFunctions && emulator.emulatedFunctions.length === 0) {
            logger_1.logger.info("No functions emulated.");
            process.exit();
        }
        const initializeContext = (context) => {
            for (const trigger of emulator.triggers) {
                if (emulator.emulatedFunctions.includes(trigger.id)) {
                    const localFunction = new localFunction_1.default(trigger, emulator.urls, emulator);
                    const triggerNameDotNotation = trigger.name.replace(/-/g, ".");
                    _.set(context, triggerNameDotNotation, localFunction.makeFn());
                }
            }
            context.help =
                "Instructions for the Functions Shell can be found at: " +
                    "https://firebase.google.com/docs/functions/local-emulator";
        };
        for (const e of runningEmulators) {
            const info = remoteEmulators[e];
            utils.logLabeledBullet("functions", `Connected to running ${clc.bold(e)} emulator at ${info.host}:${info.port}, calls to this service will affect the emulator`);
        }
        utils.logLabeledWarning("functions", `The following emulators are not running, calls to these services will affect production: ${clc.bold(otherEmulators.join(", "))}`);
        const writer = (output) => {
            if (output === localFunction_2.HTTPS_SENTINEL) {
                return localFunction_2.HTTPS_SENTINEL;
            }
            return util.inspect(output);
        };
        const prompt = "firebase > ";
        const replServer = repl.start({
            prompt: prompt,
            writer: writer,
            useColors: true,
        });
        initializeContext(replServer.context);
        replServer.on("reset", initializeContext);
        return new Promise((resolve) => {
            replServer.on("exit", () => {
                return serveFunctions.stop().then(resolve).catch(resolve);
            });
        });
    });
};
exports.actionFunction = actionFunction;
