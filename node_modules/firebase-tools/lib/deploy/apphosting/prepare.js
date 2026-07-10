"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = default_1;
exports.injectEnvVarsFromApphostingConfig = injectEnvVarsFromApphostingConfig;
exports.injectAutoInitEnvVars = injectAutoInitEnvVars;
exports.getBackendConfigs = getBackendConfigs;
exports.injectAngularEnvVars = injectAngularEnvVars;
const crypto = require("crypto");
const fs = require("fs");
const os = require("os");
const path = require("path");
const fsAsync = require("../../fsAsync");
const util_1 = require("./util");
const backend_1 = require("../../apphosting/backend");
const apphosting_1 = require("../../gcp/apphosting");
const yaml_1 = require("../../apphosting/yaml");
const config_1 = require("../../apphosting/config");
const devConnect_1 = require("../../gcp/devConnect");
const resourceManager_1 = require("../../gcp/resourceManager");
const projectUtils_1 = require("../../projectUtils");
const getProjectNumber_1 = require("../../getProjectNumber");
const prompt_1 = require("../../prompt");
const utils_1 = require("../../utils");
const localbuilds_1 = require("../../apphosting/localbuilds");
const error_1 = require("../../error");
const managementApps = require("../../management/apps");
const utils_2 = require("../../apphosting/utils");
const experiments = require("../../experiments");
const logger_1 = require("../../logger");
async function default_1(context, options) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    await (0, apphosting_1.ensureApiEnabled)(options);
    await (0, backend_1.ensureRequiredApisEnabled)(projectId);
    await (0, backend_1.ensureAppHostingComputeServiceAccount)(projectId, "");
    context.backendConfigs = {};
    context.backendLocations = {};
    context.backendStorageUris = {};
    context.backendLocalBuilds = {};
    const configs = getBackendConfigs(options);
    if (configs.some((cfg) => cfg.localBuild) && experiments.isEnabled("apphostinglocalbuilds")) {
        const projectNumber = await (0, getProjectNumber_1.getProjectNumber)(options);
        await ensureAppHostingServiceAgentRoles(projectId, projectNumber);
    }
    const { backends } = await (0, apphosting_1.listBackends)(projectId, "-");
    const foundBackends = [];
    const notFoundBackends = [];
    const ambiguousBackends = [];
    const skippedBackends = [];
    for (const cfg of configs) {
        const filteredBackends = backends.filter((backend) => (0, apphosting_1.parseBackendName)(backend.name).id === cfg.backendId);
        if (filteredBackends.length === 0) {
            notFoundBackends.push(cfg);
        }
        else if (filteredBackends.length === 1) {
            foundBackends.push(cfg);
        }
        else {
            ambiguousBackends.push(cfg);
        }
    }
    for (const cfg of ambiguousBackends) {
        const filteredBackends = backends.filter((backend) => (0, apphosting_1.parseBackendName)(backend.name).id === cfg.backendId);
        const locations = filteredBackends.map((b) => (0, apphosting_1.parseBackendName)(b.name).location);
        (0, utils_1.logLabeledWarning)("apphosting", `You have multiple backends with the same ${cfg.backendId} ID in regions: ${locations.join(", ")}. This is not allowed until we can support more locations. ` +
            "Please delete and recreate any backends that share an ID with another backend.");
    }
    if (foundBackends.length > 0) {
        (0, utils_1.logLabeledBullet)("apphosting", `Found backend(s) ${foundBackends.map((cfg) => cfg.backendId).join(", ")}`);
    }
    for (const cfg of foundBackends) {
        const filteredBackends = backends.filter((backend) => (0, apphosting_1.parseBackendName)(backend.name).id === cfg.backendId);
        if (cfg.alwaysDeployFromSource === false) {
            skippedBackends.push(cfg);
            continue;
        }
        const backend = filteredBackends[0];
        const { location } = (0, apphosting_1.parseBackendName)(backend.name);
        if (cfg.alwaysDeployFromSource === undefined && backend.codebase?.repository) {
            const { connectionName, id } = (0, devConnect_1.parseGitRepositoryLinkName)(backend.codebase.repository);
            const gitRepositoryLink = await (0, devConnect_1.getGitRepositoryLink)(projectId, location, connectionName, id);
            if (!options.force) {
                const confirmDeploy = await (0, prompt_1.confirm)({
                    default: true,
                    message: `${cfg.backendId} is linked to the remote repository at ${gitRepositoryLink.cloneUri}. Are you sure you want to deploy your local source?`,
                });
                cfg.alwaysDeployFromSource = confirmDeploy;
                const configPath = path.join(options.projectRoot || "", "firebase.json");
                options.config.writeProjectFile(configPath, options.config.src);
                (0, utils_1.logLabeledBullet)("apphosting", `On future invocations of "firebase deploy", your local source will ${!confirmDeploy ? "not " : ""}be deployed to ${cfg.backendId}. You can edit this setting in your firebase.json at any time.`);
                if (!confirmDeploy) {
                    skippedBackends.push(cfg);
                    continue;
                }
            }
        }
        context.backendConfigs[cfg.backendId] = cfg;
        context.backendLocations[cfg.backendId] = location;
    }
    if (notFoundBackends.length > 0) {
        if (options.force) {
            (0, utils_1.logLabeledWarning)("apphosting", `Skipping deployments of backend(s) ${notFoundBackends.map((cfg) => cfg.backendId).join(", ")}; ` +
                "the backend(s) do not exist yet and we cannot create them for you because you must choose primary regions for each one. " +
                "Please run 'firebase deploy' without the --force flag, or 'firebase apphosting:backends:create' to create the backend, " +
                "then retry deployment.");
            return;
        }
        const confirmCreate = await (0, prompt_1.confirm)({
            default: true,
            message: `Did not find backend(s) ${notFoundBackends.map((cfg) => cfg.backendId).join(", ")}. Do you want to create them (you'll have the option to select which to create in the next step)?`,
        });
        if (confirmCreate) {
            const selected = await (0, prompt_1.checkbox)({
                message: "Which backends do you want to create and deploy to?",
                choices: notFoundBackends.map((cfg) => cfg.backendId),
            });
            const selectedBackends = selected.map((id) => notFoundBackends.find((backend) => backend.backendId === id));
            for (const cfg of selectedBackends) {
                (0, utils_1.logLabeledBullet)("apphosting", `Creating a new backend ${cfg.backendId}...`);
                const { location } = await (0, backend_1.doSetupSourceDeploy)(projectId, cfg.backendId, options.nonInteractive, cfg.rootDir);
                context.backendConfigs[cfg.backendId] = cfg;
                context.backendLocations[cfg.backendId] = location;
            }
        }
        else {
            skippedBackends.push(...notFoundBackends);
        }
    }
    if (skippedBackends.length > 0) {
        (0, utils_1.logLabeledWarning)("apphosting", `Skipping deployment of backend(s) ${skippedBackends.map((cfg) => cfg.backendId).join(", ")}.`);
    }
    const buildEnv = {};
    const runtimeEnv = {};
    for (const cfg of Object.values(context.backendConfigs)) {
        if (!cfg.localBuild) {
            continue;
        }
        experiments.assertEnabled("apphostinglocalbuilds", "locally build App Hosting backends");
        let backend = backends.find((b) => (0, apphosting_1.parseBackendName)(b.name).id === cfg.backendId);
        if (!backend) {
            const location = context.backendLocations[cfg.backendId];
            if (location) {
                const apphosting = await Promise.resolve().then(() => require("../../gcp/apphosting"));
                try {
                    backend = await apphosting.getBackend(projectId, location, cfg.backendId);
                }
                catch {
                }
            }
        }
        if (!backend) {
            throw new error_1.FirebaseError(`Backend ${cfg.backendId} not found.`);
        }
        const rootDir = path.resolve(options.projectRoot || process.cwd());
        const appDir = path.join(rootDir, cfg.rootDir || "");
        (0, localbuilds_1.validateLocalBuildNodeVersion)(backend, appDir);
        (0, utils_1.logLabeledBullet)("apphosting", `Starting local build for backend ${cfg.backendId}`);
        await injectEnvVarsFromApphostingConfig(configs.filter((c) => c.backendId === cfg.backendId), options, buildEnv, runtimeEnv);
        await injectAutoInitEnvVars(cfg, backends, buildEnv, runtimeEnv);
        const location = context.backendLocations[cfg.backendId];
        await injectAngularEnvVars(cfg, rootDir, projectId, location, buildEnv, runtimeEnv);
        const pathHash = crypto.createHash("md5").update(rootDir).digest("hex").substring(0, 8);
        const localBuildScratchDir = path.join(os.tmpdir(), `apphosting-local-build-${cfg.backendId}-${pathHash}`);
        try {
            await prepareLocalBuildScratchDirectory(rootDir, localBuildScratchDir, cfg);
            const { outputFiles, buildConfig } = await (0, localbuilds_1.localBuild)(projectId, localBuildScratchDir, buildEnv[cfg.backendId] || {}, {
                nonInteractive: options.nonInteractive,
                allowLocalBuildSecrets: !!options.allowLocalBuildSecrets,
            });
            context.backendLocalBuilds[cfg.backendId] = {
                outputFiles,
                localBuildScratchDir,
                buildConfig: {
                    ...buildConfig,
                    env: mergeEnvVars(buildConfig.env || [], runtimeEnv[cfg.backendId] || {}),
                },
            };
        }
        catch (e) {
            const errorMsg = e instanceof Error ? e.message : String(e);
            throw new error_1.FirebaseError(`Local Build for backend ${cfg.backendId} failed: ${errorMsg}`);
        }
    }
}
async function injectEnvVarsFromApphostingConfig(configs, options, buildEnv, runtimeEnv) {
    for (const cfg of configs) {
        const rootDir = options.projectRoot || process.cwd();
        const appDir = path.join(rootDir, cfg.rootDir || "");
        let yamlConfig = yaml_1.AppHostingYamlConfig.empty();
        try {
            yamlConfig = await (0, config_1.getAppHostingConfiguration)(appDir);
        }
        catch (e) {
            (0, utils_1.logLabeledWarning)("apphosting", `Failed to read apphosting.yaml, may be missing environment variables and other configs`);
        }
        const { build, runtime } = (0, config_1.splitEnvVars)(yamlConfig.env);
        buildEnv[cfg.backendId] = { ...buildEnv[cfg.backendId], ...build };
        runtimeEnv[cfg.backendId] = { ...runtimeEnv[cfg.backendId], ...runtime };
    }
}
async function injectAutoInitEnvVars(cfg, backends, buildEnv, runtimeEnv) {
    var _a, _b;
    const backend = backends.find((b) => (0, apphosting_1.parseBackendName)(b.name).id === cfg.backendId);
    if (backend?.appId) {
        try {
            const webappConfig = (await managementApps.getAppConfig(backend.appId, managementApps.AppPlatform.WEB));
            const autoinitVars = (0, utils_2.getAutoinitEnvVars)(webappConfig);
            for (const [envVarName, envVarValue] of Object.entries(autoinitVars)) {
                (_a = buildEnv[cfg.backendId])[envVarName] ?? (_a[envVarName] = { value: envVarValue });
                (_b = runtimeEnv[cfg.backendId])[envVarName] ?? (_b[envVarName] = { value: envVarValue });
            }
        }
        catch (e) {
            (0, utils_1.logLabeledWarning)("apphosting", `Unable to lookup details for backend ${cfg.backendId}. Firebase SDK autoinit will not be available.`);
        }
    }
}
function getBackendConfigs(options) {
    if (!options.config.src.apphosting) {
        return [];
    }
    const backendConfigs = Array.isArray(options.config.src.apphosting)
        ? options.config.src.apphosting
        : [options.config.src.apphosting];
    if (!options.only) {
        return backendConfigs;
    }
    const selectors = options.only.split(",");
    const backendIds = [];
    for (const selector of selectors) {
        if (selector === "apphosting") {
            return backendConfigs;
        }
        if (selector.startsWith("apphosting:")) {
            const backendId = selector.replace("apphosting:", "");
            if (backendId.length > 0) {
                backendIds.push(backendId);
            }
        }
    }
    if (backendIds.length === 0) {
        return [];
    }
    const filteredConfigs = backendConfigs.filter((cfg) => backendIds.includes(cfg.backendId));
    const foundIds = filteredConfigs.map((cfg) => cfg.backendId);
    const missingIds = backendIds.filter((id) => !foundIds.includes(id));
    if (missingIds.length > 0) {
        throw new error_1.FirebaseError(`App Hosting backend IDs ${missingIds.join(",")} not detected in firebase.json`);
    }
    return filteredConfigs;
}
function mergeEnvVars(base, overrides) {
    const merged = new Map();
    for (const env of base) {
        if (env.variable) {
            merged.set(env.variable, env);
        }
    }
    for (const [envVarName, envVarConfig] of Object.entries(overrides)) {
        merged.set(envVarName, { ...envVarConfig, variable: envVarName });
    }
    return Array.from(merged.values());
}
async function ensureAppHostingServiceAgentRoles(projectId, projectNumber) {
    const p4saEmail = (0, apphosting_1.serviceAgentEmail)(projectNumber);
    try {
        await (0, resourceManager_1.addServiceAccountToRoles)(projectId, p4saEmail, ["roles/storage.objectViewer"], true);
    }
    catch (err) {
        logger_1.logger.debug(`Failed to grant storage.objectViewer to ${p4saEmail}: ${String(err)}`);
        (0, utils_1.logLabeledWarning)("apphosting", `Unable to verify App Hosting service agent permissions for ${p4saEmail}. If you encounter a PERMISSION_DENIED error during rollout, please ensure the service agent has the "Storage Object Viewer" role.`);
    }
}
async function prepareLocalBuildScratchDirectory(rootDir, localBuildScratchDir, cfg) {
    const ignore = (0, util_1.resolveIgnorePatterns)(cfg);
    fs.rmSync(localBuildScratchDir, { recursive: true, force: true });
    fs.mkdirSync(localBuildScratchDir, { recursive: true });
    const filesToCopy = await fsAsync.readdirRecursive({
        path: rootDir,
        ignoreStrings: ignore,
        supportGitIgnore: true,
    });
    for (const file of filesToCopy) {
        const relativePath = path.relative(rootDir, file.name);
        const destPath = path.join(localBuildScratchDir, relativePath);
        fs.mkdirSync(path.dirname(destPath), { recursive: true });
        fs.copyFileSync(file.name, destPath);
    }
}
function isAngularApplication(appDir) {
    const packageJsonPath = path.join(appDir, "package.json");
    if (fs.existsSync(packageJsonPath)) {
        try {
            const parsed = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
            if (parsed && typeof parsed === "object") {
                const pkg = parsed;
                const angularDeps = ["@angular/core", "@angular/ssr", "@angular/platform-server"];
                if (angularDeps.some((d) => pkg.dependencies?.[d] || pkg.devDependencies?.[d])) {
                    return true;
                }
            }
        }
        catch (e) {
            (0, utils_1.logLabeledError)("apphosting", `error when checking if application is angular: ${e instanceof Error ? e.message : String(e)}`);
        }
    }
    const angularJsonPath = path.join(appDir, "angular.json");
    if (fs.existsSync(angularJsonPath)) {
        return true;
    }
    return false;
}
async function injectAngularEnvVars(cfg, projectRoot, projectId, location, buildEnv, runtimeEnv) {
    const appDir = path.join(projectRoot, cfg.rootDir || "");
    if (!isAngularApplication(appDir)) {
        return;
    }
    if (!location) {
        throw new error_1.FirebaseError(`Failed to find location for backend ${cfg.backendId}.`);
    }
    const backendId = cfg.backendId;
    runtimeEnv[backendId] ?? (runtimeEnv[backendId] = {});
    buildEnv[backendId] ?? (buildEnv[backendId] = {});
    const allowedProxyHeaders = [
        "x-forwarded-host",
        "x-forwarded-port",
        "x-forwarded-proto",
        "x-forwarded-for",
    ];
    const allowedProxyHeadersValue = allowedProxyHeaders.join(",");
    let shouldInjectProxyHeaders = true;
    if (runtimeEnv[backendId]["NG_TRUST_PROXY_HEADERS"]) {
        const userProxyHeadersStr = runtimeEnv[backendId]["NG_TRUST_PROXY_HEADERS"].value;
        const userProxyHeaders = userProxyHeadersStr
            ? userProxyHeadersStr
                .split(",")
                .map((h) => h.trim().toLowerCase())
                .filter(Boolean)
            : [];
        const isSubset = userProxyHeaders.length > 0 && userProxyHeaders.every((h) => allowedProxyHeaders.includes(h));
        if (isSubset) {
            shouldInjectProxyHeaders = false;
        }
        else {
            throw new error_1.FirebaseError(`User-defined RUNTIME environment variable NG_TRUST_PROXY_HEADERS contains invalid headers. Allowed values: ${allowedProxyHeadersValue}`);
        }
    }
    if (shouldInjectProxyHeaders) {
        runtimeEnv[backendId]["NG_TRUST_PROXY_HEADERS"] = {
            value: allowedProxyHeadersValue,
            availability: ["RUNTIME"],
        };
    }
    if (!runtimeEnv[backendId]["NG_ALLOWED_HOSTS"]) {
        const projectNumber = await (0, getProjectNumber_1.getProjectNumber)({ project: projectId });
        const sharedDomain = "hosted.app";
        const defaultHosts = [
            `${backendId}-${projectNumber}.${location}.run.app`,
            `${backendId}--${projectId}.${location}.${sharedDomain}`,
            `${backendId}--${projectId}.web.app`,
            `${backendId}--${projectId}.firebaseapp.com`,
        ];
        runtimeEnv[backendId]["NG_ALLOWED_HOSTS"] = {
            value: defaultHosts.join(","),
            availability: ["RUNTIME"],
        };
    }
}
