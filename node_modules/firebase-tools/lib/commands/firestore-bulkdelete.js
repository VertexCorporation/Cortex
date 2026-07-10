"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const fsi = require("../firestore/api");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const prompt_1 = require("../prompt");
const utils = require("../utils");
const clc = require("colorette");
const utils_1 = require("../utils");
const error_1 = require("../error");
function confirmationMessage(options, databaseId, collectionIds) {
    const root = `projects/${options.project}/databases/${databaseId}/documents`;
    return ("You are about to delete all documents in the following collection groups: " +
        clc.cyan(collectionIds.map((item) => `"${item}"`).join(", ")) +
        " in " +
        clc.cyan(`"${root}"`) +
        ". Are you sure?");
}
exports.command = new command_1.Command("firestore:bulkdelete")
    .description("managed bulk delete service to delete data from one or more collection groups")
    .option("--database <databaseName>", 'Database ID for database to delete from. "(default)" if none is provided.')
    .option("--collection-ids <collectionIds>", "A comma-separated list of collection group IDs to delete. Deletes all documents in the specified collection groups.")
    .before(requirePermissions_1.requirePermissions, ["datastore.databases.bulkDeleteDocuments"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (options) => {
    if (!options.collectionIds) {
        throw new error_1.FirebaseError("Missing required flag --collection-ids=[comma separated list of collection groups]");
    }
    let collectionIds = [];
    try {
        collectionIds = options.collectionIds
            .split(",")
            .filter((id) => id.trim() !== "");
    }
    catch (e) {
        throw new error_1.FirebaseError("The value for --collection-ids must a list of comma separated collection group names");
    }
    if (collectionIds.length === 0) {
        throw new error_1.FirebaseError("Must specify at least one collection ID in --collection-ids.");
    }
    const databaseId = options.database || "(default)";
    const api = new fsi.FirestoreApi();
    const confirmed = await (0, prompt_1.confirm)({
        message: confirmationMessage(options, databaseId, collectionIds),
        default: false,
        force: options.force,
        nonInteractive: options.nonInteractive,
    });
    if (!confirmed) {
        return utils.reject("Command aborted.", { exit: 1 });
    }
    const op = await api.bulkDeleteDocuments(options.project, databaseId, collectionIds);
    if (op.name) {
        (0, utils_1.logSuccess)(`Successfully started bulk delete operation.`);
        (0, utils_1.logBullet)(`Operation name: ` + clc.cyan(op.name));
        (0, utils_1.logBullet)("You can monitor the operation's progress using the " +
            clc.cyan(`gcloud firestore operations describe`) +
            ` command.`);
    }
    else {
        (0, utils_1.logLabeledError)(`Bulk Delete:`, `Failed to start a bulk delete operation.`);
    }
    return op;
});
