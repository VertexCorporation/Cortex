"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.absoluteTemplateFilePath = absoluteTemplateFilePath;
exports.readTemplateSync = readTemplateSync;
exports.readTemplate = readTemplate;
const fs_1 = require("fs");
const promises_1 = require("fs/promises");
const path_1 = require("path");
const vsCodeUtils_1 = require("./vsCodeUtils");
const TEMPLATE_ENCODING = "utf8";
function absoluteTemplateFilePath(relPath) {
    if ((0, vsCodeUtils_1.isVSCodeExtension)()) {
        return (0, path_1.resolve)(__dirname, "templates", relPath);
    }
    return (0, path_1.resolve)(__dirname, "../templates", relPath);
}
function readTemplateSync(relPath) {
    return (0, fs_1.readFileSync)(absoluteTemplateFilePath(relPath), TEMPLATE_ENCODING);
}
function readTemplate(relPath) {
    return (0, promises_1.readFile)(absoluteTemplateFilePath(relPath), TEMPLATE_ENCODING);
}
