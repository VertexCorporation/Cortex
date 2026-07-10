"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const checkMinRequiredVersion_1 = require("../checkMinRequiredVersion");
const command_1 = require("../command");
const error_1 = require("../error");
const projectUtils_1 = require("../projectUtils");
const extensionsApi = require("../extensions/extensionsApi");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const paramHelper = require("../extensions/paramHelper");
const requirePermissions_1 = require("../requirePermissions");
const utils = require("../utils");
const logger_1 = require("../logger");
const refs = require("../extensions/refs");
const manifest = require("../extensions/manifest");
const functional_1 = require("../functional");
const paramHelper_1 = require("../extensions/paramHelper");
const askUserForEventsConfig = require("../extensions/askUserForEventsConfig");
const tos_1 = require("../extensions/tos");
exports.command = new command_1.Command("ext:configure <extensionInstanceId>")
    .description("configure an existing extension instance")
    .withForce()
    .option("--local", "deprecated")
    .before(requirePermissions_1.requirePermissions, [
    "firebaseextensions.instances.update",
    "firebaseextensions.instances.get",
])
    .before(checkMinRequiredVersion_1.checkMinRequiredVersion, "extMinVersion")
    .before(extensionsHelper_1.diagnoseAndFixProject)
    .action(async (instanceId, options) => {
    const projectId = (0, projectUtils_1.getProjectId)(options);
    if (options.nonInteractive) {
        throw new error_1.FirebaseError(`Command not supported in non-interactive mode, edit ./extensions/${instanceId}.env directly instead. ` +
            `See https://firebase.google.com/docs/extensions/manifest for more details.`);
    }
    if (options.local) {
        utils.logLabeledWarning(extensionsHelper_1.logPrefix, "As of firebase-tools@11.0.0, the `--local` flag is no longer required, as it is the default behavior.");
    }
    const config = manifest.loadConfig(options);
    const refOrPath = manifest.getInstanceTarget(instanceId, config);
    const isLocalSource = (0, extensionsHelper_1.isLocalPath)(refOrPath);
    let spec;
    if (isLocalSource) {
        const source = await (0, extensionsHelper_1.createSourceFromLocation)((0, projectUtils_1.needProjectId)({ projectId }), refOrPath);
        spec = source.spec;
    }
    else {
        const extensionVersion = await extensionsApi.getExtensionVersion(refOrPath);
        spec = extensionVersion.spec;
    }
    const oldParamValues = manifest.readInstanceParam({
        instanceId,
        projectDir: config.projectDir,
    });
    const params = (spec.params ?? []).concat(spec.systemParams ?? []);
    const [immutableParams, tbdParams] = (0, functional_1.partition)(params, (param) => (param.immutable && !!oldParamValues[param.param]) ?? false);
    infoImmutableParams(immutableParams, oldParamValues);
    paramHelper.setNewDefaults(tbdParams, oldParamValues);
    const mutableParamsBindingOptions = await paramHelper.getParams({
        projectId,
        paramSpecs: tbdParams,
        nonInteractive: false,
        instanceId,
        reconfiguring: true,
    });
    const eventsConfig = spec.events
        ? await askUserForEventsConfig.askForEventsConfig(spec.events, "${param:PROJECT_ID}", instanceId)
        : undefined;
    if (eventsConfig) {
        mutableParamsBindingOptions.EVENTARC_CHANNEL = { baseValue: eventsConfig.channel };
        mutableParamsBindingOptions.ALLOWED_EVENT_TYPES = {
            baseValue: eventsConfig.allowedEventTypes.join(","),
        };
    }
    const newParamOptions = {
        ...(0, paramHelper_1.buildBindingOptionsWithBaseValue)(oldParamValues),
        ...mutableParamsBindingOptions,
    };
    await manifest.writeToManifest([
        {
            instanceId,
            ref: !isLocalSource ? refs.parse(refOrPath) : undefined,
            localPath: isLocalSource ? refOrPath : undefined,
            params: newParamOptions,
            extensionSpec: spec,
        },
    ], config, {
        nonInteractive: false,
        force: true,
    });
    (0, tos_1.displayDeveloperTOSWarning)();
    return;
});
function infoImmutableParams(immutableParams, paramValues) {
    if (!immutableParams.length) {
        return;
    }
    const plural = immutableParams.length > 1;
    utils.logLabeledWarning(extensionsHelper_1.logPrefix, `The following param${plural ? "s are" : " is"} immutable and won't be changed:`);
    for (const { param } of immutableParams) {
        logger_1.logger.info(`param: ${param}, value: ${paramValues[param]}`);
    }
    logger_1.logger.info((plural
        ? "To set different values for these params"
        : "To set a different value for this param") +
        ", uninstall the extension, then install a new instance of this extension.");
}
