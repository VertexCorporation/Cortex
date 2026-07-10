"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const Table = require("cli-table3");
const experiments = require("../experiments");
const functional_1 = require("../functional");
const logger_1 = require("../logger");
exports.command = new command_1.Command("experiments:list")
    .description("list all experiments, along with a description of each experiment and whether it is currently enabled")
    .action(() => {
    const table = new Table({
        head: ["Enabled", "Name", "Description"],
        style: { head: ["yellow"] },
    });
    const [enabled, disabled] = (0, functional_1.partition)(Object.entries(experiments.ALL_EXPERIMENTS), ([name]) => {
        return experiments.isEnabled(name);
    });
    for (const [name, exp] of enabled) {
        table.push(["y", name, exp.shortDescription]);
    }
    for (const [name, exp] of disabled) {
        if (!exp.public) {
            continue;
        }
        table.push(["n", name, exp.shortDescription]);
    }
    logger_1.logger.info(table.toString());
});
