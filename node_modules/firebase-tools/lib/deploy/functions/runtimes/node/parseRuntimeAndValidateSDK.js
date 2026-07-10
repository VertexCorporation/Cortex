"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RUNTIME_NOT_SET = void 0;
exports.getRuntimeChoice = getRuntimeChoice;
const path = require("path");
const error_1 = require("../../../../error");
const supported = require("../supported");
const cjson = require("cjson");
const supportedNodeVersions = Object.keys(supported.RUNTIMES)
    .filter((s) => supported.runtimeIsLanguage(s, "nodejs"))
    .filter((s) => !supported.isDecommissioned(s))
    .map((s) => s.substring("nodejs".length));
exports.RUNTIME_NOT_SET = "`runtime` field is required but was not found in firebase.json or package.json.\n" +
    "To fix this, add the following lines to the `functions` section of your firebase.json:\n" +
    `"runtime": "${supported.latest("nodejs")}" or set the "engine" field in package.json\n`;
function getRuntimeChoiceFromPackageJson(sourceDir) {
    const packageJsonPath = path.join(sourceDir, "package.json");
    let loaded;
    try {
        loaded = cjson.load(packageJsonPath);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Unable to load ${packageJsonPath}: ${err}`);
    }
    const engines = loaded.engines;
    if (!engines || !engines.node) {
        throw new error_1.FirebaseError(exports.RUNTIME_NOT_SET);
    }
    const runtime = `nodejs${engines.node}`;
    if (!supported.isRuntime(runtime)) {
        throw new error_1.FirebaseError(`Detected node engine ${engines.node} in package.json, which is not a ` +
            `supported version. Valid versions are ${supportedNodeVersions.join(", ")}`);
    }
    return runtime;
}
function getRuntimeChoice(sourceDir, runtimeFromConfig) {
    return runtimeFromConfig || getRuntimeChoiceFromPackageJson(sourceDir);
}
