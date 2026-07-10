"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const path = require("path");
const fs_extra_1 = require("fs-extra");
const fsAsync_1 = require("../fsAsync");
const command_1 = require("../command");
const error_1 = require("../error");
const utils_1 = require("../utils");
const projectUtils_1 = require("../projectUtils");
const getProjectNumber_1 = require("../getProjectNumber");
const requireAuth_1 = require("../requireAuth");
const sourcemap_1 = require("../crashlytics/sourcemap");
exports.command = new command_1.Command("crashlytics:sourcemap:upload [mappingFiles]")
    .description("upload javascript source maps to de-minify stack traces")
    .option("--app <appID>", "the app id of your Firebase app")
    .option("--bucket-location <bucketLocation>", 'the location of the Google Cloud Storage bucket (default: "US-CENTRAL1"')
    .option("--app-version <appVersion>", "the version of your Firebase app (defaults to Git commit hash, if available)")
    .before(requireAuth_1.requireAuth)
    .action(async (mappingFiles, options) => {
    (0, sourcemap_1.checkGoogleAppID)(options);
    const appVersion = (0, sourcemap_1.getAppVersion)(options);
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const projectNumber = await (0, getProjectNumber_1.getProjectNumber)(options);
    const bucketName = await (0, sourcemap_1.upsertBucket)(projectId, projectNumber, options);
    const rootDir = path.resolve(options.projectRoot ?? process.cwd());
    const filePath = mappingFiles ? path.resolve(mappingFiles) : rootDir;
    let fstat;
    try {
        fstat = (0, fs_extra_1.statSync)(filePath);
    }
    catch (e) {
        throw new error_1.FirebaseError("provide a valid directory to mapping file(s), e.g. app/build/outputs");
    }
    let successCount = 0;
    const failedFiles = [];
    if (fstat.isDirectory()) {
        (0, utils_1.logLabeledBullet)("crashlytics", "Looking for mapping files in your directory...");
        const files = await (0, fsAsync_1.readdirRecursive)({
            path: filePath,
            ignoreStrings: ["node_modules", ".git"],
            maxDepth: 20,
        });
        const mappings = await (0, sourcemap_1.findSourceMapMappings)(files, rootDir);
        const result = await (0, sourcemap_1.uploadSourceMaps)(mappings, {
            projectId,
            bucketName,
            appVersion,
            options,
        });
        successCount = result.successCount;
        failedFiles.push(...result.failedFiles);
    }
    else {
        throw new error_1.FirebaseError("provide a valid directory to mapping file(s), e.g. app/build/outputs");
    }
    (0, utils_1.logLabeledBullet)("crashlytics", `Uploaded ${successCount} (${failedFiles.length} failed) mapping files to ${bucketName}`);
    if (failedFiles.length > 0) {
        (0, utils_1.logLabeledBullet)("crashlytics", `Could not upload the following files:\n${failedFiles.join("\n")}`);
    }
});
