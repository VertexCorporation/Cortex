"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const requireAuth_1 = require("../requireAuth");
const error_1 = require("../error");
const prompt_1 = require("../prompt");
const utils = require("../utils");
const apphosting = require("../gcp/apphosting");
const apphosting_backends_list_1 = require("./apphosting-backends-list");
const backend_1 = require("../apphosting/backend");
const ora = require("ora");
exports.command = new command_1.Command("apphosting:backends:delete <backend>")
    .description("delete a Firebase App Hosting backend")
    .withForce()
    .before(requireAuth_1.requireAuth)
    .before(apphosting.ensureApiEnabled)
    .action(async (backendId, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const backends = await (0, backend_1.chooseBackends)(projectId, backendId, "Please select the backends you'd like to delete:", options.force);
    utils.logWarning("You are about to permanently delete these backend(s):");
    (0, apphosting_backends_list_1.printBackendsTable)(backends);
    const confirmDeletion = await (0, prompt_1.confirm)({
        message: "Are you sure?",
        default: false,
        force: options.force,
        nonInteractive: options.nonInteractive,
    });
    if (!confirmDeletion) {
        return;
    }
    for (const b of backends) {
        const { location, id } = apphosting.parseBackendName(b.name);
        const spinner = ora(`Deleting backend ${id}(${location})...`).start();
        try {
            await (0, backend_1.deleteBackendAndPoll)(projectId, location, id);
            spinner.succeed(`Successfully deleted the backend: ${id}(${location})`);
        }
        catch (err) {
            spinner.stop();
            throw new error_1.FirebaseError(`Failed to delete backend: ${id}(${location}). Please retry.`, {
                original: (0, error_1.getError)(err),
            });
        }
    }
});
