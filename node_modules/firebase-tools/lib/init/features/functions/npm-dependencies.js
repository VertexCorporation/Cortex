"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.askInstallDependencies = askInstallDependencies;
const logger_1 = require("../../../logger");
const prompt_1 = require("../../../prompt");
const spawn_1 = require("../../spawn");
async function askInstallDependencies(setup, config) {
    setup.npm = await (0, prompt_1.confirm)({
        message: "Do you want to install dependencies with npm now?",
        default: true,
    });
    if (setup.npm) {
        try {
            await (0, spawn_1.wrapSpawn)("npm", ["install"], config.projectDir + `/${setup.source}`);
        }
        catch (e) {
            logger_1.logger.info();
            logger_1.logger.error("NPM install failed, continuing with Firebase initialization...");
        }
    }
}
