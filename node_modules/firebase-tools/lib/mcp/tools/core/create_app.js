"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.create_app = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const apps_1 = require("../../../management/apps");
const CREATE_APP_OUTUT_PREFIX = "Created app with the following details:\n\n";
const CREATE_APP_OUTUT_SUFFIX = "\n\nTo fetch the SDK configuration for this app, use the firebase_get_sdk_config tool.";
exports.create_app = (0, tool_1.tool)("core", {
    name: "create_app",
    description: "Use this to create a new Firebase App in the currently active Firebase Project. Firebase Apps can be iOS, Android, or Web.",
    inputSchema: zod_1.z.object({
        display_name: zod_1.z
            .string()
            .optional()
            .describe("The user-friendly display name for your app. If not provided, a default name may be generated."),
        platform: zod_1.z
            .enum(["web", "ios", "android"])
            .describe("The platform for which to create an app."),
        android_config: zod_1.z
            .object({
            package_name: zod_1.z
                .string()
                .describe("The package name for your Android app (e.g., com.example.myapp)."),
        })
            .optional()
            .describe("Configuration for Android apps. Required if platform is 'android'."),
        ios_config: zod_1.z
            .object({
            bundle_id: zod_1.z
                .string()
                .describe("The bundle ID for your iOS app (e.g., com.example.myapp)."),
            app_store_id: zod_1.z.string().optional().describe("The App Store ID for your iOS app."),
        })
            .optional()
            .describe("Configuration for iOS apps. Required if platform is 'ios'."),
    }),
    annotations: {
        title: "Create Firebase App",
        destructiveHint: false,
        readOnlyHint: false,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async ({ display_name, platform, android_config, ios_config }, { projectId }) => {
    if (platform === "android" && !android_config) {
        throw new Error("Android configuration is required when platform is 'android'");
    }
    if (platform === "ios" && !ios_config) {
        throw new Error("iOS configuration is required when platform is 'ios'");
    }
    try {
        switch (platform) {
            case "android":
                return (0, util_1.toContent)(await (0, apps_1.createAndroidApp)(projectId, {
                    displayName: display_name,
                    packageName: android_config.package_name,
                }), {
                    format: "yaml",
                    contentPrefix: CREATE_APP_OUTUT_PREFIX,
                    contentSuffix: CREATE_APP_OUTUT_SUFFIX,
                });
            case "ios":
                return (0, util_1.toContent)(await (0, apps_1.createIosApp)(projectId, {
                    displayName: display_name,
                    bundleId: ios_config.bundle_id,
                    appStoreId: ios_config.app_store_id,
                }), {
                    format: "yaml",
                    contentPrefix: CREATE_APP_OUTUT_PREFIX,
                    contentSuffix: CREATE_APP_OUTUT_SUFFIX,
                });
            case "web":
                return (0, util_1.toContent)(await (0, apps_1.createWebApp)(projectId, {
                    displayName: display_name,
                }), {
                    format: "yaml",
                    contentPrefix: CREATE_APP_OUTUT_PREFIX,
                    contentSuffix: CREATE_APP_OUTUT_SUFFIX,
                });
        }
    }
    catch (err) {
        const originalMessage = err.original ? `: ${err.original.message}` : "";
        throw new Error(`${err.message}\nOriginal error: ${originalMessage}`);
    }
});
