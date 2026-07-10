"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Distribution = exports.DistributionFileType = void 0;
exports.upload = upload;
exports.awaitTestResults = awaitTestResults;
const fs = require("fs-extra");
const logger_1 = require("../logger");
const pathUtil = require("path");
const utils = require("../utils");
const types_1 = require("../appdistribution/types");
const error_1 = require("../error");
const TEST_MAX_POLLING_RETRIES = 40;
const TEST_POLLING_INTERVAL_MILLIS = 30000;
var DistributionFileType;
(function (DistributionFileType) {
    DistributionFileType["IPA"] = "ipa";
    DistributionFileType["APK"] = "apk";
    DistributionFileType["AAB"] = "aab";
})(DistributionFileType || (exports.DistributionFileType = DistributionFileType = {}));
async function upload(requests, appName, distribution) {
    utils.logBullet("uploading binary...");
    try {
        const operationName = await requests.uploadRelease(appName, distribution);
        const uploadResponse = await requests.pollUploadStatus(operationName);
        const release = uploadResponse.release;
        switch (uploadResponse.result) {
            case types_1.UploadReleaseResult.RELEASE_CREATED:
                utils.logSuccess(`uploaded new release ${release.displayVersion} (${release.buildVersion}) successfully!`);
                break;
            case types_1.UploadReleaseResult.RELEASE_UPDATED:
                utils.logSuccess(`uploaded update to existing release ${release.displayVersion} (${release.buildVersion}) successfully!`);
                break;
            case types_1.UploadReleaseResult.RELEASE_UNMODIFIED:
                utils.logSuccess(`re-uploaded already existing release ${release.displayVersion} (${release.buildVersion}) successfully!`);
                break;
            default:
                utils.logSuccess(`uploaded release ${release.displayVersion} (${release.buildVersion}) successfully!`);
        }
        utils.logSuccess(`View this release in the Firebase console: ${release.firebaseConsoleUri}`);
        utils.logSuccess(`Share this release with testers who have access: ${release.testingUri}`);
        utils.logSuccess(`Download the release binary (link expires in 1 hour): ${release.binaryDownloadUri}`);
        return uploadResponse.release;
    }
    catch (err) {
        if ((0, error_1.getErrStatus)(err) === 404) {
            throw new error_1.FirebaseError(`App Distribution could not find your app ${appName}. ` +
                `Make sure to onboard your app by pressing the "Get started" ` +
                "button on the App Distribution page in the Firebase console: " +
                "https://console.firebase.google.com/project/_/appdistribution", { exit: 1 });
        }
        throw new error_1.FirebaseError(`Failed to upload release. ${(0, error_1.getErrMsg)(err)}`, { exit: 1 });
    }
}
class Distribution {
    constructor(path) {
        this.path = path;
        if (!path) {
            throw new error_1.FirebaseError("must specify a release binary file");
        }
        const distributionType = path.split(".").pop();
        if (distributionType !== DistributionFileType.IPA &&
            distributionType !== DistributionFileType.APK &&
            distributionType !== DistributionFileType.AAB) {
            throw new error_1.FirebaseError("Unsupported file format, should be .ipa, .apk or .aab");
        }
        let stat;
        try {
            stat = fs.statSync(path);
        }
        catch (err) {
            logger_1.logger.info((0, error_1.getErrMsg)(err));
            throw new error_1.FirebaseError(`File ${path} does not exist: verify that file points to a binary`);
        }
        if (!stat.isFile()) {
            throw new error_1.FirebaseError(`${path} is not a file. Verify that it points to a binary.`);
        }
        this.path = path;
        this.fileType = distributionType;
        this.fileName = pathUtil.basename(path);
    }
    distributionFileType() {
        return this.fileType;
    }
    readStream() {
        return fs.createReadStream(this.path);
    }
    getFileName() {
        return this.fileName;
    }
}
exports.Distribution = Distribution;
async function awaitTestResults(releaseTests, requests) {
    const releaseTestNames = new Set(releaseTests.map((rt) => rt.name).filter((n) => !!n));
    for (let i = 0; i < TEST_MAX_POLLING_RETRIES; i++) {
        utils.logBullet(`${releaseTestNames.size} automated test results are pending...`);
        await delay(TEST_POLLING_INTERVAL_MILLIS);
        for (const releaseTestName of releaseTestNames) {
            const releaseTest = await requests.getReleaseTest(releaseTestName);
            if (releaseTest.deviceExecutions.every((e) => e.state === "PASSED")) {
                releaseTestNames.delete(releaseTestName);
                if (releaseTestNames.size === 0) {
                    utils.logSuccess("Automated test(s) passed!");
                    return;
                }
                else {
                    continue;
                }
            }
            for (const execution of releaseTest.deviceExecutions) {
                const device = deviceToString(execution.device);
                switch (execution.state) {
                    case "PASSED":
                    case "IN_PROGRESS":
                        continue;
                    case "FAILED":
                        throw new error_1.FirebaseError(`Automated test failed for ${device}: ${execution.failedReason}`, { exit: 1 });
                    case "INCONCLUSIVE":
                        throw new error_1.FirebaseError(`Automated test inconclusive for ${device}: ${execution.inconclusiveReason}`, { exit: 1 });
                    default:
                        throw new error_1.FirebaseError(`Unsupported automated test state for ${device}: ${execution.state}`, { exit: 1 });
                }
            }
        }
    }
    throw new error_1.FirebaseError("It took longer than expected to run your test(s), please try again.", {
        exit: 1,
    });
}
function delay(ms) {
    return new Promise((resolve) => setTimeout(resolve, ms));
}
function deviceToString(device) {
    return `${device.model} (${device.version}/${device.orientation}/${device.locale})`;
}
