"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const delete_1 = require("../firestore/delete");
const prompt_1 = require("../prompt");
const requirePermissions_1 = require("../requirePermissions");
const utils = require("../utils");
function confirmationMessage(deleteOp, options) {
    if (options.allCollections) {
        return ("You are about to delete " +
            clc.bold(clc.yellow(clc.underline("THE ENTIRE DATABASE"))) +
            " for " +
            clc.cyan(deleteOp.getRoot()) +
            ". Are you sure?");
    }
    if (deleteOp.isDocumentPath) {
        if (options.recursive) {
            return ("You are about to delete the document at " +
                clc.cyan(deleteOp.path) +
                " and all of its subcollections " +
                " for " +
                clc.cyan(deleteOp.getRoot()) +
                ". Are you sure?");
        }
        return ("You are about to delete the document at " +
            clc.cyan(deleteOp.path) +
            " for " +
            clc.cyan(deleteOp.getRoot()) +
            ". Are you sure?");
    }
    if (options.recursive) {
        return ("You are about to delete all documents in the collection at " +
            clc.cyan(deleteOp.path) +
            " and all of their subcollections " +
            " for " +
            clc.cyan(deleteOp.getRoot()) +
            ". Are you sure?");
    }
    return ("You are about to delete all documents in the collection at " +
        clc.cyan(deleteOp.path) +
        " for " +
        clc.cyan(deleteOp.getRoot()) +
        ". Are you sure?");
}
exports.command = new command_1.Command("firestore:delete [path]")
    .description("delete data from a Cloud Firestore database")
    .option("-r, --recursive", "if set, recursively delete all documents and subcollections at and under the " +
    "specified level. May not be passed along with --shallow")
    .option("--shallow", "delete only documents at the specified level and ignore documents in " +
    "subcollections. This action can potentially orphan documents nested in " +
    "subcollections. May not be passed along with -r")
    .option("--all-collections", "deletes all collections and documents in the Firestore database")
    .withForce()
    .option("--database <databaseId>", 'Database ID for database to delete from. "(default)" if none is provided.')
    .before(commandUtils_1.printNoticeIfEmulated, types_1.Emulators.FIRESTORE)
    .before(requirePermissions_1.requirePermissions, ["datastore.entities.list", "datastore.entities.delete"])
    .action(async (path, options) => {
    if (!path && !options.allCollections) {
        return utils.reject("Must specify a path.", { exit: 1 });
    }
    if (!options.database) {
        options.database = "(default)";
    }
    const deleteOp = new delete_1.FirestoreDelete(options.project, path, {
        recursive: options.recursive,
        shallow: options.shallow,
        allCollections: options.allCollections,
        databaseId: options.database,
    });
    const confirmed = await (0, prompt_1.confirm)({
        message: confirmationMessage(deleteOp, options),
        default: false,
        force: options.force,
        nonInteractive: options.nonInteractive,
    });
    if (!confirmed) {
        return utils.reject("Command aborted.", { exit: 1 });
    }
    if (options.allCollections) {
        return deleteOp.deleteDatabase();
    }
    return deleteOp.execute();
});
