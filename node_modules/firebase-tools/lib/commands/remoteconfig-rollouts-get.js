"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const requireAuth_1 = require("../requireAuth");
const requirePermissions_1 = require("../requirePermissions");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const interfaces_1 = require("../remoteconfig/interfaces");
const rcRollout = require("../remoteconfig/getRollout");
exports.command = new command_1.Command("remoteconfig:rollouts:get <rolloutId>")
    .description("get a Remote Config rollout")
    .before(requireAuth_1.requireAuth)
    .before(requirePermissions_1.requirePermissions, ["cloud.configs.get"])
    .action(async (rolloutId, options) => {
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    const rollout = await rcRollout.getRollout(projectNumber, interfaces_1.NAMESPACE_FIREBASE, rolloutId);
    logger_1.logger.info(rcRollout.parseRolloutIntoTable(rollout));
    return rollout;
});
