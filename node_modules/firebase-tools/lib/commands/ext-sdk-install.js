"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const semver = require("semver");
const checkMinRequiredVersion_1 = require("../checkMinRequiredVersion");
const command_1 = require("../command");
const extensionsApi = require("../extensions/extensionsApi");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const localHelper_1 = require("../extensions/localHelper");
const requirePermissions_1 = require("../requirePermissions");
const common_1 = require("../extensions/runtimes/common");
const error_1 = require("../error");
const displayExtensionInfo_1 = require("../extensions/displayExtensionInfo");
const refs = require("../extensions/refs");
const logger_1 = require("../logger");
const prompt_1 = require("../prompt");
const utils = require("../utils");
exports.command = new command_1.Command("ext:sdk:install <extensionName>")
    .description("get an SDK for this extension. The SDK will be put in the 'generated' directory")
    .option(`--codebase <codebase>`, `specifies a codebase to install the SDK into`)
    .option(`--force`, `will overwrite existing sdk files if true`)
    .before(checkMinRequiredVersion_1.checkMinRequiredVersion, "extDevMinVersion")
    .action(async (extensionName, options) => {
    const runtime = await (0, common_1.getCodebaseRuntime)(options);
    if (!runtime.startsWith("nodejs")) {
        throw new error_1.FirebaseError(`Extension SDK generation is currently only supported for NodeJs. We detected the target source to be: ${runtime}`);
    }
    let spec;
    let extensionRef;
    let localPath;
    if ((0, localHelper_1.isLocalExtension)(extensionName)) {
        spec = await (0, localHelper_1.getLocalExtensionSpec)(extensionName);
        spec.systemParams = [];
        localPath = extensionName;
        await (0, displayExtensionInfo_1.displayExtensionVersionInfo)({ spec });
    }
    else {
        await (0, requirePermissions_1.requirePermissions)(options, ["firebaseextensions.sources.get"]);
        await (0, extensionsHelper_1.ensureExtensionsApiEnabled)(options);
        const hasPublisherId = extensionName.split("/").length >= 2;
        if (hasPublisherId) {
            const nameAndVersion = extensionName.split("/")[1];
            if (nameAndVersion.split("@").length < 2) {
                extensionName = extensionName + "@latest";
            }
        }
        else {
            const [name, version] = extensionName.split("@");
            extensionName = `firebase/${name}@${version || "latest"}`;
        }
        const ref = refs.parse(extensionName);
        const extension = await extensionsApi.getExtension(refs.toExtensionRef(ref));
        const version = await extensionsApi.getExtensionVersion(extensionName);
        spec = version.spec;
        extensionRef = version.ref;
        await (0, displayExtensionInfo_1.displayExtensionVersionInfo)({
            spec,
            extensionVersion: version,
            latestApprovedVersion: extension.latestApprovedVersion,
            latestVersion: extension.latestVersion,
        });
        if (version.state === "DEPRECATED") {
            throw new error_1.FirebaseError(`Extension version ${clc.bold(extensionName)} is deprecated and cannot be installed. To install an SDK for the ` +
                `latest non-deprecated version, omit the version in the extension ref.`);
        }
        logger_1.logger.info();
        if ((extension.latestApprovedVersion &&
            semver.gt(extension.latestApprovedVersion, version.spec.version)) ||
            (!extension.latestApprovedVersion &&
                extension.latestVersion &&
                semver.gt(extension.latestVersion, version.spec.version))) {
            const latest = extension.latestApprovedVersion || extension.latestVersion;
            logger_1.logger.info(`You are about to install an SDK for extension version ${clc.bold(version.spec.version)} which is older than the latest ${extension.latestApprovedVersion ? "accepted version" : "version"} ${clc.bold(latest)}.`);
        }
    }
    if (!(await (0, prompt_1.confirm)({
        message: "Continue?",
        nonInteractive: options.nonInteractive,
        force: options.force,
        default: true,
    }))) {
        return;
    }
    const codeSample = await (0, common_1.writeSDK)(extensionRef, localPath, spec, options);
    logger_1.logger.info();
    utils.logSuccess("Extension SDK installed successfully");
    logger_1.logger.info(codeSample);
});
