"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const dataconnectEmulator_1 = require("../emulator/dataconnectEmulator");
const projectUtils_1 = require("../projectUtils");
const load_1 = require("../dataconnect/load");
const auth_1 = require("../auth");
const utils_1 = require("../utils");
const config_1 = require("../config");
const dataconnectInit = require("../init/features/dataconnect");
const dataconnectSdkInit = require("../init/features/dataconnect/sdk");
const error_1 = require("../error");
const init_1 = require("./init");
const hub_1 = require("../emulator/hub");
exports.command = new command_1.Command("dataconnect:sdk:generate")
    .description("generate typed SDKs to use SQL Connect in your apps")
    .option("--service <serviceId>", "the serviceId of the SQL Connect service. If not provided, generates SDKs for all services.")
    .option("--location <location>", "the location of the SQL Connect service. Only needed if service ID is used in multiple locations.")
    .option("--watch", "watch for changes to your connector GQL files and regenerate your SDKs when updates occur")
    .action(async (options) => {
    const projectId = (0, projectUtils_1.getProjectId)(options);
    let justRanInit = false;
    let config = options.config;
    if (!config || !config.has("dataconnect")) {
        if (options.nonInteractive) {
            throw new error_1.FirebaseError(`No dataconnect project directory found. Please run ${clc.bold("firebase init dataconnect")} to set it up first.`);
        }
        (0, utils_1.logWarning)("No dataconnect project directory found.");
        (0, utils_1.logBullet)(`Running ${clc.bold("firebase init dataconnect")} to setup a dataconnect project directory.`);
        if (!config) {
            const cwd = options.cwd || process.cwd();
            config = new config_1.Config({}, { projectDir: cwd, cwd: cwd });
        }
        const setup = {
            config: config.src,
            projectId: projectId,
            rcfile: options.rc.data,
            featureInfo: {
                dataconnectSource: "gen_sdk_init",
            },
            instructions: [],
        };
        await dataconnectInit.askQuestions(setup, config, options);
        await dataconnectInit.actuate(setup, config, options);
        await (0, init_1.postInitSaves)(setup, config);
        justRanInit = true;
        options.config = config;
    }
    let serviceInfosWithSDKs = await loadAllWithSDKs(projectId, config, options);
    if (!serviceInfosWithSDKs.length) {
        if (justRanInit || options.nonInteractive) {
            throw new error_1.FirebaseError(`No generated SDKs are configured during init. Please run ${clc.bold("firebase init dataconnect:sdk")} to configure a generated SDK.`);
        }
        (0, utils_1.logWarning)("No generated SDKs have been configured.");
        (0, utils_1.logBullet)(`Running ${clc.bold("firebase init dataconnect:sdk")} to configure a generated SDK.`);
        const setup = {
            config: config.src,
            projectId: projectId,
            rcfile: options.rc.data,
            featureInfo: {
                dataconnectSource: "gen_sdk_init_sdk",
            },
            instructions: [],
        };
        await dataconnectSdkInit.askQuestions(setup, config, options);
        await dataconnectSdkInit.actuate(setup, config);
        justRanInit = true;
        serviceInfosWithSDKs = await loadAllWithSDKs(projectId, config, options);
    }
    await generateSDKsInAll(options, serviceInfosWithSDKs, justRanInit);
});
async function loadAllWithSDKs(projectId, config, options) {
    const serviceInfos = await (0, load_1.pickServices)(projectId || hub_1.EmulatorHub.MISSING_PROJECT_PLACEHOLDER, config, options.service, options.location);
    return serviceInfos.filter((serviceInfo) => serviceInfo.connectorInfo.some((c) => {
        return (c.connectorYaml.generate?.javascriptSdk ||
            c.connectorYaml.generate?.kotlinSdk ||
            c.connectorYaml.generate?.swiftSdk ||
            c.connectorYaml.generate?.dartSdk ||
            c.connectorYaml.generate?.adminNodeSdk);
    }));
}
async function generateSDKsInAll(options, serviceInfosWithSDKs, justRanInit) {
    async function generateSDK(serviceInfo) {
        return dataconnectEmulator_1.DataConnectEmulator.generate({
            configDir: serviceInfo.sourceDirectory,
            watch: options.watch,
            account: (0, auth_1.getProjectDefaultAccount)(options.projectRoot),
        });
    }
    if (options.watch) {
        await Promise.race(serviceInfosWithSDKs.map(generateSDK));
    }
    else {
        if (justRanInit) {
            return;
        }
        for (const s of serviceInfosWithSDKs) {
            await generateSDK(s);
        }
        const services = serviceInfosWithSDKs.map((s) => s.dataConnectYaml.serviceId).join(", ");
        (0, utils_1.logLabeledSuccess)("dataconnect", `Successfully Generated SDKs for services: ${clc.bold(services)}`);
    }
}
