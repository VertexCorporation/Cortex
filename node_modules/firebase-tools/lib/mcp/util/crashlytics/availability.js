"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isCrashlyticsAvailable = isCrashlyticsAvailable;
const appUtils_1 = require("../../../appUtils");
const fs = require("fs-extra");
const path = require("path");
async function isCrashlyticsAvailable(ctx) {
    ctx.host.logger.debug("Looking for whether crashlytics is installed...");
    return await isCrashlyticsInstalled(ctx);
}
async function isCrashlyticsInstalled(ctx) {
    const host = ctx.host;
    const projectDir = ctx.config.projectDir;
    const platforms = await (0, appUtils_1.getPlatformsFromFolder)(projectDir);
    if (!platforms.includes(appUtils_1.Platform.FLUTTER) &&
        !platforms.includes(appUtils_1.Platform.ANDROID) &&
        !platforms.includes(appUtils_1.Platform.IOS)) {
        host.logger.debug("Found no supported Crashlytics platforms.");
        return false;
    }
    if (platforms.includes(appUtils_1.Platform.FLUTTER) && (await flutterAppUsesCrashlytics(projectDir))) {
        host.logger.debug("Found Flutter app using Crashlytics");
        return true;
    }
    if (platforms.includes(appUtils_1.Platform.ANDROID) && (await androidAppUsesCrashlytics(projectDir))) {
        host.logger.debug("Found Android app using Crashlytics");
        return true;
    }
    if (platforms.includes(appUtils_1.Platform.IOS) && (await iosAppUsesCrashlytics(projectDir))) {
        host.logger.debug("Found iOS app using Crashlytics");
        return true;
    }
    host.logger.debug(`Found supported platforms ${JSON.stringify(platforms)}, but did not find a Crashlytics dependency.`);
    return false;
}
async function androidAppUsesCrashlytics(appPath) {
    const buildGradleFiles = await (0, appUtils_1.detectFiles)(appPath, "build.gradle*");
    const crashlyticsPattern = /(firebase-crashlytics|firebase\.crashlytics|com\.google\.firebase\.crashlytics)/;
    for (const file of buildGradleFiles) {
        const content = await fs.readFile(path.join(appPath, file), "utf8");
        if (crashlyticsPattern.test(content)) {
            return true;
        }
    }
    return false;
}
async function iosAppUsesCrashlytics(appPath) {
    const filePatternsToDetect = ["Podfile", "Package.swift", "Cartfile*", "project.pbxproj"];
    const fileArrays = await Promise.all(filePatternsToDetect.map((term) => (0, appUtils_1.detectFiles)(appPath, term)));
    const files = fileArrays.flat();
    for (const file of files) {
        const content = await fs.readFile(path.join(appPath, file), "utf8");
        if (content.includes("Crashlytics")) {
            return true;
        }
    }
    return false;
}
async function flutterAppUsesCrashlytics(appPath) {
    const pubspecFiles = await (0, appUtils_1.detectFiles)(appPath, "pubspec.yaml");
    for (const file of pubspecFiles) {
        const content = await fs.readFile(path.join(appPath, file), "utf8");
        if (content.includes("firebase_crashlytics")) {
            return true;
        }
    }
    return false;
}
