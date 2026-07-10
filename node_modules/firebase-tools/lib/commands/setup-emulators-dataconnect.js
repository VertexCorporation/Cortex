"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const types_1 = require("../emulator/types");
const logger_1 = require("../logger");
const downloadableEmulators_1 = require("../emulator/downloadableEmulators");
const NAME = types_1.Emulators.DATACONNECT;
exports.command = new command_1.Command(`setup:emulators:${NAME}`)
    .description(`download the ${NAME} emulator`)
    .action(async (options) => {
    await (0, downloadableEmulators_1.downloadIfNecessary)(NAME);
    if (!options.config) {
        logger_1.logger.info("Not currently in a Firebase project directory. Run this command from a project directory to configure the SQL Connect emulator.");
        return;
    }
    logger_1.logger.info("Setup complete!");
});
