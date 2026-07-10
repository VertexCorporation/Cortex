"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.packageJsonIsValid = packageJsonIsValid;
const path = require("path");
const error_1 = require("../../../../error");
const logger_1 = require("../../../../logger");
const fsutils = require("../../../../fsutils");
const cjson = require("cjson");
function assertFunctionsSourcePresent(data, sourceDir, projectDir) {
    const indexJsFile = path.join(sourceDir, data.main || "index.js");
    if (!fsutils.fileExistsSync(indexJsFile)) {
        const relativeMainPath = path.relative(projectDir, indexJsFile);
        const msg = `${relativeMainPath} does not exist, can't deploy Cloud Functions`;
        throw new error_1.FirebaseError(msg);
    }
}
function packageJsonIsValid(sourceDirName, sourceDir, projectDir) {
    const packageJsonFile = path.join(sourceDir, "package.json");
    if (!fsutils.fileExistsSync(packageJsonFile)) {
        const msg = `No npm package found in functions source directory ${sourceDirName}.`;
        throw new error_1.FirebaseError(msg);
    }
    let data;
    try {
        data = cjson.load(packageJsonFile);
        logger_1.logger.debug("> [functions] package.json contents:", JSON.stringify(data, null, 2));
        assertFunctionsSourcePresent(data, sourceDir, projectDir);
    }
    catch (e) {
        const msg = `There was an error reading ${sourceDirName}${path.sep}package.json:\n\n ${e.message}`;
        throw new error_1.FirebaseError(msg);
    }
}
