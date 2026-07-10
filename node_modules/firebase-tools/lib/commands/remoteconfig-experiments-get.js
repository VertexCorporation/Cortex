"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const requireAuth_1 = require("../requireAuth");
const requirePermissions_1 = require("../requirePermissions");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const interfaces_1 = require("../remoteconfig/interfaces");
const rcExperiment = require("../remoteconfig/getExperiment");
exports.command = new command_1.Command("remoteconfig:experiments:get <experimentId>")
    .description("get a Remote Config experiment.")
    .before(requireAuth_1.requireAuth)
    .before(requirePermissions_1.requirePermissions, ["firebaseabt.experiments.get"])
    .action(async (experimentId, options) => {
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    const experiment = await rcExperiment.getExperiment(projectNumber, interfaces_1.NAMESPACE_FIREBASE, experimentId);
    logger_1.logger.info(rcExperiment.parseExperiment(experiment));
    return experiment;
});
