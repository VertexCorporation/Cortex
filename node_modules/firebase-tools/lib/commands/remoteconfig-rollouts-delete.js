"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const requireAuth_1 = require("../requireAuth");
const requirePermissions_1 = require("../requirePermissions");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const interfaces_1 = require("../remoteconfig/interfaces");
const rcRollout = require("../remoteconfig/deleteRollout");
const getRollout_1 = require("../remoteconfig/getRollout");
const prompt_1 = require("../prompt");
exports.command = new command_1.Command("remoteconfig:rollouts:delete <rolloutId>")
    .description("delete a Remote Config rollout.")
    .before(requireAuth_1.requireAuth)
    .before(requirePermissions_1.requirePermissions, [
    "cloud.configs.update",
    "firebaseanalytics.resources.googleAnalyticsEdit",
])
    .action(async (rolloutId, options) => {
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    const rollout = await (0, getRollout_1.getRollout)(projectNumber, interfaces_1.NAMESPACE_FIREBASE, rolloutId);
    logger_1.logger.info((0, getRollout_1.parseRolloutIntoTable)(rollout));
    const confirmDeletion = await (0, prompt_1.confirm)({
        message: "Are you sure you want to delete this rollout? This cannot be undone.",
        default: false,
    });
    if (!confirmDeletion) {
        return;
    }
    logger_1.logger.info(await rcRollout.deleteRollout(projectNumber, interfaces_1.NAMESPACE_FIREBASE, rolloutId));
});
