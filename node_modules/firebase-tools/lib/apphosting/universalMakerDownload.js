"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getOrDownloadUniversalMaker = getOrDownloadUniversalMaker;
const fs = require("fs-extra");
const os = require("os");
const path = require("path");
const error_1 = require("../error");
const downloadUtils = require("../downloadUtils");
const logger_1 = require("../logger");
const universalMakerInfo = require("./universalMakerInfo.json");
const CACHE_DIR = path.join(os.homedir(), ".cache", "firebase", "universal-maker");
const UNIVERSAL_MAKER_UPDATE_DETAILS = universalMakerInfo;
function getPlatformInfo() {
    let platformKey = "";
    if (process.platform === "darwin") {
        if (process.arch === "arm64") {
            platformKey = "darwin_arm64";
        }
        else {
            throw new error_1.FirebaseError("macOS Intel (darwin_x64) is not currently supported for Universal Maker.");
        }
    }
    else if (process.platform === "linux") {
        if (process.arch === "x64") {
            platformKey = "linux_x64";
        }
        else {
            throw new error_1.FirebaseError("Linux ARM (linux_arm64) is not currently supported for Universal Maker.");
        }
    }
    else if (process.platform === "win32") {
        throw new error_1.FirebaseError("Windows (win32) is not currently supported for Universal Maker.");
    }
    else {
        throw new error_1.FirebaseError(`Unsupported platform for Universal Maker: ${process.platform} ${process.arch}`);
    }
    const details = UNIVERSAL_MAKER_UPDATE_DETAILS[platformKey];
    if (!details) {
        throw new error_1.FirebaseError(`Could not find download details for platform: ${platformKey}`);
    }
    return details;
}
async function getOrDownloadUniversalMaker() {
    const details = getPlatformInfo();
    const downloadPath = path.join(CACHE_DIR, details.downloadPathRelativeToCacheDir);
    const hasBinary = fs.existsSync(downloadPath);
    if (hasBinary) {
        logger_1.logger.debug(`[apphosting] Universal Maker binary found at cache: ${downloadPath}`);
        try {
            await downloadUtils.validateSize(downloadPath, details.expectedSize);
            await downloadUtils.validateChecksum(downloadPath, details.expectedChecksumSHA256, "sha256");
            return downloadPath;
        }
        catch (err) {
            logger_1.logger.warn(`[apphosting] Cached Universal Maker binary failed verification: ${err.message}. Proceeding to redownload...`);
        }
    }
    logger_1.logger.info("Downloading Universal Maker, a tool required to build your App Hosting application locally...");
    fs.ensureDirSync(CACHE_DIR);
    let tmpfile;
    try {
        tmpfile = await downloadUtils.downloadToTmp(details.remoteUrl);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to download Universal Maker: ${err.message}`);
    }
    await downloadUtils.validateSize(tmpfile, details.expectedSize);
    await downloadUtils.validateChecksum(tmpfile, details.expectedChecksumSHA256, "sha256");
    fs.copySync(tmpfile, downloadPath);
    fs.chmodSync(downloadPath, 0o755);
    return downloadPath;
}
