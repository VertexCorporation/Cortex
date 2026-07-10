"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_report = void 0;
const js_yaml_1 = require("js-yaml");
const filters_1 = require("../../../crashlytics/filters");
const reports_1 = require("../../../crashlytics/reports");
const tool_1 = require("../../tool");
const app_id_1 = require("../../resources/guides/app_id");
const DUMP_OPTIONS = { lineWidth: 200 };
const REPORT_ERROR_CONTENT = `
Must specify the desired report:
  * TOP_ISSUES - metrics grouped by *issue*.
  * TOP_VARIANTS - metrics grouped by issue *variant*
  * TOP_VERSIONS - metrics grouped by *version*
  * TOP_OPERATING_SYSTEMS - metrics grouped by *operating system*
  * TOP_ANDROID_DEVICES - metrics grouped by *device*
  * TOP_APPLE_DEVICES - metrics grouped by *device*
`.trim();
function toText(response, filters) {
    const result = {
        name: response.name || "",
        filters: (0, js_yaml_1.dump)(filters, DUMP_OPTIONS),
    };
    for (const [key, value] of Object.entries(response)) {
        if (key === "name") {
            continue;
        }
        result[key] = (0, js_yaml_1.dump)(value, DUMP_OPTIONS);
    }
    return result;
}
exports.get_report = (0, tool_1.tool)("crashlytics", {
    name: "get_report",
    description: `Use this to request numerical reports from Crashlytics. The result aggregates the sum of events and impacted users, grouped by a dimension appropriate for that report. Agents must read the [Firebase Crashlytics Reports Guide](firebase://guides/crashlytics/reports) using the \`firebase_read_resources\` tool before calling to understand critical prerequisites for requesting reports and how to interpret the results.
    `.trim(),
    inputSchema: reports_1.ReportInputSchema,
    annotations: {
        title: "Get Crashlytics Report",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
    },
}, async ({ appId, report, pageSize, filter }) => {
    const result = { content: [] };
    if (!report) {
        result.isError = true;
        result.content.push({ type: "text", text: `Error: ${REPORT_ERROR_CONTENT}` });
    }
    if (!appId) {
        result.isError = true;
        result.content.push({ type: "text", text: "Must specify 'appId' parameter" });
        result.content.push({ type: "text", text: app_id_1.RESOURCE_CONTENT });
    }
    try {
        filter = (0, filters_1.validateEventFilters)(filter || {});
    }
    catch (error) {
        result.isError = true;
        result.content.push({ type: "text", text: `Error: ${error.message}` });
    }
    if (result.content.length > 0) {
        return result;
    }
    const reportResponse = (0, reports_1.simplifyReport)(await (0, reports_1.getReport)(report, appId, filter, pageSize));
    reportResponse.usage =
        reportResponse.groups && reportResponse.groups.length
            ? reportResponse.usage || ""
            : "This report response contains no results.";
    return {
        content: [
            {
                type: "text",
                text: (0, js_yaml_1.dump)(toText(reportResponse, filter), DUMP_OPTIONS),
            },
        ],
    };
});
