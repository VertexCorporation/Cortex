"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.consoleInstallLink = consoleInstallLink;
const api_1 = require("../api");
function consoleInstallLink(extVersionRef) {
    return `${(0, api_1.consoleOrigin)()}/project/_/extensions/install?ref=${extVersionRef}`;
}
