"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const apphosting = require("../gcp/apphosting");
const logger_1 = require("../logger");
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const requireAuth_1 = require("../requireAuth");
const utils_1 = require("../utils");
exports.command = new command_1.Command("apphosting:builds:create <backendId>")
    .description("create a build for an App Hosting backend")
    .option("-l, --location <location>", "specify the region of the backend")
    .option("-i, --id <buildId>", "id of the build (defaults to autogenerating a random id)", "")
    .option("-b, --branch <branch>", "repository branch to deploy (defaults to 'main')", "main")
    .before(requireAuth_1.requireAuth)
    .before(apphosting.ensureApiEnabled)
    .action(async (backendId, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    if (options.location !== undefined) {
        (0, utils_1.logWarning)("--location is being removed in the next major release.");
    }
    const location = options.location ?? "us-central1";
    const buildId = options.buildId ||
        (await apphosting.getNextRolloutId(projectId, location, backendId));
    const branch = options.branch ?? "main";
    const op = await apphosting.createBuild(projectId, location, backendId, buildId, {
        source: {
            codebase: {
                branch,
            },
        },
    });
    logger_1.logger.info(`Started a build for backend ${backendId} on branch ${branch}.`);
    logger_1.logger.info("Check status by running:");
    logger_1.logger.info(`\tfirebase apphosting:builds:get ${backendId} ${buildId} --location ${location}`);
    return op;
});
