"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.list_apps = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const apps_1 = require("../../../management/apps");
exports.list_apps = (0, tool_1.tool)("core", {
    name: "list_apps",
    description: "Use this to retrieve a list of the Firebase Apps registered in the currently active Firebase project. Firebase Apps can be iOS, Android, or Web.",
    inputSchema: zod_1.z.object({
        platform: zod_1.z
            .enum(["ios", "android", "web", "all"])
            .optional()
            .describe("the specific platform to list (omit to list all platforms)"),
    }),
    annotations: {
        title: "List Firebase Apps",
        readOnlyHint: true,
    },
    _meta: {
        requiresProject: true,
        requiresAuth: true,
    },
}, async ({ platform }, { projectId }) => {
    try {
        const apps = await (0, apps_1.listFirebaseApps)(projectId, !platform || platform === "all" ? apps_1.AppPlatform.ANY : platform.toUpperCase());
        return (0, util_1.toContent)(apps);
    }
    catch (err) {
        const originalMessage = err.original ? `: ${err.original.message}` : "";
        throw new Error(`Failed to list Firebase apps${originalMessage}`);
    }
});
