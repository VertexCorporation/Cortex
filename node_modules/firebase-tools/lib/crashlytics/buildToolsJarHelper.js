"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchBuildtoolsJar = fetchBuildtoolsJar;
exports.runBuildtoolsCommand = runBuildtoolsCommand;
const fs = require("fs-extra");
const os = require("os");
const path = require("path");
const spawn = require("cross-spawn");
const downloadUtils = require("../downloadUtils");
const error_1 = require("../error");
const logger_1 = require("../logger");
const utils = require("../utils");
const JAR_CACHE_DIR = process.env.FIREBASE_CRASHLYTICS_BUILDTOOLS_PATH ||
    path.join(os.homedir(), ".cache", "firebase", "crashlytics", "buildtools");
const JAR_VERSION = "3.0.3";
const JAR_URL = `https://dl.google.com/android/maven2/com/google/firebase/firebase-crashlytics-buildtools/${JAR_VERSION}/firebase-crashlytics-buildtools-${JAR_VERSION}.jar`;
async function fetchBuildtoolsJar() {
    if (process.env.CRASHLYTICS_LOCAL_JAR) {
        logger_1.logger.debug(`Using local Crashlytics Jar override at ${process.env.CRASHLYTICS_LOCAL_JAR}`);
        return process.env.CRASHLYTICS_LOCAL_JAR;
    }
    const jarPath = path.join(JAR_CACHE_DIR, `crashlytics-buildtools-${JAR_VERSION}.jar`);
    if (fs.existsSync(jarPath)) {
        logger_1.logger.debug(`Buildtools Jar already downloaded at ${jarPath}`);
        return jarPath;
    }
    if (fs.existsSync(JAR_CACHE_DIR)) {
        logger_1.logger.debug(`Deleting Jar cache at ${JAR_CACHE_DIR} because the CLI was run with a newer Jar version`);
        fs.rmSync(JAR_CACHE_DIR, { recursive: true, force: true });
    }
    utils.logBullet("Downloading crashlytics-buildtools.jar to " + jarPath);
    utils.logBullet("For open source licenses used by this command, look in the META-INF directory in the buildtools.jar file");
    const tmpfile = await downloadUtils.downloadToTmp(JAR_URL);
    fs.mkdirSync(JAR_CACHE_DIR, { recursive: true });
    fs.copySync(tmpfile, jarPath);
    return jarPath;
}
function runBuildtoolsCommand(jarFile, args, debug) {
    const fullArgs = ["-jar", jarFile, ...args, "-clientName", "firebase-cli;crashlytics-buildtools"];
    const outputs = spawn.sync("java", fullArgs, {
        stdio: debug ? "inherit" : "pipe",
    });
    if (outputs.status !== 0) {
        if (!debug) {
            utils.logWarning(outputs.stdout?.toString() || "An unknown error occurred");
        }
        throw new error_1.FirebaseError(`java command failed with args: ${fullArgs}`);
    }
}
