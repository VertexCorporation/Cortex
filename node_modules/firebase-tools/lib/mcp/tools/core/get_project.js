"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_project = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const projects_1 = require("../../../management/projects");
const util_1 = require("../../util");
exports.get_project = (0, tool_1.tool)("core", {
    name: "get_project",
    description: "Use this to retrieve information about the currently active Firebase Project.",
    inputSchema: zod_1.z.object({}),
    annotations: {
        title: "Get Current Firebase Project",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async (_, { projectId }) => {
    return (0, util_1.toContent)(await (0, projects_1.getProject)(projectId));
});
