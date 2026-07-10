"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SUPPORTED_MODES = void 0;
exports.getDriver = getDriver;
const local_1 = require("./local");
const docker_1 = require("./docker");
exports.SUPPORTED_MODES = ["local", "docker"];
function getDriver(mode, app) {
    if (mode === "local") {
        return new local_1.LocalDriver(app);
    }
    else if (mode === "docker") {
        return new docker_1.DockerDriver(app);
    }
    throw new Error(`Unsupported mode ${mode}`);
}
