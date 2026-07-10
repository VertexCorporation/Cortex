"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.readdirRecursive = readdirRecursive;
const fs_extra_1 = require("fs-extra");
const ignore_1 = require("ignore");
const _ = require("lodash");
const minimatch = require("minimatch");
const path_1 = require("path");
const logger_1 = require("./logger");
async function readdirRecursiveHelper(options) {
    const dirContents = (0, fs_extra_1.readdirSync)(options.path, { withFileTypes: true });
    let currentGitIgnoreStack = options.gitIgnoreStack || [];
    if (options.supportGitIgnore) {
        if (dirContents.find((n) => n.name === ".gitignore")?.isFile()) {
            const localGitIgnore = (0, path_1.join)(options.path, ".gitignore");
            try {
                const lines = (0, fs_extra_1.readFileSync)(localGitIgnore)
                    .toString()
                    .split("\n")
                    .map((line) => line.trim())
                    .filter((line) => !line.startsWith("#") && line !== "");
                const subIgnore = (0, ignore_1.default)().add(lines);
                currentGitIgnoreStack = [
                    ...currentGitIgnoreStack,
                    {
                        dirPath: options.path,
                        ignore: subIgnore,
                    },
                ];
            }
            catch (e) {
                logger_1.logger.debug(`Error reading .gitignore file at ${localGitIgnore}:`, e);
            }
        }
    }
    const fullPaths = dirContents
        .filter((n) => !options.ignoreSymlinks || !n.isSymbolicLink())
        .map((n) => (0, path_1.join)(options.path, n.name));
    const filteredPaths = fullPaths.filter((p) => !options.filter(p, currentGitIgnoreStack));
    const filePromises = [];
    for (const p of filteredPaths) {
        const fstat = (0, fs_extra_1.statSync)(p);
        if (fstat.isFile()) {
            filePromises.push(Promise.resolve({ name: p, mode: fstat.mode }));
        }
        if (!fstat.isDirectory()) {
            continue;
        }
        if (options.maxDepth > 1) {
            filePromises.push(readdirRecursiveHelper({
                path: p,
                filter: options.filter,
                maxDepth: options.maxDepth - 1,
                ignoreSymlinks: options.ignoreSymlinks,
                supportGitIgnore: options.supportGitIgnore,
                gitIgnoreStack: currentGitIgnoreStack,
            }));
        }
    }
    const files = await Promise.all(filePromises);
    let flatFiles = _.flattenDeep(files);
    flatFiles = flatFiles.filter((f) => f !== null);
    return flatFiles;
}
async function readdirRecursive(options) {
    const mmopts = { matchBase: true, dot: true };
    const ignoreRules = (options.ignoreStrings || []).map((glob) => {
        return (p) => minimatch(p, glob, mmopts);
    });
    const filter = (targetPath, gitIgnoreStack = []) => {
        if (options.supportGitIgnore) {
            let ignored = false;
            for (let i = gitIgnoreStack.length - 1; i >= 0; i--) {
                const state = gitIgnoreStack[i];
                const relPath = (0, path_1.relative)(state.dirPath, targetPath);
                const result = state.ignore.test(relPath);
                if (result.ignored || result.unignored) {
                    ignored = result.ignored;
                    break;
                }
            }
            return ignored;
        }
        return ignoreRules.some((rule) => {
            return rule(targetPath);
        });
    };
    const initialGitIgnoreStack = [];
    if (options.supportGitIgnore) {
        initialGitIgnoreStack.push({
            dirPath: options.path,
            ignore: (0, ignore_1.default)().add(options.ignoreStrings || []),
        });
    }
    const maxDepth = options.maxDepth && options.maxDepth > 0 ? options.maxDepth : Infinity;
    return await readdirRecursiveHelper({
        path: options.path,
        filter: filter,
        maxDepth,
        ignoreSymlinks: !!options.ignoreSymlinks,
        supportGitIgnore: options.supportGitIgnore,
        gitIgnoreStack: initialGitIgnoreStack,
    });
}
