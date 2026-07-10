"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createLocalBuildTarArchive = createLocalBuildTarArchive;
exports.createSourceDeployArchive = createSourceDeployArchive;
exports.resolveIgnorePatterns = resolveIgnorePatterns;
const archiver = require("archiver");
const fs = require("fs");
const path = require("path");
const tar = require("tar");
const tmp = require("tmp");
const error_1 = require("../../error");
const logger_1 = require("../../logger");
const fsAsync = require("../../fsAsync");
const utils_1 = require("../../utils");
const constants_1 = require("../../apphosting/constants");
async function createLocalBuildTarArchive(config, rootDir, outputFiles, sizeLimitBytes = constants_1.CLOUD_RUN_SIZE_LIMIT_BYTES) {
    const tmpFile = tmp.fileSync({ prefix: `${config.backendId}-`, postfix: ".tar.gz" }).name;
    const filesToPackage = outputFiles.length > 0 ? outputFiles : ["."];
    const allFiles = [];
    for (const fileOrDir of filesToPackage) {
        const absolutePath = path.join(rootDir, fileOrDir);
        if (!fs.existsSync(absolutePath)) {
            (0, utils_1.logLabeledWarning)("apphosting", `Expected build output file or directory not found: ${fileOrDir}`);
            continue;
        }
        const stat = fs.statSync(absolutePath);
        if (stat.isDirectory()) {
            const rdrFiles = await fsAsync.readdirRecursive({
                path: absolutePath,
                ignoreStrings: ["firebase-debug.log", "firebase-debug.*.log"],
                supportGitIgnore: false,
            });
            allFiles.push(...rdrFiles.map((rdrf) => path.relative(rootDir, rdrf.name)));
        }
        else {
            allFiles.push(path.relative(rootDir, absolutePath));
        }
    }
    try {
        fs.statSync(rootDir);
    }
    catch (err) {
        if (err instanceof Error && "code" in err && err.code === "ENOENT") {
            throw new error_1.FirebaseError(`Could not read directory "${rootDir}"`);
        }
        throw err;
    }
    if (!allFiles.length) {
        throw new error_1.FirebaseError(`Cannot create a tar archive with 0 files from directory "${rootDir}"`);
    }
    await tar.create({
        gzip: true,
        file: tmpFile,
        cwd: rootDir,
        portable: true,
    }, allFiles);
    const stats = fs.statSync(tmpFile);
    if (config.localBuild && stats.size > sizeLimitBytes) {
        const sizeInMB = stats.size / (1024 * 1024);
        const limitInMB = sizeLimitBytes / (1024 * 1024);
        logger_1.logger.warn(`The final build artifact is larger than ${limitInMB.toFixed(0)}MB (current size: ${sizeInMB.toFixed(2)}MB). Please reduce the size of your build artifacts.`);
    }
    return tmpFile;
}
async function createSourceDeployArchive(config, rootDir, targetSubDir) {
    const tmpFile = tmp.fileSync({ prefix: `${config.backendId}-`, postfix: ".zip" }).name;
    const fileStream = fs.createWriteStream(tmpFile, {
        flags: "w",
        encoding: "binary",
    });
    const archive = archiver("zip");
    const targetDir = targetSubDir ? path.join(rootDir, targetSubDir) : rootDir;
    const ignore = resolveIgnorePatterns(config);
    try {
        const files = await fsAsync.readdirRecursive({
            path: targetDir,
            ignoreStrings: ignore,
            supportGitIgnore: true,
        });
        for (const file of files) {
            const name = path.relative(rootDir, file.name);
            archive.file(file.name, {
                name,
                mode: file.mode,
            });
        }
        await pipeAsync(archive, fileStream);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Could not read source directory. Remove links and shortcuts and try again. Original: ${String(err)}`, { original: err, exit: 1 });
    }
    return tmpFile;
}
function resolveIgnorePatterns(config, skipDefaultNodeModules = false) {
    const ignore = config.ignore
        ? [...config.ignore]
        : skipDefaultNodeModules
            ? [".git"]
            : ["node_modules", ".git"];
    ignore.push("firebase-debug.log", "firebase-debug.*.log");
    ignore.push(".local_build_*");
    return ignore;
}
async function pipeAsync(from, to) {
    from.pipe(to);
    await from.finalize();
    return new Promise((resolve, reject) => {
        to.on("finish", resolve);
        to.on("error", reject);
    });
}
