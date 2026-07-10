"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deploy = deploy;
const tasks = require("./tasks");
const queue_1 = require("../../throttler/queue");
const error_1 = require("../../error");
const errors_1 = require("./errors");
const projectUtils_1 = require("../../projectUtils");
const provisioningHelper_1 = require("../../extensions/provisioningHelper");
const secrets_1 = require("./secrets");
const validate_1 = require("./validate");
async function deploy(context, options, payload) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    await (0, validate_1.checkBilling)(projectId, options.nonInteractive);
    await (0, provisioningHelper_1.bulkCheckProductsProvisioned)(projectId, [
        ...(payload.instancesToCreate ?? []),
        ...(payload.instancesToUpdate ?? []),
        ...(payload.instancesToConfigure ?? []),
    ]);
    if (context.have) {
        await (0, secrets_1.handleSecretParams)(payload, context.have, options.nonInteractive);
    }
    const errorHandler = new errors_1.ErrorHandler();
    const validationQueue = new queue_1.default({
        retries: 5,
        concurrency: 5,
        handler: tasks.extensionsDeploymentHandler(errorHandler),
    });
    for (const create of payload.instancesToCreate?.filter((i) => !!i.ref) ?? []) {
        const task = tasks.createExtensionInstanceTask(projectId, create, true);
        void validationQueue.run(task);
    }
    for (const update of payload.instancesToUpdate?.filter((i) => !!i.ref) ?? []) {
        const task = tasks.updateExtensionInstanceTask(projectId, update, true);
        void validationQueue.run(task);
    }
    for (const configure of payload.instancesToConfigure?.filter((i) => !!i.ref) ?? []) {
        const task = tasks.configureExtensionInstanceTask(projectId, configure, true);
        void validationQueue.run(task);
    }
    const validationPromise = validationQueue.wait();
    validationQueue.process();
    validationQueue.close();
    await validationPromise;
    if (errorHandler.hasErrors()) {
        errorHandler.print();
        throw new error_1.FirebaseError(`Extensions deployment failed validation. No changes have been made to the Extension instances on ${projectId}`);
    }
}
