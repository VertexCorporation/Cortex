"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.read_resources = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const resources_1 = require("../../resources");
const util_1 = require("../../util");
const track_1 = require("../../../track");
exports.read_resources = (0, tool_1.tool)("core", {
    name: "read_resources",
    description: "Use this to read the contents of `firebase://` resources or list available resources",
    annotations: {
        title: "Read Firebase Resources",
        destructiveHint: false,
        readOnlyHint: true,
    },
    inputSchema: zod_1.z.object({
        uris: zod_1.z
            .array(zod_1.z.string())
            .optional()
            .describe("list of resource uris to read. each must start with `firebase://` prefix. omit to list all available resources"),
    }),
}, async ({ uris }, ctx) => {
    if (!uris?.length) {
        void (0, track_1.trackGA4)("mcp_list_resources", { resource_name: "__list__" });
        return (0, util_1.toContent)(resources_1.resources
            .map((r) => `Available resources:\n\n- [${r.mcp.title || r.mcp.name}](${r.mcp.uri}): ${r.mcp.description}`)
            .join("\n"));
    }
    const out = [];
    for (const uri of uris) {
        const resolved = await (0, resources_1.resolveResource)(uri, ctx);
        if (!resolved) {
            out.push(`<resource uri="${uri}" error>\nRESOURCE NOT FOUND\n</resource>`);
            continue;
        }
        out.push(`<resource uri="${uri}" title="${resolved.mcp.title || resolved.mcp.name}">\n${resolved.result.contents.map((c) => ("text" in c ? c.text : "")).join("")}\n</resource>`);
    }
    return (0, util_1.toContent)(out.join("\n\n"));
});
