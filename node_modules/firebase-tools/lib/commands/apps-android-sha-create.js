"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const apps_1 = require("../management/apps");
const requireAuth_1 = require("../requireAuth");
const utils_1 = require("../utils");
function getCertHashType(shaHash) {
    shaHash = shaHash.replace(/:/g, "");
    const shaHashCount = shaHash.length;
    if (shaHashCount === 40)
        return apps_1.ShaCertificateType.SHA_1.toString();
    if (shaHashCount === 64)
        return apps_1.ShaCertificateType.SHA_256.toString();
    return apps_1.ShaCertificateType.SHA_CERTIFICATE_TYPE_UNSPECIFIED.toString();
}
exports.command = new command_1.Command("apps:android:sha:create <appId> <shaHash>")
    .description("add a SHA certificate hash for a given app id")
    .before(requireAuth_1.requireAuth)
    .action(async (appId = "", shaHash = "", options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const shaCertificate = await (0, utils_1.promiseWithSpinner)(async () => await (0, apps_1.createAppAndroidSha)(projectId, appId, {
        shaHash: shaHash,
        certType: getCertHashType(shaHash),
    }), `Creating Android SHA certificate ${clc.bold(options.shaHash)}with Android app Id ${clc.bold(appId)}`);
    return shaCertificate;
});
