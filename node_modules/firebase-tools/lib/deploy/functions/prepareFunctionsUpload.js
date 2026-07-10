"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getFunctionsConfig = getFunctionsConfig;
exports.addFilesToArchive = addFilesToArchive;
exports.prepareFunctionsUpload = prepareFunctionsUpload;
exports.convertToSortedKeyValueArray = convertToSortedKeyValueArray;
const archiver = require("archiver");
const clc = require("colorette");
const fs = require("fs");
const path = require("path");
const tmp = require("tmp");
const crypto = require("crypto");
const error_1 = require("../../error");
const logger_1 = require("../../logger");
const hash_1 = require("./cache/hash");
const functionsConfig = require("../../functionsConfig");
const utils = require("../../utils");
const fsAsync = require("../../fsAsync");
const CONFIG_DEST_FILE = ".runtimeconfig.json";
async function getFunctionsConfig(projectId) {
    try {
        return await functionsConfig.materializeAll(projectId);
    }
    catch (err) {
        logger_1.logger.debug(err);
        let errorCode = err?.context?.response?.statusCode;
        if (!errorCode) {
            logger_1.logger.debug("Got unexpected error from Runtime Config; it has no status code:", err);
            errorCode = 500;
        }
        if (errorCode === 500 || errorCode === 503) {
            throw new error_1.FirebaseError("Cloud Runtime Config is currently experiencing issues, " +
                "which is preventing your functions from being deployed. " +
                "Please wait a few minutes and then try to deploy your functions again." +
                "\nRun `firebase deploy --except functions` if you want to continue deploying the rest of your project.");
        }
    }
    return {};
}
async function pipeAsync(from, to) {
    from.pipe(to);
    await from.finalize();
    return new Promise((resolve, reject) => {
        to.on("finish", () => resolve());
        to.on("error", reject);
    });
}
async function addFilesToArchive(archive, files, sourceDir, executablePaths) {
    const hashes = [];
    for (const file of files) {
        const name = path.relative(sourceDir, file.name);
        const normalizedName = name.split(path.sep).join("/");
        const fileHash = await (0, hash_1.getSourceHash)(file.name);
        hashes.push(fileHash);
        let mode = file.mode;
        if (executablePaths?.includes(normalizedName)) {
            mode = 0o755;
        }
        archive.file(file.name, {
            name: normalizedName,
            mode,
        });
    }
    return hashes;
}
async function packageSource(projectDir, sourceDir, config, additionalSources, runtimeConfig, options) {
    const exportType = options?.exportType || "zip";
    const postfix = `.${exportType}`;
    const tmpFile = tmp.fileSync({ prefix: "firebase-functions-", postfix }).name;
    const fileStream = fs.createWriteStream(tmpFile, {
        flags: "w",
        encoding: "binary",
    });
    const archive = exportType === "tar.gz" ? archiver("tar", { gzip: true }) : archiver("zip");
    const hashes = [];
    let configHash = "";
    const ignore = config.ignore || ["node_modules", ".git"];
    ignore.push("firebase-debug.log", "firebase-debug.*.log", CONFIG_DEST_FILE);
    try {
        const files = await fsAsync.readdirRecursive({ path: sourceDir, ignoreStrings: ignore });
        hashes.push(...(await addFilesToArchive(archive, files, sourceDir, options?.executablePaths)));
        for (const name of additionalSources) {
            const absPath = utils.resolveWithin(projectDir, name);
            if (!fs.existsSync(absPath)) {
                throw new error_1.FirebaseError(clc.bold(absPath) + " does not exist.", { exit: 1 });
            }
            const mode = fs.statSync(absPath).mode;
            const fileHash = await (0, hash_1.getSourceHash)(absPath);
            hashes.push(fileHash);
            archive.file(absPath, {
                name,
                mode,
            });
        }
        if (typeof runtimeConfig !== "undefined") {
            const runtimeConfigHashString = JSON.stringify(convertToSortedKeyValueArray(runtimeConfig));
            configHash = crypto.createHash("sha1").update(runtimeConfigHashString).digest("hex");
            const runtimeConfigString = JSON.stringify(runtimeConfig, null, 2);
            archive.append(runtimeConfigString, {
                name: CONFIG_DEST_FILE,
                mode: 420,
            });
            if (Object.keys(runtimeConfig).some((k) => k !== "firebase")) {
                functionsConfig.logFunctionsConfigDeprecationWarning();
            }
        }
        await pipeAsync(archive, fileStream);
    }
    catch (err) {
        if (err instanceof error_1.FirebaseError) {
            throw err;
        }
        throw new error_1.FirebaseError(`Could not read source directory. Remove links and shortcuts and try again. Original: ${err}`, {
            original: err,
            exit: 1,
        });
    }
    utils.logBullet(clc.cyan(clc.bold("functions:")) +
        " packaged " +
        clc.bold(sourceDir) +
        " (" +
        utils.formatFilesize(archive.pointer()) +
        ") for uploading");
    const sourceHash = crypto.createHash("sha1").update(hashes.sort().join("")).digest("hex");
    const hash = configHash ? `${sourceHash}.${configHash}` : sourceHash;
    return { pathToSource: tmpFile, hash };
}
async function prepareFunctionsUpload(projectDir, sourceDir, config, additionalSources, runtimeConfig, options) {
    return packageSource(projectDir, sourceDir, config, additionalSources, runtimeConfig, options);
}
function convertToSortedKeyValueArray(config) {
    if (typeof config !== "object" || config === null)
        return config;
    return Object.keys(config)
        .sort()
        .map((key) => {
        return { key, value: convertToSortedKeyValueArray(config[key]) };
    });
}
