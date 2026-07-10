"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const containerCleaner_1 = require("../deploy/functions/containerCleaner");
const prompt_1 = require("../prompt");
const requirePermissions_1 = require("../requirePermissions");
const error_1 = require("../error");
function getConfirmationMessage(paths) {
    let message = "You are about to delete all images in the following directories:\n\n";
    for (const path of paths) {
        message += `${path}\n`;
    }
    message += "\nAre you sure?\n";
    return message;
}
exports.command = new command_1.Command("functions:deletegcfartifacts")
    .description("deletes all artifacts created by Google Cloud Functions on Google Container Registry")
    .option("--regions <regions>", "Specify regions of artifacts to be deleted. " +
    "If omitted, artifacts from all regions will be deleted. " +
    "<regions> is a Google defined region list, e.g. us-central1,us-east1,europe-west2.")
    .before(requirePermissions_1.requirePermissions, ["storage.objects.delete"])
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const regions = options.regions ? options.regions.split(",") : undefined;
    const dockerHelper = {};
    try {
        const gcfPaths = await (0, containerCleaner_1.listGcfPaths)(projectId, regions, dockerHelper);
        const confirmDeletion = await (0, prompt_1.confirm)({
            default: false,
            message: getConfirmationMessage(gcfPaths),
            force: options.force,
            nonInteractive: options.nonInteractive,
        });
        if (!confirmDeletion) {
            throw new error_1.FirebaseError("Command aborted.", { exit: 1 });
        }
        await (0, containerCleaner_1.deleteGcfArtifacts)(projectId, regions, dockerHelper);
    }
    catch (err) {
        throw new error_1.FirebaseError("Command failed.", { original: err });
    }
});
