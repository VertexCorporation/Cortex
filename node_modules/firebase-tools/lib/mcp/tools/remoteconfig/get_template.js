"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_template = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const get_1 = require("../../../remoteconfig/get");
exports.get_template = (0, tool_1.tool)("remoteconfig", {
    name: "get_template",
    description: "Use this to retrieve the specified Firebase Remote Config template from the currently active Firebase Project.",
    inputSchema: zod_1.z.object({
        version_number: zod_1.z
            .string()
            .optional()
            .describe("The version number of the template to retrieve. If not provided, retrieves the active template."),
    }),
    annotations: {
        title: "Get Remote Config template",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async ({ version_number }, { projectId }) => {
    return (0, util_1.toContent)(await (0, get_1.getTemplate)(projectId, version_number));
});
