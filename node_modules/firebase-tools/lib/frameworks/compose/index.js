"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.compose = compose;
const driver_1 = require("./driver");
const discover_1 = require("./discover");
async function compose(mode, fs, allFrameworkSpecs) {
    let bundle = { version: "v1alpha" };
    const spec = await (0, discover_1.discover)(fs, allFrameworkSpecs);
    const driver = (0, driver_1.getDriver)(mode, spec);
    if (spec.detectedCommands?.run) {
        bundle.server = {
            start: {
                cmd: spec.detectedCommands.run.cmd.split(" "),
            },
        };
    }
    driver.install();
    if (spec.frameworkHooks?.afterInstall) {
        bundle = driver.execHook(bundle, spec.frameworkHooks.afterInstall);
    }
    driver.build();
    if (spec.frameworkHooks?.afterBuild) {
        bundle = driver.execHook(bundle, spec.frameworkHooks?.afterBuild);
    }
    if (bundle.server) {
        driver.export(bundle);
    }
    return bundle;
}
