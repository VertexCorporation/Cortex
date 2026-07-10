"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_sdk_config = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const apps_1 = require("../../../management/apps");
exports.get_sdk_config = (0, tool_1.tool)("core", {
    name: "get_sdk_config",
    description: "Use this to retrieve the Firebase configuration information for a Firebase App. " +
        "You must specify EITHER a platform OR the Firebase App ID for a Firebase App registered in the currently active Firebase Project.",
    inputSchema: zod_1.z.object({
        platform: zod_1.z
            .enum(["ios", "android", "web"])
            .optional()
            .describe("The platform for which you want config. One of 'platform' or 'app_id' must be provided."),
        app_id: zod_1.z
            .string()
            .optional()
            .describe("The specific app ID to fetch. One of 'platform' or 'app_id' must be provided."),
    }),
    annotations: {
        title: "Get Firebase SDK Config",
        readOnlyHint: true,
    },
    _meta: {
        requiresProject: true,
        requiresAuth: true,
    },
}, async ({ platform: inputPlatform, app_id: appId }, { projectId }) => {
    let platform = inputPlatform?.toUpperCase();
    if (!platform && !appId)
        return (0, util_1.mcpError)("Must specify one of 'web', 'ios', or 'android' for platform or an app_id for get_sdk_config tool.");
    const apps = await (0, apps_1.listFirebaseApps)(projectId, platform ?? apps_1.AppPlatform.ANY);
    platform = platform || apps.find((app) => app.appId === appId)?.platform;
    appId = appId || apps.find((app) => app.platform === platform)?.appId;
    if (!appId)
        return (0, util_1.mcpError)(`Could not find an app for platform '${inputPlatform}' in project '${projectId}'`);
    const sdkConfig = await (0, apps_1.getAppConfig)(appId, platform);
    if ("configFilename" in sdkConfig) {
        return {
            content: [
                {
                    type: "text",
                    text: `SDK config content for \`${sdkConfig.configFilename}\`:\n\n\`\`\`\n${Buffer.from(sdkConfig.configFileContents, "base64").toString("utf-8")}\n\`\`\``,
                },
            ],
        };
    }
    return (0, util_1.toContent)(sdkConfig, { format: "json" });
});
