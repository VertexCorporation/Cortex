"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const controller = require("../emulator/controller");
const commandUtils = require("../emulator/commandUtils");
const COMMAND_NAME = "emulators:export";
exports.command = new command_1.Command(`${COMMAND_NAME} <path>`)
    .description("export data from running emulators")
    .withForce("overwrite any export data in the target directory")
    .option(commandUtils.FLAG_ONLY, commandUtils.DESC_ONLY)
    .action((exportPath, options) => {
    return controller.exportEmulatorData(exportPath, options, COMMAND_NAME);
});
