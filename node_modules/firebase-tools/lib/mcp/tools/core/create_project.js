"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.create_project = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const projects_1 = require("../../../management/projects");
const error_1 = require("../../../error");
async function checkCloudProject(projectId) {
    try {
        return await (0, projects_1.getProject)(projectId);
    }
    catch (err) {
        if ((0, error_1.getErrStatus)(err) === 403) {
            return undefined;
        }
        throw err;
    }
}
exports.create_project = (0, tool_1.tool)("core", {
    name: "create_project",
    description: "Use this to create a new Firebase Project.",
    inputSchema: zod_1.z.object({
        project_id: zod_1.z.string().describe("The project ID to create or use."),
        display_name: zod_1.z
            .string()
            .optional()
            .describe("The user-friendly display name for the project."),
    }),
    annotations: {
        title: "Create Firebase Project",
        destructiveHint: false,
        readOnlyHint: false,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: false,
    },
}, async ({ project_id, display_name }) => {
    try {
        const cloudProject = await checkCloudProject(project_id);
        if (!cloudProject) {
            const newProject = await (0, projects_1.createFirebaseProjectAndLog)(project_id, {
                displayName: display_name,
            });
            return (0, util_1.toContent)({
                message: `Successfully created new Firebase project: ${project_id}`,
                project: newProject,
            });
        }
        let firebaseProject = await (0, projects_1.checkFirebaseEnabledForCloudProject)(project_id);
        if (firebaseProject) {
            return (0, util_1.toContent)({
                message: `Project ${project_id} already exists and has Firebase enabled.`,
                project: firebaseProject,
            });
        }
        firebaseProject = await (0, projects_1.addFirebaseToCloudProject)(project_id);
        return (0, util_1.toContent)({
            message: `Successfully added Firebase to existing project: ${project_id}`,
            project: firebaseProject,
        });
    }
    catch (err) {
        const originalMessage = err.original ? `: ${err.original.message}` : "";
        throw new Error(`${err.message}\nOriginal error: ${originalMessage}`);
    }
});
