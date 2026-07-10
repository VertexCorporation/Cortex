"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.list_functions = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const backend = require("../../../deploy/functions/backend");
const error_1 = require("../../../error");
exports.list_functions = (0, tool_1.tool)("functions", {
    name: "list_functions",
    description: "List all deployed functions in your Firebase project.",
    inputSchema: zod_1.z.object({}),
    annotations: {
        title: "List Deployed Functions",
        readOnlyHint: true,
        openWorldHint: true,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async (_, { projectId }) => {
    const context = {
        projectId,
    };
    try {
        const existing = await backend.existingBackend(context);
        const endpointsList = backend.allEndpoints(existing).sort(backend.compareFunctions);
        const formattedList = endpointsList.map((endpoint) => ({
            function: endpoint.id,
            version: endpoint.platform === "gcfv2" ? "v2" : "v1",
            trigger: backend.endpointTriggerType(endpoint),
            location: endpoint.region,
            memory: endpoint.availableMemoryMb || "---",
            runtime: endpoint.runtime,
        }));
        if (!formattedList.length) {
            return (0, util_1.toContent)({ functions: [] }, {
                contentPrefix: "No functions found in this project.\n\n",
            });
        }
        return (0, util_1.toContent)({ functions: formattedList });
    }
    catch (err) {
        const errMsg = (0, error_1.getErrMsg)(err?.original || err, "Failed to list functions.");
        return (0, util_1.mcpError)(errMsg);
    }
});
