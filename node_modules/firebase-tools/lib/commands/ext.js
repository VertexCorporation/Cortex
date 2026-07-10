"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const checkMinRequiredVersion_1 = require("../checkMinRequiredVersion");
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const listExtensions_1 = require("../extensions/listExtensions");
const requirePermissions_1 = require("../requirePermissions");
const logger_1 = require("../logger");
const utils = require("../utils");
exports.command = new command_1.Command("ext")
    .description("display information on how to use ext commands and extensions installed to your project")
    .before(checkMinRequiredVersion_1.checkMinRequiredVersion, "extMinVersion")
    .action(async (options) => {
    utils.logLabeledBullet(extensionsHelper_1.logPrefix, "list of extensions commands:");
    const firebaseTools = require("../");
    const commandNames = [
        "ext:install",
        "ext:info",
        "ext:list",
        "ext:configure",
        "ext:update",
        "ext:uninstall",
        "ext:sdk:install",
    ];
    for (const commandName of commandNames) {
        const command = firebaseTools.getCommand(commandName);
        logger_1.logger.info(clc.bold("\n" + command.name()));
        command.outputHelp();
    }
    logger_1.logger.info();
    try {
        await (0, requirePermissions_1.requirePermissions)(options, ["firebaseextensions.instances.list"]);
        const projectId = (0, projectUtils_1.needProjectId)(options);
        return (0, listExtensions_1.listExtensions)(projectId);
    }
    catch (err) {
        return;
    }
});
