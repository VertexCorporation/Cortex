"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.update_user = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const auth_1 = require("../../../gcp/auth");
exports.update_user = (0, tool_1.tool)("auth", {
    name: "update_user",
    description: "Use this to disable, enable, or set a custom claim on a specific user's account.",
    inputSchema: zod_1.z.object({
        uid: zod_1.z.string().describe("the UID of the user to update"),
        disabled: zod_1.z.boolean().optional().describe("true disables the user, false enables the user"),
        claim: zod_1.z
            .object({
            key: zod_1.z.string().describe("the name (key) of the claim to update, e.g. 'admin'"),
            value: zod_1.z
                .union([zod_1.z.string(), zod_1.z.number(), zod_1.z.boolean()])
                .optional()
                .describe("Set the value of the custom claim to the specified simple scalar value. One of `value` or `json_value` must be provided if setting a claim."),
            json_value: zod_1.z
                .string()
                .optional()
                .describe("Set the claim to a complex JSON value like an object or an array by providing stringified JSON. String must be parseable as valid JSON. One of `value` or `json_value` must be provided if setting a claim."),
        })
            .optional(),
    }),
    annotations: {
        title: "Update a user",
        idempotentHint: true,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async ({ uid, disabled, claim }, { projectId }) => {
    if (disabled && claim) {
        return (0, util_1.mcpError)("Can only enable/disable a user or set a claim, not both.");
    }
    if (disabled === undefined && !claim) {
        return (0, util_1.mcpError)("At least one of 'disabled' or 'claim' must be provided to update the user.");
    }
    if (claim && claim.value === undefined && claim.json_value === undefined) {
        return (0, util_1.mcpError)("When providing 'key' for the claim, you must also provide either 'value' or 'json_value' for the claim.");
    }
    if (disabled !== undefined) {
        try {
            await (0, auth_1.toggleUserEnablement)(projectId, uid, disabled);
        }
        catch (err) {
            return (0, util_1.mcpError)(`Failed to ${disabled ? "disable" : "enable"} user ${uid}`);
        }
    }
    if (claim) {
        if (claim.value && claim.json_value) {
            return (0, util_1.mcpError)("Must supply only `value` or `json_value`, not both.");
        }
        let claimValue = claim.value;
        if (claim.json_value) {
            try {
                claimValue = JSON.parse(claim.json_value);
            }
            catch (e) {
                return (0, util_1.mcpError)(`Provided \`json_value\` was not valid JSON: ${claim.json_value}`);
            }
        }
        try {
            await (0, auth_1.setCustomClaim)(projectId, uid, { [claim.key]: claimValue }, { merge: true });
        }
        catch (e) {
            let errorMsg = `Failed to set claim: ${e.message}`;
            if (disabled !== undefined) {
                errorMsg = `User was successfully ${disabled ? "disabled" : "enabled"}, but setting the claim failed: ${e.message}`;
            }
            return (0, util_1.mcpError)(errorMsg);
        }
    }
    const messageParts = [];
    if (disabled !== undefined) {
        messageParts.push(`User ${disabled ? "disabled" : "enabled"}`);
    }
    if (claim) {
        messageParts.push(`Claim '${claim.key}' set`);
    }
    return (0, util_1.toContent)(`Successfully updated user ${uid}. ${messageParts.join(". ")}.`);
});
