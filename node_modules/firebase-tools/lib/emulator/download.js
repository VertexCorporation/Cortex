"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.downloadEmulator = downloadEmulator;
exports.downloadExtensionVersion = downloadExtensionVersion;
const fs = require("fs-extra");
const path = require("path");
const tmp = require("tmp");
const emulatorLogger_1 = require("./emulatorLogger");
const error_1 = require("../error");
const unzip_1 = require("../unzip");
const downloadableEmulators = require("./downloadableEmulators");
const downloadUtils = require("../downloadUtils");
tmp.setGracefulCleanup();
async function downloadEmulator(name) {
    const emulator = downloadableEmulators.getDownloadDetails(name);
    if (emulator.localOnly) {
        emulatorLogger_1.EmulatorLogger.forEmulator(name).logLabeled("WARN", name, `Env variable override detected, skipping download. Using ${emulator} emulator at ${emulator.binaryPath}`);
        return;
    }
    const overrideVersion = downloadableEmulators.emulatorVersionOverride(name);
    if (overrideVersion) {
        emulatorLogger_1.EmulatorLogger.forEmulator(name).logLabeled("WARN", name, `Env variable override detected. Using custom ${name} emulator version ${overrideVersion}.`);
    }
    emulatorLogger_1.EmulatorLogger.forEmulator(name).logLabeled("BULLET", name, `downloading ${path.basename(emulator.downloadPath)}...`);
    fs.ensureDirSync(emulator.opts.cacheDir);
    let tmpfile;
    try {
        tmpfile = await downloadUtils.downloadToTmp(emulator.opts.remoteUrl, !!emulator.opts.auth);
    }
    catch (err) {
        if (overrideVersion && err instanceof error_1.FirebaseError && err.status === 404) {
            throw new error_1.FirebaseError(`env variable ${name.toUpperCase()}_EMULATOR_VERSION set to ${overrideVersion}, 
        but no such version of ${name} was found. Please double check the version number, or unset this environment variable to use the latest default.`);
        }
        throw err;
    }
    if (!emulator.opts.skipChecksumAndSize) {
        await downloadUtils.validateSize(tmpfile, emulator.opts.expectedSize);
        await downloadUtils.validateChecksum(tmpfile, emulator.opts.expectedChecksum, "md5");
    }
    if (emulator.opts.skipCache) {
        removeOldFiles(name, emulator, true);
    }
    fs.copySync(tmpfile, emulator.downloadPath);
    if (emulator.unzipDir) {
        await (0, unzip_1.unzip)(emulator.downloadPath, emulator.unzipDir);
    }
    const executablePath = emulator.binaryPath || emulator.downloadPath;
    fs.chmodSync(executablePath, 0o755);
    removeOldFiles(name, emulator);
}
async function downloadExtensionVersion(extensionVersionRef, sourceDownloadUri, targetDir) {
    const emulatorLogger = emulatorLogger_1.EmulatorLogger.forExtension({ ref: extensionVersionRef });
    emulatorLogger.logLabeled("BULLET", "extensions", `Starting download for ${extensionVersionRef} source code to ${targetDir}..`);
    try {
        fs.mkdirSync(targetDir);
    }
    catch (err) {
        emulatorLogger.logLabeled("BULLET", "extensions", `cache directory for ${extensionVersionRef} already exists...`);
    }
    emulatorLogger.logLabeled("BULLET", "extensions", `downloading ${sourceDownloadUri}...`);
    const sourceCodeZip = await downloadUtils.downloadToTmp(sourceDownloadUri);
    await (0, unzip_1.unzip)(sourceCodeZip, targetDir);
    fs.chmodSync(targetDir, 0o755);
    emulatorLogger.logLabeled("BULLET", "extensions", `Downloaded to ${targetDir}...`);
    await new Promise((resolve) => setTimeout(resolve, 1000));
}
function removeOldFiles(name, emulator, removeAllVersions = false) {
    const currentLocalPath = emulator.downloadPath;
    const currentUnzipPath = emulator.unzipDir;
    const files = fs.readdirSync(emulator.opts.cacheDir);
    for (const file of files) {
        const fullFilePath = path.join(emulator.opts.cacheDir, file);
        if (file.indexOf(emulator.opts.namePrefix) < 0) {
            continue;
        }
        if ((fullFilePath !== currentLocalPath && fullFilePath !== currentUnzipPath) ||
            removeAllVersions) {
            emulatorLogger_1.EmulatorLogger.forEmulator(name).logLabeled("BULLET", name, `Removing outdated emulator files: ${file}`);
            fs.removeSync(fullFilePath);
        }
    }
}
