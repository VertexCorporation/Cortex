"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ShaCertificateType = exports.AppPlatform = exports.APP_LIST_PAGE_SIZE = void 0;
exports.getPlatform = getPlatform;
exports.sdkInit = sdkInit;
exports.getSdkOutputPath = getSdkOutputPath;
exports.checkForApps = checkForApps;
exports.getSdkConfig = getSdkConfig;
exports.getAppPlatform = getAppPlatform;
exports.createIosApp = createIosApp;
exports.createAndroidApp = createAndroidApp;
exports.createWebApp = createWebApp;
exports.listFirebaseApps = listFirebaseApps;
exports.getAppConfigFile = getAppConfigFile;
exports.writeConfigToFile = writeConfigToFile;
exports.getAppConfig = getAppConfig;
exports.listAppAndroidSha = listAppAndroidSha;
exports.createAppAndroidSha = createAppAndroidSha;
exports.deleteAppAndroidSha = deleteAppAndroidSha;
exports.findIntelligentPathForIOS = findIntelligentPathForIOS;
exports.findIntelligentPathForAndroid = findIntelligentPathForAndroid;
const fs = require("fs-extra");
const ora = require("ora");
const path = require("path");
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
const error_1 = require("../error");
const logger_1 = require("../logger");
const operation_poller_1 = require("../operation-poller");
const projectUtils_1 = require("../projectUtils");
const prompt_1 = require("../prompt");
const projects_1 = require("./projects");
const appUtils_1 = require("../appUtils");
const utils_1 = require("../utils");
const TIMEOUT_MILLIS = 30000;
exports.APP_LIST_PAGE_SIZE = 100;
const CREATE_APP_API_REQUEST_TIMEOUT_MILLIS = 15000;
async function getDisplayName() {
    return await (0, prompt_1.input)("What would you like to call your app?");
}
async function getPlatform(appDir, config) {
    let targetPlatforms = await (0, appUtils_1.getPlatformsFromFolder)(appDir);
    let targetPlatform;
    if (targetPlatforms.length === 0) {
        appDir = await (0, utils_1.promptForDirectory)({
            config,
            relativeTo: appDir,
            message: "We couldn't determine what kind of app you're using. Where is your app directory?",
        });
        targetPlatforms = await (0, appUtils_1.getPlatformsFromFolder)(appDir);
    }
    if (targetPlatforms.length !== 1) {
        if (targetPlatforms.length === 0) {
            (0, utils_1.logBullet)(`Couldn't automatically detect your app in directory ${appDir}.`);
        }
        else {
            (0, utils_1.logSuccess)(`Detected multiple app platforms in directory ${appDir}`);
        }
        const platforms = [
            { name: "iOS (Swift)", value: appUtils_1.Platform.IOS },
            { name: "Web (JavaScript)", value: appUtils_1.Platform.WEB },
            { name: "Android (Kotlin)", value: appUtils_1.Platform.ANDROID },
        ];
        targetPlatform = await (0, prompt_1.select)({
            message: "Which platform do you want to set up an SDK for? Note: We currently do not support automatically setting up C++ or Unity projects.",
            choices: platforms,
        });
    }
    else {
        targetPlatform = targetPlatforms[0];
    }
    if (targetPlatform === appUtils_1.Platform.FLUTTER) {
        (0, utils_1.logWarning)(`Detected ${targetPlatform} app in directory ${appDir}`);
        throw new error_1.FirebaseError(`Flutter is not supported by apps:configure.
Please follow the link below to set up firebase for your Flutter app:
https://firebase.google.com/docs/flutter/setup
    `);
    }
    else {
        (0, utils_1.logSuccess)(`Detected ${targetPlatform} app in directory ${appDir}`);
    }
    return targetPlatform;
}
async function initiateIosAppCreation(options) {
    if (!options.nonInteractive) {
        options.displayName = options.displayName || (await getDisplayName());
        options.bundleId = options.bundleId || (await (0, prompt_1.input)("Please specify your iOS app bundle ID:"));
        options.appStoreId =
            options.appStoreId || (await (0, prompt_1.input)("Please specify your iOS app App Store ID:"));
    }
    if (!options.bundleId) {
        throw new error_1.FirebaseError("Bundle ID for iOS app cannot be empty");
    }
    const spinner = ora("Creating your iOS app").start();
    try {
        const appData = await createIosApp(options.project, {
            displayName: options.displayName,
            bundleId: options.bundleId,
            appStoreId: options.appStoreId,
        });
        spinner.succeed();
        return appData;
    }
    catch (err) {
        spinner.fail();
        throw err;
    }
}
async function initiateAndroidAppCreation(options) {
    if (!options.nonInteractive) {
        options.displayName = options.displayName || (await getDisplayName());
        options.packageName =
            options.packageName || (await (0, prompt_1.input)("Please specify your Android app package name:"));
    }
    if (!options.packageName) {
        throw new error_1.FirebaseError("Package name for Android app cannot be empty");
    }
    const spinner = ora("Creating your Android app").start();
    try {
        const appData = await createAndroidApp(options.project, {
            displayName: options.displayName,
            packageName: options.packageName,
        });
        spinner.succeed();
        return appData;
    }
    catch (err) {
        spinner.fail();
        throw err;
    }
}
async function initiateWebAppCreation(options) {
    if (!options.nonInteractive) {
        options.displayName = options.displayName || (await getDisplayName());
    }
    if (!options.displayName) {
        throw new error_1.FirebaseError("Display name for Web app cannot be empty");
    }
    const spinner = ora("Creating your Web app").start();
    try {
        const appData = await createWebApp(options.project, { displayName: options.displayName });
        spinner.succeed();
        return appData;
    }
    catch (err) {
        spinner.fail();
        throw err;
    }
}
async function sdkInit(appPlatform, options) {
    let appData;
    switch (appPlatform) {
        case AppPlatform.IOS:
            appData = await initiateIosAppCreation(options);
            break;
        case AppPlatform.ANDROID:
            appData = await initiateAndroidAppCreation(options);
            break;
        case AppPlatform.WEB:
            appData = await initiateWebAppCreation(options);
            break;
        default:
            throw new error_1.FirebaseError("Unexpected error. This should not happen");
    }
    return appData;
}
async function getSdkOutputPath(appDir, platform, config) {
    switch (platform) {
        case AppPlatform.ANDROID:
            const androidPath = await findIntelligentPathForAndroid(appDir, config);
            return path.join(androidPath, "google-services.json");
        case AppPlatform.WEB:
            return path.join(appDir, "firebase-js-config.json");
        case AppPlatform.IOS:
            const iosPath = await findIntelligentPathForIOS(appDir, config);
            return path.join(iosPath, "GoogleService-Info.plist");
    }
    throw new error_1.FirebaseError("Platform " + platform.toString() + " is not supported yet.");
}
function checkForApps(apps, appPlatform) {
    if (!apps.length) {
        throw new error_1.FirebaseError(`There are no ${appPlatform === AppPlatform.ANY ? "" : appPlatform + " "}apps ` +
            "associated with this Firebase project.\n" +
            "You can create an app for this project with 'firebase apps:create'");
    }
}
async function selectAppInteractively(apps, appPlatform) {
    checkForApps(apps, appPlatform);
    const choices = apps.map((app) => {
        return {
            name: `${app.displayName || app.bundleId || app.packageName}` +
                ` - ${app.appId} (${app.platform})`,
            value: app,
        };
    });
    return await (0, prompt_1.select)({
        message: `Select the ${appPlatform === AppPlatform.ANY ? "" : appPlatform + " "}` +
            "app to get the configuration data:",
        choices,
    });
}
async function getSdkConfig(options, appPlatform, appId) {
    if (!appId) {
        let projectId = (0, projectUtils_1.needProjectId)(options);
        if (options.nonInteractive && !projectId) {
            throw new error_1.FirebaseError("Must supply app and project ids in non-interactive mode.");
        }
        else if (!projectId) {
            const result = await (0, projects_1.getOrPromptProject)(options);
            projectId = result.projectId;
        }
        const apps = await listFirebaseApps(projectId, appPlatform);
        checkForApps(apps, appPlatform);
        if (apps.length === 1) {
            appId = apps[0].appId;
            appPlatform = apps[0].platform;
        }
        else if (options.nonInteractive) {
            throw new error_1.FirebaseError(`Project ${projectId} has multiple apps, must specify an app id.`);
        }
        else {
            const appMetadata = await selectAppInteractively(apps, appPlatform);
            appId = appMetadata.appId;
            appPlatform = appMetadata.platform;
        }
    }
    let configData;
    const spinner = ora(`Downloading configuration data for your Firebase ${appPlatform} app`).start();
    try {
        configData = await getAppConfig(appId, appPlatform);
    }
    catch (err) {
        spinner.fail();
        throw err;
    }
    spinner.succeed();
    return configData;
}
var AppPlatform;
(function (AppPlatform) {
    AppPlatform["PLATFORM_UNSPECIFIED"] = "PLATFORM_UNSPECIFIED";
    AppPlatform["IOS"] = "IOS";
    AppPlatform["ANDROID"] = "ANDROID";
    AppPlatform["WEB"] = "WEB";
    AppPlatform["ANY"] = "ANY";
})(AppPlatform || (exports.AppPlatform = AppPlatform = {}));
var ShaCertificateType;
(function (ShaCertificateType) {
    ShaCertificateType["SHA_CERTIFICATE_TYPE_UNSPECIFIED"] = "SHA_CERTIFICATE_TYPE_UNSPECIFIED";
    ShaCertificateType["SHA_1"] = "SHA_1";
    ShaCertificateType["SHA_256"] = "SHA_256";
})(ShaCertificateType || (exports.ShaCertificateType = ShaCertificateType = {}));
function getAppPlatform(platform) {
    switch (platform.toUpperCase()) {
        case "IOS":
            return AppPlatform.IOS;
        case "ANDROID":
            return AppPlatform.ANDROID;
        case "WEB":
            return AppPlatform.WEB;
        case "":
            return AppPlatform.ANY;
        default:
            throw new error_1.FirebaseError("Unexpected platform. Only iOS, Android, and Web apps are supported");
    }
}
const apiClient = new apiv2_1.Client({ urlPrefix: (0, api_1.firebaseApiOrigin)(), apiVersion: "v1beta1" });
async function createIosApp(projectId, options) {
    try {
        const response = await apiClient.request({
            method: "POST",
            path: `/projects/${projectId}/iosApps`,
            timeout: CREATE_APP_API_REQUEST_TIMEOUT_MILLIS,
            body: options,
        });
        const appData = await (0, operation_poller_1.pollOperation)({
            pollerName: "Create iOS app Poller",
            apiOrigin: (0, api_1.firebaseApiOrigin)(),
            apiVersion: "v1beta1",
            operationResourceName: response.body.name,
        });
        return appData;
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to create iOS app for project ${projectId}. See firebase-debug.log for more info.`, { exit: 2, original: err });
    }
}
async function createAndroidApp(projectId, options) {
    try {
        const response = await apiClient.request({
            method: "POST",
            path: `/projects/${projectId}/androidApps`,
            timeout: CREATE_APP_API_REQUEST_TIMEOUT_MILLIS,
            body: options,
        });
        const appData = await (0, operation_poller_1.pollOperation)({
            pollerName: "Create Android app Poller",
            apiOrigin: (0, api_1.firebaseApiOrigin)(),
            apiVersion: "v1beta1",
            operationResourceName: response.body.name,
        });
        return appData;
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to create Android app for project ${projectId}. See firebase-debug.log for more info.`, {
            exit: 2,
            original: err,
        });
    }
}
async function createWebApp(projectId, options) {
    try {
        const response = await apiClient.request({
            method: "POST",
            path: `/projects/${projectId}/webApps`,
            timeout: CREATE_APP_API_REQUEST_TIMEOUT_MILLIS,
            body: options,
        });
        const appData = await (0, operation_poller_1.pollOperation)({
            pollerName: "Create Web app Poller",
            apiOrigin: (0, api_1.firebaseApiOrigin)(),
            apiVersion: "v1beta1",
            operationResourceName: response.body.name,
        });
        return appData;
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to create Web app for project ${projectId}. See firebase-debug.log for more info.`, { exit: 2, original: err });
    }
}
function getListAppsResourceString(projectId, platform) {
    let resourceSuffix;
    switch (platform) {
        case AppPlatform.IOS:
            resourceSuffix = "/iosApps";
            break;
        case AppPlatform.ANDROID:
            resourceSuffix = "/androidApps";
            break;
        case AppPlatform.WEB:
            resourceSuffix = "/webApps";
            break;
        case AppPlatform.ANY:
            resourceSuffix = ":searchApps";
            break;
        default:
            throw new error_1.FirebaseError("Unexpected platform. Only support iOS, Android and Web apps");
    }
    return `/projects/${projectId}${resourceSuffix}`;
}
async function listFirebaseApps(projectId, platform, pageSize = exports.APP_LIST_PAGE_SIZE) {
    const apps = [];
    try {
        let nextPageToken;
        do {
            const queryParams = { pageSize };
            if (nextPageToken) {
                queryParams.pageToken = nextPageToken;
            }
            const response = await apiClient.request({
                method: "GET",
                path: getListAppsResourceString(projectId, platform),
                queryParams,
                timeout: TIMEOUT_MILLIS,
            });
            if (response.body.apps) {
                const appsOnPage = response.body.apps.map((app) => (app.platform ? app : { ...app, platform }));
                apps.push(...appsOnPage);
            }
            nextPageToken = response.body.nextPageToken;
        } while (nextPageToken);
        return apps;
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to list Firebase ${platform === AppPlatform.ANY ? "" : platform + " "}` +
            "apps. See firebase-debug.log for more info.", {
            exit: 2,
            original: err,
        });
    }
}
function getAppConfigResourceString(appId, platform) {
    let platformResource;
    switch (platform) {
        case AppPlatform.IOS:
            platformResource = "iosApps";
            break;
        case AppPlatform.ANDROID:
            platformResource = "androidApps";
            break;
        case AppPlatform.WEB:
            platformResource = "webApps";
            break;
        default:
            throw new error_1.FirebaseError("Unexpected app platform");
    }
    return `/projects/-/${platformResource}/${appId}/config`;
}
function parseConfigFromResponse(responseBody, platform) {
    if (platform === AppPlatform.WEB) {
        return {
            fileName: "firebase-js-config.json",
            fileContents: JSON.stringify(responseBody, null, 2),
        };
    }
    else if ("configFilename" in responseBody) {
        return {
            fileName: responseBody.configFilename,
            fileContents: Buffer.from(responseBody.configFileContents, "base64").toString("utf8"),
        };
    }
    throw new error_1.FirebaseError("Unexpected app platform");
}
function getAppConfigFile(config, platform) {
    return parseConfigFromResponse(config, platform);
}
async function writeConfigToFile(filename, nonInteractive, fileContents) {
    if (fs.existsSync(filename)) {
        if (nonInteractive) {
            throw new error_1.FirebaseError(`${filename} already exists`);
        }
        const overwrite = await (0, prompt_1.confirm)(`${filename} already exists. Do you want to overwrite?`);
        if (!overwrite) {
            return false;
        }
    }
    await fs.writeFile(filename, fileContents);
    return true;
}
async function getAppConfig(appId, platform) {
    try {
        const response = await apiClient.request({
            method: "GET",
            path: getAppConfigResourceString(appId, platform),
            timeout: TIMEOUT_MILLIS,
        });
        return response.body;
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to get ${platform} app configuration. See firebase-debug.log for more info.`, {
            exit: 2,
            original: err,
        });
    }
}
async function listAppAndroidSha(projectId, appId) {
    const shaCertificates = [];
    try {
        const response = await apiClient.request({
            method: "GET",
            path: `/projects/${projectId}/androidApps/${appId}/sha`,
            timeout: CREATE_APP_API_REQUEST_TIMEOUT_MILLIS,
        });
        if (response.body.certificates) {
            shaCertificates.push(...response.body.certificates);
        }
        return shaCertificates;
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to list SHA certificate hashes for Android app ${appId}.` +
            " See firebase-debug.log for more info.", {
            exit: 2,
            original: err,
        });
    }
}
async function createAppAndroidSha(projectId, appId, options) {
    try {
        const response = await apiClient.request({
            method: "POST",
            path: `/projects/${projectId}/androidApps/${appId}/sha`,
            body: options,
            timeout: CREATE_APP_API_REQUEST_TIMEOUT_MILLIS,
        });
        const shaCertificate = response.body;
        return shaCertificate;
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to create SHA certificate hash for Android app ${appId}. See firebase-debug.log for more info.`, {
            exit: 2,
            original: err,
        });
    }
}
async function deleteAppAndroidSha(projectId, appId, shaId) {
    try {
        await apiClient.request({
            method: "DELETE",
            path: `/projects/${projectId}/androidApps/${appId}/sha/${shaId}`,
            timeout: CREATE_APP_API_REQUEST_TIMEOUT_MILLIS,
        });
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to delete SHA certificate hash for Android app ${appId}. See firebase-debug.log for more info.`, {
            exit: 2,
            original: err,
        });
    }
}
async function findIntelligentPathForIOS(appDir, options) {
    const currentFiles = await fs.readdir(appDir, { withFileTypes: true });
    for (let i = 0; i < currentFiles.length; i++) {
        const dirent = currentFiles[i];
        const xcodeStr = ".xcodeproj";
        const file = dirent.name;
        if (file.endsWith(xcodeStr)) {
            return path.join(appDir, file.substring(0, file.length - xcodeStr.length));
        }
        else if (file === "Info.plist" ||
            file === "Assets.xcassets" ||
            (dirent.isDirectory() && file === "Preview Content")) {
            return appDir;
        }
    }
    let outputPath = null;
    if (!options.nonInteractive) {
        outputPath = await (0, utils_1.promptForDirectory)({
            config: options.config,
            message: `We weren't able to automatically determine the output directory. Where would you like to output your config file?`,
            relativeTo: appDir,
        });
    }
    if (!outputPath) {
        throw new Error("We weren't able to automatically determine the output directory.");
    }
    return outputPath;
}
async function findIntelligentPathForAndroid(appDir, options) {
    const paths = appDir.split("/");
    if (paths[0] === "app") {
        return appDir;
    }
    else {
        const currentFiles = await fs.readdir(appDir, { withFileTypes: true });
        const dirs = [];
        for (const fileOrDir of currentFiles) {
            if (fileOrDir.isDirectory()) {
                if (fileOrDir.name !== "gradle") {
                    dirs.push(fileOrDir.name);
                }
                if (fileOrDir.name === "src") {
                    return appDir;
                }
            }
        }
        let module = path.join(appDir, "app");
        if (dirs.length === 1 && dirs[0] === "app") {
            return module;
        }
        if (!options.nonInteractive) {
            module = await (0, utils_1.promptForDirectory)({
                config: options.config,
                message: `We weren't able to automatically determine the output directory. Where would you like to output your config file?`,
            });
        }
        return module;
    }
}
