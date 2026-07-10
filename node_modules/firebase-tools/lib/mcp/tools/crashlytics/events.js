"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.batch_get_events = exports.list_events = void 0;
const js_yaml_1 = require("js-yaml");
const zod_1 = require("zod");
const events_1 = require("../../../crashlytics/events");
const filters_1 = require("../../../crashlytics/filters");
const types_1 = require("../../../crashlytics/types");
const app_id_1 = require("../../resources/guides/app_id");
const tool_1 = require("../../tool");
const DUMP_OPTIONS = { lineWidth: 200 };
function formatFrames(origFrames, maxFrames = 20) {
    const frames = origFrames || [];
    const shouldTruncate = frames.length > maxFrames;
    const framesToFormat = shouldTruncate ? frames.slice(0, maxFrames - 1) : frames;
    const formatted = framesToFormat.map((frame) => {
        let line = `at`;
        if (frame.symbol) {
            line += ` ${frame.symbol}`;
        }
        if (frame.file) {
            line += ` (${frame.file}`;
            if (frame.line) {
                line += `:${frame.line}`;
            }
            line += ")";
        }
        return line;
    });
    if (shouldTruncate) {
        formatted.push("... frames omitted ...");
    }
    return formatted;
}
function toText(event) {
    if (!event) {
        return {};
    }
    const result = {};
    for (const [key, value] of Object.entries(event)) {
        if (key === "logs") {
            const logs = value || [];
            const slicedLogs = logs.length > 100 ? logs.slice(logs.length - 100) : logs;
            const logLines = slicedLogs.map((log) => `[${log.logTime}] ${log.message}`);
            result["logs"] = logLines.join("\n");
        }
        else if (key === "breadcrumbs") {
            const breadcrumbs = value || [];
            const slicedBreadcrumbs = breadcrumbs.length > 10 ? breadcrumbs.slice(-10) : breadcrumbs;
            const breadcrumbLines = slicedBreadcrumbs.map((b) => {
                const paramString = Object.entries(b?.params || {})
                    .map(([k, v]) => `${k}: ${v}`)
                    .join(", ");
                const params = paramString ? ` { ${paramString} }` : "";
                return `[${b.eventTime}] ${b.title}${params}`;
            });
            result["breadcrumbs"] = breadcrumbLines.join("\n");
        }
        else if (key === "threads") {
            let threads = value || [];
            if (event.issue?.errorType === types_1.ErrorType.FATAL || event.issue?.errorType === types_1.ErrorType.ANR) {
                threads = threads.filter((t) => t.crashed || t.blamed);
            }
            const threadStrings = threads.map((thread) => {
                const header = `Thread: ${thread.name || thread.threadId || ""}${thread.crashed ? " (crashed)" : ""}`;
                const frameStrings = formatFrames(thread.frames || []);
                return [header, ...frameStrings].join("\n");
            });
            result["threads"] = threadStrings.join("\n\n");
        }
        else if (key === "exceptions") {
            const exceptions = value || [];
            const exceptionStrings = exceptions.map((exception) => {
                const header = exception.nested ? "Caused by: " : "";
                const exceptionHeader = `${header}${exception.type || ""}: ${exception.exceptionMessage || ""}`;
                const frameStrings = formatFrames(exception.frames || []);
                return [exceptionHeader, ...frameStrings].join("\n");
            });
            result["exceptions"] = exceptionStrings.join("\n\n");
        }
        else if (key === "errors") {
            const errors = value || [];
            const errorStrings = errors.map((error) => {
                const header = `Error: ${error.title || "error"}`;
                const frameStrings = formatFrames(error.frames || []);
                return [header, ...frameStrings].join("\n");
            });
            result["errors"] = errorStrings.join("\n\n");
        }
        else {
            result[key] = (0, js_yaml_1.dump)(value, DUMP_OPTIONS);
        }
    }
    return result;
}
exports.list_events = (0, tool_1.tool)("crashlytics", {
    name: "list_events",
    description: `Use this to list the most recent events matching the given filters.
      Can be used to fetch sample crashes and exceptions for an issue,
      which will include stack traces and other data useful for debugging.`,
    inputSchema: zod_1.z.object({
        appId: filters_1.ApplicationIdSchema,
        filter: filters_1.EventFilterSchema,
        pageSize: zod_1.z.number().describe("Number of rows to return").default(1),
    }),
    annotations: {
        title: "List Crashlytics Events",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
    },
}, async ({ appId, filter, pageSize }) => {
    const result = { content: [] };
    if (!appId) {
        result.isError = true;
        result.content.push({ type: "text", text: "Must specify 'appId' parameter" });
        result.content.push({ type: "text", text: app_id_1.RESOURCE_CONTENT });
    }
    if (!filter || (!filter.issueId && !filter.issueVariantId)) {
        result.isError = true;
        result.content.push({
            type: "text",
            text: `Must specify 'filter.issueId' or 'filter.issueVariantId' parameters.`,
        });
    }
    if (result.content.length > 0) {
        return result;
    }
    const response = await (0, events_1.listEvents)(appId, filter, pageSize);
    const eventsContent = response.events?.map((e) => toText(e)) || [];
    return {
        content: [{ type: "text", text: (0, js_yaml_1.dump)(eventsContent, DUMP_OPTIONS) }],
    };
});
exports.batch_get_events = (0, tool_1.tool)("crashlytics", {
    name: "batch_get_events",
    description: `Gets specific events by resource name.
      Can be used to fetch sample crashes and exceptions for an issue,
      which will include stack traces and other data useful for debugging.`,
    inputSchema: zod_1.z.object({
        appId: filters_1.ApplicationIdSchema,
        names: zod_1.z
            .array(zod_1.z.string())
            .describe("An array of the event resource names, as found in the sampleEvent field in reports."),
    }),
    annotations: {
        title: "Batch Get Crashlytics Events",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
    },
}, async ({ appId, names }) => {
    const result = { content: [] };
    if (!appId) {
        result.isError = true;
        result.content.push({ type: "text", text: "Must specify 'appId' parameter." });
        result.content.push({ type: "text", text: app_id_1.RESOURCE_CONTENT });
    }
    if (!names || names.length === 0) {
        result.isError = true;
        result.content.push({
            type: "text",
            text: "Must provide event resource names in name parameter.",
        });
    }
    if (result.content.length > 0) {
        return result;
    }
    const response = await (0, events_1.batchGetEvents)(appId, names);
    const eventsContent = response.events?.map((e) => toText(e)) || [];
    return {
        content: [{ type: "text", text: (0, js_yaml_1.dump)(eventsContent, DUMP_OPTIONS) }],
    };
});
