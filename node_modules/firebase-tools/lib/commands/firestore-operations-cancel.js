"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const fsi = require("../firestore/api");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const firestore_utils_1 = require("./firestore-utils");
const prompt_1 = require("../prompt");
const clc = require("colorette");
const utils = require("../utils");
exports.command = new command_1.Command("firestore:operations:cancel <operationName>")
    .description("cancels a long-running Cloud Firestore admin operation")
    .option("--database <databaseName>", 'Database ID for which the operation is running. "(default)" if none is provided.')
    .option("--force", "Forces the operation cancellation without asking for confirmation")
    .before(commandUtils_1.errorMissingProject)
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (operationName, options) => {
    const databaseId = options.database || "(default)";
    operationName = (0, firestore_utils_1.getShortOperationName)(operationName);
    if (!options.force) {
        const fullName = `/projects/${options.project}/databases/${databaseId}/operations/${operationName}`;
        const confirmMessage = `You are about to cancel the operation: ${clc.bold(clc.yellow(clc.underline(fullName)))}. Do you wish to continue?`;
        const consent = await (0, prompt_1.confirm)(confirmMessage);
        if (!consent) {
            return utils.reject("Command aborted.", { exit: 1 });
        }
    }
    const api = new fsi.FirestoreApi();
    const status = await api.cancelOperation(options.project, databaseId, operationName);
    if (status.success) {
        utils.logSuccess("Operation cancelled successfully.");
    }
    else {
        utils.logWarning("Canceling the operation failed.");
    }
    return status;
});
