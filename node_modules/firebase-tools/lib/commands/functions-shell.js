"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const requirePermissions_1 = require("../requirePermissions");
const functionsShellCommandAction_1 = require("../functionsShellCommandAction");
const requireConfig_1 = require("../requireConfig");
const commandUtils_1 = require("../emulator/commandUtils");
exports.command = new command_1.Command("functions:shell")
    .description("launch full Node shell with emulated functions")
    .option("-p, --port <port>", "the port on which to emulate functions")
    .option(commandUtils_1.FLAG_INSPECT_FUNCTIONS, commandUtils_1.DESC_INSPECT_FUNCTIONS)
    .before(requireConfig_1.requireConfig)
    .before(requirePermissions_1.requirePermissions)
    .action(functionsShellCommandAction_1.actionFunction);
