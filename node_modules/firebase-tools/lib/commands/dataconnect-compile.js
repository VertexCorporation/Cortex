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
const hub_1 = require("../emulator/hub");
const build_1 = require("../dataconnect/build");
const error_1 = require("../error");
exports.command = new command_1.Command("dataconnect:compile")
    .description("compile your SQL Connect schema and connector config and GQL files.")
    .option("--service <serviceId>", "the serviceId of the SQL Connect service. If not provided, compiles all services.")
    .option("--location <location>", "the location of the SQL Connect service. Only needed if service ID is used in multiple locations.")
    .action(async (options) => {
    const projectId = (0, projectUtils_1.getProjectId)(options);
    const config = options.config;
    if (!config || !config.has("dataconnect")) {
        throw new error_1.FirebaseError(`No SQL Connect project directory found. Please run ${clc.bold("firebase init dataconnect")} to set it up first.`);
    }
    const serviceInfos = await (0, load_1.pickServices)(projectId || hub_1.EmulatorHub.MISSING_PROJECT_PLACEHOLDER, config, options.service, options.location);
    if (!serviceInfos.length) {
        throw new error_1.FirebaseError("No SQL Connect services found to compile.");
    }
    for (const serviceInfo of serviceInfos) {
        const configDir = serviceInfo.sourceDirectory;
        const account = (0, auth_1.getProjectDefaultAccount)(options.projectRoot);
        const buildArgs = {
            configDir,
            projectId,
            account,
        };
        const buildResult = await dataconnectEmulator_1.DataConnectEmulator.build(buildArgs);
        if (buildResult?.errors?.length) {
            await (0, build_1.handleBuildErrors)(buildResult.errors, options.nonInteractive, options.force, false);
        }
        await dataconnectEmulator_1.DataConnectEmulator.generate({
            configDir,
            account,
        });
        (0, utils_1.logLabeledSuccess)("dataconnect", `Successfully compiled SQL Connect service: ${clc.bold(serviceInfo.dataConnectYaml.serviceId)}`);
    }
});
