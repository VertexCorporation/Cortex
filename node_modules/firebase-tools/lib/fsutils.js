"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fileExistsSync = fileExistsSync;
exports.dirExistsSync = dirExistsSync;
exports.readFile = readFile;
exports.listFiles = listFiles;
exports.moveAll = moveAll;
const fs_1 = require("fs");
const path = require("path");
const error_1 = require("./error");
const fs_extra_1 = require("fs-extra");
function fileExistsSync(path) {
    try {
        return (0, fs_1.statSync)(path).isFile();
    }
    catch (e) {
        return false;
    }
}
function dirExistsSync(path) {
    try {
        return (0, fs_1.statSync)(path).isDirectory();
    }
    catch (e) {
        return false;
    }
}
function readFile(path) {
    try {
        return (0, fs_1.readFileSync)(path).toString();
    }
    catch (e) {
        if (e.code === "ENOENT") {
            throw new error_1.FirebaseError(`File not found: ${path}`);
        }
        throw e;
    }
}
function listFiles(path) {
    try {
        return (0, fs_1.readdirSync)(path);
    }
    catch (e) {
        if (e.code === "ENOENT") {
            throw new error_1.FirebaseError(`Directory not found: ${path}`);
        }
        throw e;
    }
}
function moveAll(srcDir, destDir) {
    if (!(0, fs_1.existsSync)(destDir)) {
        (0, fs_1.mkdirSync)(destDir, { recursive: true });
    }
    const files = listFiles(srcDir);
    for (const f of files) {
        const srcPath = path.join(srcDir, f);
        if (srcPath === destDir)
            continue;
        (0, fs_extra_1.moveSync)(srcPath, path.join(destDir, f));
    }
}
