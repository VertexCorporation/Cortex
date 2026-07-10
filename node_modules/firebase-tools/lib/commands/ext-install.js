"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const semver = require("semver");
const displayExtensionInfo_1 = require("../extensions/displayExtensionInfo");
const askUserForEventsConfig = require("../extensions/askUserForEventsConfig");
const checkMinRequiredVersion_1 = require("../checkMinRequiredVersion");
const command_1 = require("../command");
const error_1 = require("../error");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const extensionsApi = require("../extensions/extensionsApi");
const refs = require("../extensions/refs");
const secretsUtils = require("../extensions/secretsUtils");
const paramHelper = require("../extensions/paramHelper");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const planner_1 = require("../deploy/extensions/planner");
const utils_1 = require("../extensions/utils");
const requirePermissions_1 = require("../requirePermissions");
const utils = require("../utils");
const track_1 = require("../track");
const prompt_1 = require("../prompt");
const manifest = require("../extensions/manifest");
const tos_1 = require("../extensions/tos");
exports.command = new command_1.Command("ext:install [extensionRefOrLocalPath]")
    .description("add an extension to firebase.json")
    .option("--local", "deprecated")
    .withForce()
    .before(requirePermissions_1.requirePermissions, ["firebaseextensions.instances.create"])
    .before(extensionsHelper_1.ensureExtensionsApiEnabled)
    .before(checkMinRequiredVersion_1.checkMinRequiredVersion, "extMinVersion")
    .before(extensionsHelper_1.diagnoseAndFixProject)
    .action(async (extensionRef, options) => {
    if (options.local) {
        utils.logLabeledWarning(extensionsHelper_1.logPrefix, "As of firebase-tools@11.0.0, the `--local` flag is no longer required, as it is the default behavior.");
    }
    if (!extensionRef) {
        throw new error_1.FirebaseError("Extension ref is required to install. To see a full list of available extensions, go to Extensions Hub (https://extensions.dev/extensions).");
    }
    let source;
    let extensionVersion;
    const projectId = (0, projectUtils_1.getProjectId)(options);
    if ((0, extensionsHelper_1.isLocalPath)(extensionRef)) {
        source = await (0, extensionsHelper_1.createSourceFromLocation)((0, projectUtils_1.needProjectId)({ projectId }), extensionRef);
        await (0, displayExtensionInfo_1.displayExtensionVersionInfo)({ spec: source.spec });
    }
    else {
        const extension = await extensionsApi.getExtension(extensionRef);
        const ref = refs.parse(extensionRef);
        ref.version = await (0, planner_1.resolveVersion)(ref, extension);
        const extensionVersionRef = refs.toExtensionVersionRef(ref);
        extensionVersion = await extensionsApi.getExtensionVersion(extensionVersionRef);
        await (0, displayExtensionInfo_1.displayExtensionVersionInfo)({
            spec: extensionVersion.spec,
            extensionVersion,
            latestApprovedVersion: extension.latestApprovedVersion,
            latestVersion: extension.latestVersion,
        });
        if (extensionVersion.state === "DEPRECATED") {
            throw new error_1.FirebaseError(`Extension version ${clc.bold(extensionVersionRef)} is deprecated and cannot be installed. To install the latest non-deprecated version, omit the version in the extension ref.`);
        }
        logger_1.logger.info();
        if ((extension.latestApprovedVersion &&
            semver.gt(extension.latestApprovedVersion, extensionVersion.spec.version)) ||
            (!extension.latestApprovedVersion &&
                extension.latestVersion &&
                semver.gt(extension.latestVersion, extensionVersion.spec.version))) {
            const version = extension.latestApprovedVersion || extension.latestVersion;
            logger_1.logger.info(`You are about to install extension version ${clc.bold(extensionVersion.spec.version)} which is older than the latest ${extension.latestApprovedVersion ? "accepted version" : "version"} ${clc.bold(version)}.`);
        }
    }
    if (!source && !extensionVersion) {
        throw new error_1.FirebaseError(`Failed to parse ${clc.bold(extensionRef)} as an extension version or a path to a local extension. Please specify a valid reference.`);
    }
    if (!(await (0, prompt_1.confirm)({
        message: "Continue?",
        nonInteractive: options.nonInteractive,
        force: options.force,
        default: true,
    }))) {
        return;
    }
    const spec = source?.spec ?? extensionVersion?.spec;
    if (!spec) {
        throw new error_1.FirebaseError(`Could not find the extension.yaml for extension '${clc.bold(extensionRef)}'. Please make sure this is a valid extension and try again.`);
    }
    if (source) {
        void (0, track_1.trackGA4)("extension_added_to_manifest", {
            published: "local",
            interactive: options.nonInteractive ? "false" : "true",
        });
    }
    else if (extensionVersion) {
        void (0, track_1.trackGA4)("extension_added_to_manifest", {
            published: extensionVersion.listing?.state === "APPROVED" ? "published" : "uploaded",
            interactive: options.nonInteractive ? "false" : "true",
        });
    }
    try {
        return installToManifest({
            projectId,
            extensionRef,
            source,
            extVersion: extensionVersion,
            nonInteractive: options.nonInteractive,
            force: options.force,
        });
    }
    catch (err) {
        if (!(err instanceof error_1.FirebaseError)) {
            throw new error_1.FirebaseError(`Error occurred saving the extension to manifest: ${(0, error_1.getErrMsg)(err)}`, {
                original: (0, error_1.getError)(err),
            });
        }
        throw err;
    }
});
async function installToManifest(options) {
    const { projectId, extensionRef, extVersion, source, nonInteractive, force } = options;
    const isLocalSource = (0, extensionsHelper_1.isLocalPath)(extensionRef);
    const spec = extVersion?.spec ?? source?.spec;
    if (!spec) {
        throw new error_1.FirebaseError(`Could not find the extension.yaml for ${extensionRef}. Please make sure this is a valid extension and try again.`);
    }
    if (secretsUtils.usesSecrets(spec)) {
        await secretsUtils.ensureSecretManagerApiEnabled(options);
    }
    const config = manifest.loadConfig(options);
    let instanceId = spec.name;
    while (manifest.instanceExists(instanceId, config)) {
        instanceId = await (0, extensionsHelper_1.promptForValidInstanceId)(`${spec.name}-${(0, utils_1.getRandomString)(4)}`);
    }
    const paramBindingOptions = await paramHelper.getParams({
        projectId,
        paramSpecs: (spec.params ?? []).concat(spec.systemParams ?? []),
        nonInteractive,
        instanceId,
    });
    const eventsConfig = spec.events
        ? await askUserForEventsConfig.askForEventsConfig(spec.events, "${param:PROJECT_ID}", instanceId)
        : undefined;
    if (eventsConfig) {
        paramBindingOptions.EVENTARC_CHANNEL = { baseValue: eventsConfig.channel };
        paramBindingOptions.ALLOWED_EVENT_TYPES = {
            baseValue: eventsConfig.allowedEventTypes.join(","),
        };
    }
    const ref = extVersion ? refs.parse(extVersion.ref) : undefined;
    await manifest.writeToManifest([
        {
            instanceId,
            ref: !isLocalSource ? ref : undefined,
            localPath: isLocalSource ? extensionRef : undefined,
            params: paramBindingOptions,
            extensionSpec: spec,
        },
    ], config, { nonInteractive, force: force ?? false });
    (0, tos_1.displayDeveloperTOSWarning)();
}
