"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const apphosting = require("../gcp/apphosting");
const logger_1 = require("../logger");
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const requireAuth_1 = require("../requireAuth");
const utils_1 = require("../utils");
exports.command = new command_1.Command("apphosting:builds:get <backendId> <buildId>")
    .description("get a build for an App Hosting backend")
    .option("-l, --location <location>", "specify the region of the backend")
    .before(requireAuth_1.requireAuth)
    .before(apphosting.ensureApiEnabled)
    .action(async (backendId, buildId, options) => {
    if (options.location !== undefined) {
        (0, utils_1.logWarning)("--location is being removed in the next major release.");
    }
    options.location = options.location ?? "us-central";
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const location = options.location;
    const build = await apphosting.getBuild(projectId, location, backendId, buildId);
    logger_1.logger.info(JSON.stringify(build, null, 2));
    return build;
});
