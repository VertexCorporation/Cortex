"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.doSetup = doSetup;
const prompt_1 = require("../../prompt");
const fsutils = require("../../fsutils");
const clc = require("colorette");
async function doSetup(setup, config) {
    const jsonFilePath = await (0, prompt_1.input)({
        message: "What file should be used for your Remote Config template?",
        default: "remoteconfig.template.json",
    });
    if (fsutils.fileExistsSync(jsonFilePath)) {
        const msg = "File " +
            clc.bold(jsonFilePath) +
            " already exists." +
            " Do you want to overwrite the existing Remote Config template?";
        const overwrite = await (0, prompt_1.confirm)(msg);
        if (!overwrite) {
            return;
        }
    }
    setup.config.remoteconfig = {
        template: jsonFilePath,
    };
    config.writeProjectFile(setup.config.remoteconfig.template, "{}");
}
