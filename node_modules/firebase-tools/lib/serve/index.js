"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.serve = serve;
const logger_1 = require("../logger");
const frameworks_1 = require("../frameworks");
const experiments = require("../experiments");
const track_1 = require("../track");
const projectUtils_1 = require("../projectUtils");
const constants_1 = require("../emulator/constants");
const config = require("../hosting/config");
const { FunctionsServer } = require("./functions");
const TARGETS = {
    hosting: require("./hosting"),
    functions: new FunctionsServer(),
};
async function serve(options) {
    options.targets || (options.targets = []);
    const targetNames = options.targets;
    options.port = parseInt(options.port, 10);
    if (targetNames.includes("hosting") && config.extract(options).some((it) => it.source)) {
        experiments.assertEnabled("webframeworks", "emulate a web framework");
        await (0, frameworks_1.prepareFrameworks)("emulate", targetNames, undefined, options);
    }
    const isDemoProject = constants_1.Constants.isDemoProject((0, projectUtils_1.getProjectId)(options) || "");
    targetNames.forEach((targetName) => {
        void (0, track_1.trackEmulator)("emulator_run", {
            emulator_name: targetName,
            is_demo_project: String(isDemoProject),
        });
    });
    await Promise.all(targetNames.map((targetName) => {
        return TARGETS[targetName].start(options);
    }));
    await Promise.all(targetNames.map((targetName) => {
        return TARGETS[targetName].connect();
    }));
    void (0, track_1.trackEmulator)("emulators_started", {
        count: targetNames.length,
        count_all: targetNames.length,
        is_demo_project: String(isDemoProject),
    });
    await new Promise((resolve) => {
        process.on("SIGINT", () => {
            logger_1.logger.info("Shutting down...");
            Promise.all(targetNames.map((targetName) => {
                return TARGETS[targetName].stop(options);
            }))
                .then(resolve)
                .catch(resolve);
        });
    });
}
