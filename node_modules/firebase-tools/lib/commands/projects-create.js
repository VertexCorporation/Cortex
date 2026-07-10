"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const error_1 = require("../error");
const projects_1 = require("../management/projects");
const requireAuth_1 = require("../requireAuth");
exports.command = new command_1.Command("projects:create [projectId]")
    .description("creates a new Google Cloud Platform project, then adds Firebase resources to the project")
    .option("-n, --display-name <displayName>", "(optional) display name for the project")
    .option("-o, --organization <organizationId>", "(optional) ID of the parent Google Cloud Platform organization under which to create this project")
    .option("-f, --folder <folderId>", "(optional) ID of the parent Google Cloud Platform folder in which to create this project")
    .before(requireAuth_1.requireAuth)
    .action(async (projectId, options) => {
    options.projectId = projectId;
    if (options.organization && options.folder) {
        throw new error_1.FirebaseError("Invalid argument, please provide only one type of project parent (organization or folder)");
    }
    if (!options.nonInteractive) {
        options = { ...options, ...(await (0, projects_1.promptProjectCreation)(options)) };
    }
    if (!options.projectId) {
        throw new error_1.FirebaseError("Project ID cannot be empty");
    }
    let parentResource;
    if (options.organization) {
        parentResource = { type: projects_1.ProjectParentResourceType.ORGANIZATION, id: options.organization };
    }
    else if (options.folder) {
        parentResource = { type: projects_1.ProjectParentResourceType.FOLDER, id: options.folder };
    }
    return (0, projects_1.createFirebaseProjectAndLog)(options.projectId, {
        displayName: options.displayName,
        parentResource,
    });
});
