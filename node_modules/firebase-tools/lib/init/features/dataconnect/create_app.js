"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createReactApp = createReactApp;
exports.createNextApp = createNextApp;
exports.createFlutterApp = createFlutterApp;
const spawn = require("cross-spawn");
const clc = require("colorette");
const utils_1 = require("../../../utils");
async function createReactApp(webAppId) {
    const args = ["create", "vite@latest", webAppId, "--", "--template", "react", "--no-interactive"];
    await executeCommand("npm", args);
}
async function createNextApp(webAppId) {
    const args = [
        "create-next-app@latest",
        webAppId,
        "--ts",
        "--eslint",
        "--tailwind",
        "--src-dir",
        "--app",
        "--turbopack",
        "--import-alias",
        '"@/*"',
        "--skip-install",
    ];
    await executeCommand("npx", args);
}
async function createFlutterApp(webAppId) {
    const args = ["create", webAppId];
    await executeCommand("flutter", args);
}
async function executeCommand(command, args) {
    (0, utils_1.logLabeledBullet)("dataconnect", `> ${clc.bold(`${command} ${args.join(" ")}`)}`);
    return new Promise((resolve, reject) => {
        const childProcess = spawn(command, args, {
            stdio: "inherit",
        });
        childProcess.on("close", (code) => {
            if (code === 0) {
                resolve();
            }
            else {
                reject(new Error(`Command failed with exit code ${code ?? "null"}`));
            }
        });
        childProcess.on("error", (err) => {
            reject(err);
        });
    });
}
