"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PLATFORM_PATH = exports.CRASHLYTICS_API_CLIENT = exports.TIMEOUT = void 0;
exports.parseProjectNumber = parseProjectNumber;
exports.parsePlatform = parsePlatform;
const error_1 = require("../error");
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
exports.TIMEOUT = 10000;
exports.CRASHLYTICS_API_CLIENT = new apiv2_1.Client({
    urlPrefix: (0, api_1.crashlyticsApiOrigin)(),
    apiVersion: "v1alpha",
});
var PLATFORM_PATH;
(function (PLATFORM_PATH) {
    PLATFORM_PATH["ANDROID"] = "topAndroidDevices";
    PLATFORM_PATH["IOS"] = "topAppleDevices";
})(PLATFORM_PATH || (exports.PLATFORM_PATH = PLATFORM_PATH = {}));
function parseProjectNumber(appId) {
    const appIdParts = appId.split(":");
    if (appIdParts.length > 1) {
        return appIdParts[1];
    }
    throw new error_1.FirebaseError("Unable to get the projectId from the AppId.");
}
function parsePlatform(appId) {
    const appIdParts = appId.split(":");
    if (appIdParts.length < 3) {
        throw new error_1.FirebaseError("Unable to get the platform from the AppId.");
    }
    if (appIdParts[2] === "android") {
        return PLATFORM_PATH.ANDROID;
    }
    else if (appIdParts[2] === "ios") {
        return PLATFORM_PATH.IOS;
    }
    throw new error_1.FirebaseError(`Only android or ios apps are supported.`);
}
