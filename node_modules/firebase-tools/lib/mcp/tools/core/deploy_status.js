"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deploy_status = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const jobs_1 = require("../../util/jobs");
exports.deploy_status = (0, tool_1.tool)("core", {
    name: "deploy_status",
    description: "Check the status of a background deployment job using its Job ID.",
    inputSchema: zod_1.z.object({
        jobId: zod_1.z.string().describe("The Job ID returned by the deploy tool"),
    }),
    annotations: {
        title: "Check Deployment Status",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async ({ jobId }) => {
    const job = jobs_1.jobTracker.getJob(jobId);
    if (!job) {
        return (0, util_1.mcpError)(`Job not found: ${jobId}`);
    }
    const contentRes = (0, util_1.toContent)(`Job ID: ${jobId}\nStatus: ${job.status}\nProgress: ${job.progress}%\n\nLogs:\n${job.logs.join("\n")}`);
    return {
        ...contentRes,
        structuredContent: job,
    };
});
