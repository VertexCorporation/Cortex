"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const error_1 = require("../error");
const projects_1 = require("../management/projects");
const requireAuth_1 = require("../requireAuth");
exports.command = new command_1.Command("projects:addfirebase [projectId]")
    .description("add Firebase resources to a Google Cloud Platform project")
    .before(requireAuth_1.requireAuth)
    .action(async (projectId, options) => {
    if (!options.nonInteractive && !projectId) {
        projectId = await (0, projects_1.promptAvailableProjectId)();
    }
    if (!projectId) {
        throw new error_1.FirebaseError("Project ID cannot be empty");
    }
    return (0, projects_1.addFirebaseToCloudProjectAndLog)(projectId);
});
