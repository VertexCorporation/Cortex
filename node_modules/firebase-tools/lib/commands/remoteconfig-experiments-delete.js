"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const requireAuth_1 = require("../requireAuth");
const requirePermissions_1 = require("../requirePermissions");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const interfaces_1 = require("../remoteconfig/interfaces");
const rcExperiment = require("../remoteconfig/deleteExperiment");
const getExperiment_1 = require("../remoteconfig/getExperiment");
const prompt_1 = require("../prompt");
exports.command = new command_1.Command("remoteconfig:experiments:delete <experimentId>")
    .description("delete a Remote Config experiment.")
    .before(requireAuth_1.requireAuth)
    .before(requirePermissions_1.requirePermissions, [
    "firebaseabt.experiments.delete",
    "firebaseanalytics.resources.googleAnalyticsEdit",
])
    .action(async (experimentId, options) => {
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    const experiment = await (0, getExperiment_1.getExperiment)(projectNumber, interfaces_1.NAMESPACE_FIREBASE, experimentId);
    logger_1.logger.info((0, getExperiment_1.parseExperiment)(experiment));
    const confirmDeletion = await (0, prompt_1.confirm)({
        message: "Are you sure you want to delete this experiment? This cannot be undone.",
        default: false,
    });
    if (!confirmDeletion) {
        return;
    }
    logger_1.logger.info(await rcExperiment.deleteExperiment(projectNumber, interfaces_1.NAMESPACE_FIREBASE, experimentId));
});
