"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DataConnectToolkitController = void 0;
const types_1 = require("./types");
const error_1 = require("../error");
const portUtils = require("./portUtils");
const utils_1 = require("../utils");
const dataconnectEmulator_1 = require("./dataconnectEmulator");
const downloadableEmulators_1 = require("./downloadableEmulators");
const name = "SQL Connect Toolkit";
class DataConnectToolkitController {
    static async start(args) {
        if (this.isRunning || this.instance) {
            throw new error_1.FirebaseError(`${name} is already running!`, {});
        }
        this.instance = new dataconnectEmulator_1.DataConnectEmulator(args);
        this.isRunning = true;
        await this.instance.start();
        const info = this.instance.getInfo();
        await portUtils.waitForPortUsed(info.port, (0, utils_1.connectableHostname)(info.host), info.timeout);
    }
    static async stop() {
        if (!this.isRunning) {
            return;
        }
        try {
            await this.instance.stop();
            this.isRunning = false;
        }
        catch (e) {
            throw new error_1.FirebaseError(`SQL Connect Toolkit failed to stop with error: ${e}`);
        }
    }
    static getVersion() {
        return (0, downloadableEmulators_1.getDownloadDetails)(types_1.Emulators.DATACONNECT).version;
    }
    static getInfo() {
        return this.instance.getInfo();
    }
    static getUrl() {
        const info = this.instance.getInfo();
        if (info.host.includes(":")) {
            return `http://[${info.host}]:${info.port}`;
        }
        return `http://${info.host}:${info.port}`;
    }
}
exports.DataConnectToolkitController = DataConnectToolkitController;
DataConnectToolkitController.isRunning = false;
