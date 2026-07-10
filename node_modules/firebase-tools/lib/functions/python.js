"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEFAULT_VENV_DIR = void 0;
exports.virtualEnvCmd = virtualEnvCmd;
exports.runWithVirtualEnv = runWithVirtualEnv;
const path = require("path");
const cross_spawn_1 = require("cross-spawn");
const logger_1 = require("../logger");
const utils_1 = require("../utils");
exports.DEFAULT_VENV_DIR = "venv";
function virtualEnvCmd(cwd, venvDir) {
    const activateScriptPath = utils_1.IS_WINDOWS ? ["Scripts", "activate.bat"] : ["bin", "activate"];
    const venvActivate = `"${path.join(cwd, venvDir, ...activateScriptPath)}"`;
    return {
        command: utils_1.IS_WINDOWS ? venvActivate : ".",
        args: utils_1.IS_WINDOWS ? [] : [venvActivate],
    };
}
function runWithVirtualEnv(commandAndArgs, cwd, envs, spawnOpts = {}, venvDir = exports.DEFAULT_VENV_DIR) {
    const { command, args } = virtualEnvCmd(cwd, venvDir);
    args.push("&&", ...commandAndArgs);
    logger_1.logger.debug(`Running command with virtualenv: command=${command}, args=${JSON.stringify(args)}`);
    return (0, cross_spawn_1.spawn)(command, args, {
        shell: true,
        cwd,
        stdio: "pipe",
        ...spawnOpts,
        env: envs,
    });
}
