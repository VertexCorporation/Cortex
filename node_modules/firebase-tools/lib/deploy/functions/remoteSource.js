"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getRemoteSource = getRemoteSource;
exports.requireFunctionsYaml = requireFunctionsYaml;
const fs = require("fs");
const path = require("path");
const url_1 = require("url");
const error_1 = require("../../error");
const logger_1 = require("../../logger");
const utils_1 = require("../../utils");
const fsutils_1 = require("../../fsutils");
const downloadUtils = require("../../downloadUtils");
const unzipModule = require("../../unzip");
async function getRemoteSource(repository, ref, destDir, subDir) {
    logger_1.logger.debug(`Downloading remote source: ${repository}@${ref} (destDir: ${destDir}, subDir: ${subDir || "."})`);
    const gitHubInfo = parseGitHubUrl(repository);
    if (!gitHubInfo) {
        throw new error_1.FirebaseError(`Could not parse GitHub repository URL: ${repository}. ` +
            `Only GitHub repositories are supported.`);
    }
    let rootDir = destDir;
    try {
        logger_1.logger.debug(`Attempting to download via GitHub Archive API for ${repository}@${ref}...`);
        const archiveUrl = `https://github.com/${gitHubInfo.owner}/${gitHubInfo.repo}/archive/${ref}.zip`;
        const archivePath = await downloadUtils.downloadToTmp(archiveUrl);
        logger_1.logger.debug(`Downloaded archive to ${archivePath}, unzipping...`);
        await unzipModule.unzip(archivePath, destDir);
        const files = fs.readdirSync(destDir);
        if (files.length === 1 && fs.statSync(path.join(destDir, files[0])).isDirectory()) {
            rootDir = path.join(destDir, files[0]);
            logger_1.logger.debug(`Found top-level directory in archive: ${files[0]}`);
        }
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to download GitHub archive for ${repository}@${ref}. ` +
            `Make sure the repository is public and the ref exists. ` +
            `Private repositories are not supported via this method.`, { original: err });
    }
    const sourceDir = subDir
        ? (0, utils_1.resolveWithin)(rootDir, subDir, `Subdirectory '${subDir}' in remote source must not escape the repository root.`)
        : rootDir;
    if (subDir && !(0, fsutils_1.dirExistsSync)(sourceDir)) {
        throw new error_1.FirebaseError(`Directory '${subDir}' not found in repository ${repository}@${ref}`);
    }
    const origin = `${repository}@${ref}${subDir ? `/${subDir}` : ""}`;
    (0, utils_1.logLabeledBullet)("functions", `downloaded remote source (${origin})`);
    return sourceDir;
}
function parseGitHubUrl(url) {
    const shorthandMatch = /^[a-zA-Z0-9-]+\/[a-zA-Z0-9-_.]+$/.exec(url);
    if (shorthandMatch) {
        const [owner, repo] = url.split("/");
        return { owner, repo };
    }
    try {
        const u = new url_1.URL(url);
        if (u.hostname !== "github.com") {
            return undefined;
        }
        const parts = u.pathname.split("/").filter((p) => !!p);
        if (parts.length < 2) {
            return undefined;
        }
        const owner = parts[0];
        let repo = parts[1];
        if (repo.endsWith(".git")) {
            repo = repo.slice(0, -4);
        }
        return { owner, repo };
    }
    catch {
        return undefined;
    }
}
function requireFunctionsYaml(codeDir) {
    const functionsYamlPath = path.join(codeDir, "functions.yaml");
    if (!(0, fsutils_1.fileExistsSync)(functionsYamlPath)) {
        throw new error_1.FirebaseError(`The remote repository is missing a required deployment manifest (functions.yaml).\n\n` +
            `For your security, Firebase requires a static manifest to deploy functions from a remote source. ` +
            `This prevents the execution of arbitrary code on your machine during the function discovery process.\n\n` +
            `If you trust this repository and want to use it anyway, clone the repository locally, inspect the code for safety, and deploy it as a local source.`);
    }
}
