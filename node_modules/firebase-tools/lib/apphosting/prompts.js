"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEFAULT_RUNTIME = void 0;
exports.promptRuntime = promptRuntime;
exports.resolveRuntime = resolveRuntime;
const prompt_1 = require("../prompt");
const utils_1 = require("../utils");
const apphosting = require("../gcp/apphosting");
const experiments_1 = require("../experiments");
exports.DEFAULT_RUNTIME = "nodejs";
async function promptRuntime(projectId, location) {
    const choices = [];
    let nodejsChoice = { name: "Node.js (default)", value: exports.DEFAULT_RUNTIME };
    try {
        const supportedRuntimes = await apphosting.listSupportedRuntimes(projectId, location);
        for (const r of supportedRuntimes) {
            const abiuText = r.automaticBaseImageUpdatesSupported
                ? "Enables Automatic Base Image Updates"
                : "No Automatic Base Image Updates";
            const choiceName = `${r.runtimeId} - ${abiuText}`;
            if (r.runtimeId === exports.DEFAULT_RUNTIME) {
                nodejsChoice = { name: choiceName, value: r.runtimeId };
            }
            else {
                choices.push({ name: choiceName, value: r.runtimeId });
            }
        }
        choices.unshift(nodejsChoice);
    }
    catch (err) {
        (0, utils_1.logWarning)("Failed to list supported runtimes. Falling back to hardcoded list.");
        choices.push({ name: "nodejs - No Automatic Base Image Updates", value: "nodejs" });
        choices.push({ name: "nodejs22 - Enables Automatic Base Image Updates", value: "nodejs22" });
    }
    const selectedRuntime = await (0, prompt_1.select)({
        message: "Which runtime do you want to use?",
        choices: choices,
        default: exports.DEFAULT_RUNTIME,
    });
    if (selectedRuntime === exports.DEFAULT_RUNTIME) {
        (0, utils_1.logBullet)("ABIU will not be enabled for the unversioned 'nodejs' runtime.");
    }
    return selectedRuntime;
}
async function resolveRuntime(projectId, location, nonInteractive, runtimeOption) {
    if (runtimeOption !== undefined) {
        return runtimeOption;
    }
    if (!(0, experiments_1.isEnabled)("abiu")) {
        return undefined;
    }
    if (nonInteractive) {
        return exports.DEFAULT_RUNTIME;
    }
    return promptRuntime(projectId, location);
}
