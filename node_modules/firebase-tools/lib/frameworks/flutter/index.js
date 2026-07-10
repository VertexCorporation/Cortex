"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.support = exports.type = exports.name = void 0;
exports.discover = discover;
exports.init = init;
exports.build = build;
exports.ɵcodegenPublicDirectory = ɵcodegenPublicDirectory;
const cross_spawn_1 = require("cross-spawn");
const fs_extra_1 = require("fs-extra");
const path_1 = require("path");
const error_1 = require("../../error");
const utils_1 = require("./utils");
const constants_1 = require("./constants");
exports.name = "Flutter Web";
exports.type = 3;
exports.support = "experimental";
async function discover(dir) {
    if (!(await (0, fs_extra_1.pathExists)((0, path_1.join)(dir, "pubspec.yaml"))))
        return;
    if (!(await (0, fs_extra_1.pathExists)((0, path_1.join)(dir, "web"))))
        return;
    const pubSpec = await (0, utils_1.getPubSpec)(dir);
    const usingFlutter = pubSpec.dependencies?.flutter;
    if (!usingFlutter)
        return;
    return { mayWantBackend: false };
}
function init(setup, config) {
    (0, utils_1.assertFlutterCliExists)();
    const projectName = constants_1.DART_RESERVED_WORDS.includes(setup.projectId)
        ? constants_1.FALLBACK_PROJECT_NAME
        : setup.projectId.replaceAll("-", "_");
    const result = (0, cross_spawn_1.sync)("flutter", [
        "create",
        "--template=app",
        `--project-name=${projectName}`,
        "--overwrite",
        "--platforms=web",
        setup.featureInfo.hosting.source,
    ], { stdio: "inherit", cwd: config.projectDir });
    if (result.status !== 0)
        throw new error_1.FirebaseError("We were not able to create your flutter app, create the application yourself https://docs.flutter.dev/get-started/test-drive?tab=terminal before trying again.");
    return Promise.resolve();
}
async function build(cwd) {
    (0, utils_1.assertFlutterCliExists)();
    const pubSpec = await (0, utils_1.getPubSpec)(cwd);
    const otherArgs = (0, utils_1.getAdditionalBuildArgs)(pubSpec);
    const buildArgs = ["build", "web", ...otherArgs].filter(Boolean);
    const build = (0, cross_spawn_1.sync)("flutter", buildArgs, { cwd, stdio: "inherit" });
    if (build.status !== 0)
        throw new error_1.FirebaseError("Unable to build your Flutter app");
    return Promise.resolve({ wantsBackend: false });
}
async function ɵcodegenPublicDirectory(sourceDir, destDir) {
    await (0, fs_extra_1.copy)((0, path_1.join)(sourceDir, "build", "web"), destDir);
}
