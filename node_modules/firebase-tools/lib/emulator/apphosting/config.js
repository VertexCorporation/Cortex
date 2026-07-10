"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getLocalAppHostingConfiguration = getLocalAppHostingConfiguration;
const config_1 = require("../../apphosting/config");
async function getLocalAppHostingConfiguration(backendDir) {
    return (0, config_1.getAppHostingConfiguration)(backendDir);
}
