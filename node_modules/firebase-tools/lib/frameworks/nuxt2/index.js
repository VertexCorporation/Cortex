"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.supportedRange = exports.type = exports.support = exports.name = void 0;
exports.discover = discover;
exports.build = build;
exports.ɵcodegenPublicDirectory = ɵcodegenPublicDirectory;
exports.ɵcodegenFunctionsDirectory = ɵcodegenFunctionsDirectory;
exports.getDevModeHandle = getDevModeHandle;
const fs_extra_1 = require("fs-extra");
const promises_1 = require("fs/promises");
const path_1 = require("path");
const semver_1 = require("semver");
const utils_1 = require("../utils");
const utils_2 = require("../nuxt/utils");
const utils_3 = require("../utils");
const cross_spawn_1 = require("cross-spawn");
exports.name = "Nuxt";
exports.support = "experimental";
exports.type = 2;
exports.supportedRange = "2";
async function getAndLoadNuxt(options) {
    const nuxt = await (0, utils_1.relativeRequire)(options.rootDir, "nuxt/dist/nuxt.js");
    const app = await nuxt.loadNuxt(options);
    await app.ready();
    return { app, nuxt };
}
async function discover(rootDir) {
    if (!(await (0, fs_extra_1.pathExists)((0, path_1.join)(rootDir, "package.json"))))
        return;
    const version = (0, utils_2.getNuxtVersion)(rootDir);
    if (!version || (version && (0, semver_1.gte)(version, "3.0.0-0")))
        return;
    return { mayWantBackend: true, version };
}
async function build(rootDir) {
    const { app, nuxt } = await getAndLoadNuxt({ rootDir, for: "build" });
    const { options: { ssr, target }, } = app;
    const cwd = process.cwd();
    process.chdir(rootDir);
    await nuxt.build(app);
    const { app: generateApp } = await getAndLoadNuxt({ rootDir, for: "start" });
    const builder = await nuxt.getBuilder(generateApp);
    const generator = new nuxt.Generator(generateApp, builder);
    await generator.generate({ build: false, init: true });
    process.chdir(cwd);
    const wantsBackend = ssr && target === "server";
    const rewrites = wantsBackend ? [] : [{ source: "**", destination: "/200.html" }];
    return { wantsBackend, rewrites };
}
async function ɵcodegenPublicDirectory(rootDir, dest) {
    const { app: { options }, } = await getAndLoadNuxt({ rootDir, for: "build" });
    await (0, fs_extra_1.copy)(options.generate.dir, dest);
}
async function ɵcodegenFunctionsDirectory(rootDir, destDir) {
    const packageJsonBuffer = await (0, promises_1.readFile)((0, path_1.join)(rootDir, "package.json"));
    const packageJson = JSON.parse(packageJsonBuffer.toString());
    const { app: { options }, } = await getAndLoadNuxt({ rootDir, for: "build" });
    const { buildDir, _nuxtConfigFile: configFilePath } = options;
    await (0, fs_extra_1.copy)(buildDir, (0, path_1.join)(destDir, (0, path_1.relative)(rootDir, buildDir)));
    await (0, fs_extra_1.copy)(configFilePath, (0, path_1.join)(destDir, (0, path_1.basename)(configFilePath)));
    return { packageJson: { ...packageJson }, frameworksEntry: "nuxt" };
}
async function getDevModeHandle(cwd) {
    const host = new Promise((resolve, reject) => {
        const cli = (0, utils_1.getNodeModuleBin)("nuxt", cwd);
        const serve = (0, cross_spawn_1.spawn)(cli, ["dev"], { cwd });
        serve.stdout.on("data", (data) => {
            process.stdout.write(data);
            const match = data.toString().match(/(http:\/\/.+:\d+)/);
            if (match)
                resolve(match[1]);
        });
        serve.stderr.on("data", (data) => {
            process.stderr.write(data);
        });
        serve.on("exit", reject);
    });
    return (0, utils_3.simpleProxy)(await host);
}
