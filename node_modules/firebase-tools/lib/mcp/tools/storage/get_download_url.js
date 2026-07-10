"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_object_download_url = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const storage_1 = require("../../../gcp/storage");
const types_1 = require("../../../emulator/types");
exports.get_object_download_url = (0, tool_1.tool)("storage", {
    name: "get_object_download_url",
    description: "Use this to retrieve the download URL for an object in a Cloud Storage for Firebase bucket.",
    inputSchema: zod_1.z.object({
        bucket: zod_1.z
            .string()
            .optional()
            .describe("The bucket name in Firebase Storage. If not provided, defaults to the project's default bucket (e.g., `{projectid}.firebasestorage.app`)."),
        object_path: zod_1.z
            .string()
            .describe("The path to the object in Firebase storage without the bucket name attached"),
        use_emulator: zod_1.z.boolean().default(false).describe("Target the Storage emulator if true."),
    }),
    annotations: {
        title: "Get Storage Object Download URL",
        readOnlyHint: true,
    },
    _meta: {
        requiresProject: true,
        requiresAuth: true,
    },
}, async ({ bucket, object_path, use_emulator }, { projectId, host }) => {
    if (!bucket) {
        bucket = `${projectId}.firebasestorage.app`;
    }
    let emulatorUrl;
    if (use_emulator) {
        emulatorUrl = await host.getEmulatorUrl(types_1.Emulators.STORAGE);
    }
    const downloadUrl = await (0, storage_1.getDownloadUrl)(bucket, object_path, emulatorUrl);
    return (0, util_1.toContent)(downloadUrl);
});
