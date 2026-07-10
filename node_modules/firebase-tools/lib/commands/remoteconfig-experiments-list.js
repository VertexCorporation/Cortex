"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const rcExperiment = require("../remoteconfig/listExperiments");
const interfaces_1 = require("../remoteconfig/interfaces");
const command_1 = require("../command");
const requireAuth_1 = require("../requireAuth");
const requirePermissions_1 = require("../requirePermissions");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
exports.command = new command_1.Command("remoteconfig:experiments:list")
    .description("get a list of Remote Config experiments")
    .option("--pageSize <pageSize>", "Maximum number of experiments to return per page. Defaults to 10. Pass '0' to fetch all experiments")
    .option("--pageToken <pageToken>", "Token from a previous list operation to retrieve the next page of results. Listing starts from the beginning if omitted.")
    .option("--filter <filter>", "Filters experiments by their full resource name. Format: `name:projects/{project_number}/namespaces/{namespace}/experiments/{experiment_id}`")
    .before(requireAuth_1.requireAuth)
    .before(requirePermissions_1.requirePermissions, [
    "firebaseabt.experiments.list",
    "firebaseanalytics.resources.googleAnalyticsReadAndAnalyze",
])
    .action(async (options) => {
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    const listExperimentOptions = {
        pageSize: options.pageSize ?? interfaces_1.DEFAULT_PAGE_SIZE,
        pageToken: options.pageToken,
        filter: options.filter,
    };
    const { experiments, nextPageToken } = await rcExperiment.listExperiments(projectNumber, interfaces_1.NAMESPACE_FIREBASE, listExperimentOptions);
    logger_1.logger.info(rcExperiment.parseExperimentList(experiments ?? []));
    if (nextPageToken) {
        logger_1.logger.info(`\nNext Page Token: \x1b[32m${nextPageToken}\x1b[0m\n`);
    }
    return {
        experiments,
        nextPageToken,
    };
});
