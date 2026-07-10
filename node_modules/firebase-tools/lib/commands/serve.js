"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const logger_1 = require("../logger");
const utils = require("../utils");
const requirePermissions_1 = require("../requirePermissions");
const requireConfig_1 = require("../requireConfig");
const index_1 = require("../serve/index");
const filterTargets_1 = require("../filterTargets");
const projectUtils_1 = require("../projectUtils");
const error_1 = require("../error");
const VALID_TARGETS = ["hosting", "functions"];
const REQUIRES_AUTH = ["hosting", "functions"];
const ALL_TARGETS = Array.from(new Set(["database", "firestore", ...VALID_TARGETS]));
function filterOnly(list, only = "") {
    if (!only) {
        return [];
    }
    const targets = only.split(",").map((o) => o.split(":")[0]);
    return targets.filter((t) => list.includes(t));
}
exports.command = new command_1.Command("serve")
    .description("start a local server for your static assets")
    .option("-p, --port <port>", "the port on which to listen (default: 5000)", 5000)
    .option("-o, --host <host>", "the host on which to listen (default: localhost)", "localhost")
    .option("--only <targets>", "only serve specified targets (valid targets are: " + VALID_TARGETS.join(", ") + ")")
    .option("--except <targets>", "serve all except specified targets (valid targets are: " + VALID_TARGETS.join(", ") + ")")
    .before((options) => {
    if (options.only &&
        options.only.length > 0 &&
        filterOnly(REQUIRES_AUTH, options.only).length === 0) {
        return Promise.resolve();
    }
    return (0, requireConfig_1.requireConfig)(options)
        .then(() => (0, requirePermissions_1.requirePermissions)(options))
        .then(() => (0, projectUtils_1.needProjectNumber)(options));
})
    .action((options) => {
    options.targets = filterOnly(ALL_TARGETS, options.only);
    if (options.targets.includes("database") || options.targets.includes("firestore")) {
        throw new error_1.FirebaseError(`Please use ${clc.bold("firebase emulators:start")} to start the Realtime Database or Cloud Firestore emulators. ${clc.bold("firebase serve")} only supports Hosting and Cloud Functions.`);
    }
    options.targets = filterOnly(VALID_TARGETS, options.only);
    if (options.targets.length > 0) {
        return (0, index_1.serve)(options);
    }
    if (options.config) {
        logger_1.logger.info();
        logger_1.logger.info(clc.bold(clc.white("===") + " Serving from '" + options.config.projectDir + "'..."));
        logger_1.logger.info();
    }
    else {
        utils.logWarning("No Firebase project directory detected. Serving static content from " +
            clc.bold(options.cwd || process.cwd()));
    }
    options.targets = (0, filterTargets_1.filterTargets)(options, VALID_TARGETS);
    return (0, index_1.serve)(options);
});
