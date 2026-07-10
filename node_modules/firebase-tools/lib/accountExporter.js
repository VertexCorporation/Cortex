"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validateOptions = validateOptions;
exports.serialExportUsers = serialExportUsers;
const os = require("os");
const path = require("path");
const apiv2_1 = require("./apiv2");
const error_1 = require("./error");
const api_1 = require("./api");
const utils = require("./utils");
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.googleOrigin)(),
});
const EXPORTED_JSON_KEYS = [
    "localId",
    "email",
    "emailVerified",
    "passwordHash",
    "salt",
    "displayName",
    "photoUrl",
    "lastLoginAt",
    "createdAt",
    "phoneNumber",
    "disabled",
    "customAttributes",
    "mfaInfo",
];
const EXPORTED_JSON_KEYS_RENAMING = {
    lastLoginAt: "lastSignedInAt",
};
const EXPORTED_PROVIDER_USER_INFO_KEYS = [
    "providerId",
    "rawId",
    "email",
    "displayName",
    "photoUrl",
];
const PROVIDER_ID_INDEX_MAP = new Map([
    ["google.com", 7],
    ["facebook.com", 11],
    ["twitter.com", 15],
    ["github.com", 19],
    ["apple.com", 28],
    ["microsoft.com", 32],
    ["gc.apple.com", 36],
    ["playgames.google.com", 40],
    ["linkedin.com", 44],
    ["yahoo.com", 48],
]);
function escapeCsv(str) {
    if (str.includes(",") || str.includes('"') || str.includes("\n") || str.includes("\r")) {
        return `"${str.replace(/"/g, '""')}"`;
    }
    return str;
}
function convertToNormalBase64(data) {
    return data.replace(/_/g, "/").replace(/-/g, "+");
}
function addProviderUserInfo(providerInfo, arr, startPos) {
    arr[startPos] = providerInfo.rawId;
    arr[startPos + 1] = providerInfo.email || "";
    arr[startPos + 2] = escapeCsv(providerInfo.displayName || "");
    arr[startPos + 3] = providerInfo.photoUrl || "";
}
function transUserToArray(user) {
    const arrLength = Math.max(...PROVIDER_ID_INDEX_MAP.values()) + 4;
    const arr = Array(arrLength).fill("");
    arr[0] = user.localId;
    arr[1] = user.email || "";
    arr[2] = user.emailVerified || false;
    arr[3] = convertToNormalBase64(user.passwordHash || "");
    arr[4] = convertToNormalBase64(user.salt || "");
    arr[5] = escapeCsv(user.displayName || "");
    arr[6] = user.photoUrl || "";
    for (let i = 0; i < (!user.providerUserInfo ? 0 : user.providerUserInfo.length); i++) {
        const providerInfo = user.providerUserInfo[i];
        if (providerInfo) {
            const providerIndex = PROVIDER_ID_INDEX_MAP.get(providerInfo.providerId);
            if (providerIndex) {
                addProviderUserInfo(providerInfo, arr, providerIndex);
            }
        }
    }
    arr[23] = user.createdAt;
    arr[24] = user.lastLoginAt;
    arr[25] = user.phoneNumber;
    arr[26] = user.disabled;
    arr[27] = user.customAttributes
        ? `"${user.customAttributes.replace(/(?<!\\)"/g, '""')}"`
        : user.customAttributes;
    return arr;
}
function transUserJson(user) {
    const newUser = {};
    const pickedUser = {};
    for (const k of EXPORTED_JSON_KEYS) {
        pickedUser[k] = user[k];
    }
    for (const [key, value] of Object.entries(pickedUser)) {
        const newKey = EXPORTED_JSON_KEYS_RENAMING[key] || key;
        newUser[newKey] = value;
    }
    if (newUser.passwordHash) {
        newUser.passwordHash = convertToNormalBase64(newUser.passwordHash);
    }
    if (newUser.salt) {
        newUser.salt = convertToNormalBase64(newUser.salt);
    }
    if (user.providerUserInfo) {
        newUser.providerUserInfo = [];
        for (const providerInfo of user.providerUserInfo) {
            if (PROVIDER_ID_INDEX_MAP.has(providerInfo.providerId)) {
                const picked = {};
                for (const k of EXPORTED_PROVIDER_USER_INFO_KEYS) {
                    picked[k] = providerInfo[k];
                }
                newUser.providerUserInfo.push(picked);
            }
        }
    }
    return newUser;
}
function validateOptions(options, fileName) {
    const exportOptions = {};
    if (fileName === undefined) {
        throw new error_1.FirebaseError("Must specify data file");
    }
    const extName = path.extname(fileName.toLowerCase());
    if (extName === ".csv") {
        exportOptions.format = "csv";
    }
    else if (extName === ".json") {
        exportOptions.format = "json";
    }
    else if (options.format) {
        const format = options.format.toLowerCase();
        if (format === "csv" || format === "json") {
            exportOptions.format = format;
        }
        else {
            throw new error_1.FirebaseError("Unsupported data file format, should be csv or json");
        }
    }
    else {
        throw new error_1.FirebaseError("Please specify data file format in file name, or use `format` parameter");
    }
    return exportOptions;
}
function createWriteUsersToFile() {
    let jsonSep = "";
    return (userList, format, writeStream) => {
        userList.map((user) => {
            if (user.passwordHash && user.version !== 0) {
                delete user.passwordHash;
                delete user.salt;
            }
            if (format === "csv") {
                writeStream.write(transUserToArray(user).join(",") + "," + os.EOL, "utf8");
            }
            else {
                writeStream.write(jsonSep + JSON.stringify(transUserJson(user), null, 2), "utf8");
                jsonSep = "," + os.EOL;
            }
        });
    };
}
async function serialExportUsers(projectId, options) {
    if (!options.writeUsersToFile) {
        options.writeUsersToFile = createWriteUsersToFile();
    }
    const postBody = {
        targetProjectId: projectId,
        maxResults: options.batchSize,
    };
    if (options.nextPageToken) {
        postBody.nextPageToken = options.nextPageToken;
    }
    if (!options.timeoutRetryCount) {
        options.timeoutRetryCount = 0;
    }
    try {
        const ret = await apiClient.post("/identitytoolkit/v3/relyingparty/downloadAccount", postBody, {
            skipLog: { resBody: true },
        });
        options.timeoutRetryCount = 0;
        const userList = ret.body.users;
        if (userList && userList.length > 0) {
            options.writeUsersToFile(userList, options.format, options.writeStream);
            utils.logSuccess("Exported " + userList.length + " account(s) successfully.");
            if (!ret.body.nextPageToken) {
                return;
            }
            options.nextPageToken = ret.body.nextPageToken;
            return serialExportUsers(projectId, options);
        }
    }
    catch (err) {
        if (err.original?.code === "ETIMEDOUT") {
            options.timeoutRetryCount++;
            if (options.timeoutRetryCount > 5) {
                return err;
            }
            return serialExportUsers(projectId, options);
        }
        if (err instanceof error_1.FirebaseError) {
            throw err;
        }
        else {
            throw new error_1.FirebaseError(`Failed to export accounts: ${err}`, { original: err });
        }
    }
}
