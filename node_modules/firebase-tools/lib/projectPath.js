"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resolveProjectPath = resolveProjectPath;
const path = require("path");
const detectProjectRoot_1 = require("./detectProjectRoot");
const error_1 = require("./error");
function resolveProjectPath(options, filePath) {
    const projectRoot = (0, detectProjectRoot_1.detectProjectRoot)(options);
    if (!projectRoot) {
        throw new error_1.FirebaseError("Expected to be in a project directory, but none was found.", {
            exit: 2,
        });
    }
    return path.resolve(projectRoot, filePath);
}
