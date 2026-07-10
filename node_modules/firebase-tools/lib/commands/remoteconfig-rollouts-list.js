"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const requireAuth_1 = require("../requireAuth");
const requirePermissions_1 = require("../requirePermissions");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const interfaces_1 = require("../remoteconfig/interfaces");
const rcRollout = require("../remoteconfig/listRollouts");
exports.command = new command_1.Command("remoteconfig:rollouts:list")
    .description("get a list of Remote Config rollouts.")
    .option("--pageSize <pageSize>", "Maximum number of rollouts to return per page. Defaults to 10. Pass '0' to fetch all rollouts")
    .option("--pageToken <pageToken>", "Token from a previous list operation to retrieve the next page of results. Listing starts from the beginning if omitted.")
    .option("--filter <filter>", "Filters rollouts by their full resource name. Format: `name:projects/{project_id}/namespaces/{namespace}/rollouts/{rollout_id}`")
    .before(requireAuth_1.requireAuth)
    .before(requirePermissions_1.requirePermissions, [
    "cloud.configs.get",
    "firebaseanalytics.resources.googleAnalyticsReadAndAnalyze",
])
    .action(async (options) => {
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    const listRolloutOptions = {
        pageSize: options.pageSize ?? interfaces_1.DEFAULT_PAGE_SIZE,
        pageToken: options.pageToken,
        filter: options.filter,
    };
    const { rollouts, nextPageToken } = await rcRollout.listRollouts(projectNumber, interfaces_1.NAMESPACE_FIREBASE, listRolloutOptions);
    logger_1.logger.info(rcRollout.parseRolloutList(rollouts ?? []));
    if (nextPageToken) {
        logger_1.logger.info(`\nNext Page Token: \x1b[32m${nextPageToken}\x1b[0m\n`);
    }
    return {
        rollouts,
        nextPageToken,
    };
});
