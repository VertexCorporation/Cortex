"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.list_projects = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const projects_1 = require("../../../management/projects");
const PROJECT_LIST_PAGE_SIZE = 20;
exports.list_projects = (0, tool_1.tool)("core", {
    name: "list_projects",
    description: "Use this to retrieve a list of Firebase Projects that the signed-in user has access to.",
    inputSchema: zod_1.z.object({
        page_size: zod_1.z
            .number()
            .min(1)
            .default(PROJECT_LIST_PAGE_SIZE)
            .describe("the number of projects to list per page (defaults to 1000)"),
        page_token: zod_1.z.string().optional().describe("the page token to start listing from"),
    }),
    annotations: {
        title: "List Firebase Projects",
        readOnlyHint: true,
        idempotentHint: true,
    },
    _meta: {
        requiresAuth: true,
    },
}, async ({ page_size, page_token }) => {
    try {
        const projectPage = await (0, projects_1.getFirebaseProjectPage)(page_size, page_token);
        return (0, util_1.toContent)({
            projects: projectPage.projects,
            next_page_token: projectPage.nextPageToken,
        }, {
            contentPrefix: `Here are ${projectPage.projects.length} Firebase projects${page_token ? " (continued)" : ""}:\n\n`,
            contentSuffix: projectPage.nextPageToken
                ? "\nThere are more projects available. To see the next page, call this tool again with the next_page_token shown above."
                : "",
        });
    }
    catch (err) {
        const originalMessage = err.original ? `: ${err.original.message}` : "";
        throw new Error(`Failed to list Firebase projects${originalMessage}`);
    }
});
