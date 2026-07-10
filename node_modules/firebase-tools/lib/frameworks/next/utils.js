"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.I18N_SOURCE = void 0;
exports.cleanEscapedChars = cleanEscapedChars;
exports.cleanCustomRouteI18n = cleanCustomRouteI18n;
exports.cleanI18n = cleanI18n;
exports.isRewriteSupportedByHosting = isRewriteSupportedByHosting;
exports.isRedirectSupportedByHosting = isRedirectSupportedByHosting;
exports.isHeaderSupportedByHosting = isHeaderSupportedByHosting;
exports.getNextjsRewritesToUse = getNextjsRewritesToUse;
exports.usesAppDirRouter = usesAppDirRouter;
exports.usesNextImage = usesNextImage;
exports.hasUnoptimizedImage = hasUnoptimizedImage;
exports.isUsingMiddleware = isUsingMiddleware;
exports.isUsingImageOptimization = isUsingImageOptimization;
exports.isUsingNextImageInAppDirectory = isUsingNextImageInAppDirectory;
exports.isUsingNextImageInServerComponent = isUsingNextImageInServerComponent;
exports.isUsingNextImageInClientComponent = isUsingNextImageInClientComponent;
exports.isUsingAppDirectory = isUsingAppDirectory;
exports.allDependencyNames = allDependencyNames;
exports.getMiddlewareMatcherRegexes = getMiddlewareMatcherRegexes;
exports.getNonStaticRoutes = getNonStaticRoutes;
exports.getNonStaticServerComponents = getNonStaticServerComponents;
exports.getAppMetadataFromMetaFiles = getAppMetadataFromMetaFiles;
exports.getBuildId = getBuildId;
exports.getNextVersion = getNextVersion;
exports.getNextVersionRaw = getNextVersionRaw;
exports.hasStaticAppNotFoundComponent = hasStaticAppNotFoundComponent;
exports.getRoutesWithServerAction = getRoutesWithServerAction;
exports.getProductionDistDirFiles = getProductionDistDirFiles;
exports.whichNextConfigFile = whichNextConfigFile;
exports.findEsbuildPath = findEsbuildPath;
exports.getGlobalEsbuildVersion = getGlobalEsbuildVersion;
exports.installEsbuild = installEsbuild;
exports.isNextJsVersionVulnerable = isNextJsVersionVulnerable;
const fs_1 = require("fs");
const fs_extra_1 = require("fs-extra");
const path_1 = require("path");
const promises_1 = require("fs/promises");
const glob_1 = require("glob");
const semver_1 = require("semver");
const utils_1 = require("../utils");
const constants_1 = require("./constants");
const fsutils_1 = require("../../fsutils");
const utils_2 = require("../../utils");
const child_process_1 = require("child_process");
const error_1 = require("../../error");
exports.I18N_SOURCE = /\/:nextInternalLocale(\([^\)]+\))?/;
function cleanEscapedChars(path) {
    return path.replace(/\\([(){}:+?*])/g, (a, b) => b);
}
function cleanCustomRouteI18n(path) {
    return path.replace(exports.I18N_SOURCE, "");
}
function cleanI18n(it) {
    const [, localesRegex] = it.source.match(exports.I18N_SOURCE) || [undefined, undefined];
    const source = localesRegex ? cleanCustomRouteI18n(it.source) : it.source;
    const destination = "destination" in it && localesRegex ? cleanCustomRouteI18n(it.destination) : it.destination;
    const regex = "regex" in it && localesRegex ? it.regex.replace(`(?:/${localesRegex})`, "") : it.regex;
    return {
        ...it,
        source,
        destination,
        regex,
    };
}
function isRewriteSupportedByHosting(rewrite) {
    return !("has" in rewrite ||
        "missing" in rewrite ||
        (0, utils_1.isUrl)(rewrite.destination) ||
        rewrite.destination.includes("?"));
}
function isRedirectSupportedByHosting(redirect) {
    return !("has" in redirect ||
        "missing" in redirect ||
        "internal" in redirect ||
        redirect.destination.includes("?"));
}
function isHeaderSupportedByHosting(header) {
    return !("has" in header || "missing" in header);
}
function getNextjsRewritesToUse(nextJsRewrites) {
    if (Array.isArray(nextJsRewrites)) {
        return nextJsRewrites.map(cleanI18n);
    }
    if (nextJsRewrites?.beforeFiles) {
        return nextJsRewrites.beforeFiles.map(cleanI18n);
    }
    return [];
}
function usesAppDirRouter(sourceDir) {
    const appPathRoutesManifestPath = (0, path_1.join)(sourceDir, constants_1.APP_PATH_ROUTES_MANIFEST);
    return (0, fs_1.existsSync)(appPathRoutesManifestPath);
}
async function usesNextImage(sourceDir, distDir) {
    const exportMarker = await (0, utils_1.readJSON)((0, path_1.join)(sourceDir, distDir, constants_1.EXPORT_MARKER));
    return exportMarker.isNextImageImported;
}
async function hasUnoptimizedImage(sourceDir, distDir) {
    const imagesManifest = await (0, utils_1.readJSON)((0, path_1.join)(sourceDir, distDir, constants_1.IMAGES_MANIFEST));
    return imagesManifest.images.unoptimized;
}
async function isUsingMiddleware(dir, isDevMode) {
    if (isDevMode) {
        const middlewareFiles = await Promise.all([
            (0, fs_extra_1.pathExists)((0, path_1.join)(dir, "middleware.js")),
            (0, fs_extra_1.pathExists)((0, path_1.join)(dir, "middleware.ts")),
            (0, fs_extra_1.pathExists)((0, path_1.join)(dir, "proxy.js")),
            (0, fs_extra_1.pathExists)((0, path_1.join)(dir, "proxy.ts")),
            (0, fs_extra_1.pathExists)((0, path_1.join)(dir, "src", "middleware.js")),
            (0, fs_extra_1.pathExists)((0, path_1.join)(dir, "src", "middleware.ts")),
            (0, fs_extra_1.pathExists)((0, path_1.join)(dir, "src", "proxy.js")),
            (0, fs_extra_1.pathExists)((0, path_1.join)(dir, "src", "proxy.ts")),
        ]);
        return middlewareFiles.some((file) => file);
    }
    else {
        const middlewareManifest = await (0, utils_1.readJSON)((0, path_1.join)(dir, "server", constants_1.MIDDLEWARE_MANIFEST));
        if (middlewareManifest.version === 3) {
            const functionsConfigManifest = await (0, utils_1.readJSON)((0, path_1.join)(dir, "server", constants_1.FUNCTIONS_CONFIG_MANIFEST)).catch(() => undefined);
            if ((functionsConfigManifest?.functions?.["/_middleware"]?.matchers || [])?.length > 0) {
                return true;
            }
        }
        return Object.keys(middlewareManifest.middleware).length > 0;
    }
}
async function isUsingImageOptimization(projectDir, distDir) {
    let isNextImageImported = await usesNextImage(projectDir, distDir);
    if (!isNextImageImported && isUsingAppDirectory((0, path_1.join)(projectDir, distDir))) {
        isNextImageImported = await isUsingNextImageInAppDirectory(projectDir, distDir);
    }
    if (isNextImageImported) {
        const imagesManifest = await (0, utils_1.readJSON)((0, path_1.join)(projectDir, distDir, constants_1.IMAGES_MANIFEST));
        return !imagesManifest.images.unoptimized;
    }
    return false;
}
async function isUsingNextImageInAppDirectory(projectDir, distDir) {
    return ((await isUsingNextImageInServerComponent(projectDir, distDir)) ||
        isUsingNextImageInClientComponent(projectDir, distDir));
}
async function isUsingNextImageInServerComponent(projectDir, nextDir) {
    const nextImagePath = ["node_modules", "next", "dist", "client", "image"];
    const nextImageString = utils_2.IS_WINDOWS
        ?
            nextImagePath.join(path_1.sep + path_1.sep)
        : (0, path_1.join)(...nextImagePath);
    const files = (0, glob_1.sync)((0, path_1.join)(projectDir, nextDir, "server", "**", "*client-reference-manifest.js"));
    for (const filepath of files) {
        const fileContents = await (0, promises_1.readFile)(filepath, "utf-8");
        if (fileContents.includes(nextImageString)) {
            return true;
        }
    }
    return false;
}
async function isUsingNextImageInClientComponent(projectDir, distDir) {
    const htmlFiles = await (0, glob_1.glob)((0, path_1.join)(projectDir, distDir, "server", "app", "**", "*.html"));
    for (const filepath of htmlFiles) {
        const contents = await (0, promises_1.readFile)(filepath, "utf-8");
        if (contents.includes('data-nimg="')) {
            return true;
        }
    }
    return false;
}
function isUsingAppDirectory(dir) {
    const appPathRoutesManifestPath = (0, path_1.join)(dir, constants_1.APP_PATH_ROUTES_MANIFEST);
    return (0, fsutils_1.fileExistsSync)(appPathRoutesManifestPath);
}
function allDependencyNames(mod) {
    if (!mod.dependencies)
        return [];
    const dependencyNames = Object.keys(mod.dependencies).reduce((acc, it) => [...acc, it, ...allDependencyNames(mod.dependencies[it])], []);
    return dependencyNames;
}
function getMiddlewareMatcherRegexes(middlewareManifest, functionsConfigManifest) {
    const middlewareObjectValues = Object.values(middlewareManifest.middleware);
    const middlewareMatchers = [];
    if (middlewareManifest.version === 1) {
        middlewareMatchers.push(...middlewareObjectValues.map((page) => ({
            regexp: page.regexp,
        })));
    }
    else if (middlewareManifest.version === 2) {
        middlewareMatchers.push(...middlewareObjectValues
            .map((page) => page.matchers)
            .flat());
    }
    else if (middlewareManifest.version === 3) {
        if (functionsConfigManifest?.functions?.["/_middleware"]) {
            middlewareMatchers.push(...(functionsConfigManifest.functions["/_middleware"].matchers || []));
        }
        else {
            middlewareMatchers.push(...middlewareObjectValues
                .map((page) => page.matchers)
                .flat());
        }
    }
    return middlewareMatchers.map((matcher) => new RegExp(matcher.regexp));
}
function getNonStaticRoutes(pagesManifestJSON, prerenderedRoutes, dynamicRoutes) {
    const nonStaticRoutes = Object.entries(pagesManifestJSON)
        .filter(([it, src]) => !((0, path_1.extname)(src) !== ".js" ||
        ["/_app", "/_error", "/_document"].includes(it) ||
        prerenderedRoutes.includes(it) ||
        dynamicRoutes.includes(it)))
        .map(([it]) => it);
    return nonStaticRoutes;
}
function getNonStaticServerComponents(appPathsManifest, appPathRoutesManifest, prerenderedRoutes, dynamicRoutes) {
    const nonStaticServerComponents = Object.entries(appPathsManifest)
        .filter(([it, src]) => {
        if ((0, path_1.extname)(src) !== ".js")
            return;
        const path = appPathRoutesManifest[it];
        return !(prerenderedRoutes.includes(path) || dynamicRoutes.includes(path));
    })
        .map(([it]) => it);
    return new Set(nonStaticServerComponents);
}
async function getAppMetadataFromMetaFiles(sourceDir, distDir, basePath, appPathRoutesManifest) {
    const headers = [];
    const pprRoutes = [];
    await Promise.all(Object.entries(appPathRoutesManifest).map(async ([key, source]) => {
        if (!["route", "page"].includes((0, path_1.basename)(key)))
            return;
        const parts = source.split("/").filter((it) => !!it);
        const partsOrIndex = parts.length > 0 ? parts : ["index"];
        const routePath = (0, path_1.join)(sourceDir, distDir, "server", "app", ...partsOrIndex);
        const metadataPath = `${routePath}.meta`;
        if ((0, fsutils_1.dirExistsSync)(routePath) && (0, fsutils_1.fileExistsSync)(metadataPath)) {
            const meta = await (0, utils_1.readJSON)(metadataPath);
            if (meta.headers)
                headers.push({
                    source: path_1.posix.join(basePath, source),
                    headers: Object.entries(meta.headers).map(([key, value]) => ({ key, value })),
                });
            if (meta.postponed)
                pprRoutes.push(source);
        }
    }));
    return { headers, pprRoutes };
}
async function getBuildId(distDir) {
    const buildId = await (0, promises_1.readFile)((0, path_1.join)(distDir, "BUILD_ID"));
    return buildId.toString();
}
function getNextVersion(cwd) {
    const dependency = (0, utils_1.findDependency)("next", { cwd, depth: 0, omitDev: false });
    if (!dependency)
        return undefined;
    const nextVersionSemver = (0, semver_1.coerce)(dependency.version);
    if (!nextVersionSemver)
        return dependency.version;
    return nextVersionSemver.toString();
}
function getNextVersionRaw(cwd) {
    const dependency = (0, utils_1.findDependency)("next", { cwd, depth: 0, omitDev: false });
    return dependency?.version;
}
async function hasStaticAppNotFoundComponent(sourceDir, distDir) {
    return (0, fs_extra_1.pathExists)((0, path_1.join)(sourceDir, distDir, "server", "app", "_not-found.html"));
}
function getRoutesWithServerAction(serverReferenceManifest, appPathRoutesManifest) {
    const routesWithServerAction = new Set();
    for (const key of Object.keys(serverReferenceManifest)) {
        if (key !== "edge" && key !== "node")
            continue;
        const edgeOrNode = serverReferenceManifest[key];
        for (const actionId of Object.keys(edgeOrNode)) {
            if (!edgeOrNode[actionId].layer)
                continue;
            for (const [route, type] of Object.entries(edgeOrNode[actionId].layer)) {
                if (type === constants_1.WEBPACK_LAYERS.actionBrowser) {
                    routesWithServerAction.add(appPathRoutesManifest[route.replace("app", "")]);
                }
            }
        }
    }
    return Array.from(routesWithServerAction);
}
async function getProductionDistDirFiles(sourceDir, distDir) {
    return (0, glob_1.glob)("**", {
        ignore: [(0, path_1.join)("cache", "webpack", "*-development", "**"), (0, path_1.join)("cache", "eslint", "**")],
        cwd: (0, path_1.join)(sourceDir, distDir),
        nodir: true,
        absolute: false,
    });
}
async function whichNextConfigFile(dir) {
    for (const file of constants_1.CONFIG_FILES) {
        if (await (0, fs_extra_1.pathExists)((0, path_1.join)(dir, file)))
            return file;
    }
    return null;
}
function findEsbuildPath() {
    try {
        const esbuildBinPath = (0, child_process_1.execSync)("npx which esbuild", { encoding: "utf8" })?.trim();
        if (!esbuildBinPath) {
            return null;
        }
        const globalVersion = getGlobalEsbuildVersion(esbuildBinPath);
        if (globalVersion && !(0, semver_1.satisfies)(globalVersion, constants_1.ESBUILD_VERSION)) {
            console.warn(`Warning: Global esbuild version (${globalVersion}) does not match the required version (${constants_1.ESBUILD_VERSION}).`);
        }
        return (0, path_1.resolve)((0, path_1.dirname)(esbuildBinPath), "../esbuild");
    }
    catch (error) {
        console.error(`Failed to find esbuild with npx which: ${error}`);
        return null;
    }
}
function getGlobalEsbuildVersion(binPath) {
    try {
        const versionOutput = (0, child_process_1.execSync)(`"${binPath}" --version`, { encoding: "utf8" })?.trim();
        if (!versionOutput) {
            return null;
        }
        const versionMatch = versionOutput.match(/(\d+\.\d+\.\d+)/);
        return versionMatch ? versionMatch[0] : null;
    }
    catch (error) {
        console.error(`Failed to get global esbuild version: ${error}`);
        return null;
    }
}
function installEsbuild(version) {
    const installCommand = `npm install esbuild@${version} --no-save`;
    try {
        (0, child_process_1.execSync)(installCommand, { stdio: "inherit" });
    }
    catch (error) {
        if (error instanceof error_1.FirebaseError) {
            throw error;
        }
        else {
            throw new error_1.FirebaseError(`Failed to install esbuild: ${error}`, { original: error });
        }
    }
}
function isNextJsVersionVulnerable(versionStr) {
    const v = (0, semver_1.parse)(versionStr);
    if (!v)
        return false;
    if (v.major === 15) {
        if (v.minor === 0)
            return (0, semver_1.lt)(versionStr, "15.0.5");
        if (v.minor === 1)
            return (0, semver_1.lt)(versionStr, "15.1.9");
        if (v.minor === 2)
            return (0, semver_1.lt)(versionStr, "15.2.6");
        if (v.minor === 3)
            return (0, semver_1.lt)(versionStr, "15.3.6");
        if (v.minor === 4)
            return (0, semver_1.lt)(versionStr, "15.4.8");
        if (v.minor === 5)
            return (0, semver_1.lt)(versionStr, "15.5.7");
        return false;
    }
    if (v.major === 16) {
        if (v.minor === 0)
            return (0, semver_1.lt)(versionStr, "16.0.7");
        return false;
    }
    if (v.major === 14) {
        const pre = (0, semver_1.prerelease)(versionStr);
        if (pre && pre.includes("canary")) {
            if ((0, semver_1.gte)(versionStr, "14.3.0-canary.77")) {
                return true;
            }
        }
    }
    return false;
}
