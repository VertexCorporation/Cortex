"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ENV_DIRECTORY = void 0;
exports.writeToManifest = writeToManifest;
exports.writeEmptyManifest = writeEmptyManifest;
exports.writeLocalSecrets = writeLocalSecrets;
exports.removeFromManifest = removeFromManifest;
exports.loadConfig = loadConfig;
exports.instanceExists = instanceExists;
exports.getInstanceTarget = getInstanceTarget;
exports.getInstanceRef = getInstanceRef;
exports.writeExtensionsToFirebaseJson = writeExtensionsToFirebaseJson;
exports.readInstanceParam = readInstanceParam;
const path = require("path");
const fs = require("fs-extra");
const refs = require("./refs");
const config_1 = require("../config");
const planner_1 = require("../deploy/extensions/planner");
const logger_1 = require("../logger");
const prompt_1 = require("../prompt");
const paramHelper_1 = require("./paramHelper");
const error_1 = require("../error");
const extensionsHelper_1 = require("./extensionsHelper");
const types_1 = require("./types");
exports.ENV_DIRECTORY = "extensions";
async function writeToManifest(specs, config, options, allowOverwrite = false) {
    if (config.has("extensions") &&
        Object.keys(config.get("extensions")).length &&
        !options.nonInteractive &&
        !options.force) {
        const currentExtensions = Object.entries(config.get("extensions"))
            .map((i) => `${i[0]}: ${i[1]}`)
            .join("\n\t");
        if (allowOverwrite) {
            const overwrite = await (0, prompt_1.select)({
                message: `firebase.json already contains extensions:\n${currentExtensions}\nWould you like to overwrite or merge?`,
                choices: [
                    { name: "Overwrite", value: true },
                    { name: "Merge", value: false },
                ],
            });
            if (overwrite) {
                config.set("extensions", {});
            }
        }
    }
    writeExtensionsToFirebaseJson(specs, config);
    await writeEnvFiles(specs, config, options.force);
    await writeLocalSecrets(specs, config, options.force);
}
async function writeEmptyManifest(config, options) {
    if (!fs.existsSync(config.path("extensions"))) {
        fs.mkdirSync(config.path("extensions"));
    }
    if (config.has("extensions") && Object.keys(config.get("extensions")).length) {
        const currentExtensions = Object.entries(config.get("extensions"))
            .map((i) => `${i[0]}: ${i[1]}`)
            .join("\n\t");
        if (!(await (0, prompt_1.confirm)({
            message: `firebase.json already contains extensions:\n${currentExtensions}\nWould you like to overwrite them?`,
            nonInteractive: options?.nonInteractive,
            force: options?.force,
            default: false,
        }))) {
            return;
        }
    }
    config.set("extensions", {});
}
async function writeLocalSecrets(specs, config, force) {
    for (const spec of specs) {
        const extensionSpec = await (0, planner_1.getExtensionSpec)(spec);
        if (!extensionSpec.params) {
            continue;
        }
        const writeBuffer = {};
        const locallyOverridenSecretParams = extensionSpec.params.filter((p) => p.type === types_1.ParamType.SECRET && spec.params[p.param]?.local);
        for (const paramSpec of locallyOverridenSecretParams) {
            const key = paramSpec.param;
            const localValue = spec.params[key].local;
            writeBuffer[key] = localValue;
        }
        const content = Object.entries(writeBuffer)
            .sort((a, b) => {
            return a[0].localeCompare(b[0]);
        })
            .map((r) => `${r[0]}=${r[1]}`)
            .join("\n");
        if (content) {
            await config.askWriteProjectFile(`extensions/${spec.instanceId}.secret.local`, content, force);
        }
    }
}
function removeFromManifest(instanceId, config) {
    if (!instanceExists(instanceId, config)) {
        throw new error_1.FirebaseError(`Extension instance ${instanceId} not found in firebase.json.`);
    }
    const extensions = config.get("extensions", {});
    extensions[instanceId] = undefined;
    config.set("extensions", extensions);
    config.writeProjectFile("firebase.json", config.src);
    logger_1.logger.info(`Removed extension instance ${instanceId} from firebase.json`);
    config.deleteProjectFile(`extensions/${instanceId}.env`);
    logger_1.logger.info(`Removed extension instance environment config extensions/${instanceId}.env`);
    if (config.projectFileExists(`extensions/${instanceId}.env.local`)) {
        config.deleteProjectFile(`extensions/${instanceId}.env.local`);
        logger_1.logger.info(`Removed extension instance local environment config extensions/${instanceId}.env.local`);
    }
    if (config.projectFileExists(`extensions/${instanceId}.secret.local`)) {
        config.deleteProjectFile(`extensions/${instanceId}.secret.local`);
        logger_1.logger.info(`Removed extension instance local secret config extensions/${instanceId}.secret.local`);
    }
}
function loadConfig(options) {
    const existingConfig = config_1.Config.load(options, true);
    if (!existingConfig) {
        throw new error_1.FirebaseError("Not currently in a Firebase directory. Run `firebase init` to create a Firebase directory.");
    }
    return existingConfig;
}
function instanceExists(instanceId, config) {
    return !!config.get("extensions", {})[instanceId];
}
function getInstanceTarget(instanceId, config) {
    if (!instanceExists(instanceId, config)) {
        throw new error_1.FirebaseError(`Could not find extension instance ${instanceId} in firebase.json`);
    }
    return config.get("extensions", {})[instanceId];
}
function getInstanceRef(instanceId, config) {
    const source = getInstanceTarget(instanceId, config);
    if ((0, extensionsHelper_1.isLocalPath)(source)) {
        throw new error_1.FirebaseError(`Extension instance ${instanceId} doesn't have a ref because it is from a local source`);
    }
    return refs.parse(source);
}
function writeExtensionsToFirebaseJson(specs, config) {
    const extensions = config.get("extensions", {});
    for (const s of specs) {
        let target;
        if (s.ref) {
            target = refs.toExtensionVersionRef(s.ref);
        }
        else if (s.localPath) {
            target = s.localPath;
        }
        else {
            throw new error_1.FirebaseError(`Unable to resolve ManifestInstanceSpec, make sure you provide either extension ref or a local path to extension source code`);
        }
        extensions[s.instanceId] = target;
    }
    config.set("extensions", extensions);
    config.writeProjectFile("firebase.json", config.src);
}
async function writeEnvFiles(specs, config, force) {
    for (const spec of specs) {
        const content = Object.entries(spec.params)
            .filter((r) => r[1].baseValue !== "" && r[1].baseValue !== undefined)
            .sort((a, b) => {
            return a[0].localeCompare(b[0]);
        })
            .map((r) => `${r[0]}=${r[1].baseValue}`)
            .join("\n");
        await config.askWriteProjectFile(`extensions/${spec.instanceId}.env`, content, force);
    }
}
function readInstanceParam(args) {
    const aliases = args.aliases ?? [];
    const filesToCheck = [
        `${args.instanceId}.env`,
        ...aliases.map((alias) => `${args.instanceId}.env.${alias}`),
        ...(args.projectNumber ? [`${args.instanceId}.env.${args.projectNumber}`] : []),
        ...(args.projectId ? [`${args.instanceId}.env.${args.projectId}`] : []),
    ];
    if (args.checkLocal) {
        filesToCheck.push(`${args.instanceId}.env.local`);
    }
    let noFilesFound = true;
    const combinedParams = {};
    for (const fileToCheck of filesToCheck) {
        try {
            const params = readParamsFile(args.projectDir, fileToCheck);
            logger_1.logger.debug(`Successfully read params from ${fileToCheck}`);
            noFilesFound = false;
            Object.assign(combinedParams, params);
        }
        catch (err) {
            logger_1.logger.debug(`${err}`);
        }
    }
    if (noFilesFound) {
        throw new error_1.FirebaseError(`No params file found for ${args.instanceId}`);
    }
    return combinedParams;
}
function readParamsFile(projectDir, fileName) {
    const paramPath = path.join(projectDir, exports.ENV_DIRECTORY, fileName);
    const params = (0, paramHelper_1.readEnvFile)(paramPath);
    return params;
}
