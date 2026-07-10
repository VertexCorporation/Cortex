"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const download_1 = require("../emulator/download");
const types_1 = require("../emulator/types");
const EMULATOR_NAME = types_1.Emulators.STORAGE;
exports.command = new command_1.Command(`setup:emulators:${EMULATOR_NAME}`)
    .description(`download the ${EMULATOR_NAME} emulator`)
    .action(() => {
    return (0, download_1.downloadEmulator)(EMULATOR_NAME);
});
