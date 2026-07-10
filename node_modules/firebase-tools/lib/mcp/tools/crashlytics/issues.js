"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.update_issue = exports.get_issue = void 0;
const zod_1 = require("zod");
const filters_1 = require("../../../crashlytics/filters");
const issues_1 = require("../../../crashlytics/issues");
const types_1 = require("../../../crashlytics/types");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const app_id_1 = require("../../resources/guides/app_id");
exports.get_issue = (0, tool_1.tool)("crashlytics", {
    name: "get_issue",
    description: `Gets data for a Crashlytics issue, which can be used as a starting point for debugging.`,
    inputSchema: zod_1.z.object({
        appId: filters_1.ApplicationIdSchema,
        issueId: filters_1.IssueIdSchema,
    }),
    annotations: {
        title: "Get Crashlytics Issue Details",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
    },
}, async ({ appId, issueId }) => {
    const result = { content: [] };
    if (!appId) {
        result.isError = true;
        result.content.push({ type: "text", text: "Must specify 'appId' parameter" });
        result.content.push({ type: "text", text: app_id_1.RESOURCE_CONTENT });
    }
    if (!issueId) {
        result.isError = true;
        result.content.push({ type: "text", text: "Must specify 'issueId' parameter." });
    }
    if (result.content.length > 0) {
        return result;
    }
    return (0, util_1.toContent)(await (0, issues_1.getIssue)(appId, issueId));
});
exports.update_issue = (0, tool_1.tool)("crashlytics", {
    name: "update_issue",
    description: "Use this to update the state of Crashlytics issue.",
    inputSchema: zod_1.z.object({
        appId: filters_1.ApplicationIdSchema,
        issueId: filters_1.IssueIdSchema,
        state: zod_1.z
            .nativeEnum(types_1.State)
            .describe("The new state for the issue. Can be 'OPEN' or 'CLOSED'."),
    }),
    annotations: {
        title: "Update Crashlytics Issue",
        readOnlyHint: false,
    },
    _meta: {
        requiresAuth: true,
    },
}, async ({ appId, issueId, state }) => {
    const result = { content: [] };
    if (!appId) {
        result.isError = true;
        result.content.push({ type: "text", text: "Must specify 'appId' parameter" });
        result.content.push({ type: "text", text: app_id_1.RESOURCE_CONTENT });
    }
    if (!issueId) {
        result.isError = true;
        result.content.push({ type: "text", text: "Must specify 'issueId' parameter." });
    }
    if (!state) {
        result.isError = true;
        result.content.push({ type: "text", text: "Must specify 'state' parameter" });
    }
    if (result.content.length > 0) {
        return result;
    }
    return (0, util_1.toContent)(await (0, issues_1.updateIssue)(appId, issueId, state));
});
