"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.askQuestions = askQuestions;
exports.actuate = actuate;
const prompt_1 = require("../../../prompt");
const error_1 = require("../../../error");
const utils_1 = require("./utils");
const apps_1 = require("../../../management/apps");
const provision_1 = require("../../../management/provisioning/provision");
function checkForApps(apps) {
    if (!apps.length) {
        throw new error_1.FirebaseError("No Firebase apps found in this project. Please create an app first using the Firebase Console or 'firebase apps:create'.", { exit: 1 });
    }
}
async function selectAppInteractively(apps) {
    checkForApps(apps);
    const choices = apps.map((app) => {
        let displayText = app.displayName || app.appId;
        if (!app.displayName) {
            if (app.platform === apps_1.AppPlatform.IOS && "bundleId" in app) {
                displayText = app.bundleId;
            }
            else if (app.platform === apps_1.AppPlatform.ANDROID && "packageName" in app) {
                displayText = app.packageName;
            }
        }
        return {
            name: `${displayText} - ${app.appId} (${app.platform})`,
            value: app,
        };
    });
    return await (0, prompt_1.select)({
        message: "Select the Firebase app to enable AI Logic for:",
        choices,
    });
}
async function askQuestions(setup) {
    if (!setup.projectId) {
        throw new error_1.FirebaseError("No project ID found. Please ensure you are in a Firebase project directory or specify a project.", { exit: 1 });
    }
    const apps = await (0, apps_1.listFirebaseApps)(setup.projectId, apps_1.AppPlatform.ANY);
    const selectedApp = await selectAppInteractively(apps);
    if (!setup.featureInfo) {
        setup.featureInfo = {};
    }
    setup.featureInfo.ailogic = {
        appId: selectedApp.appId,
        displayName: selectedApp.displayName,
    };
}
function getAppOptions(appInfo, displayName) {
    switch (appInfo.platform) {
        case apps_1.AppPlatform.IOS:
            return {
                platform: apps_1.AppPlatform.IOS,
                appId: appInfo.appId,
                displayName,
            };
        case apps_1.AppPlatform.ANDROID:
            return {
                platform: apps_1.AppPlatform.ANDROID,
                appId: appInfo.appId,
                displayName,
            };
        case apps_1.AppPlatform.WEB:
            return {
                platform: apps_1.AppPlatform.WEB,
                appId: appInfo.appId,
                displayName,
            };
        default:
            throw new error_1.FirebaseError(`Unsupported platform ${appInfo.platform}`, { exit: 1 });
    }
}
async function actuate(setup) {
    const ailogicInfo = setup.featureInfo?.ailogic;
    if (!ailogicInfo) {
        return;
    }
    try {
        const appInfo = (0, utils_1.parseAppId)(ailogicInfo.appId);
        if (!setup.projectId) {
            throw new error_1.FirebaseError("No project ID found. Please ensure you are in a Firebase project directory or specify a project.", { exit: 1 });
        }
        const provisionOptions = {
            project: {
                parent: { type: "existing_project", projectId: setup.projectId },
            },
            app: getAppOptions(appInfo, ailogicInfo.displayName),
            features: {
                firebaseAiLogicInput: {},
            },
        };
        const response = await (0, provision_1.provisionFirebaseApp)(provisionOptions);
        const configFileName = (0, utils_1.getConfigFileName)(appInfo.platform);
        const configContent = Buffer.from(response.configData, "base64").toString("utf8");
        setup.instructions.push(`Firebase AI Logic has been enabled for existing ${appInfo.platform} app: ${ailogicInfo.appId}`, `Save the following content as ${configFileName} in your app's root directory:`, "", configContent, "", "Place this config file in the appropriate location for your platform.");
    }
    catch (error) {
        throw new error_1.FirebaseError(`AI Logic setup failed: ${error instanceof Error ? error.message : String(error)}`, { original: error instanceof Error ? error : new Error(String(error)), exit: 2 });
    }
}
