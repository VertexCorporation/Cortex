"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TYPESCRIPT_VERSION = exports.FIREBASE_FUNCTIONS_VERSION = exports.SDK_GENERATION_VERSION = void 0;
exports.writeSDK = writeSDK;
const path = require("path");
const marked_terminal_1 = require("marked-terminal");
const marked_1 = require("marked");
const error_1 = require("../../error");
const types_1 = require("../types");
const prompt_1 = require("../../prompt");
const secretsUtils = require("../secretsUtils");
const utils_1 = require("../../utils");
const common_1 = require("./common");
const askUserForEventsConfig_1 = require("../askUserForEventsConfig");
const extensionsHelper_1 = require("../extensionsHelper");
const error_2 = require("../../error");
const spawn_1 = require("../../init/spawn");
marked_1.marked.use((0, marked_terminal_1.markedTerminal)());
exports.SDK_GENERATION_VERSION = "1.0.0";
exports.FIREBASE_FUNCTIONS_VERSION = ">=5.1.0";
exports.TYPESCRIPT_VERSION = "^4.9.0";
function makePackageName(extensionRef, name) {
    if (!extensionRef) {
        return `@firebase-extensions/local-${name}-sdk`;
    }
    const pub = extensionRef.split("/")[0];
    return `@firebase-extensions/${pub}-${name}-sdk`;
}
function makeTypeName(name) {
    let typeName = name.replace(/_/g, " ");
    typeName = typeName.replace(/\w\S*/g, common_1.toTitleCase);
    return typeName.replace(/ /g, "") + "Param";
}
const systemPrefixes = {
    "firebaseextensions.v1beta.function": "_FUNCTION",
    "firebaseextensions.v1beta.v2function": "_V2FUNCTION",
    FUNCTION: "firebaseextensions.v1beta.function",
    V2FUNCTION: "firebaseextensions.v1beta.v2function",
};
function convertSystemPrefix(prefix) {
    return systemPrefixes[prefix];
}
function makeSystemTypeName(name) {
    if (name.includes("/")) {
        const prefix = name.split("/")[0];
        let typeName = name.split("/")[1];
        typeName = typeName.replace(/([A-Z])/g, " $1").trim();
        typeName = `${convertSystemPrefix(prefix)}_${typeName}`;
        return `System${makeTypeName(typeName)}`;
    }
    return makeTypeName(name);
}
function makeSystemParamName(name) {
    if (name.includes("/")) {
        const prefix = name.split("/")[0];
        let paramName = name.split("/")[1];
        paramName = paramName.replace(/([A-Z])/g, " $1").trim();
        paramName = paramName.toUpperCase();
        paramName = paramName.replace(/ /g, "_");
        return `${convertSystemPrefix(prefix)}_${paramName}`;
    }
    return name;
}
function makeClassName(name) {
    let className = name.replace(/[_-]/g, " ");
    className = className.replace(/\w\S*/g, common_1.toTitleCase);
    return className.replace(/ /g, "");
}
function makeEventName(name, prefix) {
    let eventName;
    const versionedEvent = /^(?:[^.]+[.])+(?:[vV]\d+[.])(?<event>.*)$/;
    const match = versionedEvent.exec(name);
    if (match) {
        eventName = match[1];
    }
    else if (prefix.length < name.length) {
        eventName = name.substring(prefix.length);
    }
    else {
        const parts = name.split(".");
        eventName = parts[parts.length - 1];
    }
    const allCaps = /^[A-Z._-]+$/;
    eventName = allCaps.exec(eventName) ? eventName : eventName.replace(/([A-Z])/g, " $1").trim();
    eventName = eventName.replace(/[._-]/g, " ");
    eventName = eventName.toLowerCase().startsWith("on") ? eventName : "on " + eventName;
    eventName = eventName.replace(/\w\S*/g, common_1.toTitleCase);
    eventName = eventName.replace(/ /g, "");
    eventName = eventName.charAt(0).toLowerCase() + eventName.substring(1);
    return eventName;
}
function addPeerDependency(pkgJson, dependency, version) {
    if (!pkgJson.peerDependencies) {
        pkgJson.peerDependencies = {};
    }
    if (!(0, error_1.isObject)(pkgJson.peerDependencies)) {
        throw new error_2.FirebaseError("Internal error generating peer dependencies.");
    }
    pkgJson.peerDependencies[dependency] = version;
}
async function writeSDK(extensionRef, localPath, spec, options) {
    const sdkLines = [];
    const className = makeClassName(spec.name);
    let dirPath;
    if (extensionRef) {
        dirPath = path.join((0, common_1.getInstallPathPrefix)(options), extensionRef.replace("@", "/"));
    }
    else if (localPath) {
        dirPath = path.join((0, common_1.getInstallPathPrefix)(options), "local", spec.name, spec.version);
        if (await (0, prompt_1.confirm)({
            message: `Copy local extension source to deployment directory? (required for successful deploy)`,
            nonInteractive: options.nonInteractive,
            force: options.force,
            default: true,
        })) {
            const newLocalPath = path.join(dirPath, "src");
            await (0, common_1.copyDirectory)(localPath, newLocalPath, options);
            localPath = newLocalPath.replace(options.projectRoot || ".", ".");
        }
    }
    if (!dirPath) {
        throw new error_2.FirebaseError("Invalid extension definition. Must have either extensionRef or localPath");
    }
    const packageName = makePackageName(extensionRef, spec.name);
    const pkgJson = {
        name: packageName,
        version: `${exports.SDK_GENERATION_VERSION}`,
        description: `Generated SDK for ${spec.displayName || spec.name}@${spec.version}`,
        main: "./output/index.js",
        private: true,
        scripts: {
            build: "tsc",
            "build:watch": "npm run build && tsc --watch",
        },
        devDependencies: {
            typescript: exports.TYPESCRIPT_VERSION,
        },
    };
    const tsconfigJson = {
        compilerOptions: {
            declaration: true,
            declarationMap: true,
            module: "commonjs",
            strict: true,
            target: "es2017",
            removeComments: false,
            outDir: "output",
        },
    };
    sdkLines.push("/**");
    sdkLines.push(` * ${spec.displayName || spec.name} SDK for ${spec.name}@${spec.version}`);
    sdkLines.push(" *");
    sdkLines.push(" * When filing bugs or feature requests please specify:");
    if (extensionRef) {
        sdkLines.push(` *   "Extensions SDK v${exports.SDK_GENERATION_VERSION} for ${spec.name}@${spec.version}"`);
    }
    else {
        sdkLines.push(` *   "Extensions SDK v${exports.SDK_GENERATION_VERSION} for Local extension.`);
    }
    sdkLines.push(" * https://github.com/firebase/firebase-tools/issues/new/choose");
    sdkLines.push(" *");
    sdkLines.push(" * GENERATED FILE. DO NOT EDIT.");
    sdkLines.push(" */\n");
    const hasEvents = spec.events && spec.events.length > 0;
    if (hasEvents) {
        sdkLines.push(`import { CloudEvent } from "firebase-functions/v2";`);
        sdkLines.push(`import { onCustomEventPublished, EventarcTriggerOptions } from "firebase-functions/v2/eventarc";`);
        addPeerDependency(pkgJson, "firebase-functions", exports.FIREBASE_FUNCTIONS_VERSION);
    }
    const usesSecrets = secretsUtils.usesSecrets(spec);
    if (usesSecrets) {
        sdkLines.push(`import { defineSecret } from "firebase-functions/params";`);
        addPeerDependency(pkgJson, "firebase-functions", exports.FIREBASE_FUNCTIONS_VERSION);
    }
    if (hasEvents || usesSecrets) {
        sdkLines.push("");
    }
    if (hasEvents) {
        sdkLines.push(`export type EventCallback<T> = (event: CloudEvent<T>) => unknown | Promise<unknown>;`);
        sdkLines.push(`export type SimpleEventarcTriggerOptions = Omit<EventarcTriggerOptions, 'eventType' | 'channel' | 'region'>;`);
        sdkLines.push(`export type EventArcRegionType = "${askUserForEventsConfig_1.ALLOWED_EVENT_ARC_REGIONS.join('" | "')}";`);
    }
    if (usesSecrets) {
        sdkLines.push("export type SecretParam = ReturnType<typeof defineSecret>;");
    }
    if (spec.params && Array.isArray(spec.params) && spec.params.length > 0) {
        for (const param of spec.params) {
            let line;
            if (param.type === types_1.ParamType.SELECT ||
                param.type === types_1.ParamType.MULTISELECT ||
                param.type === extensionsHelper_1.SpecParamType.SELECT ||
                param.type === extensionsHelper_1.SpecParamType.MULTISELECT) {
                line = `export type ${makeTypeName(param.param)} =`;
                param.options?.forEach((opt, i) => {
                    if (i === 0) {
                        line = line.concat(` "${opt.value}"`);
                    }
                    else {
                        line = line.concat(` | "${opt.value}"`);
                    }
                });
                line = line.concat(";");
                sdkLines.push(line);
            }
        }
    }
    sdkLines.push("");
    if (spec.systemParams && Array.isArray(spec.systemParams) && spec.systemParams.length > 0) {
        for (const sysParam of spec.systemParams) {
            let line;
            if (sysParam.type === types_1.ParamType.SELECT || sysParam.type === types_1.ParamType.MULTISELECT) {
                line = `export type ${makeSystemTypeName(sysParam.param)} =`;
                sysParam.options?.forEach((opt, i) => {
                    if (i === 0) {
                        line = line.concat(` "${opt.value}"`);
                    }
                    else {
                        line = line.concat(` | "${opt.value}"`);
                    }
                });
                line = line.concat(";");
                sdkLines.push(line);
            }
        }
    }
    sdkLines.push("");
    sdkLines.push("/**");
    sdkLines.push(` * Parameters for ${spec.name}@${spec.version} extension`);
    sdkLines.push(" */");
    sdkLines.push(`export interface ${className}Params {`);
    for (const param of spec.params) {
        const opt = param.required ? "" : "?";
        sdkLines.push("  /**");
        sdkLines.push(`   * ${param.label}`);
        if (param.validationRegex && !param.validationRegex.includes("*/")) {
            sdkLines.push(`   * - Validation regex: ${param.validationRegex}`);
        }
        sdkLines.push("   */");
        switch (param.type) {
            case types_1.ParamType.STRING:
            case extensionsHelper_1.SpecParamType.STRING:
                sdkLines.push(`  ${param.param}${opt}: string;`);
                break;
            case types_1.ParamType.MULTISELECT:
            case extensionsHelper_1.SpecParamType.MULTISELECT:
                sdkLines.push(`  ${param.param}${opt}: ${makeTypeName(param.param)}[];`);
                break;
            case types_1.ParamType.SELECT:
            case extensionsHelper_1.SpecParamType.SELECT:
                sdkLines.push(`  ${param.param}${opt}: ${makeTypeName(param.param)};`);
                break;
            case types_1.ParamType.SECRET:
            case extensionsHelper_1.SpecParamType.SECRET:
                sdkLines.push(`  ${param.param}${opt}: SecretParam;`);
                break;
            case types_1.ParamType.SELECT_RESOURCE:
            case extensionsHelper_1.SpecParamType.SELECTRESOURCE:
                sdkLines.push(`  ${param.param}${opt}: string;`);
                break;
            default:
                sdkLines.push(`  ${param.param}${opt}: string;  // Assuming string for unknown type`);
        }
        sdkLines.push("");
    }
    if (hasEvents) {
        sdkLines.push("  /**");
        sdkLines.push(`   * Event Arc Region`);
        sdkLines.push("   */");
        sdkLines.push("  _EVENT_ARC_REGION?: EventArcRegionType\n");
    }
    for (const sysParam of spec.systemParams) {
        const opt = sysParam.required ? "" : "?";
        sdkLines.push("  /**");
        sdkLines.push(`   * ${sysParam.label}`);
        if (sysParam.validationRegex && !sysParam.validationRegex.includes("*/")) {
            sdkLines.push(`   * - Validation regex: ${sysParam.validationRegex}`);
        }
        sdkLines.push("   */");
        switch (sysParam.type) {
            case types_1.ParamType.STRING:
                sdkLines.push(`  ${makeSystemParamName(sysParam.param)}${opt}: string;`);
                break;
            case types_1.ParamType.MULTISELECT:
                sdkLines.push(`  ${makeSystemParamName(sysParam.param)}${opt}: ${makeSystemTypeName(sysParam.param)}[];`);
                break;
            case types_1.ParamType.SELECT:
                sdkLines.push(`  ${makeSystemParamName(sysParam.param)}${opt}: ${makeSystemTypeName(sysParam.param)};`);
                break;
            case types_1.ParamType.SECRET:
                sdkLines.push(`  ${makeSystemParamName(sysParam.param)}${opt}: SecretParam;`);
                break;
            case types_1.ParamType.SELECT_RESOURCE:
                sdkLines.push(`  ${sysParam.param}${opt}: string;`);
                break;
            default:
                throw new error_2.FirebaseError(`Error: Unknown systemParam type: ${sysParam.type || "undefined"}.`);
        }
        sdkLines.push("");
    }
    sdkLines.push("}\n");
    const lowerClassName = (0, common_1.lowercaseFirstLetter)(className);
    sdkLines.push(`export function ${lowerClassName}(instanceId: string, params: ${className}Params) {`);
    sdkLines.push(`  return new ${className}(instanceId, params);`);
    sdkLines.push("}\n");
    sdkLines.push(`/**`);
    sdkLines.push(` * ${spec.displayName || spec.name}`);
    spec.description?.split("\n").forEach((val) => {
        sdkLines.push(` * ${val.replace(/\*\//g, "* /")}`);
    });
    sdkLines.push(` */`);
    sdkLines.push(`export class ${className} {`);
    if (hasEvents) {
        sdkLines.push(`  events: string[] = [];`);
    }
    if (extensionRef) {
        sdkLines.push(`  readonly FIREBASE_EXTENSION_REFERENCE = "${extensionRef}";`);
        sdkLines.push(`  readonly EXTENSION_VERSION = "${extensionRef.split("@")[1]}";\n`);
    }
    else if (localPath) {
        sdkLines.push(`  readonly FIREBASE_EXTENSION_LOCAL_PATH = "${localPath}";`);
    }
    sdkLines.push(`  constructor(private instanceId: string, private params: ${className}Params) {}\n`);
    sdkLines.push(`  getInstanceId(): string { return this.instanceId; }\n`);
    sdkLines.push(`  getParams(): ${className}Params { return this.params; }\n`);
    if (spec.events) {
        const prefix = (0, common_1.longestCommonPrefix)(spec.events.map((e) => e.type));
        for (const event of spec.events) {
            const eventName = makeEventName(event.type, prefix);
            sdkLines.push("  /**");
            sdkLines.push(`   * ${event.description}`);
            sdkLines.push(`   */`);
            sdkLines.push(`  ${eventName}<T = unknown>(callback: EventCallback<T>, options?: SimpleEventarcTriggerOptions) {`);
            sdkLines.push(`    this.events.push("${event.type}");`);
            sdkLines.push(`    return onCustomEventPublished({`);
            sdkLines.push(`        ...options,`);
            sdkLines.push(`        "eventType": "${event.type}",`);
            sdkLines.push('        "channel": `projects/locations/${this.params._EVENT_ARC_REGION}/channels/firebase`,');
            sdkLines.push('        "region": `${this.params._EVENT_ARC_REGION}`');
            sdkLines.push("    },");
            sdkLines.push("    callback);");
            sdkLines.push(`  }\n`);
        }
    }
    sdkLines.push(`}`);
    const shortDirPath = dirPath.replace(process.cwd(), ".");
    await (0, common_1.writeFile)(`${dirPath}/index.ts`, sdkLines.join("\n"), options);
    await (0, common_1.writeFile)(`${dirPath}/package.json`, JSON.stringify(pkgJson, null, 2), options);
    await (0, common_1.writeFile)(`${dirPath}/tsconfig.json`, JSON.stringify(tsconfigJson, null, 2), options);
    (0, utils_1.logLabeledBullet)("extensions", `running 'npm --prefix ${shortDirPath} install'`);
    try {
        await (0, spawn_1.spawnWithOutput)("npm", ["--prefix", dirPath, "install"]);
    }
    catch (err) {
        const errMsg = (0, error_2.getErrMsg)(err, "unknown error");
        throw new error_2.FirebaseError(`Error during npm install in ${shortDirPath}: ${errMsg}`);
    }
    (0, utils_1.logLabeledBullet)("extensions", `running 'npm --prefix ${shortDirPath} run build'`);
    try {
        await (0, spawn_1.spawnWithOutput)("npm", ["--prefix", dirPath, "run", "build"]);
    }
    catch (err) {
        const errMsg = (0, error_2.getErrMsg)(err, "unknown error");
        throw new error_2.FirebaseError(`Error during npm run build in ${shortDirPath}: ${errMsg}`);
    }
    const codebaseDir = (0, common_1.getCodebaseDir)(options);
    const shortCodebaseDir = codebaseDir.replace(process.cwd(), ".");
    let installCmd = "";
    if (await (0, prompt_1.confirm)({
        message: `Do you want to install the SDK with npm now?`,
        nonInteractive: options.nonInteractive,
        force: options.force,
        default: true,
    })) {
        (0, utils_1.logLabeledBullet)("extensions", `running 'npm --prefix ${shortCodebaseDir} install --save ${shortDirPath}'`);
        try {
            await (0, spawn_1.spawnWithOutput)("npm", ["--prefix", codebaseDir, "install", "--save", dirPath]);
        }
        catch (err) {
            const errMsg = (0, error_2.getErrMsg)(err, "unknown error");
            throw new error_2.FirebaseError(`Error during npm install in ${codebaseDir}: ${errMsg}`);
        }
    }
    else {
        installCmd = `npm --prefix ${shortCodebaseDir} install --save ${shortDirPath}`;
    }
    let sampleImport;
    if ((0, common_1.isTypescriptCodebase)(codebaseDir)) {
        sampleImport =
            "```typescript\n" + `import { ${lowerClassName} } from "${packageName}";` + "\n```";
    }
    else {
        sampleImport = "```js\n" + `const { ${lowerClassName} } = require("${packageName}");` + "\n```";
    }
    const prefix = installCmd
        ? `\nTo install the SDK to your project run:\n    ${installCmd}\n\nThen you `
        : "\nYou ";
    const instructions = prefix +
        `can add this to your codebase to begin using the SDK:\n\n` +
        (0, common_1.fixDarkBlueText)(await (0, marked_1.marked)(sampleImport)) +
        `See also: ${(0, common_1.fixDarkBlueText)(await (0, marked_1.marked)("[Extension SDKs documentation](https://firebase.google.com/docs/extensions/install-extensions?interface=sdk#config)"))}`;
    return instructions;
}
