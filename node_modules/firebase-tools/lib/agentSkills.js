"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.promptForAgentSkills = promptForAgentSkills;
exports.installAgentSkills = installAgentSkills;
const child_process_1 = require("child_process");
const utils = require("./utils");
const prompt = require("./prompt");
const error_1 = require("./error");
async function promptForAgentSkills(options) {
    return prompt.confirm({
        message: "Would you like to install agent skills for Firebase?",
        default: !options?.nonInteractive,
        nonInteractive: options?.nonInteractive,
    });
}
async function installAgentSkills(options) {
    if (!utils.commandExistsSync("npx")) {
        return;
    }
    const skillPackage = options.skillPackage || "firebase/agent-skills";
    const args = [
        "-y",
        "skills",
        "add",
        skillPackage,
        "--skill",
        "*",
        "-y",
    ];
    if (options.agentName) {
        args.push("-a", options.agentName);
    }
    if (options.global) {
        args.push("-g");
    }
    if (options.background) {
        utils.logBullet("Installing Agent skills in the background...");
        try {
            const child = (0, child_process_1.spawn)("npx", args, {
                cwd: options.cwd,
                stdio: "ignore",
                detached: true,
                shell: process.platform === "win32",
            });
            child.unref();
            utils.logSuccess("Agent skills installation started");
        }
        catch (err) {
            utils.logWarning(`Could not start Agent skills installation: ${(0, error_1.getErrMsg)(err)}`);
        }
    }
    else {
        utils.logBullet("Adding Agent skills...");
        try {
            const result = (0, child_process_1.spawnSync)("npx", args, {
                cwd: options.cwd,
                stdio: "ignore",
                shell: process.platform === "win32",
            });
            if (result.error) {
                throw result.error;
            }
            if (result.status !== 0) {
                throw new Error(`npx skills add exited with code ${result.status}`);
            }
            utils.logSuccess("Added Agent skills");
        }
        catch (err) {
            utils.logWarning(`Could not add Agent skills: ${(0, error_1.getErrMsg)(err)}`);
        }
    }
}
