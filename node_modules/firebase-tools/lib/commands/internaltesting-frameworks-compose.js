"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const logger_1 = require("../logger");
const driver_1 = require("../frameworks/compose/driver");
const compose_1 = require("../frameworks/compose");
const error_1 = require("../error");
const filesystem_1 = require("../frameworks/compose/discover/filesystem");
const frameworkSpec_1 = require("../frameworks/compose/discover/frameworkSpec");
exports.command = new command_1.Command("internaltesting:frameworks:compose")
    .option("-m, --mode <mode>", "composer mode (local or docker)", "local")
    .description("compose framework in current directory")
    .action(async (options) => {
    const mode = options.mode;
    if (!driver_1.SUPPORTED_MODES.includes(mode)) {
        throw new error_1.FirebaseError(`Unsupported mode ${mode}. Supported modes are [${driver_1.SUPPORTED_MODES.join(", ")}]`);
    }
    const bundle = await (0, compose_1.compose)(mode, new filesystem_1.LocalFileSystem("."), frameworkSpec_1.frameworkSpecs);
    logger_1.logger.info(JSON.stringify(bundle, null, 2));
    return {};
});
