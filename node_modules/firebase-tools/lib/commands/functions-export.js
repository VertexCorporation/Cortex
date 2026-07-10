"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const error_1 = require("../error");
const iac = require("../functions/iac/export");
const projectConfig_1 = require("../functions/projectConfig");
const clc = require("colorette");
const logger_1 = require("../logger");
const EXPORTERS = {
    internal: iac.getInternalIac,
};
exports.command = new command_1.Command("functions:export")
    .description("export Cloud Functions code and configuration")
    .option("--format <format>", `Format of the output. Can be ${Object.keys(EXPORTERS).join(", ")}.`)
    .option("--codebase <codebase>", "Optional codebase to export. If not specified, exports the default or only codebase.")
    .action(async (options) => {
    if (!options.format || !Object.keys(EXPORTERS).includes(options.format)) {
        throw new error_1.FirebaseError(`Must specify --format as ${Object.keys(EXPORTERS).join(", ")}.`);
    }
    const config = (0, projectConfig_1.normalizeAndValidate)(options.config?.src?.functions);
    let codebaseConfig;
    if (options.codebase) {
        codebaseConfig = (0, projectConfig_1.configForCodebase)(config, options.codebase);
    }
    else if (config.length === 1) {
        codebaseConfig = config[0];
    }
    else {
        codebaseConfig = (0, projectConfig_1.configForCodebase)(config, "default");
    }
    if (!codebaseConfig.source) {
        throw new error_1.FirebaseError("Codebase does not have a local source directory.");
    }
    const manifest = await EXPORTERS[options.format](options, codebaseConfig);
    for (const [file, contents] of Object.entries(manifest)) {
        logger_1.logger.info(`Manifest file: ${clc.bold(file)}`);
        logger_1.logger.info(contents);
    }
});
