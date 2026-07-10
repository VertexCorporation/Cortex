"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const colorette_1 = require("colorette");
const command_1 = require("../command");
const error_1 = require("../error");
const experiments = require("../experiments");
const logger_1 = require("../logger");
const utils_1 = require("../utils");
exports.command = new command_1.Command("experiments:describe <experiment>")
    .description("describe what an experiment does when enabled")
    .action((experiment) => {
    if (!experiments.isValidExperiment(experiment)) {
        let message = `Cannot find experiment ${(0, colorette_1.bold)(experiment)}`;
        const potentials = experiments.experimentNameAutocorrect(experiment);
        if (potentials.length === 1) {
            message = `${message}\nDid you mean ${potentials[0]}?`;
        }
        else if (potentials.length) {
            message = `${message}\nDid you mean ${potentials.slice(0, -1).join(",")} or ${(0, utils_1.last)(potentials)}?`;
        }
        throw new error_1.FirebaseError(message);
    }
    const spec = experiments.ALL_EXPERIMENTS[experiment];
    logger_1.logger.info(`${(0, colorette_1.bold)("Name")}: ${experiment}`);
    logger_1.logger.info(`${(0, colorette_1.bold)("Enabled")}: ${experiments.isEnabled(experiment) ? "yes" : "no"}`);
    if (spec.docsUri) {
        logger_1.logger.info(`${(0, colorette_1.bold)("Documentation")}: ${spec.docsUri}`);
    }
    logger_1.logger.info(`${(0, colorette_1.bold)("Description")}: ${spec.fullDescription || spec.shortDescription}`);
});
