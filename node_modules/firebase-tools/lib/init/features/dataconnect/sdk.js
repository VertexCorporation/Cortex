"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FDC_SDK_PLATFORM_ENV = exports.FDC_SDK_FRAMEWORKS_ENV = exports.FDC_APP_FOLDER = void 0;
exports.askQuestions = askQuestions;
exports.chooseApp = chooseApp;
exports.actuate = actuate;
exports.initAppCounters = initAppCounters;
exports.addSdkGenerateToConnectorYaml = addSdkGenerateToConnectorYaml;
const yaml = require("yaml");
const clc = require("colorette");
const path = require("path");
const cwd = process.cwd();
const prompt_1 = require("../../../prompt");
const load_1 = require("../../../dataconnect/load");
const experiments = require("../../../experiments");
const error_1 = require("../../../error");
const lodash_1 = require("lodash");
const utils_1 = require("../../../utils");
const appUtils_1 = require("../../../appUtils");
const dataconnectEmulator_1 = require("../../../emulator/dataconnectEmulator");
const auth_1 = require("../../../auth");
const create_app_1 = require("./create_app");
const track_1 = require("../../../track");
const fsutils_1 = require("../../../fsutils");
const cloudbilling_1 = require("../../../gcp/cloudbilling");
exports.FDC_APP_FOLDER = "FDC_APP_FOLDER";
exports.FDC_SDK_FRAMEWORKS_ENV = "FDC_SDK_FRAMEWORKS";
exports.FDC_SDK_PLATFORM_ENV = "FDC_SDK_PLATFORM";
async function askQuestions(setup, config, options) {
    const info = {
        apps: [],
    };
    info.apps = await chooseApp(options);
    if (!info.apps.length) {
        const npxMissingWarning = (0, utils_1.commandExistsSync)("npx")
            ? ""
            : clc.yellow(" (you need to install Node.js first)");
        const flutterMissingWarning = (0, utils_1.commandExistsSync)("flutter")
            ? ""
            : clc.yellow(" (you need to install Flutter first)");
        const choice = await (0, prompt_1.select)({
            message: `Do you want to create an app template?`,
            choices: [
                { name: `React${npxMissingWarning}`, value: "react" },
                { name: `Next.JS${npxMissingWarning}`, value: "next" },
                { name: `Flutter${flutterMissingWarning}`, value: "flutter" },
                { name: "skip", value: "skip" },
            ],
            default: "skip",
            nonInteractive: options?.nonInteractive,
        });
        try {
            switch (choice) {
                case "react":
                    await (0, create_app_1.createReactApp)((0, utils_1.newUniqueId)("web-app", (0, fsutils_1.listFiles)(cwd)));
                    break;
                case "next":
                    await (0, create_app_1.createNextApp)((0, utils_1.newUniqueId)("web-app", (0, fsutils_1.listFiles)(cwd)));
                    break;
                case "flutter":
                    await (0, create_app_1.createFlutterApp)((0, utils_1.newUniqueId)("flutter_app", (0, fsutils_1.listFiles)(cwd)));
                    break;
                case "skip":
                    break;
            }
        }
        catch (err) {
            (0, utils_1.logLabeledError)("dataconnect", `Failed to create a ${choice} app template: ${(0, error_1.getErrStack)(err)}`);
        }
    }
    setup.featureInfo = setup.featureInfo || {};
    setup.featureInfo.dataconnectSdk = info;
}
async function chooseApp(options) {
    let apps = dedupeAppsByPlatformAndDirectory(await (0, appUtils_1.detectApps)(cwd));
    if (apps.length) {
        (0, utils_1.logLabeledSuccess)("dataconnect", `Detected existing apps ${apps.map((a) => (0, appUtils_1.appDescription)(a)).join(", ")}`);
    }
    else {
        (0, utils_1.logLabeledWarning)("dataconnect", "Cannot detect an existing app in the current directory.");
    }
    const envAppFolder = (0, utils_1.envOverride)(exports.FDC_APP_FOLDER, "");
    const envPlatform = (0, utils_1.envOverride)(exports.FDC_SDK_PLATFORM_ENV, "");
    const envFrameworks = (0, utils_1.envOverride)(exports.FDC_SDK_FRAMEWORKS_ENV, "")
        .split(",")
        .filter((f) => !!f)
        .map((f) => f);
    if (envAppFolder && envPlatform) {
        const envAppRelDir = path.relative(cwd, path.resolve(cwd, envAppFolder));
        const matchedApps = apps.filter((app) => app.directory === envAppRelDir && (!app.platform || app.platform === envPlatform));
        if (matchedApps.length) {
            for (const a of matchedApps) {
                a.frameworks = [...(a.frameworks || []), ...envFrameworks];
            }
            return matchedApps;
        }
        return [
            {
                platform: envPlatform,
                directory: envAppRelDir,
                frameworks: envFrameworks,
            },
        ];
    }
    if (apps.length >= 2) {
        const choices = apps.map((a) => {
            return {
                name: (0, appUtils_1.appDescription)(a),
                value: a,
                checked: a.directory === ".",
            };
        });
        const defaultApps = choices.filter((c) => c.checked).map((c) => c.value);
        const pickedApps = await (0, prompt_1.checkbox)({
            message: "Which apps do you want to set up SQL Connect SDKs in?",
            choices,
            default: defaultApps.length > 0 ? defaultApps : [choices[0].value],
            nonInteractive: options?.nonInteractive,
            validate: (choices) => {
                if (choices.length === 0) {
                    return "Please choose at least one app.";
                }
                return true;
            },
        });
        if (!pickedApps || !pickedApps.length) {
            throw new error_1.FirebaseError("Command Aborted. Please choose at least one app.");
        }
        apps = pickedApps;
    }
    return apps;
}
async function actuate(setup, config) {
    const sdkInfo = setup.featureInfo?.dataconnectSdk;
    if (!sdkInfo) {
        throw new Error("SQL Connect SDK feature RequiredInfo is not provided");
    }
    const startTime = Date.now();
    try {
        await actuateWithInfo(setup, config, sdkInfo);
    }
    finally {
        const fdcInfo = setup.featureInfo?.dataconnect;
        if (!fdcInfo) {
            const source = setup.featureInfo?.dataconnectSource || "init_sdk";
            void (0, track_1.trackGA4)("dataconnect_init", {
                source,
                project_status: setup.projectId
                    ? (await (0, cloudbilling_1.isBillingEnabled)(setup))
                        ? "blaze"
                        : "spark"
                    : "missing",
                ...initAppCounters(sdkInfo),
            }, Date.now() - startTime);
        }
    }
}
function initAppCounters(info) {
    const counts = {
        num_web_apps: 0,
        num_android_apps: 0,
        num_ios_apps: 0,
        num_flutter_apps: 0,
        num_admin_node_apps: 0,
    };
    for (const app of info.apps ?? []) {
        switch (app.platform) {
            case appUtils_1.Platform.ADMIN_NODE:
                counts.num_admin_node_apps++;
                break;
            case appUtils_1.Platform.WEB:
                counts.num_web_apps++;
                break;
            case appUtils_1.Platform.ANDROID:
                counts.num_android_apps++;
                break;
            case appUtils_1.Platform.IOS:
                counts.num_ios_apps++;
                break;
            case appUtils_1.Platform.FLUTTER:
                counts.num_flutter_apps++;
                break;
        }
    }
    return counts;
}
async function actuateWithInfo(setup, config, info) {
    if (!info.apps.length) {
        info.apps = await (0, appUtils_1.detectApps)(cwd);
        if (!info.apps.length) {
            (0, utils_1.logLabeledBullet)("dataconnect", "No apps to setup SQL Connect Generated SDKs");
            return;
        }
    }
    const apps = dedupeAppsByPlatformAndDirectory(info.apps);
    const connectorInfo = await chooseExistingConnector(setup, config);
    const connectorYaml = JSON.parse(JSON.stringify(connectorInfo.connectorYaml));
    for (const app of apps) {
        if (!(0, fsutils_1.dirExistsSync)(app.directory)) {
            (0, utils_1.logLabeledWarning)("dataconnect", `App directory ${app.directory} does not exist`);
        }
        addSdkGenerateToConnectorYaml(connectorInfo, connectorYaml, app);
    }
    const connectorYamlContents = yaml.stringify(connectorYaml);
    connectorInfo.connectorYaml = connectorYaml;
    const connectorYamlPath = `${connectorInfo.directory}/connector.yaml`;
    config.writeProjectFile(path.relative(config.projectDir, connectorYamlPath), connectorYamlContents);
    (0, utils_1.logLabeledBullet)("dataconnect", `Installing the generated SDKs ...`);
    const account = (0, auth_1.getGlobalDefaultAccount)();
    try {
        await dataconnectEmulator_1.DataConnectEmulator.generate({
            configDir: connectorInfo.directory,
            account,
        });
    }
    catch (e) {
        (0, utils_1.logLabeledError)("dataconnect", `Failed to generate SQL Connect SDKs\n${(0, error_1.getErrMsg)(e)}`);
    }
    (0, utils_1.logLabeledSuccess)("dataconnect", `Installed generated SDKs for ${clc.bold(apps.map((a) => (0, appUtils_1.appDescription)(a)).join(", "))}`);
    if (apps.some((a) => a.platform === appUtils_1.Platform.IOS)) {
        (0, utils_1.logBullet)(clc.bold("Please follow the instructions here to add your generated sdk to your XCode project:\n\thttps://firebase.google.com/docs/data-connect/ios-sdk#set-client"));
    }
    if (apps.some((a) => a.frameworks?.includes(appUtils_1.Framework.REACT))) {
        (0, utils_1.logBullet)("Visit https://firebase.google.com/docs/data-connect/web-sdk#react for more information on how to set up React Generated SDKs for Firebase SQL Connect");
    }
    if (apps.some((a) => a.frameworks?.includes(appUtils_1.Framework.ANGULAR))) {
        (0, utils_1.logBullet)("Run `ng add @angular/fire` to install angular sdk dependencies.\nVisit https://github.com/invertase/tanstack-query-firebase/tree/main/packages/angular for more information on how to set up Angular Generated SDKs for Firebase SQL Connect");
    }
}
async function chooseExistingConnector(setup, config) {
    const serviceInfos = await (0, load_1.loadAll)(setup.projectId || "", config);
    const choices = serviceInfos
        .map((si) => {
        return si.connectorInfo.map((ci) => {
            return {
                name: `${si.dataConnectYaml.location}/${si.dataConnectYaml.serviceId}/${ci.connectorYaml.connectorId}`,
                value: ci,
            };
        });
    })
        .flat();
    if (!choices.length) {
        throw new error_1.FirebaseError(`No Firebase SQL Connect workspace found. Run ${clc.bold("firebase init dataconnect")} to set up a service and connector.`);
    }
    if (choices.length === 1) {
        return choices[0].value;
    }
    const connectorEnvVar = (0, utils_1.envOverride)("FDC_CONNECTOR", "");
    if (connectorEnvVar) {
        const existingConnector = choices.find((c) => c.name === connectorEnvVar);
        if (existingConnector) {
            (0, utils_1.logBullet)(`Picking up the existing connector ${clc.bold(connectorEnvVar)}.`);
            return existingConnector.value;
        }
        (0, utils_1.logWarning)(`Unable to pick up an existing connector based on FDC_CONNECTOR=${connectorEnvVar}.`);
    }
    (0, utils_1.logWarning)(`Pick up the first connector ${clc.bold(connectorEnvVar)}. Use FDC_CONNECTOR to override it`);
    return choices[0].value;
}
function addSdkGenerateToConnectorYaml(connectorInfo, connectorYaml, app) {
    const connectorDir = connectorInfo.directory;
    const appDir = app.directory;
    if (!connectorYaml.generate) {
        connectorYaml.generate = {};
    }
    const generate = connectorYaml.generate;
    switch (app.platform) {
        case appUtils_1.Platform.ADMIN_NODE: {
            const adminNodeSdk = {
                outputDir: path.relative(connectorDir, path.join(appDir, `src/dataconnect-admin-generated`)),
                package: `@dataconnect/admin-generated`,
                packageJsonDir: path.relative(connectorDir, appDir),
            };
            if (!(0, lodash_1.isArray)(generate?.adminNodeSdk)) {
                generate.adminNodeSdk = generate.adminNodeSdk ? [generate.adminNodeSdk] : [];
            }
            if (!generate.adminNodeSdk.some((s) => s.outputDir === adminNodeSdk.outputDir)) {
                generate.adminNodeSdk.push(adminNodeSdk);
            }
            break;
        }
        case appUtils_1.Platform.WEB: {
            const javascriptSdk = {
                outputDir: path.relative(connectorDir, path.join(app.directory, "src/dataconnect-generated")),
                package: "@dataconnect/generated",
                packageJsonDir: path.relative(connectorDir, app.directory),
                react: app.frameworks?.includes(appUtils_1.Framework.REACT) ?? false,
                angular: app.frameworks?.includes(appUtils_1.Framework.ANGULAR) ?? false,
            };
            if (experiments.isEnabled("fdcrealtime")) {
                javascriptSdk.clientCache = {};
            }
            if (!(0, lodash_1.isArray)(generate?.javascriptSdk)) {
                generate.javascriptSdk = generate.javascriptSdk ? [generate.javascriptSdk] : [];
            }
            const existing = generate.javascriptSdk.find((s) => s.outputDir === javascriptSdk.outputDir);
            if (!existing) {
                generate.javascriptSdk.push(javascriptSdk);
            }
            break;
        }
        case appUtils_1.Platform.FLUTTER: {
            const dartSdk = {
                outputDir: path.relative(connectorDir, path.join(appDir, `lib/dataconnect_generated`)),
                package: "dataconnect_generated/generated.dart",
            };
            if (experiments.isEnabled("fdcrealtime")) {
                dartSdk.clientCache = {};
            }
            if (!(0, lodash_1.isArray)(generate?.dartSdk)) {
                generate.dartSdk = generate.dartSdk ? [generate.dartSdk] : [];
            }
            const existing = generate.dartSdk.find((s) => s.outputDir === dartSdk.outputDir);
            if (!existing) {
                generate.dartSdk.push(dartSdk);
            }
            break;
        }
        case appUtils_1.Platform.ANDROID: {
            const kotlinSdk = {
                outputDir: path.relative(connectorDir, path.join(app.directory, "src/main/kotlin")),
                package: `com.google.firebase.dataconnect.generated`,
            };
            if (experiments.isEnabled("fdcrealtime")) {
                kotlinSdk.clientCache = {};
            }
            if (!(0, lodash_1.isArray)(generate?.kotlinSdk)) {
                generate.kotlinSdk = generate.kotlinSdk ? [generate.kotlinSdk] : [];
            }
            const existing = generate.kotlinSdk.find((s) => s.outputDir === kotlinSdk.outputDir);
            if (!existing) {
                generate.kotlinSdk.push(kotlinSdk);
            }
            break;
        }
        case appUtils_1.Platform.IOS: {
            const swiftSdk = {
                outputDir: path.relative(connectorDir, path.join(app.directory, `../FirebaseDataConnectGenerated`)),
                package: "DataConnectGenerated",
            };
            if (experiments.isEnabled("fdcrealtime")) {
                swiftSdk.clientCache = {};
            }
            if (!(0, lodash_1.isArray)(generate?.swiftSdk)) {
                generate.swiftSdk = generate.swiftSdk ? [generate.swiftSdk] : [];
            }
            const existing = generate.swiftSdk.find((s) => s.outputDir === swiftSdk.outputDir);
            if (!existing) {
                generate.swiftSdk.push(swiftSdk);
            }
            break;
        }
        default:
            throw new error_1.FirebaseError(`Unsupported platform ${app.platform} for SQL Connect SDK generation. Supported platforms are: ${Object.values(appUtils_1.Platform).join(", ")}\n${JSON.stringify(app)}`);
    }
}
function dedupeAppsByPlatformAndDirectory(apps) {
    const uniqueApps = new Map();
    for (const app of apps) {
        const frameworkKey = app.frameworks ? [...app.frameworks].sort().join(",") : "";
        const key = `${app.platform}:${app.directory}:${frameworkKey}`;
        if (!uniqueApps.has(key)) {
            const minifiedApp = {
                platform: app.platform,
                directory: app.directory,
            };
            if (app.frameworks?.length) {
                minifiedApp.frameworks = [...app.frameworks];
            }
            uniqueApps.set(key, minifiedApp);
        }
    }
    return Array.from(uniqueApps.values());
}
