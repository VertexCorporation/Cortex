"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
exports.uploadExtensionAction = uploadExtensionAction;
const clc = require("colorette");
const marked_1 = require("marked");
const marked_terminal_1 = require("marked-terminal");
const command_1 = require("../command");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const refs = require("../extensions/refs");
const localHelper_1 = require("../extensions/localHelper");
const publishHelpers_1 = require("../extensions/publishHelpers");
const requireAuth_1 = require("../requireAuth");
const error_1 = require("../error");
const tos_1 = require("../extensions/tos");
const utils = require("../utils");
const publisherApi_1 = require("../extensions/publisherApi");
const extensionsHelper_2 = require("../extensions/extensionsHelper");
const projects_1 = require("../management/projects");
marked_1.marked.use((0, marked_terminal_1.markedTerminal)());
exports.command = new command_1.Command("ext:dev:upload <extensionRef>")
    .description(`upload a new version of an extension`)
    .option(`-s, --stage <stage>`, `release stage (supports "alpha", "beta", "rc", and "stable")`)
    .option(`--repo <repo>`, `Public GitHub repo URI that contains the extension source`)
    .option(`--ref <ref>`, `commit hash, branch, or tag to build from the repo (defaults to HEAD)`)
    .option(`--root <root>`, `root directory that contains this extension (defaults to last uploaded root or "/" if none set)`)
    .option(`--local`, `upload from local source instead`)
    .withForce()
    .help("if you have not previously uploaded a version of this extension, this will " +
    "create the extension. If you have previously uploaded a version of this extension, this version must " +
    "be greater than previous versions.")
    .before(requireAuth_1.requireAuth)
    .before(extensionsHelper_1.ensureExtensionsPublisherApiEnabled)
    .action(uploadExtensionAction);
async function uploadExtensionAction(extensionRef, options) {
    const { publisherId, extensionId, version } = refs.parse(extensionRef);
    if (version) {
        throw new error_1.FirebaseError(`The input extension reference must be of the format ${clc.bold("<publisherId>/<extensionId>")}. Version should not be supplied and will be inferred directly from extension.yaml. Please increment the version in extension.yaml if you would like to bump/specify a version.`);
    }
    if (!publisherId || !extensionId) {
        throw new error_1.FirebaseError(`Error parsing publisher ID and extension ID from extension reference '${clc.bold(extensionRef)}'. Please use the format '${clc.bold("<publisherId>/<extensionId>")}'.`);
    }
    let profile;
    try {
        profile = await (0, publisherApi_1.getPublisherProfile)("-", publisherId);
    }
    catch (err) {
        if ((0, error_1.getErrStatus)(err) === 404) {
            throw (0, extensionsHelper_1.getMissingPublisherError)(publisherId);
        }
        throw err;
    }
    const projectNumber = `${(0, extensionsHelper_2.getPublisherProjectFromName)(profile.name)}`;
    const { projectId } = await (0, projects_1.getProject)(projectNumber);
    await (0, tos_1.acceptLatestPublisherTOS)(options, projectNumber);
    let res;
    if (options.local) {
        const extensionYamlDirectory = (0, localHelper_1.findExtensionYaml)(process.cwd());
        res = await (0, extensionsHelper_1.uploadExtensionVersionFromLocalSource)({
            publisherId,
            extensionId,
            rootDirectory: extensionYamlDirectory,
            nonInteractive: options.nonInteractive,
            force: options.force,
            stage: options.stage,
        });
    }
    else {
        res = await (0, extensionsHelper_1.uploadExtensionVersionFromGitHubSource)({
            publisherId,
            extensionId,
            repoUri: options.repo,
            sourceRef: options.ref,
            extensionRoot: options.root,
            nonInteractive: options.nonInteractive,
            force: options.force,
            stage: options.stage,
        });
    }
    if (res) {
        utils.logLabeledBullet(extensionsHelper_1.logPrefix, await (0, marked_1.marked)(`[Install Link](${(0, publishHelpers_1.consoleInstallLink)(res.ref)})`));
        const version = res.ref.split("@")[1];
        utils.logLabeledBullet(extensionsHelper_1.logPrefix, await (0, marked_1.marked)(`[View in Console](${utils.consoleUrl(projectId, `/publisher/extensions/${extensionId}/v/${version}`)})`));
    }
    return res;
}
