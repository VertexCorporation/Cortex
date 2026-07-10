"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const marked_1 = require("marked");
const command_1 = require("../command");
const publisherApi_1 = require("../extensions/publisherApi");
const projectUtils_1 = require("../projectUtils");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const tos_1 = require("../extensions/tos");
const requirePermissions_1 = require("../requirePermissions");
const error_1 = require("../error");
const utils = require("../utils");
const prompt_1 = require("../prompt");
exports.command = new command_1.Command("ext:dev:register")
    .description("register a publisher ID; run this before publishing your first extension")
    .before(requirePermissions_1.requirePermissions, ["firebaseextensions.sources.create"])
    .before(extensionsHelper_1.ensureExtensionsPublisherApiEnabled)
    .before(extensionsHelper_1.ensureExtensionsApiEnabled)
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    await (0, tos_1.acceptLatestPublisherTOS)(options, projectId);
    const msg = "What would you like to register as your publisher ID? " +
        "This value identifies you in Firebase's registry of extensions as the author of your extensions. " +
        "Examples: my-company-name, MyGitHubUsername.\n\n" +
        "You can only do this once for each project.";
    const publisherId = await (0, prompt_1.input)({
        message: msg,
        default: projectId,
    });
    let profile;
    try {
        profile = await (0, publisherApi_1.registerPublisherProfile)(projectId, publisherId);
    }
    catch (err) {
        if ((0, error_1.getErrStatus)(err) === 409) {
            const error = `Couldn't register the publisher ID '${clc.bold(publisherId)}' to the project '${clc.bold(projectId)}'.` +
                " This can happen for either of two reasons:\n\n" +
                ` - Publisher ID '${clc.bold(publisherId)}' is registered to another project\n` +
                ` - Project '${clc.bold(projectId)}' already has a publisher ID\n\n` +
                ` Try again with a unique publisher ID or a new project. If your business’s name has been registered to another project, contact Firebase support ${(0, marked_1.marked)("(https://firebase.google.com/support/troubleshooter/contact).")}`;
            throw new error_1.FirebaseError(error, { exit: 1 });
        }
        throw new error_1.FirebaseError(`Failed to register publisher ID ${clc.bold(publisherId)} for project ${clc.bold(projectId)}: ${(0, error_1.getErrMsg)(err)}`);
    }
    utils.logLabeledSuccess(extensionsHelper_1.logPrefix, `Publisher ID '${clc.bold(publisherId)}' has been registered to project ${clc.bold(projectId)}. View and edit your profile at ${utils.consoleUrl(projectId, `/publisher`)}`);
    return profile;
});
