"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const checkMinRequiredVersion_1 = require("../checkMinRequiredVersion");
const command_1 = require("../command");
const error_1 = require("../error");
const extensionsApi = require("../extensions/extensionsApi");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const paramHelper = require("../extensions/paramHelper");
const updateHelper_1 = require("../extensions/updateHelper");
const secretsUtils = require("../extensions/secretsUtils");
const refs = require("../extensions/refs");
const projectUtils_1 = require("../projectUtils");
const requirePermissions_1 = require("../requirePermissions");
const utils = require("../utils");
const prompt_1 = require("../prompt");
const manifest = require("../extensions/manifest");
const askUserForEventsConfig = require("../extensions/askUserForEventsConfig");
const tos_1 = require("../extensions/tos");
exports.command = new command_1.Command("ext:update <extensionInstanceId> [updateSource]")
    .description("update an existing extension instance to the latest version, or to a specific version if provided")
    .before(requirePermissions_1.requirePermissions, [
    "firebaseextensions.instances.update",
    "firebaseextensions.instances.get",
])
    .before(extensionsHelper_1.ensureExtensionsApiEnabled)
    .before(checkMinRequiredVersion_1.checkMinRequiredVersion, "extMinVersion")
    .before(extensionsHelper_1.diagnoseAndFixProject)
    .withForce()
    .action(async (instanceId, updateSource, options) => {
    const projectId = (0, projectUtils_1.getProjectId)(options);
    const config = manifest.loadConfig(options);
    const oldRefOrPath = manifest.getInstanceTarget(instanceId, config);
    if ((0, extensionsHelper_1.isLocalPath)(oldRefOrPath)) {
        throw new error_1.FirebaseError(`Updating an extension with local source is not neccessary. ` +
            `Rerun "firebase deploy" or restart the emulator after making changes to your local extension source. ` +
            `If you've edited the extension param spec, you can edit an extension instance's params ` +
            `interactively by running "firebase ext:configure --local {instance-id}"`);
    }
    const oldRef = manifest.getInstanceRef(instanceId, config);
    const oldExtensionVersion = await extensionsApi.getExtensionVersion(refs.toExtensionVersionRef(oldRef));
    updateSource = (0, updateHelper_1.inferUpdateSource)(updateSource, refs.toExtensionRef(oldRef));
    const newSourceOrigin = (0, extensionsHelper_1.getSourceOrigin)(updateSource);
    if (![extensionsHelper_1.SourceOrigin.PUBLISHED_EXTENSION, extensionsHelper_1.SourceOrigin.PUBLISHED_EXTENSION_VERSION].includes(newSourceOrigin)) {
        throw new error_1.FirebaseError(`Only updating to a published extension version is allowed`);
    }
    const newExtensionVersion = await extensionsApi.getExtensionVersion(updateSource);
    if (oldExtensionVersion.ref === newExtensionVersion.ref) {
        utils.logLabeledBullet(extensionsHelper_1.logPrefix, `${clc.bold(instanceId)} is already up to date. Its version is ${clc.bold(newExtensionVersion.ref)}.`);
        return;
    }
    utils.logLabeledBullet(extensionsHelper_1.logPrefix, `Updating ${clc.bold(instanceId)} from version ${clc.bold(oldExtensionVersion.ref)} to version ${clc.bold(newExtensionVersion.ref)}.`);
    if (!(await (0, prompt_1.confirm)({
        message: "Continue?",
        nonInteractive: options.nonInteractive,
        force: options.force,
        default: false,
    }))) {
        utils.logLabeledBullet(extensionsHelper_1.logPrefix, "Update aborted.");
        return;
    }
    if (secretsUtils.usesSecrets(newExtensionVersion.spec)) {
        await secretsUtils.ensureSecretManagerApiEnabled(options);
    }
    const oldParamValues = manifest.readInstanceParam({
        instanceId,
        projectDir: config.projectDir,
    });
    const newParamBindingOptions = await paramHelper.getParamsForUpdate({
        spec: oldExtensionVersion.spec,
        newSpec: newExtensionVersion.spec,
        currentParams: oldParamValues,
        projectId,
        nonInteractive: options.nonInteractive,
        instanceId,
    });
    const eventsConfig = newExtensionVersion.spec.events
        ? await askUserForEventsConfig.askForEventsConfig(newExtensionVersion.spec.events, "${param:PROJECT_ID}", instanceId)
        : undefined;
    if (eventsConfig) {
        newParamBindingOptions.EVENTARC_CHANNEL = { baseValue: eventsConfig.channel };
        newParamBindingOptions.ALLOWED_EVENT_TYPES = {
            baseValue: eventsConfig.allowedEventTypes.join(","),
        };
    }
    await manifest.writeToManifest([
        {
            instanceId,
            ref: refs.parse(newExtensionVersion.ref),
            params: newParamBindingOptions,
            extensionSpec: newExtensionVersion.spec,
            extensionVersion: newExtensionVersion,
        },
    ], config, {
        nonInteractive: options.nonInteractive,
        force: true,
    });
    (0, tos_1.displayDeveloperTOSWarning)();
    return;
});
