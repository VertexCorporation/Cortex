"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEFAULT_RUNTIME = void 0;
exports.readExtensionYaml = readExtensionYaml;
exports.readPostinstall = readPostinstall;
exports.getFunctionResourcesWithParamSubstitution = getFunctionResourcesWithParamSubstitution;
exports.getFunctionProperties = getFunctionProperties;
exports.getRuntime = getRuntime;
const supported = require("../../deploy/functions/runtimes/supported");
const error_1 = require("../../error");
const extensionsHelper_1 = require("../extensionsHelper");
const utils_1 = require("../utils");
const utils_2 = require("../../utils");
const SPEC_FILE = "extension.yaml";
const POSTINSTALL_FILE = "POSTINSTALL.md";
const validFunctionTypes = [
    "firebaseextensions.v1beta.function",
    "firebaseextensions.v1beta.v2function",
    "firebaseextensions.v1beta.scheduledFunction",
];
async function readExtensionYaml(directory) {
    const extensionYaml = await (0, utils_2.readFileFromDirectory)(directory, SPEC_FILE);
    const source = extensionYaml.source;
    const spec = (0, utils_2.wrappedSafeLoad)(source);
    spec.params = spec.params ?? [];
    spec.systemParams = spec.systemParams ?? [];
    spec.resources = spec.resources ?? [];
    spec.apis = spec.apis ?? [];
    spec.roles = spec.roles ?? [];
    spec.externalServices = spec.externalServices ?? [];
    spec.events = spec.events ?? [];
    spec.lifecycleEvents = spec.lifecycleEvents ?? [];
    spec.contributors = spec.contributors ?? [];
    return spec;
}
async function readPostinstall(directory) {
    const content = await (0, utils_2.readFileFromDirectory)(directory, POSTINSTALL_FILE);
    return content.source;
}
function getFunctionResourcesWithParamSubstitution(extensionSpec, params) {
    const rawResources = extensionSpec.resources.filter((resource) => validFunctionTypes.includes(resource.type));
    return (0, extensionsHelper_1.substituteParams)(rawResources, params);
}
function getFunctionProperties(resources) {
    return resources.map((r) => r.properties);
}
exports.DEFAULT_RUNTIME = supported.latest("nodejs");
function getRuntime(resources) {
    if (resources.length === 0) {
        return exports.DEFAULT_RUNTIME;
    }
    const invalidRuntimes = [];
    const runtimes = resources.map((r) => {
        const runtime = (0, utils_1.getResourceRuntime)(r);
        if (!runtime) {
            return exports.DEFAULT_RUNTIME;
        }
        if (!supported.runtimeIsLanguage(runtime, "nodejs")) {
            invalidRuntimes.push(runtime);
            return exports.DEFAULT_RUNTIME;
        }
        return runtime;
    });
    if (invalidRuntimes.length) {
        throw new error_1.FirebaseError(`The following runtimes are not supported by the Emulator Suite: ${invalidRuntimes.join(", ")}. \n Only Node runtimes are supported.`);
    }
    return supported.latest("nodejs", runtimes);
}
