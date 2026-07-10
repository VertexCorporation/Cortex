"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.set_sms_region_policy = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const auth_1 = require("../../../gcp/auth");
exports.set_sms_region_policy = (0, tool_1.tool)("auth", {
    name: "set_sms_region_policy",
    description: "Use this to set an SMS region policy for Firebase Authentication to restrict the regions which can receive text messages based on an ALLOW or DENY list of country codes. This policy will override any existing policies when set.",
    inputSchema: zod_1.z.object({
        policy_type: zod_1.z
            .enum(["ALLOW", "DENY"])
            .describe("with an ALLOW policy, only the specified country codes can use SMS auth. with a DENY policy, all countries can use SMS auth except the ones specified"),
        country_codes: zod_1.z
            .array(zod_1.z.string())
            .describe("the country codes to allow or deny based on ISO 3166"),
    }),
    annotations: {
        title: "Set SMS Region Policy",
        idempotentHint: true,
        destructiveHint: true,
    },
    _meta: {
        requiresProject: true,
        requiresAuth: true,
    },
}, async ({ policy_type, country_codes }, { projectId }) => {
    country_codes = country_codes.map((code) => {
        return code.toUpperCase();
    });
    if (policy_type === "ALLOW") {
        return (0, util_1.toContent)(await (0, auth_1.setAllowSmsRegionPolicy)(projectId, country_codes));
    }
    return (0, util_1.toContent)(await (0, auth_1.setDenySmsRegionPolicy)(projectId, country_codes));
});
