"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.wrapSpawn = wrapSpawn;
exports.spawnWithOutput = spawnWithOutput;
exports.spawnWithCommandString = spawnWithCommandString;
const spawn = require("cross-spawn");
const logger_1 = require("../logger");
const error_1 = require("../error");
function wrapSpawn(cmd, args, projectDir) {
    return new Promise((resolve, reject) => {
        const installer = spawn(cmd, args, {
            cwd: projectDir,
            stdio: "inherit",
            env: { ...process.env },
        });
        installer.on("error", (err) => {
            logger_1.logger.debug((0, error_1.getErrStack)(err));
        });
        installer.on("close", (code) => {
            if (code === 0) {
                return resolve();
            }
            return reject(new Error(`Error: spawn(${cmd}, [${args.join(", ")}]) \n exited with code: ${code || "null"}`));
        });
    });
}
function spawnWithOutput(cmd, args) {
    return new Promise((resolve, reject) => {
        const child = spawn(cmd, args);
        let output = "";
        child.stdout?.on("data", (data) => {
            if ((0, error_1.isObject)(data) && data.toString) {
                output += data.toString();
            }
            else {
                output += JSON.stringify(data);
            }
        });
        child.stderr?.on("data", (data) => {
            logger_1.logger.debug(`Error: spawn(${cmd}, ${args.join(", ")})\n  Stderr:\n${JSON.stringify(data)}\n`);
        });
        child.on("error", (err) => {
            logger_1.logger.debug((0, error_1.getErrStack)(err));
        });
        child.on("close", (code) => {
            if (code === 0) {
                resolve(output);
            }
            else {
                reject(new Error(`Error: spawn(${cmd}, [${args.join(", ")}]) \n exited with code: ${code || "null"}`));
            }
        });
    });
}
function spawnWithCommandString(cmd, projectDir, environmentVariables) {
    return new Promise((resolve, reject) => {
        const installer = spawn(cmd, {
            cwd: projectDir,
            stdio: "inherit",
            shell: true,
            env: { ...process.env, ...environmentVariables },
        });
        installer.on("error", (err) => {
            logger_1.logger.log("DEBUG", (0, error_1.getErrStack)(err));
        });
        installer.on("close", (code) => {
            if (code === 0) {
                return resolve();
            }
            return reject(new Error(`Error: spawn(${cmd}) \n exited with code: ${code || "null"}`));
        });
    });
}
