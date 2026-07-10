"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.setup = setup;
const spawn = require("cross-spawn");
const prompt_1 = require("../../../prompt");
const supported_1 = require("../../../deploy/functions/runtimes/supported");
const templates_1 = require("../../../templates");
const PUBSPEC_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/dart/pubspec.yaml");
const MAIN_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/dart/server.dart");
const GITIGNORE_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/dart/_gitignore");
const ANALYSIS_OPTIONS_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/dart/analysis_options.yaml");
async function setup(setup, config) {
    await config.askWriteProjectFile(`${setup.functions.source}/pubspec.yaml`, PUBSPEC_TEMPLATE);
    await config.askWriteProjectFile(`${setup.functions.source}/.gitignore`, GITIGNORE_TEMPLATE);
    await config.askWriteProjectFile(`${setup.functions.source}/analysis_options.yaml`, ANALYSIS_OPTIONS_TEMPLATE);
    await config.askWriteProjectFile(`${setup.functions.source}/bin/server.dart`, MAIN_TEMPLATE);
    config.set("functions.runtime", (0, supported_1.latest)("dart"));
    config.set("functions.ignore", [".dart_tool", "build"]);
    const install = await (0, prompt_1.confirm)({
        message: "Do you want to install dependencies now?",
        default: true,
    });
    if (install) {
        const installProcess = spawn("dart", ["pub", "get"], {
            cwd: config.path(setup.functions.source),
            stdio: ["inherit", "inherit", "inherit"],
        });
        await new Promise((resolve, reject) => {
            installProcess.on("exit", resolve);
            installProcess.on("error", reject);
        });
    }
}
