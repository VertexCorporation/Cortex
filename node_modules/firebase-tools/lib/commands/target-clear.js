"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const requireConfig_1 = require("../requireConfig");
const utils = require("../utils");
exports.command = new command_1.Command("target:clear <type> <target>")
    .description("clear all resources from a named resource target")
    .before(requireConfig_1.requireConfig)
    .action((type, name, options) => {
    const existed = options.rc.clearTarget(options.project, type, name);
    if (existed) {
        utils.logSuccess(`Cleared ${type} target ${clc.bold(name)}`);
    }
    else {
        utils.logWarning(`No action taken. No ${type} target found named ${clc.bold(name)}`);
    }
    return existed;
});
