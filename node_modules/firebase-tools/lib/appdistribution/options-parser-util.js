"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parseIntoStringArray = parseIntoStringArray;
exports.getEmails = getEmails;
exports.ensureFileExists = ensureFileExists;
exports.getProjectName = getProjectName;
exports.getAppName = getAppName;
exports.toAppName = toAppName;
exports.parseTestDevices = parseTestDevices;
exports.getLoginCredential = getLoginCredential;
exports.getResultsBucket = getResultsBucket;
const fs = require("fs-extra");
const error_1 = require("../error");
const projectUtils_1 = require("../projectUtils");
function parseIntoStringArray(value, file = "") {
    if (!value && file) {
        ensureFileExists(file);
        value = fs.readFileSync(file, "utf8");
    }
    if (value) {
        return splitter(value);
    }
    return [];
}
function getEmails(emails, file) {
    if (emails.length === 0) {
        ensureFileExists(file);
        const readFile = fs.readFileSync(file, "utf8");
        return splitter(readFile);
    }
    return emails;
}
function ensureFileExists(file, message = "") {
    if (!fs.existsSync(file)) {
        throw new error_1.FirebaseError(`File ${file} does not exist: ${message}`);
    }
}
function splitter(value) {
    return value
        .split(/[,\n]/)
        .map((entry) => entry.trim())
        .filter((entry) => !!entry);
}
async function getProjectName(options) {
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    return `projects/${projectNumber}`;
}
function getAppName(options) {
    if (!options.app) {
        throw new error_1.FirebaseError("set the --app option to a valid Firebase app id and try again");
    }
    return toAppName(options.app);
}
const APP_ID_FORMAT = /^\d+:\d+:(android|ios|web):[a-fA-F0-9]+$/;
function validateAppId(appId) {
    if (!APP_ID_FORMAT.test(appId)) {
        throw new error_1.FirebaseError(`Invalid Firebase app ID: ${appId}`);
    }
}
function toAppName(appId) {
    validateAppId(appId);
    return `projects/${appId.split(":")[1]}/apps/${appId}`;
}
function parseTestDevices(value, file = "") {
    if (!value && file) {
        ensureFileExists(file);
        value = fs.readFileSync(file, "utf8");
    }
    if (!value) {
        return [];
    }
    return value
        .split(/[;\n]/)
        .map((entry) => entry.trim())
        .filter((entry) => !!entry)
        .map((str) => parseTestDevice(str));
}
function parseTestDevice(testDeviceString) {
    const entries = testDeviceString.split(",");
    const allowedKeys = new Set(["model", "version", "orientation", "locale"]);
    let model;
    let version;
    let orientation;
    let locale;
    for (const entry of entries) {
        const keyAndValue = entry.split("=");
        switch (keyAndValue[0]) {
            case "model":
                model = keyAndValue[1];
                break;
            case "version":
                version = keyAndValue[1];
                break;
            case "orientation":
                orientation = keyAndValue[1];
                break;
            case "locale":
                locale = keyAndValue[1];
                break;
            default:
                throw new error_1.FirebaseError(`Unrecognized key in test devices. Can only contain ${Array.from(allowedKeys).join(", ")}`);
        }
    }
    if (!model || !version || !orientation || !locale) {
        throw new error_1.FirebaseError("Test devices must be in the format 'model=<model-id>,version=<os-version-id>,locale=<locale>,orientation=<orientation>'");
    }
    return { model, version, locale, orientation };
}
function getLoginCredential(args) {
    const { username, passwordFile, usernameResourceName, passwordResourceName } = args;
    let password = args.password;
    if (!password && passwordFile) {
        ensureFileExists(passwordFile);
        password = fs.readFileSync(passwordFile, "utf8").trim();
    }
    if (isPresenceMismatched(usernameResourceName, passwordResourceName)) {
        throw new error_1.FirebaseError("Username and password resource names for automated tests need to be specified together.");
    }
    let fieldHints;
    if (usernameResourceName && passwordResourceName) {
        fieldHints = {
            usernameResourceName: usernameResourceName,
            passwordResourceName: passwordResourceName,
        };
    }
    if (isPresenceMismatched(username, password)) {
        throw new error_1.FirebaseError("Username and password for automated tests need to be specified together.");
    }
    let loginCredential;
    if (username && password) {
        loginCredential = { username, password, fieldHints };
    }
    else if (fieldHints) {
        throw new error_1.FirebaseError("Must specify username and password for automated tests if resource names are set");
    }
    return loginCredential;
}
function isPresenceMismatched(value1, value2) {
    return (value1 && !value2) || (!value1 && value2);
}
const APP_NAME_REGEX = /^projects\/(?<projectNumber>[^\/]+)\/apps\/(?<appId>[^\/]+)$/;
const BUCKET_NAME_FORMAT_REGEX = /^[a-z0-9_.-]+$/;
function getResultsBucket(bucket, appName) {
    if (!bucket) {
        return undefined;
    }
    let bucketName = bucket;
    if (bucketName.startsWith("gs://")) {
        bucketName = bucketName.substring(5);
    }
    if (!BUCKET_NAME_FORMAT_REGEX.test(bucketName)) {
        throw new error_1.FirebaseError(`Invalid results bucket format: ${bucket}`);
    }
    const match = APP_NAME_REGEX.exec(appName);
    if (!match || typeof match.groups === "undefined") {
        throw new error_1.FirebaseError(`Invalid app name: ${appName}`);
    }
    const { projectNumber } = match.groups;
    return `projects/${projectNumber}/buckets/${bucketName}`;
}
