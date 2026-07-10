"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.update_template = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const publish_1 = require("../../../remoteconfig/publish");
const rollback_1 = require("../../../remoteconfig/rollback");
exports.update_template = (0, tool_1.tool)("remoteconfig", {
    name: "update_template",
    description: "Use this to publish a new remote config template or roll back to a specific version for the project",
    inputSchema: zod_1.z
        .object({
        template: zod_1.z.object({}).optional().describe("The Remote Config template object to publish."),
        version_number: zod_1.z.number().optional().describe("The version number to roll back to."),
        force: zod_1.z
            .boolean()
            .optional()
            .describe("If true, the publish will bypass ETag validation and overwrite the current template. Defaults to false if not provided."),
    })
        .refine((data) => (data.template && !data.version_number) || (!data.template && data.version_number), {
        message: "Either provide a template for publish, or a version number to rollback to, but not both.",
    }),
    annotations: {
        title: "Update Remote Config template",
        readOnlyHint: false,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async ({ template, version_number, force }, { projectId }) => {
    if (version_number) {
        return (0, util_1.toContent)(await (0, rollback_1.rollbackTemplate)(projectId, version_number));
    }
    if (template) {
        if (force === undefined) {
            return (0, util_1.toContent)(await (0, publish_1.publishTemplate)(projectId, template));
        }
        return (0, util_1.toContent)(await (0, publish_1.publishTemplate)(projectId, template, { force }));
    }
    return (0, util_1.mcpError)("Either a template or a version number must be specified.");
});
