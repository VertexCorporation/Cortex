"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deploy = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const deploy_1 = require("../../../deploy");
const util_1 = require("../../util");
const jobs_1 = require("../../util/jobs");
const TARGETS = {
    hosting: null,
    database: null,
    firestore: null,
    functions: null,
    storage: null,
    remoteconfig: null,
    extensions: null,
    dataconnect: null,
    apphosting: null,
    auth: null,
};
exports.deploy = (0, tool_1.tool)("core", {
    name: "deploy",
    description: "Deploy resources to your Firebase project, based on the contents of firebase.json.",
    inputSchema: zod_1.z.object({
        only: zod_1.z
            .string()
            .optional()
            .describe("Comma-separated list of services to deploy. Valid targets are: database, storage, firestore, functions, hosting, remoteconfig, extensions, dataconnect, apphosting, auth."),
    }),
    annotations: {
        title: "Deploy Firebase Services",
        readOnlyHint: false,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
        ui: {
            resourceUri: "ui://core/deploy/mcp-app.html",
        },
    },
}, async ({ only }, ctx) => {
    const validTargets = Object.keys(TARGETS);
    let targets = validTargets;
    if (only) {
        const parts = only.split(",").map((p) => p.trim());
        targets = parts.filter((p) => validTargets.includes(p));
    }
    const jobId = Date.now().toString();
    jobs_1.jobTracker.createJob(jobId);
    const options = {
        only: only || "",
        except: "",
        filteredTargets: targets,
        project: ctx.projectId,
        projectId: ctx.projectId,
        rc: ctx.rc,
        config: ctx.config,
        nonInteractive: true,
        onProgress: (progress) => {
            const phaseNumbers = {
                predeploy: 10,
                prepare: 30,
                deploy: 60,
                release: 80,
                postdeploy: 100,
            };
            const percentage = phaseNumbers[progress.phase] || 0;
            jobs_1.jobTracker.updateJob(jobId, { progress: percentage });
            jobs_1.jobTracker.addLog(jobId, `Deploy [${progress.phase}]: Complete for targets ${(progress.targets || []).join(",")}`);
        },
    };
    void (async () => {
        try {
            const res = await (0, deploy_1.deploy)(targets, options);
            jobs_1.jobTracker.updateJob(jobId, { status: "success", progress: 100, result: res });
        }
        catch (err) {
            const message = err instanceof Error ? err.message : String(err);
            jobs_1.jobTracker.updateJob(jobId, { status: "failed", error: message });
        }
    })();
    const contentRes = (0, util_1.toContent)(`Deployment started with Job ID: ${jobId}. Use deploy_status tool to track.`);
    return {
        ...contentRes,
        structuredContent: { jobId, message: "Deployment started" },
    };
});
