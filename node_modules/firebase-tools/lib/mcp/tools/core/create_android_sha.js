"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.create_android_sha = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const apps_1 = require("../../../management/apps");
function getCertHashType(shaHash) {
    shaHash = shaHash.replace(/:/g, "");
    const shaHashCount = shaHash.length;
    if (shaHashCount === 40)
        return apps_1.ShaCertificateType.SHA_1.toString();
    if (shaHashCount === 64)
        return apps_1.ShaCertificateType.SHA_256.toString();
    return apps_1.ShaCertificateType.SHA_CERTIFICATE_TYPE_UNSPECIFIED.toString();
}
exports.create_android_sha = (0, tool_1.tool)("core", {
    name: "create_android_sha",
    description: "Use this to add the specified SHA certificate hash to the specified Firebase Android App.",
    inputSchema: zod_1.z.object({
        app_id: zod_1.z.string().describe("The Android app ID to add the SHA certificate to."),
        sha_hash: zod_1.z.string().describe("The SHA certificate hash to add (SHA-1 or SHA-256)."),
    }),
    annotations: {
        title: "Add SHA Certificate to Android App",
        destructiveHint: false,
        readOnlyHint: false,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async ({ app_id, sha_hash }, { projectId }) => {
    const certType = getCertHashType(sha_hash);
    const shaCertificate = await (0, apps_1.createAppAndroidSha)(projectId, app_id, {
        shaHash: sha_hash,
        certType,
    });
    return (0, util_1.toContent)({
        ...shaCertificate,
        message: `Successfully added ${certType} certificate to Android app ${app_id}`,
    });
});
