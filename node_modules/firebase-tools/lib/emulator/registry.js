"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.EmulatorRegistry = void 0;
const types_1 = require("./types");
const error_1 = require("../error");
const portUtils = require("./portUtils");
const constants_1 = require("./constants");
const emulatorLogger_1 = require("./emulatorLogger");
const utils_1 = require("../utils");
const apiv2_1 = require("../apiv2");
const downloadableEmulators_1 = require("./downloadableEmulators");
class EmulatorRegistry {
    static async start(instance) {
        const description = constants_1.Constants.description(instance.getName());
        if (this.isRunning(instance.getName())) {
            throw new error_1.FirebaseError(`${description} is already running!`, {});
        }
        this.set(instance.getName(), instance);
        await instance.start();
        if (instance.getName() !== types_1.Emulators.EXTENSIONS) {
            const info = instance.getInfo();
            await portUtils.waitForPortUsed(info.port, (0, utils_1.connectableHostname)(info.host), info.timeout);
        }
    }
    static async stop(name) {
        emulatorLogger_1.EmulatorLogger.forEmulator(name).logLabeled("BULLET", name, `Stopping ${constants_1.Constants.description(name)}`);
        const instance = this.get(name);
        if (!instance) {
            return;
        }
        try {
            await instance.stop();
            this.clear(instance.getName());
        }
        catch (e) {
            emulatorLogger_1.EmulatorLogger.forEmulator(name).logLabeled("WARN", name, `Error stopping ${constants_1.Constants.description(name)}`);
        }
    }
    static async stopAll() {
        const stopPriority = {
            ui: 0,
            extensions: 1,
            functions: 1.1,
            hosting: 2,
            apphosting: 2.1,
            database: 3.0,
            firestore: 3.1,
            pubsub: 3.2,
            auth: 3.3,
            storage: 3.5,
            eventarc: 3.6,
            dataconnect: 3.7,
            tasks: 3.8,
            hub: 4,
            logging: 5,
        };
        const emulatorsToStop = this.listRunning().sort((a, b) => {
            return stopPriority[a] - stopPriority[b];
        });
        for (const name of emulatorsToStop) {
            await this.stop(name);
        }
    }
    static isRunning(emulator) {
        if (emulator === types_1.Emulators.EXTENSIONS) {
            return this.INSTANCES.get(emulator) !== undefined && this.isRunning(types_1.Emulators.FUNCTIONS);
        }
        const instance = this.INSTANCES.get(emulator);
        return instance !== undefined;
    }
    static listRunning() {
        return types_1.ALL_EMULATORS.filter((name) => this.isRunning(name));
    }
    static listRunningWithInfo() {
        return this.listRunning()
            .map((emulator) => this.getInfo(emulator))
            .filter((info) => typeof info !== "undefined");
    }
    static get(emulator) {
        return this.INSTANCES.get(emulator);
    }
    static getInfo(emulator) {
        const info = EmulatorRegistry.get(emulator)?.getInfo();
        if (!info) {
            return undefined;
        }
        return {
            ...info,
            host: (0, utils_1.connectableHostname)(info.host),
        };
    }
    static getDetails(emulator) {
        return (0, downloadableEmulators_1.get)(emulator);
    }
    static url(emulator, req) {
        const url = new URL("http://unknown/");
        if (req) {
            url.protocol = req.protocol;
            const host = req.headers.host;
            if (host) {
                url.host = host;
                return url;
            }
        }
        const info = EmulatorRegistry.getInfo(emulator);
        if (info) {
            if (info.host.includes(":")) {
                url.hostname = `[${info.host}]`;
            }
            else {
                url.hostname = info.host;
            }
            url.port = info.port.toString();
        }
        else {
            throw new Error(`Cannot determine host and port of ${emulator}`);
        }
        return url;
    }
    static client(emulator, options = {}) {
        return new apiv2_1.Client({
            urlPrefix: EmulatorRegistry.url(emulator).toString(),
            auth: false,
            ...options,
        });
    }
    static set(emulator, instance) {
        this.INSTANCES.set(emulator, instance);
    }
    static clear(emulator) {
        this.INSTANCES.delete(emulator);
    }
}
exports.EmulatorRegistry = EmulatorRegistry;
EmulatorRegistry.INSTANCES = new Map();
