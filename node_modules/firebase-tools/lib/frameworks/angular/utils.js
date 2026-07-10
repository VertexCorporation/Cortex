"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ANGULAR_22_DEFAULT_SERVER_ENTRY = exports.ANGULAR_22_RECOMMENDED_ALLOWED_HOSTS = exports.BuilderType = void 0;
exports.getAllTargets = getAllTargets;
exports.getContext = getContext;
exports.getBrowserConfig = getBrowserConfig;
exports.getServerConfig = getServerConfig;
exports.getBuildConfig = getBuildConfig;
exports.getAngularVersion = getAngularVersion;
exports.tryToGetOptionsForTarget = tryToGetOptionsForTarget;
exports.getBuilderType = getBuilderType;
exports.getAngular22SsrSecurityWarning = getAngular22SsrSecurityWarning;
exports.formatAngular22SsrSecurityWarning = formatAngular22SsrSecurityWarning;
exports.maybeWarnAngular22SsrSecurity = maybeWarnAngular22SsrSecurity;
exports.extractAngular22AllowedHostsFromBuildOptions = extractAngular22AllowedHostsFromBuildOptions;
exports.getAngular22ServerEntryPath = getAngular22ServerEntryPath;
const utils_1 = require("../utils");
const error_1 = require("../../error");
const path_1 = require("path");
const promises_1 = require("fs/promises");
const assert_1 = require("assert");
const utils_2 = require("../../utils");
const semver_1 = require("semver");
const clc = require("colorette");
async function localesForTarget(dir, architectHost, target, workspaceProject) {
    const { targetStringFromTarget } = await (0, utils_1.relativeRequire)(dir, "@angular-devkit/architect");
    const targetOptions = await architectHost.getOptionsForTarget(target);
    if (!targetOptions) {
        const targetString = targetStringFromTarget(target);
        throw new error_1.FirebaseError(`Couldn't find options for ${targetString}.`);
    }
    let locales = undefined;
    let defaultLocale = undefined;
    if (targetOptions.localize) {
        const i18n = workspaceProject.extensions?.i18n;
        if (!i18n)
            throw new error_1.FirebaseError(`No i18n config on project.`);
        if (typeof i18n.sourceLocale === "string") {
            throw new error_1.FirebaseError(`All your i18n locales must have a baseHref of "" on Firebase, use an object for sourceLocale in your angular.json:
  "i18n": {
    "sourceLocale": {
      "code": "${i18n.sourceLocale}",
      "baseHref": ""
    },
    ...
  }`);
        }
        if (i18n.sourceLocale.baseHref !== "")
            throw new error_1.FirebaseError('All your i18n locales must have a baseHref of "" on Firebase, errored on sourceLocale.');
        defaultLocale = i18n.sourceLocale.code;
        if (targetOptions.localize === true) {
            locales = [defaultLocale];
            for (const [locale, { baseHref }] of Object.entries(i18n.locales)) {
                if (baseHref !== "")
                    throw new error_1.FirebaseError(`All your i18n locales must have a baseHref of \"\" on Firebase, errored on ${locale}.`);
                locales.push(locale);
            }
        }
        else if (Array.isArray(targetOptions.localize)) {
            locales = [defaultLocale];
            for (const locale of targetOptions.localize) {
                if (typeof locale !== "string")
                    continue;
                locales.push(locale);
            }
        }
    }
    (0, utils_1.validateLocales)(locales);
    return { locales, defaultLocale };
}
var BuilderType;
(function (BuilderType) {
    BuilderType["DEPLOY"] = "deploy";
    BuilderType["DEV_SERVER"] = "dev-server";
    BuilderType["SSR_DEV_SERVER"] = "ssr-dev-server";
    BuilderType["SERVER"] = "server";
    BuilderType["BROWSER"] = "browser";
    BuilderType["BROWSER_ESBUILD"] = "browser-esbuild";
    BuilderType["APPLICATION"] = "application";
    BuilderType["PRERENDER"] = "prerender";
})(BuilderType || (exports.BuilderType = BuilderType = {}));
const DEV_SERVER_TARGETS = [BuilderType.DEV_SERVER, BuilderType.SSR_DEV_SERVER];
function getValidBuilderTypes(purpose) {
    return [
        BuilderType.APPLICATION,
        BuilderType.BROWSER_ESBUILD,
        BuilderType.DEPLOY,
        BuilderType.BROWSER,
        BuilderType.PRERENDER,
        ...(purpose === "deploy" ? [] : DEV_SERVER_TARGETS),
    ];
}
async function getAllTargets(purpose, dir) {
    const validBuilderTypes = getValidBuilderTypes(purpose);
    const [{ NodeJsAsyncHost }, { workspaces }, { targetStringFromTarget }] = await Promise.all([
        (0, utils_1.relativeRequire)(dir, "@angular-devkit/core/node"),
        (0, utils_1.relativeRequire)(dir, "@angular-devkit/core"),
        (0, utils_1.relativeRequire)(dir, "@angular-devkit/architect"),
    ]);
    const host = workspaces.createWorkspaceHost(new NodeJsAsyncHost());
    const { workspace } = await workspaces.readWorkspace(dir, host);
    const targets = [];
    workspace.projects.forEach((projectDefinition, project) => {
        if (projectDefinition.extensions.projectType !== "application")
            return;
        projectDefinition.targets.forEach((targetDefinition, target) => {
            const builderType = getBuilderType(targetDefinition.builder);
            if (builderType && !validBuilderTypes.includes(builderType)) {
                return;
            }
            const configurations = Object.keys(targetDefinition.configurations || {});
            if (!configurations.includes("production"))
                configurations.push("production");
            if (!configurations.includes("development"))
                configurations.push("development");
            configurations.forEach((configuration) => {
                targets.push(targetStringFromTarget({ project, target, configuration }));
            });
        });
    });
    return targets;
}
async function getContext(dir, targetOrConfiguration) {
    const [{ NodeJsAsyncHost }, { workspaces }, { WorkspaceNodeModulesArchitectHost }, { Architect, targetFromTargetString, targetStringFromTarget }, { parse },] = await Promise.all([
        (0, utils_1.relativeRequire)(dir, "@angular-devkit/core/node"),
        (0, utils_1.relativeRequire)(dir, "@angular-devkit/core"),
        (0, utils_1.relativeRequire)(dir, "@angular-devkit/architect/node"),
        (0, utils_1.relativeRequire)(dir, "@angular-devkit/architect"),
        (0, utils_1.relativeRequire)(dir, "jsonc-parser"),
    ]);
    const host = workspaces.createWorkspaceHost(new NodeJsAsyncHost());
    const { workspace } = await workspaces.readWorkspace(dir, host);
    const architectHost = new WorkspaceNodeModulesArchitectHost(workspace, dir);
    const architect = new Architect(architectHost);
    let overrideTarget;
    let deployTarget;
    let project;
    let buildTarget;
    let browserTarget;
    let serverTarget;
    let prerenderTarget;
    let serveTarget;
    let serveOptimizedImages = false;
    let configuration = undefined;
    if (targetOrConfiguration) {
        try {
            overrideTarget = targetFromTargetString(targetOrConfiguration);
            configuration = overrideTarget.configuration;
            project = overrideTarget.project;
        }
        catch (e) {
            configuration = targetOrConfiguration;
        }
    }
    if (!project) {
        const angularJson = parse(await host.readFile((0, path_1.join)(dir, "angular.json")));
        project = angularJson.defaultProject;
    }
    if (!project) {
        const apps = [];
        workspace.projects.forEach((value, key) => {
            if (value.extensions.projectType === "application")
                apps.push(key);
        });
        if (apps.length === 1)
            project = apps[0];
    }
    if (!project) {
        throwCannotDetermineTarget();
    }
    const workspaceProject = workspace.projects.get(project);
    if (!workspaceProject)
        throw new error_1.FirebaseError(`No project ${project} found.`);
    if (overrideTarget) {
        const target = workspaceProject.targets.get(overrideTarget.target);
        const builderType = getBuilderType(target.builder);
        switch (builderType) {
            case BuilderType.DEPLOY:
                deployTarget = overrideTarget;
                break;
            case BuilderType.APPLICATION:
                buildTarget = overrideTarget;
                break;
            case BuilderType.BROWSER:
            case BuilderType.BROWSER_ESBUILD:
                browserTarget = overrideTarget;
                break;
            case BuilderType.PRERENDER:
                prerenderTarget = overrideTarget;
                break;
            case BuilderType.DEV_SERVER:
            case BuilderType.SSR_DEV_SERVER:
                serveTarget = overrideTarget;
                break;
            default:
                throw new error_1.FirebaseError(`builder type ${builderType} not known.`);
        }
    }
    else if (workspaceProject.targets.has("deploy")) {
        const { builder, defaultConfiguration = "production" } = workspaceProject.targets.get("deploy");
        if (getBuilderType(builder) === BuilderType.DEPLOY) {
            deployTarget = {
                project,
                target: "deploy",
                configuration: configuration || defaultConfiguration,
            };
        }
    }
    if (deployTarget) {
        const options = await architectHost
            .getOptionsForTarget(deployTarget)
            .catch(() => workspaceProject.targets.get(deployTarget.target)?.options);
        if (!options)
            throw new error_1.FirebaseError("Unable to get options for ng-deploy.");
        if (options.buildTarget) {
            (0, utils_2.assertIsString)(options.buildTarget);
            buildTarget = targetFromTargetString(options.buildTarget);
        }
        if (options.prerenderTarget) {
            (0, utils_2.assertIsString)(options.prerenderTarget);
            prerenderTarget = targetFromTargetString(options.prerenderTarget);
        }
        if (options.browserTarget) {
            (0, utils_2.assertIsString)(options.browserTarget);
            browserTarget = targetFromTargetString(options.browserTarget);
        }
        if (options.serverTarget) {
            (0, utils_2.assertIsString)(options.serverTarget);
            serverTarget = targetFromTargetString(options.serverTarget);
        }
        if (options.serveTarget) {
            (0, utils_2.assertIsString)(options.serveTarget);
            serveTarget = targetFromTargetString(options.serveTarget);
        }
        if (options.serveOptimizedImages) {
            serveOptimizedImages = true;
        }
        if (prerenderTarget) {
            const prerenderOptions = await architectHost.getOptionsForTarget(prerenderTarget);
            if (!browserTarget) {
                throw new error_1.FirebaseError("ng-deploy with prerenderTarget requires a browserTarget");
            }
            if (targetStringFromTarget(browserTarget) !== prerenderOptions?.browserTarget) {
                throw new error_1.FirebaseError("ng-deploy's browserTarget and prerender's browserTarget do not match. Please check your angular.json");
            }
            if (serverTarget && targetStringFromTarget(serverTarget) !== prerenderOptions?.serverTarget) {
                throw new error_1.FirebaseError("ng-deploy's serverTarget and prerender's serverTarget do not match. Please check your angular.json");
            }
            if (!serverTarget) {
                console.warn("Treating the application as fully rendered. Add a serverTarget to your deploy target in angular.json to utilize server-side rendering.");
            }
        }
        if (!buildTarget && !browserTarget) {
            throw new error_1.FirebaseError("ng-deploy is missing a build target. Plase check your angular.json.");
        }
    }
    else if (!overrideTarget) {
        if (workspaceProject.targets.has("prerender")) {
            const { defaultConfiguration = "production" } = workspaceProject.targets.get("prerender");
            prerenderTarget = {
                project,
                target: "prerender",
                configuration: configuration || defaultConfiguration,
            };
            const options = await architectHost.getOptionsForTarget(prerenderTarget);
            (0, utils_2.assertIsString)(options?.browserTarget);
            browserTarget = targetFromTargetString(options.browserTarget);
            (0, utils_2.assertIsString)(options?.serverTarget);
            serverTarget = targetFromTargetString(options.serverTarget);
        }
        if (!buildTarget && !browserTarget && workspaceProject.targets.has("build")) {
            const { builder, defaultConfiguration = "production" } = workspaceProject.targets.get("build");
            const builderType = getBuilderType(builder);
            const target = {
                project,
                target: "build",
                configuration: configuration || defaultConfiguration,
            };
            if (builderType === BuilderType.BROWSER || builderType === BuilderType.BROWSER_ESBUILD) {
                browserTarget = target;
            }
            else {
                buildTarget = target;
            }
        }
        if (!serverTarget && workspaceProject.targets.has("server")) {
            const { defaultConfiguration = "production" } = workspaceProject.targets.get("server");
            serverTarget = {
                project,
                target: "server",
                configuration: configuration || defaultConfiguration,
            };
        }
    }
    if (!serveTarget) {
        if (serverTarget && workspaceProject.targets.has("serve-ssr")) {
            const { defaultConfiguration = "development" } = workspaceProject.targets.get("serve-ssr");
            serveTarget = {
                project,
                target: "serve-ssr",
                configuration: configuration || defaultConfiguration,
            };
        }
        else if (workspaceProject.targets.has("serve")) {
            const { defaultConfiguration = "development" } = workspaceProject.targets.get("serve");
            serveTarget = {
                project,
                target: "serve",
                configuration: configuration || defaultConfiguration,
            };
        }
    }
    for (const target of [
        deployTarget,
        buildTarget,
        prerenderTarget,
        serverTarget,
        browserTarget,
        serveTarget,
    ]) {
        if (target) {
            const targetString = targetStringFromTarget(target);
            if (target.project !== project)
                throw new error_1.FirebaseError(`${targetString} is not in project ${project}. Please check your angular.json`);
            const definition = workspaceProject.targets.get(target.target);
            if (!definition)
                throw new error_1.FirebaseError(`${target} could not be found in your angular.json`);
            const { builder } = definition;
            const builderType = getBuilderType(builder);
            if (target === deployTarget && builderType === BuilderType.DEPLOY)
                continue;
            if (target === buildTarget && builderType === BuilderType.APPLICATION)
                continue;
            if (target === buildTarget && builderType === BuilderType.BROWSER)
                continue;
            if (target === browserTarget && builderType === BuilderType.BROWSER_ESBUILD)
                continue;
            if (target === browserTarget && builderType === BuilderType.BROWSER)
                continue;
            if (target === browserTarget && builderType === BuilderType.APPLICATION)
                continue;
            if (target === prerenderTarget && builderType === BuilderType.PRERENDER)
                continue;
            if (target === prerenderTarget && builderType === BuilderType.PRERENDER)
                continue;
            if (target === serverTarget && builderType === BuilderType.SERVER)
                continue;
            if (target === serveTarget && builderType === BuilderType.SSR_DEV_SERVER)
                continue;
            if (target === serveTarget && builderType === BuilderType.DEV_SERVER)
                continue;
            if (target === serveTarget && builderType === BuilderType.SERVER)
                continue;
            throw new error_1.FirebaseError(`${definition.builder} (${targetString}) is not a recognized builder. Please check your angular.json`);
        }
    }
    const buildOrBrowserTarget = buildTarget || browserTarget;
    if (!buildOrBrowserTarget) {
        throw new error_1.FirebaseError(`No build target on ${project}`);
    }
    const browserTargetOptions = await tryToGetOptionsForTarget(architectHost, buildOrBrowserTarget);
    if (!browserTargetOptions) {
        const targetString = targetStringFromTarget(buildOrBrowserTarget);
        throw new error_1.FirebaseError(`Couldn't find options for ${targetString}.`);
    }
    const baseHref = browserTargetOptions.baseHref || "/";
    (0, utils_2.assertIsString)(baseHref);
    const buildTargetOptions = buildTarget && (await tryToGetOptionsForTarget(architectHost, buildTarget));
    const ssr = buildTarget ? !!buildTargetOptions?.ssr : !!serverTarget;
    return {
        architect,
        architectHost,
        baseHref,
        host,
        buildTarget,
        browserTarget,
        prerenderTarget,
        serverTarget,
        serveTarget,
        workspaceProject,
        serveOptimizedImages,
        ssr,
        buildTargetOptions: buildTargetOptions || undefined,
    };
}
async function getBrowserConfig(sourceDir, configuration) {
    const { architectHost, browserTarget, buildTarget, baseHref, workspaceProject } = await getContext(sourceDir, configuration);
    const buildOrBrowserTarget = buildTarget || browserTarget;
    if (!buildOrBrowserTarget) {
        throw new assert_1.AssertionError({ message: "expected build or browser target defined" });
    }
    const [{ locales, defaultLocale }, targetOptions, builderName] = await Promise.all([
        localesForTarget(sourceDir, architectHost, buildOrBrowserTarget, workspaceProject),
        architectHost.getOptionsForTarget(buildOrBrowserTarget),
        architectHost.getBuilderNameForTarget(buildOrBrowserTarget),
    ]);
    const buildOutputPath = typeof targetOptions?.outputPath === "string"
        ? targetOptions.outputPath
        : (0, path_1.join)("dist", buildOrBrowserTarget.project);
    const outputPath = (0, path_1.join)(buildOutputPath, buildTarget && getBuilderType(builderName) === BuilderType.APPLICATION ? "browser" : "");
    return { locales, baseHref, outputPath, defaultLocale };
}
async function getServerConfig(sourceDir, configuration) {
    const { architectHost, host, buildTarget, serverTarget, browserTarget, baseHref, workspaceProject, serveOptimizedImages, ssr, } = await getContext(sourceDir, configuration);
    const buildOrBrowserTarget = buildTarget || browserTarget;
    if (!buildOrBrowserTarget) {
        throw new assert_1.AssertionError({ message: "expected build or browser target to be defined" });
    }
    const browserTargetOptions = await architectHost.getOptionsForTarget(buildOrBrowserTarget);
    const buildOutputPath = typeof browserTargetOptions?.outputPath === "string"
        ? browserTargetOptions.outputPath
        : (0, path_1.join)("dist", buildOrBrowserTarget.project);
    const browserOutputPath = (0, path_1.join)(buildOutputPath, buildTarget ? "browser" : "")
        .split(path_1.sep)
        .join(path_1.posix.sep);
    const packageJson = JSON.parse(await host.readFile((0, path_1.join)(sourceDir, "package.json")));
    if (!ssr) {
        return {
            packageJson,
            browserOutputPath,
            serverOutputPath: undefined,
            baseHref,
            bundleDependencies: false,
            externalDependencies: [],
            serverLocales: [],
            browserLocales: undefined,
            defaultLocale: undefined,
            serveOptimizedImages,
        };
    }
    const buildOrServerTarget = buildTarget || serverTarget;
    if (!buildOrServerTarget) {
        throw new assert_1.AssertionError({ message: "expected build or server target to be defined" });
    }
    const { locales: serverLocales, defaultLocale } = await localesForTarget(sourceDir, architectHost, buildOrServerTarget, workspaceProject);
    const serverTargetOptions = await architectHost.getOptionsForTarget(buildOrServerTarget);
    if (!serverTargetOptions) {
        throw new assert_1.AssertionError({
            message: `expected "JsonObject" but got "${typeof serverTargetOptions}"`,
        });
    }
    const serverTargetOutputPath = typeof serverTargetOptions?.outputPath === "string"
        ? serverTargetOptions.outputPath
        : (0, path_1.join)("dist", buildOrServerTarget.project);
    const serverOutputPath = (0, path_1.join)(serverTargetOutputPath, buildTarget ? "server" : "")
        .split(path_1.sep)
        .join(path_1.posix.sep);
    if (serverLocales && !defaultLocale) {
        throw new error_1.FirebaseError("It's required that your source locale to be one of the localize options");
    }
    const serverEntry = buildTarget ? "server.mjs" : serverTarget && "main.js";
    const externalDependencies = serverTargetOptions.externalDependencies || [];
    const bundleDependencies = serverTargetOptions.bundleDependencies ?? true;
    const { locales: browserLocales } = await localesForTarget(sourceDir, architectHost, buildOrBrowserTarget, workspaceProject);
    return {
        packageJson,
        browserOutputPath,
        serverOutputPath,
        baseHref,
        bundleDependencies,
        externalDependencies,
        serverLocales,
        browserLocales,
        defaultLocale,
        serveOptimizedImages,
        serverEntry,
    };
}
async function getBuildConfig(sourceDir, configuration) {
    const { targetStringFromTarget } = await (0, utils_1.relativeRequire)(sourceDir, "@angular-devkit/architect");
    const { buildTarget, browserTarget, baseHref, prerenderTarget, serverTarget, architectHost, workspaceProject, serveOptimizedImages, ssr, buildTargetOptions, } = await getContext(sourceDir, configuration);
    const targets = (buildTarget
        ? [buildTarget]
        : prerenderTarget
            ? [prerenderTarget]
            : [browserTarget, serverTarget].filter((it) => !!it)).map((it) => targetStringFromTarget(it));
    const buildOrBrowserTarget = buildTarget || browserTarget;
    if (!buildOrBrowserTarget) {
        throw new assert_1.AssertionError({ message: "expected build or browser target defined" });
    }
    const locales = await localesForTarget(sourceDir, architectHost, buildOrBrowserTarget, workspaceProject);
    return {
        targets,
        baseHref,
        locales,
        serveOptimizedImages,
        ssr,
        buildTargetOptions,
    };
}
function getAngularVersion(cwd) {
    const dependency = (0, utils_1.findDependency)("@angular/core", { cwd, depth: 0, omitDev: false });
    if (!dependency)
        return undefined;
    const angularVersionSemver = (0, semver_1.coerce)(dependency.version);
    if (!angularVersionSemver)
        return dependency.version;
    return angularVersionSemver.toString();
}
async function tryToGetOptionsForTarget(architectHost, target) {
    return await architectHost.getOptionsForTarget(target).catch(throwCannotDetermineTarget);
}
function throwCannotDetermineTarget(error) {
    throw new error_1.FirebaseError(`Unable to determine the application to deploy, specify a target via the FIREBASE_FRAMEWORKS_BUILD_TARGET environment variable.`, { original: error });
}
function getBuilderType(builder) {
    const colonIndex = builder.lastIndexOf(":");
    const builderType = colonIndex >= 0 ? builder.slice(colonIndex + 1) : undefined;
    if (!builderType || !Object.values(BuilderType).includes(builderType)) {
        return null;
    }
    return builderType;
}
const ANGULAR_22_PUBLIC_HOST_PATTERNS = ["*.web.app", "*.firebaseapp.com"];
const ANGULAR_22_CLOUD_RUN_HOST_PATTERNS = ["*.a.run.app"];
exports.ANGULAR_22_RECOMMENDED_ALLOWED_HOSTS = [
    ...ANGULAR_22_PUBLIC_HOST_PATTERNS,
    ...ANGULAR_22_CLOUD_RUN_HOST_PATTERNS,
];
function getAngular22SsrSecurityWarning(opts) {
    if (!opts.ssr)
        return undefined;
    const declared = opts.buildOptionsAllowedHosts ?? [];
    const serverHasAllowedHosts = !!opts.serverEntrySource && /\ballowedHosts\s*[:=]/.test(opts.serverEntrySource);
    if (declared.includes("*") || (serverHasAllowedHosts && declared.length === 0)) {
        return undefined;
    }
    const trustProxyHeadersEnabled = !!opts.serverEntrySource && /\btrustProxyHeaders\s*[:=]/.test(opts.serverEntrySource);
    const requiredHostPatterns = trustProxyHeadersEnabled
        ? ANGULAR_22_PUBLIC_HOST_PATTERNS
        : ANGULAR_22_CLOUD_RUN_HOST_PATTERNS;
    if (requiredHostPatterns.every((pattern) => declared.includes(pattern)))
        return undefined;
    const allowedHostsMissing = exports.ANGULAR_22_RECOMMENDED_ALLOWED_HOSTS.filter((pattern) => !declared.includes(pattern));
    return { allowedHostsMissing, trustProxyHeadersEnabled };
}
function formatAngular22SsrSecurityWarning(warning) {
    const sections = [
        "Angular 22 enabled strict SSRF protection on its SSR engine. Without the matching security.allowedHosts entries, the SSR function will reject requests and return errors after deploy.",
        [
            "Add these hostnames to security.allowedHosts in angular.json:",
            `  ${JSON.stringify(warning.allowedHostsMissing)}`,
            `${clc.bold("Documentation")}: https://angular.dev/best-practices/security#configuring-allowed-hosts`,
        ].join("\n"),
    ];
    if (!warning.trustProxyHeadersEnabled) {
        sections.push([
            "Alternatively, enable trustProxyHeaders so the engine validates the forwarded Hosting domain instead of the SSR function host. If you do, also add any custom domains you serve from to security.allowedHosts.",
            `${clc.bold("Documentation")}: https://angular.dev/best-practices/security#configuring-trusted-proxy-headers`,
        ].join("\n"));
    }
    const message = sections.join("\n\n");
    return message
        .split("\n")
        .map((line, i) => (i === 0 ? line : "  " + line))
        .join("\n")
        .concat("\n");
}
async function maybeWarnAngular22SsrSecurity(dir, opts) {
    try {
        const version = getAngularVersion(dir);
        if (!version)
            return;
        const semver = (0, semver_1.coerce)(version);
        if (!semver || semver.major < 22)
            return;
        if (!opts.ssr)
            return;
        const buildOptionsAllowedHosts = extractAngular22AllowedHostsFromBuildOptions(opts.buildTargetOptions);
        const entryPath = getAngular22ServerEntryPath(opts.buildTargetOptions);
        let serverEntrySource;
        try {
            serverEntrySource = await (0, promises_1.readFile)((0, path_1.join)(dir, entryPath), "utf8");
        }
        catch {
        }
        const warning = getAngular22SsrSecurityWarning({
            ssr: opts.ssr,
            buildOptionsAllowedHosts,
            serverEntrySource,
        });
        if (!warning)
            return;
        (0, utils_2.logLabeledWarning)("Angular 22", formatAngular22SsrSecurityWarning(warning));
    }
    catch {
    }
}
function extractAngular22AllowedHostsFromBuildOptions(options) {
    const security = options?.security;
    if (!security || !Array.isArray(security.allowedHosts))
        return undefined;
    return security.allowedHosts.filter((h) => typeof h === "string");
}
exports.ANGULAR_22_DEFAULT_SERVER_ENTRY = "src/server.ts";
function getAngular22ServerEntryPath(options) {
    const ssr = options?.ssr;
    if (ssr && typeof ssr !== "boolean" && typeof ssr.entry === "string") {
        return ssr.entry;
    }
    return exports.ANGULAR_22_DEFAULT_SERVER_ENTRY;
}
