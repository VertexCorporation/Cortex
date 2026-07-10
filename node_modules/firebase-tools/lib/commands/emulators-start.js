"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const controller = require("../emulator/controller");
const commandUtils = require("../emulator/commandUtils");
const logger_1 = require("../logger");
const registry_1 = require("../emulator/registry");
const types_1 = require("../emulator/types");
const clc = require("colorette");
const constants_1 = require("../emulator/constants");
const utils_1 = require("../utils");
const webhook_1 = require("../dataconnect/webhook");
const Table = require("cli-table3");
function stylizeLink(url) {
    return clc.underline(clc.bold(url));
}
exports.command = new command_1.Command("emulators:start")
    .before(commandUtils.setExportOnExitOptions)
    .before(commandUtils.beforeEmulatorCommand)
    .description("start the local Firebase emulators")
    .option(commandUtils.FLAG_ONLY, commandUtils.DESC_ONLY)
    .option(commandUtils.FLAG_INSPECT_FUNCTIONS, commandUtils.DESC_INSPECT_FUNCTIONS)
    .option(commandUtils.FLAG_IMPORT, commandUtils.DESC_IMPORT)
    .option(commandUtils.FLAG_EXPORT_ON_EXIT, commandUtils.DESC_EXPORT_ON_EXIT)
    .option(commandUtils.FLAG_VERBOSITY, commandUtils.DESC_VERBOSITY)
    .action((options) => {
    const killSignalPromise = commandUtils.shutdownWhenKilled(options);
    return Promise.race([
        killSignalPromise,
        (async () => {
            let deprecationNotices;
            try {
                ({ deprecationNotices } = await controller.startAll(options));
                await (0, webhook_1.sendVSCodeMessage)({ message: webhook_1.VSCODE_MESSAGE.EMULATORS_STARTED });
            }
            catch (e) {
                await (0, webhook_1.sendVSCodeMessage)({ message: webhook_1.VSCODE_MESSAGE.EMULATORS_START_ERRORED });
                await controller.cleanShutdown();
                throw e;
            }
            printEmulatorOverview(options);
            for (const notice of deprecationNotices) {
                (0, utils_1.logLabeledWarning)("emulators", notice, "warn");
            }
            return killSignalPromise;
        })(),
    ]);
});
function printEmulatorOverview(options) {
    const reservedPorts = [];
    for (const internalEmulator of [types_1.Emulators.LOGGING]) {
        const info = registry_1.EmulatorRegistry.getInfo(internalEmulator);
        if (info) {
            reservedPorts.push(info.port);
        }
        controller.filterEmulatorTargets(options).forEach((emulator) => {
            reservedPorts.push(...(registry_1.EmulatorRegistry.getInfo(emulator)?.reservedPorts || []));
        });
    }
    const reservedPortsString = reservedPorts.length > 0 ? reservedPorts.join(", ") : "None";
    const uiRunning = registry_1.EmulatorRegistry.isRunning(types_1.Emulators.UI);
    const head = ["Emulator", "Host:Port"];
    if (uiRunning) {
        head.push(`View in ${constants_1.Constants.description(types_1.Emulators.UI)}`);
    }
    const successMessageTable = new Table();
    let successMsg = `${clc.green("✔")}  ${clc.bold("All emulators ready! It is now safe to connect your app.")}`;
    if (uiRunning) {
        successMsg += `\n${clc.cyan("i")}  View Emulator UI at ${stylizeLink(registry_1.EmulatorRegistry.url(types_1.Emulators.UI).toString())}`;
    }
    successMessageTable.push([successMsg]);
    const emulatorsTable = new Table({
        head: head,
        style: {
            head: ["yellow"],
        },
    });
    emulatorsTable.push(...controller
        .filterEmulatorTargets(options)
        .map((emulator) => {
        const emulatorName = constants_1.Constants.description(emulator).replace(/ emulator/i, "");
        const isSupportedByUi = types_1.EMULATORS_SUPPORTED_BY_UI.includes(emulator);
        const listen = commandUtils.getListenOverview(emulator);
        if (!listen) {
            const row = [emulatorName, "Failed to initialize (see above)"];
            if (uiRunning) {
                row.push("");
            }
            return row;
        }
        let uiLink = "n/a";
        if (isSupportedByUi && uiRunning) {
            const url = registry_1.EmulatorRegistry.url(types_1.Emulators.UI);
            url.pathname = `/${emulator}`;
            uiLink = stylizeLink(url.toString());
        }
        return [emulatorName, listen, uiLink];
    })
        .map((col) => col.slice(0, head.length))
        .filter((v) => v));
    let extensionsTable = "";
    if (registry_1.EmulatorRegistry.isRunning(types_1.Emulators.EXTENSIONS)) {
        const extensionsEmulatorInstance = registry_1.EmulatorRegistry.get(types_1.Emulators.EXTENSIONS);
        extensionsTable = extensionsEmulatorInstance.extensionsInfoTable();
    }
    const hubInfo = registry_1.EmulatorRegistry.getInfo(types_1.Emulators.HUB);
    logger_1.logger.info(`\n${successMessageTable}

${emulatorsTable}
${hubInfo
        ? clc.blackBright(`  Emulator Hub host: ${hubInfo.host} port: ${hubInfo.port}`)
        : clc.blackBright("  Emulator Hub not running.")}
${clc.blackBright("  Other reserved ports:")} ${reservedPortsString}
${extensionsTable}
Issues? Report them at ${stylizeLink("https://github.com/firebase/firebase-tools/issues")} and attach the *-debug.log files.
 `);
}
