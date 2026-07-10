"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Framework = exports.Platform = void 0;
exports.appDescription = appDescription;
exports.getPlatformsFromFolder = getPlatformsFromFolder;
exports.detectApps = detectApps;
exports.getAllDepsFromPackageJson = getAllDepsFromPackageJson;
exports.extractAppIdentifiersFlutter = extractAppIdentifiersFlutter;
exports.extractAppIdentifierIos = extractAppIdentifierIos;
exports.extractAppIdentifiersAndroid = extractAppIdentifiersAndroid;
exports.detectFiles = detectFiles;
const fs = require("fs-extra");
const path = require("path");
const glob_1 = require("glob");
var Platform;
(function (Platform) {
    Platform["ANDROID"] = "ANDROID";
    Platform["WEB"] = "WEB";
    Platform["IOS"] = "IOS";
    Platform["FLUTTER"] = "FLUTTER";
    Platform["ADMIN_NODE"] = "ADMIN_NODE";
})(Platform || (exports.Platform = Platform = {}));
var Framework;
(function (Framework) {
    Framework["REACT"] = "react";
    Framework["ANGULAR"] = "angular";
})(Framework || (exports.Framework = Framework = {}));
function appDescription(a) {
    return `${a.directory} (${a.platform.toLowerCase()})`;
}
async function getPlatformsFromFolder(dirPath) {
    const apps = await detectApps(dirPath);
    return [...new Set(apps.map((app) => app.platform))];
}
async function detectApps(dirPath) {
    const [packageJsonFiles, pubSpecYamlFiles, srcMainFolders, xCodeProjects] = await Promise.all([
        detectFiles(dirPath, "package.json"),
        detectFiles(dirPath, "pubspec.yaml"),
        detectFiles(dirPath, "src/main/"),
        detectFiles(dirPath, "*.xcodeproj/"),
    ]);
    const [adminAndWebApps, flutterApps, androidAppsRaw, iosAppsRaw] = await Promise.all([
        Promise.all(packageJsonFiles.map((p) => packageJsonToAdminOrWebApp(dirPath, p))).then((r) => r.flat()),
        Promise.all(pubSpecYamlFiles.map((f) => processFlutterDir(dirPath, f))).then((r) => r.flat()),
        Promise.all(srcMainFolders.map((f) => processAndroidDir(dirPath, f))).then((r) => r.flat()),
        Promise.all(xCodeProjects.map((f) => processIosDir(dirPath, f))).then((r) => r.flat()),
    ]);
    const androidApps = androidAppsRaw.filter((a) => !flutterApps.some((f) => isPathInside(f.directory, a.directory)));
    const iosApps = iosAppsRaw.filter((a) => !flutterApps.some((f) => isPathInside(f.directory, a.directory)));
    return [...flutterApps, ...androidApps, ...iosApps, ...adminAndWebApps];
}
async function processIosDir(dirPath, filePath) {
    const iosDir = path.dirname(filePath);
    const iosAppIds = await detectAppIdsForPlatform(dirPath, Platform.IOS);
    if (iosAppIds.length === 0) {
        return [
            {
                platform: Platform.IOS,
                directory: iosDir,
            },
        ];
    }
    const iosApps = await Promise.all(iosAppIds.map((app) => ({
        platform: Platform.IOS,
        directory: iosDir,
        appId: app.appId,
        bundleId: app.bundleId,
    })));
    return iosApps.flat();
}
async function processAndroidDir(dirPath, filePath) {
    const androidDir = path.dirname(path.dirname(filePath));
    const androidAppIds = await detectAppIdsForPlatform(dirPath, Platform.ANDROID);
    if (androidAppIds.length === 0) {
        return [
            {
                platform: Platform.ANDROID,
                directory: androidDir,
            },
        ];
    }
    const androidApps = await Promise.all(androidAppIds.map((app) => ({
        platform: Platform.ANDROID,
        directory: androidDir,
        appId: app.appId,
        bundleId: app.bundleId,
    })));
    return androidApps.flat();
}
async function processFlutterDir(dirPath, filePath) {
    const flutterDir = path.dirname(filePath);
    const flutterAppIds = await detectAppIdsForPlatform(dirPath, Platform.FLUTTER);
    if (flutterAppIds.length === 0) {
        return [
            {
                platform: Platform.FLUTTER,
                directory: flutterDir,
            },
        ];
    }
    const flutterApps = await Promise.all(flutterAppIds.map((app) => {
        const flutterApp = {
            platform: Platform.FLUTTER,
            directory: flutterDir,
            appId: app.appId,
            bundleId: app.bundleId,
        };
        return flutterApp;
    }));
    return flutterApps.flat();
}
function isPathInside(parent, child) {
    const relativePath = path.relative(parent, child);
    return !relativePath.startsWith(`..`);
}
function getAllDepsFromPackageJson(packageJson) {
    const devDependencies = Object.keys(packageJson.devDependencies ?? {});
    const dependencies = Object.keys(packageJson.dependencies ?? {});
    const allDeps = Array.from(new Set([...devDependencies, ...dependencies]));
    return allDeps;
}
async function packageJsonToAdminOrWebApp(dirPath, packageJsonFile) {
    try {
        const fullPath = path.join(dirPath, packageJsonFile);
        const packageJson = JSON.parse((await fs.readFile(fullPath)).toString());
        const allDeps = getAllDepsFromPackageJson(packageJson);
        const detectedApps = [];
        if (allDeps.includes("firebase-admin") || allDeps.includes("firebase-functions")) {
            detectedApps.push({
                platform: Platform.ADMIN_NODE,
                directory: path.dirname(packageJsonFile),
            });
        }
        if (allDeps.includes("firebase") || detectedApps.length === 0) {
            detectedApps.push({
                platform: Platform.WEB,
                directory: path.dirname(packageJsonFile),
                frameworks: getFrameworksFromPackageJson(packageJson),
            });
        }
        return detectedApps;
    }
    catch (err) {
        return [];
    }
}
const WEB_FRAMEWORKS = Object.values(Framework);
const WEB_FRAMEWORKS_SIGNALS = {
    react: ["react", "next"],
    angular: ["@angular/core"],
};
async function detectAppIdsForPlatform(dirPath, platform) {
    let appIdFiles;
    let extractFunc;
    switch (platform) {
        case Platform.ANDROID:
            appIdFiles = await detectFiles(dirPath, "google-services*.json*");
            extractFunc = extractAppIdentifiersAndroid;
            break;
        case Platform.IOS:
            appIdFiles = await detectFiles(dirPath, "GoogleService-*.plist*");
            extractFunc = extractAppIdentifierIos;
            break;
        case Platform.FLUTTER:
            appIdFiles = await detectFiles(dirPath, "firebase_options.dart");
            extractFunc = extractAppIdentifiersFlutter;
            break;
        default:
            return [];
    }
    const allAppIds = await Promise.all(appIdFiles.map(async (file) => {
        const fileContent = (await fs.readFile(path.join(dirPath, file))).toString();
        return extractFunc(fileContent);
    }));
    return allAppIds.flat();
}
function getFrameworksFromPackageJson(packageJson) {
    const allDeps = getAllDepsFromPackageJson(packageJson);
    return WEB_FRAMEWORKS.filter((framework) => WEB_FRAMEWORKS_SIGNALS[framework].find((dep) => allDeps.includes(dep)));
}
function extractAppIdentifiersFlutter(fileContent) {
    const optionsRegex = /FirebaseOptions\(([^)]*)\)/g;
    const appIdRegex = /appId: '([^']*)'/;
    const bundleIdRegex = /iosBundleId: '([^']*)'/;
    const matches = fileContent.matchAll(optionsRegex);
    const identifiers = [];
    for (const match of matches) {
        const optionsContent = match[1];
        const appIdMatch = appIdRegex.exec(optionsContent);
        const bundleIdMatch = bundleIdRegex.exec(optionsContent);
        if (appIdMatch?.[1]) {
            identifiers.push({
                appId: appIdMatch[1],
                bundleId: bundleIdMatch?.[1],
            });
        }
    }
    return identifiers;
}
function extractAppIdentifierIos(fileContent) {
    const appIdRegex = /<key>GOOGLE_APP_ID<\/key>\s*<string>([^<]*)<\/string>/;
    const bundleIdRegex = /<key>BUNDLE_ID<\/key>\s*<string>([^<]*)<\/string>/;
    const appIdMatch = fileContent.match(appIdRegex);
    const bundleIdMatch = fileContent.match(bundleIdRegex);
    if (appIdMatch?.[1]) {
        return [
            {
                appId: appIdMatch[1],
                bundleId: bundleIdMatch?.[1],
            },
        ];
    }
    return [];
}
function extractAppIdentifiersAndroid(fileContent) {
    const identifiers = [];
    try {
        const config = JSON.parse(fileContent);
        if (config.client && Array.isArray(config.client)) {
            for (const client of config.client) {
                if (client.client_info?.mobilesdk_app_id) {
                    identifiers.push({
                        appId: client.client_info.mobilesdk_app_id,
                        bundleId: client.client_info.android_client_info?.package_name,
                    });
                }
            }
        }
    }
    catch (e) {
        console.error("Error parsing google-services.json:", e);
    }
    return identifiers;
}
async function detectFiles(dirPath, filePattern) {
    const options = {
        cwd: dirPath,
        ignore: [
            "**/dataconnect*/**",
            "**/node_modules/**",
            "**/dist/**",
            "**/build/**",
            "**/out/**",
            "**/.next/**",
            "**/coverage/**",
        ],
        absolute: false,
        maxDepth: 4,
    };
    return (0, glob_1.glob)(`**/${filePattern}`, options);
}
