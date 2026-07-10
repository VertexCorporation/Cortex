"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const colorette_1 = require("colorette");
const command_1 = require("../command");
const error_1 = require("../error");
const experiments = require("../experiments");
const logger_1 = require("../logger");
const utils_1 = require("../utils");
exports.command = new command_1.Command("experiments:disable <experiment>")
    .description("disable an experiment on this machine")
    .action((experiment) => {
    if (experiments.isValidExperiment(experiment)) {
        experiments.setEnabled(experiment, false);
        experiments.flushToDisk();
        logger_1.logger.info(`Disabled experiment ${(0, colorette_1.bold)(experiment)}`);
        return;
    }
    let message = `Cannot find experiment ${(0, colorette_1.bold)(experiment)}`;
    const potentials = experiments.experimentNameAutocorrect(experiment);
    if (potentials.length === 1) {
        message = `${message}\nDid you mean ${potentials[0]}?`;
    }
    else if (potentials.length) {
        message = `${message}\nDid you mean ${potentials.slice(0, -1).join(",")} or ${(0, utils_1.last)(potentials)}?`;
    }
    throw new error_1.FirebaseError(message);
});
