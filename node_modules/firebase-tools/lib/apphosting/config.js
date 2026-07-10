"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.APPHOSTING_YAML_FILE_REGEX = exports.APPHOSTING_LOCAL_YAML_FILE = exports.APPHOSTING_EMULATORS_YAML_FILE = exports.APPHOSTING_BASE_YAML_FILE = void 0;
exports.discoverBackendRoot = discoverBackendRoot;
exports.listAppHostingFilesInPath = listAppHostingFilesInPath;
exports.load = load;
exports.getAppHostingConfiguration = getAppHostingConfiguration;
exports.store = store;
exports.findEnv = findEnv;
exports.upsertEnv = upsertEnv;
exports.maybeAddSecretToYaml = maybeAddSecretToYaml;
exports.maybeGenerateEmulatorYaml = maybeGenerateEmulatorYaml;
exports.overrideChosenEnv = overrideChosenEnv;
exports.suggestedTestKeyName = suggestedTestKeyName;
exports.splitEnvVars = splitEnvVars;
const path_1 = require("path");
const fs_1 = require("fs");
const yaml = require("yaml");
const clc = require("colorette");
const fs = require("../fsutils");
const prompt = require("../prompt");
const dialogs = require("./secrets/dialogs");
const yaml_1 = require("./yaml");
const logger_1 = require("../logger");
const csm = require("../gcp/secretManager");
const error_1 = require("../error");
exports.APPHOSTING_BASE_YAML_FILE = "apphosting.yaml";
exports.APPHOSTING_EMULATORS_YAML_FILE = "apphosting.emulator.yaml";
exports.APPHOSTING_LOCAL_YAML_FILE = "apphosting.local.yaml";
exports.APPHOSTING_YAML_FILE_REGEX = /^apphosting(\.[a-z0-9_]+)?\.yaml$/;
function discoverBackendRoot(cwd) {
    let dir = cwd;
    while (true) {
        const files = fs.listFiles(dir);
        if (files.some((file) => exports.APPHOSTING_YAML_FILE_REGEX.test(file))) {
            return dir;
        }
        if (files.includes("firebase.json")) {
            return null;
        }
        const parent = (0, path_1.dirname)(dir);
        if (parent === dir) {
            return null;
        }
        dir = parent;
    }
}
function listAppHostingFilesInPath(path) {
    return fs
        .listFiles(path)
        .filter((file) => exports.APPHOSTING_YAML_FILE_REGEX.test(file))
        .map((file) => (0, path_1.join)(path, file));
}
function load(yamlPath) {
    let raw;
    try {
        raw = fs.readFile(yamlPath);
    }
    catch (err) {
        if (err.code !== "ENOENT") {
            throw new error_1.FirebaseError(`Unexpected error trying to load ${yamlPath}`, {
                original: (0, error_1.getError)(err),
            });
        }
        return new yaml.Document();
    }
    return yaml.parseDocument(raw);
}
const dynamicDispatch = exports;
async function getAppHostingConfiguration(backendDir) {
    const appHostingConfigPaths = dynamicDispatch.listAppHostingFilesInPath(backendDir);
    const fileNameToPathMap = Object.fromEntries(appHostingConfigPaths.map((path) => [(0, path_1.basename)(path), path]));
    const output = yaml_1.AppHostingYamlConfig.empty();
    const baseFilePath = fileNameToPathMap[exports.APPHOSTING_BASE_YAML_FILE];
    const emulatorsFilePath = fileNameToPathMap[exports.APPHOSTING_EMULATORS_YAML_FILE];
    const localFilePath = fileNameToPathMap[exports.APPHOSTING_LOCAL_YAML_FILE];
    if (baseFilePath) {
        const baseFile = await yaml_1.AppHostingYamlConfig.loadFromFile(baseFilePath);
        output.merge(baseFile, false);
    }
    if (emulatorsFilePath) {
        const emulatorsConfig = await yaml_1.AppHostingYamlConfig.loadFromFile(emulatorsFilePath);
        output.merge(emulatorsConfig, false);
    }
    if (localFilePath) {
        const localYamlConfig = await yaml_1.AppHostingYamlConfig.loadFromFile(localFilePath);
        output.merge(localYamlConfig, true);
    }
    return output;
}
function store(yamlPath, document) {
    (0, fs_1.writeFileSync)(yamlPath, document.toString());
}
function findEnv(document, variable) {
    if (!document.has("env")) {
        return undefined;
    }
    const envs = document.get("env");
    for (const env of envs.items) {
        if (env.get("variable") === variable) {
            return env.toJSON();
        }
    }
    return undefined;
}
function upsertEnv(document, env) {
    if (!document.has("env")) {
        document.set("env", document.createNode([env]));
        return;
    }
    const envs = document.get("env");
    const envYaml = document.createNode(env);
    for (let i = 0; i < envs.items.length; i++) {
        if (envs.items[i].get("variable") === env.variable) {
            envs.set(i, envYaml);
            return;
        }
    }
    envs.add(envYaml);
}
async function maybeAddSecretToYaml(secretName, fileName = exports.APPHOSTING_BASE_YAML_FILE) {
    const backendRoot = dynamicDispatch.discoverBackendRoot(process.cwd());
    let path;
    let projectYaml;
    if (backendRoot) {
        path = (0, path_1.join)(backendRoot, fileName);
        projectYaml = dynamicDispatch.load(path);
    }
    else {
        projectYaml = new yaml.Document();
    }
    if (dynamicDispatch.findEnv(projectYaml, secretName)) {
        return;
    }
    const addToYaml = await prompt.confirm({
        message: `Would you like to add this secret to ${fileName}?`,
        default: true,
    });
    if (!addToYaml) {
        return;
    }
    if (!path) {
        path = await prompt.input({
            message: `It looks like you don't have an ${fileName} yet. Where would you like to store it?`,
            default: process.cwd(),
        });
        path = (0, path_1.join)(path, fileName);
    }
    const envName = await dialogs.envVarForSecret(secretName, fileName === exports.APPHOSTING_EMULATORS_YAML_FILE);
    dynamicDispatch.upsertEnv(projectYaml, {
        variable: envName,
        secret: secretName,
    });
    dynamicDispatch.store(path, projectYaml);
}
async function maybeGenerateEmulatorYaml(projectId, backendRoot) {
    const basePath = dynamicDispatch.discoverBackendRoot(backendRoot) || backendRoot;
    if (fs.fileExistsSync((0, path_1.join)(basePath, exports.APPHOSTING_EMULATORS_YAML_FILE))) {
        logger_1.logger.debug("apphosting.emulator.yaml already exists, skipping generation and secrets access prompt");
        return null;
    }
    let baseConfig;
    try {
        baseConfig = await yaml_1.AppHostingYamlConfig.loadFromFile((0, path_1.join)(basePath, exports.APPHOSTING_BASE_YAML_FILE));
    }
    catch {
        baseConfig = yaml_1.AppHostingYamlConfig.empty();
    }
    const createFile = await prompt.confirm({
        message: "The App Hosting emulator uses a file called apphosting.emulator.yaml to override " +
            "values in apphosting.yaml for local testing. This codebase does not have one, would you like " +
            "to create it?",
        default: true,
    });
    if (!createFile) {
        return (0, yaml_1.toEnvList)(baseConfig.env);
    }
    const newEnv = await dynamicDispatch.overrideChosenEnv(projectId, baseConfig.env || {});
    const envList = Object.entries(newEnv);
    if (envList.length) {
        const newYaml = new yaml.Document();
        for (const [variable, env] of envList) {
            dynamicDispatch.upsertEnv(newYaml, { variable, ...env });
        }
        dynamicDispatch.store((0, path_1.join)(basePath, exports.APPHOSTING_EMULATORS_YAML_FILE), newYaml);
    }
    else {
        const sample = "env:\n" +
            "#- variable: ENV_VAR_NAME\n" +
            "#  value: plaintext value\n" +
            "#- variable: SECRET_ENV_VAR_NAME\n" +
            "#  secret: cloud-secret-manager-id\n";
        (0, fs_1.writeFileSync)((0, path_1.join)(basePath, exports.APPHOSTING_EMULATORS_YAML_FILE), sample);
    }
    return (0, yaml_1.toEnvList)({ ...baseConfig.env, ...newEnv });
}
async function overrideChosenEnv(projectId, env) {
    const names = Object.keys(env);
    if (!names.length) {
        return {};
    }
    const toOverwrite = await prompt.checkbox({
        message: "Which environment variables would you like to override?",
        choices: names,
    });
    if (!projectId && toOverwrite.some((name) => "secret" in env[name])) {
        throw new error_1.FirebaseError(`Need a project ID to overwrite a secret. Either use ${clc.bold("firebase use")} or pass the ${clc.bold("--project")} flag`);
    }
    const newEnv = {};
    for (const name of toOverwrite) {
        if ("value" in env[name]) {
            const newValue = await prompt.input(`What new value would you like for plaintext ${name}?`);
            newEnv[name] = { variable: name, value: newValue };
            continue;
        }
        let secretRef;
        let action = "pick-new";
        while (action === "pick-new") {
            secretRef = await prompt.input({
                message: `What would you like to name the secret reference for ${name}?`,
                default: suggestedTestKeyName(name),
            });
            if (await csm.secretExists(projectId, secretRef)) {
                action = await prompt.select({
                    message: "This secret reference already exists, would you like to reuse it or create a new one?",
                    choices: [
                        { name: "Reuse it", value: "reuse" },
                        { name: "Create a new one", value: "pick-new" },
                    ],
                });
            }
            else {
                action = "create";
            }
        }
        newEnv[name] = { variable: name, secret: secretRef };
        if (action === "reuse") {
            continue;
        }
        const secretValue = await prompt.password(`What new value would you like for secret ${name} [input is hidden]?`);
        await csm.createSecret(projectId, secretRef, { [csm.FIREBASE_MANAGED]: "apphosting" });
        await csm.addVersion(projectId, secretRef, secretValue);
    }
    return newEnv;
}
function suggestedTestKeyName(variable) {
    return "test-" + variable.replace(/_/g, "-").toLowerCase();
}
function splitEnvVars(env) {
    const build = {};
    const runtime = {};
    for (const [key, val] of Object.entries(env)) {
        const envVal = { ...val };
        if (envVal.value !== undefined) {
            envVal.value = String(envVal.value);
        }
        if (val.availability?.includes("BUILD") || !val.availability) {
            build[key] = envVal;
        }
        if (val.availability?.includes("RUNTIME") || !val.availability) {
            runtime[key] = envVal;
        }
    }
    return { build, runtime };
}
