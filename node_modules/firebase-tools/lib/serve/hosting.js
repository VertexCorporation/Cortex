"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.stop = stop;
exports.start = start;
exports.connect = connect;
const morgan = require("morgan");
const net_1 = require("net");
const superstatic_1 = require("superstatic");
const clc = require("colorette");
const detectProjectRoot_1 = require("../detectProjectRoot");
const error_1 = require("../error");
const implicitInit_1 = require("../hosting/implicitInit");
const initMiddleware_1 = require("../hosting/initMiddleware");
const config = require("../hosting/config");
const cloudRunProxy_1 = require("../hosting/cloudRunProxy");
const functionsProxy_1 = require("../hosting/functionsProxy");
const stream_1 = require("stream");
const emulatorLogger_1 = require("../emulator/emulatorLogger");
const types_1 = require("../emulator/types");
const utils_1 = require("../utils");
const requireHostingSite_1 = require("../requireHostingSite");
const projectUtils_1 = require("../projectUtils");
const portUtils_1 = require("../emulator/portUtils");
let destroyServer = undefined;
const logger = emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.HOSTING);
function startServer(options, config, port, init) {
    const firebaseMiddleware = (0, initMiddleware_1.initMiddleware)(init);
    const morganStream = new stream_1.Writable();
    morganStream._write = (chunk, encoding, callback) => {
        if (chunk instanceof Buffer) {
            logger.logLabeled("BULLET", "hosting", chunk.toString().trim());
        }
        callback();
    };
    const morganMiddleware = morgan("combined", {
        stream: morganStream,
    });
    const after = options.frameworksDevModeHandle && {
        files: options.frameworksDevModeHandle,
    };
    const server = (0, superstatic_1.server)({
        debug: false,
        port: port,
        hostname: options.host,
        config: config,
        compression: true,
        cwd: (0, detectProjectRoot_1.detectProjectRoot)(options) || undefined,
        stack: "strict",
        before: {
            files: (req, res, next) => {
                morganMiddleware(req, res, () => null);
                firebaseMiddleware(req, res, next);
            },
        },
        after,
        rewriters: {
            function: (0, functionsProxy_1.functionsProxy)(options),
            run: (0, cloudRunProxy_1.default)(options),
        },
    }).listen(() => {
        const siteName = config.target || config.site;
        const label = siteName ? "hosting[" + siteName + "]" : "hosting";
        if (config.public && config.public !== ".") {
            logger.logLabeled("BULLET", label, "Serving hosting files from: " + clc.bold(config.public));
        }
        logger.logLabeled("SUCCESS", label, "Local server: " + clc.underline(clc.bold("http://" + options.host + ":" + port)));
    });
    destroyServer = (0, utils_1.createDestroyer)(server);
    server.on("error", (err) => {
        logger.log("DEBUG", `Error from superstatic server: ${err.stack || ""}`);
        throw new error_1.FirebaseError(`An error occurred while starting the hosting development server:\n\n${err.message}`);
    });
}
function stop() {
    return destroyServer ? destroyServer() : Promise.resolve();
}
async function start(options) {
    const init = await (0, implicitInit_1.implicitInit)(options);
    if (!options.site) {
        try {
            await (0, requireHostingSite_1.requireHostingSite)(options);
        }
        catch {
            if (init.json) {
                options.site = JSON.parse(init.json).projectId;
            }
            else {
                options.site = (0, projectUtils_1.getProjectId)(options) || "site";
            }
        }
    }
    const configs = config.hostingConfig(options);
    const assignedPorts = new Set([5001]);
    for (let i = 0; i < configs.length; i++) {
        let port = i === 0 ? options.port : options.port + 4 + i;
        while (assignedPorts.has(port) || !(await availablePort(options.host, port))) {
            port += 1;
        }
        assignedPorts.add(port);
        startServer(options, configs[i], port, init);
    }
    assignedPorts.delete(5001);
    return { ports: Array.from(assignedPorts) };
}
async function connect() {
    await Promise.resolve();
}
function availablePort(host, port) {
    return (0, portUtils_1.checkListenable)({
        address: host,
        port,
        family: (0, net_1.isIPv4)(host) ? "IPv4" : "IPv6",
    });
}
