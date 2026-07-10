"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fixDarkBlueText = fixDarkBlueText;
exports.extractExtensionsFromBuilds = extractExtensionsFromBuilds;
exports.extensionMatchesAnyFilter = extensionMatchesAnyFilter;
exports.isTypescriptCodebase = isTypescriptCodebase;
exports.writeFile = writeFile;
exports.copyDirectory = copyDirectory;
exports.getCodebaseRuntime = getCodebaseRuntime;
exports.writeSDK = writeSDK;
exports.getCodebaseDir = getCodebaseDir;
exports.getInstallPathPrefix = getInstallPathPrefix;
exports.toTitleCase = toTitleCase;
exports.capitalizeFirstLetter = capitalizeFirstLetter;
exports.lowercaseFirstLetter = lowercaseFirstLetter;
exports.snakeToCamelCase = snakeToCamelCase;
exports.longestCommonPrefix = longestCommonPrefix;
const fs = require("fs");
const path = require("path");
const prompt_1 = require("../../prompt");
const fsutils = require("../../fsutils");
const utils_1 = require("../../utils");
const error_1 = require("../../error");
const projectConfig_1 = require("../../functions/projectConfig");
const functionRuntimes = require("../../deploy/functions/runtimes");
const nodeRuntime = require("./node");
function fixDarkBlueText(txt) {
    const DARK_BLUE = "\u001b[34m";
    const BRIGHT_CYAN = "\u001b[36;1m";
    return txt.replaceAll(DARK_BLUE, BRIGHT_CYAN);
}
function extractExtensionsFromBuilds(builds, filters) {
    const extRecords = {};
    for (const [codebase, build] of Object.entries(builds)) {
        if (build.extensions) {
            for (const [id, ext] of Object.entries(build.extensions)) {
                if (extensionMatchesAnyFilter(codebase, id, filters)) {
                    if (extRecords[id]) {
                        throw new error_1.FirebaseError(`Duplicate extension id found: ${id}`);
                    }
                    extRecords[id] = { ...ext, labels: { createdBy: "SDK", codebase } };
                }
            }
        }
    }
    return extRecords;
}
function extensionMatchesAnyFilter(codebase, extensionId, filters) {
    if (!filters) {
        return true;
    }
    return filters.some((f) => extensionMatchesFilter(codebase, extensionId, f));
}
function extensionMatchesFilter(codebase, extensionId, filter) {
    if (codebase && filter.codebase) {
        if (codebase !== filter.codebase) {
            return false;
        }
    }
    if (!filter.idChunks) {
        return true;
    }
    const filterId = filter.idChunks.join("-");
    return extensionId === filterId;
}
function isTypescriptCodebase(codebaseDir) {
    return fsutils.fileExistsSync(path.join(codebaseDir, "tsconfig.json"));
}
async function writeFile(filePath, data, options) {
    const shortFilePath = filePath.replace(process.cwd(), ".");
    if (fsutils.fileExistsSync(filePath)) {
        if (await (0, prompt_1.confirm)({
            message: `${shortFilePath} already exists. Overwite it?`,
            nonInteractive: options.nonInteractive,
            force: options.force,
            default: false,
        })) {
            try {
                await fs.promises.writeFile(filePath, data, { flag: "w" });
                (0, utils_1.logLabeledBullet)("extensions", `successfully wrote ${shortFilePath}`);
            }
            catch (err) {
                throw new error_1.FirebaseError(`Failed to write ${shortFilePath}:\n    ${(0, error_1.getErrMsg)(err)}`);
            }
        }
        else {
            return;
        }
    }
    else {
        try {
            await fs.promises.mkdir(path.dirname(filePath), { recursive: true });
            try {
                await fs.promises.writeFile(`${filePath}`, data, { flag: "w" });
                (0, utils_1.logLabeledBullet)("extensions", `successfully created ${shortFilePath}`);
            }
            catch (err) {
                throw new error_1.FirebaseError(`Failed to create ${shortFilePath}:\n    ${(0, error_1.getErrMsg)(err)}`);
            }
        }
        catch (err) {
            throw new error_1.FirebaseError(`Error during SDK file creation:\n    ${(0, error_1.getErrMsg)(err)}`);
        }
    }
}
async function copyDirectory(src, dest, options) {
    const shortDestPath = dest.replace(process.cwd(), ",");
    if (fsutils.dirExistsSync(dest)) {
        if (await (0, prompt_1.confirm)({
            message: `${shortDestPath} already exists. Copy anyway?`,
            nonInteractive: options.nonInteractive,
            force: options.force,
            default: false,
        })) {
            const entries = await fs.promises.readdir(src, { withFileTypes: true });
            for (const entry of entries) {
                const srcPath = path.join(src, entry.name);
                const destPath = path.join(dest, entry.name);
                if (entry.isDirectory()) {
                    if (srcPath.includes("node_modules")) {
                        continue;
                    }
                    await copyDirectory(srcPath, destPath, { ...options, force: true });
                }
                else if (entry.isFile())
                    try {
                        await fs.promises.copyFile(srcPath, destPath);
                    }
                    catch (err) {
                        throw new error_1.FirebaseError(`Failed to copy ${destPath.replace(process.cwd(), ".")}:\n    ${(0, error_1.getErrMsg)(err)}`);
                    }
            }
        }
        else {
            return;
        }
    }
    else {
        await fs.promises.mkdir(dest, { recursive: true });
        await copyDirectory(src, dest, { ...options, force: true });
    }
}
async function getCodebaseRuntime(options) {
    const config = (0, projectConfig_1.normalizeAndValidate)(options.config.src.functions);
    const codebaseConfig = (0, projectConfig_1.configForCodebase)(config, options.codebase || projectConfig_1.DEFAULT_CODEBASE);
    const localCfg = (0, projectConfig_1.requireLocal)(codebaseConfig);
    const sourceDirName = localCfg.source;
    const sourceDir = options.config.path(sourceDirName);
    const delegateContext = {
        projectId: "",
        sourceDir,
        projectDir: options.config.projectDir,
        runtime: localCfg.runtime,
    };
    let delegate;
    try {
        delegate = await functionRuntimes.getRuntimeDelegate(delegateContext);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Could not detect target language for SDK at ${sourceDir}`);
    }
    return delegate.runtime;
}
async function writeSDK(extensionRef, localPath, spec, options) {
    const runtime = await getCodebaseRuntime(options);
    if (runtime.startsWith("nodejs")) {
        let sampleImport = await nodeRuntime.writeSDK(extensionRef, localPath, spec, options);
        sampleImport = fixDarkBlueText(sampleImport);
        return sampleImport;
    }
    else {
        throw new error_1.FirebaseError(`Extension SDK generation is currently only supported for NodeJs. We detected the target source to be: ${runtime}`);
    }
}
function getCodebaseDir(options) {
    if (!options.projectRoot) {
        throw new error_1.FirebaseError("Unable to determine root directory of project");
    }
    const config = (0, projectConfig_1.normalizeAndValidate)(options.config.src.functions);
    const codebaseConfig = (0, projectConfig_1.configForCodebase)(config, options.codebase || projectConfig_1.DEFAULT_CODEBASE);
    return `${options.projectRoot}/${codebaseConfig.source}/`;
}
function getInstallPathPrefix(options) {
    return `${getCodebaseDir(options)}generated/extensions/`;
}
function toTitleCase(txt) {
    return txt.charAt(0).toUpperCase() + txt.substring(1).toLowerCase();
}
function capitalizeFirstLetter(txt) {
    return txt.charAt(0).toUpperCase() + txt.substring(1);
}
function lowercaseFirstLetter(txt) {
    return txt.charAt(0).toLowerCase() + txt.substring(1);
}
function snakeToCamelCase(txt) {
    let ret = txt.toLowerCase();
    ret = ret.replace(/_/g, " ");
    ret = ret.replace(/\w\S*/g, toTitleCase);
    ret = ret.charAt(0).toLowerCase() + ret.substring(1);
    return ret;
}
function longestCommonPrefix(arr) {
    if (arr.length === 0) {
        return "";
    }
    let prefix = "";
    for (let pos = 0; pos < arr[0].length; pos++) {
        if (arr.every((s) => s.charAt(pos) === arr[0][pos])) {
            prefix += arr[0][pos];
        }
        else
            break;
    }
    return prefix;
}
