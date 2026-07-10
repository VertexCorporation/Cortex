"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.archiveDirectory = archiveDirectory;
const archiver = require("archiver");
const utils_1 = require("./utils");
const fs = require("fs");
const path = require("path");
const tmp = require("tmp");
const error_1 = require("./error");
const logger_1 = require("./logger");
const fsAsync = require("./fsAsync");
async function archiveDirectory(sourceDirectory, options = {}) {
    const postfix = ".zip";
    const tempFile = tmp.fileSync({
        prefix: "firebase-archive-",
        postfix,
    });
    if (!options.ignore) {
        options.ignore = [];
    }
    const makeArchive = zipDirectory(sourceDirectory, tempFile, options);
    try {
        const archive = await makeArchive;
        logger_1.logger.debug(`Archived ${(0, utils_1.formatFilesize)(archive.size)} in ${sourceDirectory}.`);
        return archive;
    }
    catch (err) {
        if (err instanceof error_1.FirebaseError) {
            throw err;
        }
        throw new error_1.FirebaseError("Failed to create archive.", { original: (0, error_1.getError)(err) });
    }
}
async function zipDirectory(sourceDirectory, tempFile, options) {
    const archiveFileStream = fs.createWriteStream(tempFile.name, {
        flags: "w",
        encoding: "binary",
    });
    const archive = archiver("zip");
    const archiveDone = pipeAsync(archive, archiveFileStream);
    const allFiles = [];
    let files;
    try {
        files = await fsAsync.readdirRecursive({
            path: sourceDirectory,
            ignoreStrings: options.ignore,
            ignoreSymlinks: true,
        });
    }
    catch (err) {
        if (err.code === "ENOENT") {
            throw new error_1.FirebaseError(`Could not read directory "${sourceDirectory}"`, { original: err });
        }
        throw err;
    }
    for (const file of files) {
        const name = path.relative(sourceDirectory, file.name);
        allFiles.push(name);
        archive.file(file.name, {
            name,
            mode: file.mode,
        });
    }
    void archive.finalize();
    await archiveDone;
    const stats = fs.statSync(tempFile.name);
    return {
        file: tempFile.name,
        stream: fs.createReadStream(tempFile.name),
        manifest: allFiles,
        size: stats.size,
        source: sourceDirectory,
    };
}
async function pipeAsync(from, to) {
    return new Promise((resolve, reject) => {
        to.on("finish", resolve);
        to.on("error", reject);
        from.pipe(to);
    });
}
