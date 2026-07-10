"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.setup = setup;
const spawn_1 = require("../../spawn");
const python_1 = require("../../../deploy/functions/runtimes/python");
const python_2 = require("../../../functions/python");
const prompt_1 = require("../../../prompt");
const supported_1 = require("../../../deploy/functions/runtimes/supported");
const templates_1 = require("../../../templates");
const error_1 = require("../../../error");
const MAIN_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/python/main.py");
const REQUIREMENTS_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/python/requirements.txt");
const GITIGNORE_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/python/_gitignore");
function waitForProcess(p) {
    return new Promise((resolve) => {
        p.on("exit", resolve);
        p.on("error", () => resolve(-1));
    });
}
async function createVirtualEnv(pythonBinary, cwd) {
    try {
        await (0, spawn_1.wrapSpawn)(pythonBinary, ["-m", "venv", "venv"], cwd);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to create virtual environment. Please make sure Python is installed and in your PATH.`);
    }
}
async function installDependencies(pythonBinary, cwd) {
    const upgradeProcess = (0, python_2.runWithVirtualEnv)([pythonBinary, "-m", "pip", "install", "--upgrade", "pip"], cwd, {}, { stdio: "inherit" });
    const upgradeExitCode = await waitForProcess(upgradeProcess);
    if (upgradeExitCode !== 0) {
        throw new error_1.FirebaseError("Failed to upgrade pip inside virtual environment.");
    }
    const installProcess = (0, python_2.runWithVirtualEnv)([pythonBinary, "-m", "pip", "install", "-r", "requirements.txt"], cwd, {}, { stdio: "inherit" });
    const installExitCode = await waitForProcess(installProcess);
    if (installExitCode !== 0) {
        throw new error_1.FirebaseError("Failed to install dependencies.");
    }
}
async function setup(setup, config) {
    const sourceDir = config.path(setup.functions.source);
    await config.askWriteProjectFile(`${setup.functions.source}/requirements.txt`, REQUIREMENTS_TEMPLATE);
    await config.askWriteProjectFile(`${setup.functions.source}/.gitignore`, GITIGNORE_TEMPLATE);
    await config.askWriteProjectFile(`${setup.functions.source}/main.py`, MAIN_TEMPLATE);
    config.set("functions.runtime", (0, supported_1.latest)("python"));
    config.set("functions.ignore", ["venv", "__pycache__"]);
    const pythonBinary = (0, python_1.getPythonBinary)((0, supported_1.latest)("python"));
    await createVirtualEnv(pythonBinary, sourceDir);
    const install = await (0, prompt_1.confirm)({
        message: "Do you want to install dependencies now?",
        default: true,
    });
    if (install) {
        await installDependencies(pythonBinary, sourceDir);
    }
}
