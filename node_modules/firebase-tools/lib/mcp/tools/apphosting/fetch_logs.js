"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetch_logs = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const apphosting_1 = require("../../../gcp/apphosting");
const utils_1 = require("../../../utils");
const error_1 = require("../../../error");
const run_1 = require("../../../gcp/run");
const cloudlogging_1 = require("../../../gcp/cloudlogging");
exports.fetch_logs = (0, tool_1.tool)("apphosting", {
    name: "fetch_logs",
    description: "Use this to fetch the most recent logs for a specified App Hosting backend. If `buildLogs` is specified, the logs from the build process for the latest build are returned. The most recent logs are listed first.",
    inputSchema: zod_1.z.object({
        buildLogs: zod_1.z
            .boolean()
            .default(false)
            .describe("If specified, the logs for the most recent build will be returned instead of the logs for the service. The build logs are returned 'in order', to be read from top to bottom."),
        backendId: zod_1.z.string().describe("The ID of the backend for which to fetch logs."),
        location: zod_1.z
            .string()
            .describe("The specific region for the backend. By default, if a backend is uniquely named across all locations, that one will be used."),
    }),
    annotations: {
        title: "Fetch logs for App Hosting backends and builds.",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async ({ buildLogs, backendId, location }, { projectId }) => {
    location || (location = "");
    if (!backendId) {
        return (0, util_1.toContent)(`backendId must be specified.`);
    }
    const backend = await (0, apphosting_1.getBackend)(projectId, location, backendId);
    const traffic = await (0, apphosting_1.getTraffic)(projectId, location, backendId);
    const data = { ...backend, traffic };
    if (buildLogs) {
        const builds = await (0, apphosting_1.listBuilds)(projectId, location, backendId);
        builds.builds.sort((a, b) => new Date(a.createTime).getTime() - new Date(b.createTime).getTime());
        const build = (0, utils_1.last)(builds.builds);
        const r = new RegExp(`region=${location}/([0-9a-f-]+)?`);
        const match = r.exec(build.buildLogsUri ?? "");
        if (!match) {
            throw new error_1.FirebaseError("Unable to determine the build ID.");
        }
        const buildId = match[1];
        const thirtyDaysAgo = new Date();
        thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
        const timestampFilter = `timestamp >= "${thirtyDaysAgo.toISOString()}"`;
        const filter = `resource.type="build" resource.labels.build_id="${buildId}" ${timestampFilter}`;
        const { entries } = await (0, cloudlogging_1.listEntries)(projectId, filter, 100, "asc");
        if (!entries.length) {
            return (0, util_1.toContent)("No logs found.");
        }
        return (0, util_1.toContent)(entries);
    }
    const serviceName = (0, utils_1.last)(data.managedResources)?.runService.service;
    if (!serviceName) {
        throw new error_1.FirebaseError("Unable to get service name from managedResources.");
    }
    const serviceId = (0, utils_1.last)(serviceName.split("/"));
    const logs = await (0, run_1.fetchServiceLogs)(projectId, serviceId);
    return (0, util_1.toContent)(logs);
});
