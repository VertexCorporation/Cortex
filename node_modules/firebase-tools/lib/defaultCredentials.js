"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getCredentialPathAsync = getCredentialPathAsync;
exports.clearCredentials = clearCredentials;
exports.hasDefaultCredentials = hasDefaultCredentials;
const fs = require("fs");
const path = require("path");
const google_auth_library_1 = require("google-auth-library");
const api_1 = require("./api");
const logger_1 = require("./logger");
async function getCredentialPathAsync(account) {
    const filePath = credFilePath(account.user);
    if (!filePath) {
        logger_1.logger.debug("defaultcredentials: could not create path to default credentials file.");
        return undefined;
    }
    const cred = getCredential(account.tokens);
    if (!cred) {
        logger_1.logger.debug("defaultcredentials: no credential available.");
        return undefined;
    }
    logger_1.logger.debug(`defaultcredentials: writing to file ${filePath}`);
    return new Promise((res, rej) => {
        fs.writeFile(filePath, JSON.stringify(cred, undefined, 2), "utf8", (err) => {
            if (err) {
                rej(err);
            }
            else {
                res(filePath);
            }
        });
    });
}
function clearCredentials(account) {
    const filePath = credFilePath(account.user);
    if (!filePath) {
        return;
    }
    if (!fs.existsSync(filePath)) {
        return;
    }
    fs.unlinkSync(filePath);
}
function getCredential(tokens) {
    if (tokens.refresh_token) {
        return {
            client_id: (0, api_1.clientId)(),
            client_secret: (0, api_1.clientSecret)(),
            refresh_token: tokens.refresh_token,
            type: "authorized_user",
        };
    }
}
function credFilePath(user) {
    let configDir = undefined;
    if (process.platform.startsWith("win")) {
        configDir = process.env["APPDATA"];
    }
    else {
        const home = process.env["HOME"];
        if (home) {
            configDir = path.join(home, ".config");
        }
    }
    if (!configDir) {
        return undefined;
    }
    if (!fs.existsSync(configDir)) {
        fs.mkdirSync(configDir);
    }
    const fbtConfigDir = path.join(configDir, "firebase");
    if (!fs.existsSync(fbtConfigDir)) {
        fs.mkdirSync(fbtConfigDir);
    }
    return path.join(fbtConfigDir, `${userEmailSlug(user)}_application_default_credentials.json`);
}
function userEmailSlug(user) {
    const email = user.email || "unknown_user";
    const slug = email.replace("@", "_").replace(".", "_");
    return slug;
}
async function hasDefaultCredentials() {
    try {
        await google_auth_library_1.auth.getApplicationDefault();
        return true;
    }
    catch (err) {
        return false;
    }
}
