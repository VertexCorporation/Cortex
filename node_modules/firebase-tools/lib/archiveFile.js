"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.archiveFile = archiveFile;
const archiver = require("archiver");
const fs = require("fs");
const path = require("path");
const tmp = require("tmp");
async function archiveFile(filePath, options) {
    const tmpFileObj = tmp.fileSync({ postfix: ".zip" });
    const tmpFile = tmpFileObj.name;
    fs.closeSync(tmpFileObj.fd);
    const fileStream = fs.createWriteStream(tmpFile, {
        flags: "w",
        encoding: "binary",
    });
    const archive = archiver("zip");
    const name = options?.archivedFileName ?? path.basename(filePath);
    archive.file(filePath, { name });
    await pipeAsync(archive, fileStream);
    return tmpFile;
}
async function pipeAsync(from, to) {
    return new Promise((resolve, reject) => {
        to.on("finish", resolve);
        to.on("error", reject);
        from.on("error", reject);
        from.pipe(to);
        from.finalize().catch(reject);
    });
}
