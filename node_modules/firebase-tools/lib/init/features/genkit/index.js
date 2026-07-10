"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isPackageJson = exports.isTsConfig = void 0;
exports.doSetup = doSetup;
exports.ensureVertexApiEnabled = ensureVertexApiEnabled;
exports.genkitSetup = genkitSetup;
exports.promptWriteMode = promptWriteMode;
const fs = require("fs");
const path = require("path");
const semver = require("semver");
const clc = require("colorette");
const functions = require("../functions");
const prompt_1 = require("../../../prompt");
const spawn_1 = require("../../spawn");
const projectUtils_1 = require("../../../projectUtils");
const ensureApiEnabled_1 = require("../../../ensureApiEnabled");
const logger_1 = require("../../../logger");
const error_1 = require("../../../error");
const utils_1 = require("../../../utils");
const UNKNOWN_VERSION_TOO_HIGH = "2.0.0";
const MIN_VERSION = "1.0.0-rc.1";
const UNIFIED_PLUGIN_VERSION = "1.18.0";
const LATEST_TEMPLATE = "1.0.0";
async function getPackageVersion(packageName, envVariable) {
    const envVal = process.env[envVariable];
    if (envVal && typeof envVal === "string") {
        if (semver.parse(envVal)) {
            return envVal;
        }
        else {
            throw new error_1.FirebaseError(`Invalid version string '${envVal}' specified in ${envVariable}`);
        }
    }
    try {
        const output = await (0, spawn_1.spawnWithOutput)("npm", ["view", packageName, "version"]);
        if (!output) {
            throw new error_1.FirebaseError(`Unable to determine ${packageName} version to install`);
        }
        return output;
    }
    catch (err) {
        throw new error_1.FirebaseError(`Unable to determine which version of ${packageName} to install.\n` +
            `npm Error: ${(0, error_1.getErrMsg)(err)}\n\n` +
            "For a possible workaround run\n  npm view " +
            packageName +
            " version\n" +
            "and then set an environment variable:\n" +
            `  export ${envVariable}=<output from previous command>\n` +
            "and run `firebase init genkit` again");
    }
}
async function getGenkitInfo() {
    let templateVersion = LATEST_TEMPLATE;
    let stopInstall = false;
    const genkitVersion = await getPackageVersion("genkit", "GENKIT_DEV_VERSION");
    const cliVersion = await getPackageVersion("genkit-cli", "GENKIT_CLI_DEV_VERSION");
    const genaiVersion = await getPackageVersion("@genkit-ai/google-genai", "GENKIT_GENAI_VERSION");
    const vertexVersion = await getPackageVersion("@genkit-ai/vertexai", "GENKIT_VERTEX_VERSION");
    const googleAiVersion = await getPackageVersion("@genkit-ai/googleai", "GENKIT_GOOGLEAI_VERSION");
    if (semver.gte(genkitVersion, UNKNOWN_VERSION_TOO_HIGH)) {
        const continueInstall = await (0, prompt_1.confirm)({
            message: clc.yellow(`WARNING: The latest version of Genkit (${genkitVersion}) isn't supported by this\n` +
                "version of firebase-tools. You can proceed, but the provided sample code may\n" +
                "not work with the latest library. You can also try updating firebase-tools with\n" +
                "npm install -g firebase-tools@latest, and then running this command again.\n\n") + "Proceed with installing the latest version of Genkit?",
            default: false,
        });
        if (!continueInstall) {
            stopInstall = true;
        }
    }
    else if (semver.gte(genkitVersion, UNIFIED_PLUGIN_VERSION) &&
        semver.gte(genaiVersion, "0.0.2-rc.1")) {
        templateVersion = UNIFIED_PLUGIN_VERSION;
    }
    else if (semver.gte(genkitVersion, MIN_VERSION)) {
        templateVersion = "1.0.0";
    }
    else {
        throw new error_1.FirebaseError(`The requested version of Genkit (${genkitVersion}) is no ` +
            `longer supported. Please specify a newer version.`);
    }
    return {
        genkitVersion,
        cliVersion,
        vertexVersion,
        googleAiVersion,
        genaiVersion,
        templateVersion,
        stopInstall,
    };
}
function showStartMessage(setup, command) {
    logger_1.logger.info();
    logger_1.logger.info("\nLogin to Google Cloud using:");
    logger_1.logger.info(clc.bold(clc.green(`    gcloud auth application-default login --project ${setup.projectId || "your-project-id"}\n`)));
    logger_1.logger.info("Then start the Genkit developer experience by running:");
    logger_1.logger.info(clc.bold(clc.green(`    ${command}`)));
}
async function doSetup(initSetup, config, options) {
    const setup = initSetup;
    const genkitInfo = await getGenkitInfo();
    if (genkitInfo.stopInstall) {
        (0, utils_1.logLabeledWarning)("genkit", "Stopped Genkit initialization");
        return;
    }
    if (setup.functions?.languageChoice !== "typescript") {
        const continueFunctions = await (0, prompt_1.confirm)({
            message: "Genkit's Firebase integration uses Cloud Functions for Firebase with TypeScript.\nInitialize Functions to continue?",
            default: true,
        });
        if (!continueFunctions) {
            (0, utils_1.logLabeledWarning)("genkit", "Stopped Genkit initialization");
            return;
        }
        setup.languageOverride = "typescript";
        await functions.askQuestions(setup, config, options);
        await functions.actuate(setup, config);
        delete setup.languageOverride;
        logger_1.logger.info();
    }
    if (!setup.functions) {
        throw new error_1.FirebaseError("Failed to initialize Genkit prerequisite: Firebase functions");
    }
    const projectDir = `${config.projectDir}/${setup.functions.source}`;
    const installType = await (0, prompt_1.select)({
        message: "Install the Genkit CLI globally or locally in this project?",
        choices: [
            { name: "Globally", value: "globally" },
            { name: "Just this project", value: "project" },
        ],
    });
    try {
        (0, utils_1.logLabeledBullet)("genkit", `Installing Genkit CLI version ${genkitInfo.cliVersion}`);
        if (installType === "globally") {
            await (0, spawn_1.wrapSpawn)("npm", ["install", "-g", `genkit-cli@${genkitInfo.cliVersion}`], projectDir);
            await genkitSetup(options, genkitInfo, projectDir);
            showStartMessage(setup, `cd ${setup.functions.source} && npm run genkit:start`);
        }
        else {
            await (0, spawn_1.wrapSpawn)("npm", ["install", `genkit-cli@${genkitInfo.cliVersion}`, "--save-dev"], projectDir);
            await genkitSetup(options, genkitInfo, projectDir);
            showStartMessage(setup, `cd ${setup.functions.source} && npm run genkit:start`);
        }
    }
    catch (err) {
        (0, utils_1.logLabeledError)("genkit", `Genkit initialization failed: ${(0, error_1.getErrMsg)(err)}`);
        return;
    }
}
async function ensureVertexApiEnabled(options) {
    const VERTEX_AI_URL = "https://aiplatform.googleapis.com";
    const projectId = (0, projectUtils_1.getProjectId)(options);
    if (!projectId) {
        return;
    }
    const silently = typeof options.markdown === "boolean" && options.markdown;
    return await (0, ensureApiEnabled_1.ensure)(projectId, VERTEX_AI_URL, "aiplatform", silently);
}
function getModelOptions(genkitInfo) {
    let modelOptions;
    if (semver.gte(genkitInfo.templateVersion, UNIFIED_PLUGIN_VERSION)) {
        modelOptions = {
            vertexai: {
                label: "Google Cloud Vertex AI",
                provider: "vertexai",
                plugin: "@genkit-ai/google-genai",
                package: `@genkit-ai/google-genai@${genkitInfo.genaiVersion}`,
            },
            googleai: {
                label: "Google AI",
                provider: "googleai",
                plugin: "@genkit-ai/google-genai",
                package: `@genkit-ai/google-genai@${genkitInfo.genaiVersion}`,
            },
            none: { label: "None" },
        };
    }
    else {
        modelOptions = {
            vertexai: {
                label: "Google Cloud Vertex AI",
                plugin: "@genkit-ai/vertexai",
                package: `@genkit-ai/vertexai@${genkitInfo.vertexVersion}`,
            },
            googleai: {
                label: "Google AI",
                plugin: "@genkit-ai/googleai",
                package: `@genkit-ai/googleai@${genkitInfo.googleAiVersion}`,
            },
            none: { label: "None" },
        };
    }
    return modelOptions;
}
const pluginToInfo = {
    "@genkit-ai/firebase": {
        plugin: "@genkit-ai/firebase",
        imports: "firebase",
        init: `
    // Load the Firebase plugin, which provides integrations with several
    // Firebase services.
    firebase()`.trimStart(),
    },
    "@genkit-ai/google-genai(vertexai)": {
        plugin: "@genkit-ai/google-genai",
        imports: "vertexAI",
        modelImportComment: `
// Import vertexAI provider from the unified plugin. The Vertex AI API provides
// access to many models.`,
        init: `    // Load the VertexAI provider. You can optionally specify your location
    // and projectID by passing in a config object; if you don't, the provider
    // uses the value from environment variables like GCLOUD_PROJECT and GCLOUD_LOCATION.
    // If you want to use Vertex Express Mode, you can specify apiKey instead.
    vertexAI({location: "global"})`,
        model: 'vertexAI.model("gemini-2.5-flash")',
    },
    "@genkit-ai/google-genai(googleai)": {
        plugin: "@genkit-ai/google-genai",
        imports: "googleAI",
        modelImportComment: `
// Import googleAI provider from the unified plugin. The Gemini Developer API
// provides access to several generative models.`,
        init: `    // Load the GoogleAI provider. You can optionally specify your API key by
    // passing in a config object; if you don't, the provider uses the value
    // from the GOOGLE_GENAI_API_KEY environment variable, which is the
    // recommended practice.
    googleAI()`,
        model: 'googleAI.model("gemini-2.5-flash")',
    },
    "@genkit-ai/vertexai": {
        plugin: "@genkit-ai/vertexai",
        imports: "vertexAI",
        modelImportComment: `
// Import models from the Vertex AI plugin. The Vertex AI API provides access to
// several generative models. Here, we import Gemini 2.0 Flash.`.trimStart(),
        init: `
    // Load the Vertex AI plugin. You can optionally specify your project ID
    // by passing in a config object; if you don't, the Vertex AI plugin uses
    // the value from the GCLOUD_PROJECT environment variable.
    vertexAI({location: "us-central1"})`.trimStart(),
        model: 'vertexAI.model("gemini-2.5-flash")',
    },
    "@genkit-ai/googleai": {
        plugin: "@genkit-ai/googleai",
        imports: "googleAI",
        modelImportComment: `
// Import models from the Google AI plugin. The Google AI API provides access to
// several generative models. Here, we import Gemini 2.0 Flash.`.trimStart(),
        init: `
    // Load the Google AI plugin. You can optionally specify your API key
    // by passing in a config object; if you don't, the Google AI plugin uses
    // the value from the GOOGLE_GENAI_API_KEY environment variable, which is
    // the recommended practice.
    googleAI()`.trimStart(),
        model: 'googleAI.model("gemini-2.5-flash")',
    },
};
function getPluginInfo(option) {
    if (option?.provider && option.plugin) {
        return pluginToInfo[`${option.plugin}(${option.provider})`];
    }
    if (option?.plugin) {
        return pluginToInfo[option.plugin];
    }
    return {
        plugin: "",
        imports: "",
        init: "",
    };
}
function getBasePackages(genkitVersion) {
    const basePackages = ["express", `genkit@${genkitVersion}`];
    return basePackages;
}
const externalDevPackages = ["typescript", "tsx"];
async function genkitSetup(options, genkitInfo, projectDir) {
    const modelOptions = getModelOptions(genkitInfo);
    const supportedModels = Object.keys(modelOptions);
    const model = await (0, prompt_1.select)({
        message: "Select a model provider:",
        choices: supportedModels.map((model) => ({
            name: modelOptions[model].label,
            value: model,
        })),
    });
    if (model === "vertexai") {
        await ensureVertexApiEnabled(options);
    }
    const pluginPackages = [];
    pluginPackages.push(`@genkit-ai/firebase@${genkitInfo.genkitVersion}`);
    if (modelOptions[model]?.package) {
        pluginPackages.push(modelOptions[model].package || "");
    }
    const packages = [...getBasePackages(genkitInfo.genkitVersion)];
    packages.push(...pluginPackages);
    await installNpmPackages(projectDir, packages, externalDevPackages);
    if (!fs.existsSync(path.join(projectDir, "src"))) {
        fs.mkdirSync(path.join(projectDir, "src"));
    }
    await updateTsConfig(options.nonInteractive || false, projectDir);
    await updatePackageJson(options.nonInteractive || false, projectDir);
    if (options.nonInteractive ||
        (await (0, prompt_1.confirm)({
            message: "Would you like to generate a sample flow?",
            default: true,
        }))) {
        logger_1.logger.info("Telemetry data can be used to monitor and gain insights into your AI features. There may be a cost associated with using this feature. See https://firebase.google.com/docs/genkit/observability/telemetry-collection.");
        const enableTelemetry = options.nonInteractive ||
            (await (0, prompt_1.confirm)({
                message: "Would like you to enable telemetry collection?",
                default: true,
            }));
        generateSampleFile(modelOptions[model], projectDir, genkitInfo.templateVersion, enableTelemetry);
    }
}
const isTsConfig = (value) => {
    if (!(0, error_1.isObject)(value) || (value.compilerOptions && !(0, error_1.isObject)(value.compilerOptions))) {
        return false;
    }
    return true;
};
exports.isTsConfig = isTsConfig;
async function updateTsConfig(nonInteractive, projectDir) {
    const tsConfigPath = path.join(projectDir, "tsconfig.json");
    let existingTsConfig = undefined;
    if (fs.existsSync(tsConfigPath)) {
        const parsed = JSON.parse(fs.readFileSync(tsConfigPath, "utf-8"));
        if (!(0, exports.isTsConfig)(parsed)) {
            throw new error_1.FirebaseError("Unable to parse existing tsconfig.json");
        }
        existingTsConfig = parsed;
    }
    let choice = "overwrite";
    if (!nonInteractive && existingTsConfig) {
        choice = await promptWriteMode("Would you like to update your tsconfig.json with suggested settings?");
    }
    const tsConfig = {
        compileOnSave: true,
        include: ["src"],
        compilerOptions: {
            module: "commonjs",
            noImplicitReturns: true,
            outDir: "lib",
            sourceMap: true,
            strict: true,
            target: "es2017",
            skipLibCheck: true,
            esModuleInterop: true,
        },
    };
    (0, utils_1.logLabeledBullet)("genkit", "Updating tsconfig.json");
    let newTsConfig = {};
    switch (choice) {
        case "overwrite":
            newTsConfig = {
                ...existingTsConfig,
                ...tsConfig,
                compilerOptions: {
                    ...existingTsConfig?.compilerOptions,
                    ...tsConfig.compilerOptions,
                },
            };
            break;
        case "merge":
            newTsConfig = {
                ...tsConfig,
                ...existingTsConfig,
                compilerOptions: {
                    ...tsConfig.compilerOptions,
                    ...existingTsConfig?.compilerOptions,
                },
            };
            break;
        case "keep":
            (0, utils_1.logLabeledWarning)("genkit", "Skipped updating tsconfig.json");
            return;
    }
    try {
        fs.writeFileSync(tsConfigPath, JSON.stringify(newTsConfig, null, 2));
        (0, utils_1.logLabeledSuccess)("genkit", "Successfully updated tsconfig.json");
    }
    catch (err) {
        (0, utils_1.logLabeledError)("genkit", `Failed to update tsconfig.json: ${(0, error_1.getErrMsg)(err)}`);
        process.exit(1);
    }
}
async function installNpmPackages(projectDir, packages, devPackages) {
    (0, utils_1.logLabeledBullet)("genkit", "Installing NPM packages for genkit");
    try {
        if (packages.length) {
            await (0, spawn_1.wrapSpawn)("npm", ["install", ...packages, "--save"], projectDir);
        }
        if (devPackages?.length) {
            await (0, spawn_1.wrapSpawn)("npm", ["install", ...devPackages, "--save-dev"], projectDir);
        }
        (0, utils_1.logLabeledSuccess)("genkit", "Successfully installed NPM packages");
    }
    catch (err) {
        (0, utils_1.logLabeledError)("genkit", `Failed to install NPM packages: ${(0, error_1.getErrMsg)(err)}`);
        process.exit(1);
    }
}
function generateSampleFile(modelOption, projectDir, templateVersion, enableTelemetry) {
    let modelImport = "";
    const pluginInfo = getPluginInfo(modelOption);
    if (pluginInfo.imports) {
        modelImport = "\n" + generateImportStatement(pluginInfo) + "\n";
    }
    let modelImportComment = "";
    if (pluginInfo.modelImportComment) {
        modelImportComment = `\n${pluginInfo.modelImportComment}`;
    }
    const commentedModelImport = `${modelImportComment}${modelImport}`;
    const templatePath = path.join(__dirname, `../../../../templates/genkit/firebase.${templateVersion}.template`);
    const template = fs.readFileSync(templatePath, "utf8");
    const sample = renderConfig(pluginInfo, template
        .replace("$GENKIT_MODEL_IMPORT\n", commentedModelImport)
        .replace("$GENKIT_MODEL", pluginInfo.model ?? "'' /* TODO: Set a model. */"), enableTelemetry);
    (0, utils_1.logLabeledBullet)("genkit", "Generating sample file");
    try {
        const samplePath = "src/genkit-sample.ts";
        fs.writeFileSync(path.join(projectDir, samplePath), sample, "utf8");
        (0, utils_1.logLabeledSuccess)("genkit", `Successfully generated sample file (${samplePath})`);
    }
    catch (err) {
        (0, utils_1.logLabeledError)("genkit", `Failed to generate sample file: ${(0, error_1.getErrMsg)(err)}`);
        process.exit(1);
    }
}
const isPackageJson = (value) => {
    if (!(0, error_1.isObject)(value) || (value.scripts && !(0, error_1.isObject)(value.scripts))) {
        return false;
    }
    return true;
};
exports.isPackageJson = isPackageJson;
async function updatePackageJson(nonInteractive, projectDir) {
    const packageJsonPath = path.join(projectDir, "package.json");
    if (!fs.existsSync(packageJsonPath)) {
        throw new error_1.FirebaseError("Failed to find package.json.");
    }
    const existingPackageJson = JSON.parse(fs.readFileSync(packageJsonPath, "utf8"));
    if (!(0, exports.isPackageJson)(existingPackageJson)) {
        throw new error_1.FirebaseError("Unable to parse existing package.json file");
    }
    const choice = nonInteractive
        ? "overwrite"
        : await promptWriteMode("Would you like to update your package.json with suggested settings?");
    const packageJson = {
        main: "lib/index.js",
        scripts: {
            "genkit:start": "genkit start -- tsx --watch src/genkit-sample.ts",
        },
    };
    (0, utils_1.logLabeledBullet)("genkit", "Updating package.json");
    let newPackageJson = {};
    switch (choice) {
        case "overwrite":
            newPackageJson = {
                ...existingPackageJson,
                ...packageJson,
                scripts: {
                    ...existingPackageJson.scripts,
                    ...packageJson.scripts,
                },
            };
            break;
        case "merge":
            newPackageJson = {
                ...packageJson,
                ...existingPackageJson,
                main: packageJson.main,
                scripts: {
                    ...packageJson.scripts,
                    ...existingPackageJson.scripts,
                },
            };
            break;
        case "keep":
            (0, utils_1.logLabeledWarning)("genkit", "Skipped updating package.json");
            return;
    }
    try {
        fs.writeFileSync(packageJsonPath, JSON.stringify(newPackageJson, null, 2));
        (0, utils_1.logLabeledSuccess)("genkit", "Successfully updated package.json");
    }
    catch (err) {
        (0, utils_1.logLabeledError)("genkit", `Failed to update package.json: ${(0, error_1.getErrMsg)(err)}`);
        process.exit(1);
    }
}
function renderConfig(pluginInfo, template, enableTelemetry) {
    const plugins = pluginInfo.init || "    /* Add your plugins here. */";
    return template
        .replace("$GENKIT_CONFIG_IMPORTS", generateImportStatement(pluginInfo))
        .replace("$GENKIT_CONFIG_PLUGINS", plugins)
        .replaceAll("$TELEMETRY_COMMENT", enableTelemetry ? "" : "// ");
}
function generateImportStatement(pluginInfo) {
    if (pluginInfo.imports && pluginInfo.plugin) {
        return `import {${pluginInfo.imports}} from "${pluginInfo.plugin}";`;
    }
    return "";
}
async function promptWriteMode(message, defaultOption = "merge") {
    return (0, prompt_1.select)({
        message,
        choices: [
            { name: "Set if unset", value: "merge" },
            { name: "Overwrite", value: "overwrite" },
            { name: "Keep unchanged", value: "keep" },
        ],
        default: defaultOption,
    });
}
