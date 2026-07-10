"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.delete_note = exports.list_notes = exports.create_note = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const notes_1 = require("../../../crashlytics/notes");
const filters_1 = require("../../../crashlytics/filters");
const util_1 = require("../../util");
exports.create_note = (0, tool_1.tool)("crashlytics", {
    name: "create_note",
    description: "Add a note to an issue from crashlytics.",
    inputSchema: zod_1.z.object({
        appId: filters_1.ApplicationIdSchema,
        issueId: filters_1.IssueIdSchema,
        note: zod_1.z.string().describe("The note to add to the issue."),
    }),
    annotations: {
        title: "Add note to Crashlytics issue.",
        readOnlyHint: false,
    },
    _meta: {
        requiresAuth: true,
    },
}, async ({ appId, issueId, note }) => {
    if (!appId)
        return (0, util_1.mcpError)(`Must specify 'appId' parameter.`);
    if (!issueId)
        return (0, util_1.mcpError)(`Must specify 'issueId' parameter.`);
    if (!note)
        return (0, util_1.mcpError)(`Must specify 'note' parameter.`);
    return (0, util_1.toContent)(await (0, notes_1.createNote)(appId, issueId, note));
});
exports.list_notes = (0, tool_1.tool)("crashlytics", {
    name: "list_notes",
    description: "Use this to list all notes for an issue in Crashlytics.",
    inputSchema: zod_1.z.object({
        appId: filters_1.ApplicationIdSchema,
        issueId: filters_1.IssueIdSchema,
        pageSize: zod_1.z.number().optional().default(20).describe("Number of rows to return"),
    }),
    annotations: {
        title: "List notes for a Crashlytics issue.",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
    },
}, async ({ appId, issueId, pageSize }) => {
    if (!appId)
        return (0, util_1.mcpError)(`Must specify 'appId' parameter.`);
    if (!issueId)
        return (0, util_1.mcpError)(`Must specify 'issueId' parameter.`);
    return (0, util_1.toContent)(await (0, notes_1.listNotes)(appId, issueId, pageSize));
});
exports.delete_note = (0, tool_1.tool)("crashlytics", {
    name: "delete_note",
    description: "Delete a note from a Crashlytics issue.",
    inputSchema: zod_1.z.object({
        appId: filters_1.ApplicationIdSchema,
        issueId: filters_1.IssueIdSchema,
        noteId: zod_1.z.string().describe("The id of the note to delete"),
    }),
    annotations: {
        title: "Delete Crashlytics Issue Note",
        readOnlyHint: false,
        destructiveHint: true,
    },
    _meta: {
        requiresAuth: true,
    },
}, async ({ appId, issueId, noteId }) => {
    if (!appId)
        return (0, util_1.mcpError)(`Must specify 'appId' parameter.`);
    if (!issueId)
        return (0, util_1.mcpError)(`Must specify 'issueId' parameter.`);
    if (!noteId)
        return (0, util_1.mcpError)(`Must specify 'noteId' parameter.`);
    return (0, util_1.toContent)(await (0, notes_1.deleteNote)(appId, issueId, noteId));
});
