"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.askQuestions = askQuestions;
exports.actuate = actuate;
const agentSkills_1 = require("../../agentSkills");
const logger_1 = require("../../logger");
const error_1 = require("../../error");
async function askQuestions(setup, config, options) {
    try {
        logger_1.logger.info("If you are using an AI coding agent, Firebase Agent Skills make it an expert at Firebase.");
        const shouldInstall = await (0, agentSkills_1.promptForAgentSkills)(options);
        setup.featureInfo = setup.featureInfo || {};
        setup.featureInfo.agentSkills = { shouldInstall };
    }
    catch (err) {
        logger_1.logger.debug(`Could not prompt for agent skills: ${(0, error_1.getErrMsg)(err)}`);
    }
}
async function actuate(setup, config) {
    const info = setup.featureInfo?.agentSkills;
    if (!info || !info.shouldInstall) {
        return;
    }
    const cwd = config.projectDir;
    void (0, agentSkills_1.installAgentSkills)({ background: true, cwd });
}
