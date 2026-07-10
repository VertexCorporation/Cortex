"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.tool = tool;
const zod_1 = require("zod");
const util_1 = require("./util");
const availability_1 = require("./util/availability");
function tool(feature, options, fn) {
    const { isAvailable, ...mcpOptions } = options;
    return {
        mcp: {
            ...mcpOptions,
            inputSchema: (0, util_1.cleanSchema)(zod_1.z.toJSONSchema(options.inputSchema, { target: "draft-7", io: "input" })),
        },
        fn,
        isAvailable: (ctx) => {
            const isAvailableFunc = isAvailable || (0, availability_1.getDefaultFeatureAvailabilityCheck)(feature);
            return isAvailableFunc(ctx);
        },
    };
}
