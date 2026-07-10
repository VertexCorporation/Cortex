"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.isRuntime = isRuntime;
exports.runtimeIsLanguage = runtimeIsLanguage;
exports.latest = latest;
exports.isDecommissioned = isDecommissioned;
exports.guardVersionSupport = guardVersionSupport;
const error_1 = require("../../../../error");
const utils = require("../../../../utils");
const types_1 = require("./types");
__exportStar(require("./types"), exports);
function isRuntime(maybe) {
    return maybe in types_1.RUNTIMES;
}
function runtimeIsLanguage(runtime, language) {
    return !!runtime && runtime.startsWith(language);
}
function latest(language, runtimes = Object.keys(types_1.RUNTIMES)) {
    const sorted = runtimes
        .filter((s) => runtimeIsLanguage(s, language))
        .sort((left, right) => {
        const leftVersion = +left.substring(language.length);
        const rightVersion = +right.substring(language.length);
        if (isNaN(leftVersion) || isNaN(rightVersion)) {
            throw new error_1.FirebaseError("Internal error. Runtime or language names are malformed", {
                exit: 1,
            });
        }
        return leftVersion - rightVersion;
    });
    const latest = utils.last(sorted);
    if (!latest) {
        throw new error_1.FirebaseError(`Internal error trying to find the latest supported runtime for ${language}`, { exit: 1 });
    }
    return latest;
}
function isDecommissioned(runtime, now = new Date()) {
    const cutoff = new Date(types_1.RUNTIMES[runtime].decommissionDate);
    return cutoff < now;
}
function guardVersionSupport(runtime, now = new Date()) {
    const { deprecationDate, decommissionDate } = types_1.RUNTIMES[runtime];
    const decommission = new Date(decommissionDate);
    if (now >= decommission) {
        throw new error_1.FirebaseError(`Runtime ${types_1.RUNTIMES[runtime].friendly} was decommissioned on ${decommissionDate}. To deploy ` +
            "you must first upgrade your runtime version.", { exit: 1 });
    }
    const deprecation = new Date(deprecationDate);
    if (now >= deprecation) {
        utils.logLabeledWarning("functions", `Runtime ${types_1.RUNTIMES[runtime].friendly} was deprecated on ${deprecationDate} and will be ` +
            `decommissioned on ${decommissionDate}, after which you will not be able ` +
            "to deploy without upgrading. Consider upgrading now to avoid disruption. See " +
            "https://cloud.google.com/functions/docs/runtime-support for full " +
            "details on the lifecycle policy");
        return;
    }
    const warning = new Date(deprecation.getTime() - 90 * 24 * 60 * 60 * 1000);
    if (now >= warning) {
        utils.logLabeledWarning("functions", `Runtime ${types_1.RUNTIMES[runtime].friendly} will be deprecated on ${deprecationDate} and will be ` +
            `decommissioned on ${decommissionDate}, after which you will not be able ` +
            "to deploy without upgrading. Consider upgrading now to avoid disruption. See " +
            "https://cloud.google.com/functions/docs/runtime-support for full " +
            "details on the lifecycle policy");
    }
}
