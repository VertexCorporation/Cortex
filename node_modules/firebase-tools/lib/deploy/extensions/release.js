"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.release = release;
const queue_1 = require("../../throttler/queue");
const tasks = require("./tasks");
const planner = require("./planner");
const error_1 = require("../../error");
const errors_1 = require("./errors");
const projectUtils_1 = require("../../projectUtils");
const etags_1 = require("../../extensions/etags");
const track_1 = require("../../track");
async function release(context, options, payload) {
    if (!payload.instancesToCreate &&
        !payload.instancesToUpdate &&
        !payload.instancesToConfigure &&
        !payload.instancesToDelete) {
        return;
    }
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const errorHandler = new errors_1.ErrorHandler();
    const deploymentQueue = new queue_1.default({
        retries: 5,
        concurrency: 5,
        handler: tasks.extensionsDeploymentHandler(errorHandler),
    });
    for (const inst of payload.instancesToConfigure ?? []) {
        const task = tasks.configureExtensionInstanceTask(projectId, inst);
        void deploymentQueue.run(task);
    }
    for (const inst of payload.instancesToDelete ?? []) {
        const task = tasks.deleteExtensionInstanceTask(projectId, inst);
        void deploymentQueue.run(task);
    }
    for (const inst of payload.instancesToCreate ?? []) {
        const task = tasks.createExtensionInstanceTask(projectId, inst);
        void deploymentQueue.run(task);
    }
    for (const inst of payload.instancesToUpdate ?? []) {
        const task = tasks.updateExtensionInstanceTask(projectId, inst);
        void deploymentQueue.run(task);
    }
    const deploymentPromise = deploymentQueue.wait();
    deploymentQueue.process();
    deploymentQueue.close();
    await deploymentPromise;
    const duration = context.extensionsStartTime ? Date.now() - context.extensionsStartTime : 1;
    await (0, track_1.trackGA4)("extensions_deploy", {
        extension_instance_created: payload.instancesToCreate?.length ?? 0,
        extension_instance_updated: payload.instancesToUpdate?.length ?? 0,
        extension_instance_configured: payload.instancesToConfigure?.length ?? 0,
        extension_instance_deleted: payload.instancesToDelete?.length ?? 0,
        errors: errorHandler.errors.length ?? 0,
        interactive: options.nonInteractive ? "false" : "true",
    }, duration);
    const have = await planner.have(projectId);
    const dynamicHave = await planner.haveDynamic(projectId);
    (0, etags_1.saveEtags)(options.rc, projectId, have.concat(dynamicHave));
    if (errorHandler.hasErrors()) {
        errorHandler.print();
        throw new error_1.FirebaseError(`Extensions deployment failed.`);
    }
}
