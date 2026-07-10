"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const logger_1 = require("../logger");
const utils = require("../utils");
exports.command = new command_1.Command("help [command]")
    .description("display help information")
    .action(function (commandName) {
    const client = this.client;
    const cmd = commandName ? client.getCommand(commandName) : undefined;
    if (cmd) {
        cmd.outputHelp();
    }
    else if (commandName) {
        logger_1.logger.warn();
        utils.logWarning(clc.bold(commandName) + " is not a valid command. See below for valid commands");
        client.cli.outputHelp();
    }
    else {
        client.cli.outputHelp();
        logger_1.logger.info();
        logger_1.logger.info("  To get help with a specific command, type", clc.bold("firebase help [command_name]"));
        logger_1.logger.info();
    }
    logger_1.logger.info(" Privacy Policy: https://firebase.google.com/support/privacy");
    logger_1.logger.info();
});
