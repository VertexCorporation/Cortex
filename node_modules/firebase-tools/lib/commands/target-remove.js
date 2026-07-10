"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const requireConfig_1 = require("../requireConfig");
const utils = require("../utils");
exports.command = new command_1.Command("target:remove <type> <resource>")
    .description("remove a resource target")
    .before(requireConfig_1.requireConfig)
    .action((type, resource, options) => {
    const name = options.rc.removeTarget(options.project, type, resource);
    if (name) {
        utils.logSuccess(`Removed ${type} target ${clc.bold(name)} from ${clc.bold(resource)}`);
    }
    else {
        utils.logWarning(`No action taken. No target found for ${type} resource ${clc.bold(resource)}`);
    }
    return Promise.resolve(name);
});
