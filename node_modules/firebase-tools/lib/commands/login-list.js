"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const logger_1 = require("../logger");
const utils = require("../utils");
const auth = require("../auth");
exports.command = new command_1.Command("login:list")
    .description("list authorized CLI accounts")
    .action((options) => {
    const user = options.user;
    const allAccounts = auth.getAllAccounts();
    if (!user) {
        utils.logWarning(`No authorized accounts, run "${clc.bold("firebase login")}"`);
        return;
    }
    logger_1.logger.info(`Logged in as ${user.email}`);
    const otherAccounts = allAccounts.filter((a) => a.user.email !== user.email);
    if (otherAccounts.length > 0) {
        logger_1.logger.info();
        logger_1.logger.info(`Other available accounts (switch with "${clc.bold("firebase login:use")}")`);
        for (const a of otherAccounts) {
            logger_1.logger.info(` - ${a.user.email}`);
        }
    }
    return allAccounts;
});
