"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.discover = discover;
const node_1 = require("./runtime/node");
const error_1 = require("../../../error");
const supportedRuntimes = [new node_1.NodejsRuntime()];
async function discover(fs, allFrameworkSpecs) {
    try {
        let discoveredRuntime = undefined;
        for (const runtime of supportedRuntimes) {
            if (await runtime.match(fs)) {
                if (!discoveredRuntime) {
                    discoveredRuntime = runtime;
                }
                else {
                    throw new error_1.FirebaseError(`Conflit occurred as multiple runtimes ${discoveredRuntime.getRuntimeName()}, ${runtime.getRuntimeName()} are discovered in the application.`);
                }
            }
        }
        if (!discoveredRuntime) {
            throw new error_1.FirebaseError(`Unable to determine the specific runtime for the application. The supported runtime options include ${supportedRuntimes
                .map((x) => x.getRuntimeName())
                .join(" , ")}.`);
        }
        const runtimeSpec = await discoveredRuntime.analyseCodebase(fs, allFrameworkSpecs);
        return runtimeSpec;
    }
    catch (error) {
        throw new error_1.FirebaseError(`Failed to identify required specifications to execute the application: ${error}`);
    }
}
