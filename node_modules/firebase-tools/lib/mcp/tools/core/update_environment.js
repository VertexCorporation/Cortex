"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.update_environment = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const use_1 = require("../../../commands/use");
const auth_1 = require("../../../auth");
const node_fs_1 = require("node:fs");
exports.update_environment = (0, tool_1.tool)("core", {
    name: "update_environment",
    description: "Use this to update environment config for the Firebase CLI and Firebase MCP server, such as project directory, active project, active user account, accept terms of service, and more. Use `firebase_get_environment` to see the currently configured environment.",
    inputSchema: zod_1.z.object({
        project_dir: zod_1.z
            .string()
            .optional()
            .describe("Change the current project directory - this should be a directory that has a `firebase.json` file (or will have one)."),
        active_project: zod_1.z
            .string()
            .optional()
            .describe("Change the active project for the current project directory. Should be a Firebase project ID or configured project alias."),
        active_user_account: zod_1.z
            .string()
            .optional()
            .describe("The email address of the signed-in user to authenticate as when interacting with the current project directory."),
    }),
    annotations: {
        title: "Update Firebase Environment",
        readOnlyHint: false,
    },
    _meta: {
        optionalProjectDir: true,
        requiresAuth: false,
        requiresProject: false,
        ui: {
            resourceUri: "ui://core/update_environment/mcp-app.html",
        },
    },
}, async ({ project_dir, active_project, active_user_account }, { config, rc, host }) => {
    let output = "";
    if (project_dir) {
        if (!(0, node_fs_1.existsSync)(project_dir))
            return (0, util_1.mcpError)(`Cannot update project directory to '${project_dir}' as it does not exist.`);
        host.setProjectRoot(project_dir);
        output += `- Updated project directory to '${project_dir}'\n`;
    }
    if (active_project) {
        await (0, use_1.setNewActive)(active_project, undefined, rc, config.projectDir);
        output += `- Updated active project to '${active_project}'\n`;
    }
    if (active_user_account) {
        (0, auth_1.assertAccount)(active_user_account, { mcp: true });
        (0, auth_1.setProjectAccount)(host.cachedProjectDir, active_user_account);
        output += `- Updated active account to '${active_user_account}'\n`;
    }
    if (output === "")
        output = "No changes were made.";
    return (0, util_1.toContent)(output);
});
