"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const semver = require("semver");
const refs = require("../extensions/refs");
const utils = require("../utils");
const command_1 = require("../command");
const prompt_1 = require("../prompt");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const publisherApi_1 = require("../extensions/publisherApi");
const versionHelper_1 = require("../extensions/versionHelper");
const requireAuth_1 = require("../requireAuth");
const error_1 = require("../error");
exports.command = new command_1.Command("ext:dev:deprecate <extensionRef> [versionPredicate]")
    .description("deprecate extension versions that match the version predicate")
    .option("-m, --message <deprecationMessage>", "deprecation message")
    .option("-f, --force", "override deprecation message for existing deprecated extension versions that match")
    .before(requireAuth_1.requireAuth)
    .before(extensionsHelper_1.ensureExtensionsPublisherApiEnabled)
    .action(async (extensionRef, versionPredicate, options) => {
    const ref = refs.parse(extensionRef);
    return deprecate(ref, versionPredicate, options);
});
async function deprecate(extensionRef, versionPredicate, options) {
    const { publisherId, extensionId, version } = extensionRef;
    if (version) {
        throw new error_1.FirebaseError(`The input extension reference must be of the format ${clc.bold("<publisherId>/<extensionId>")}. Version should be supplied in the version predicate argument.`);
    }
    if (!publisherId || !extensionId) {
        throw new error_1.FirebaseError(`Error parsing publisher ID and extension ID from extension reference '${clc.bold(refs.toExtensionRef(extensionRef))}'. Please use the format '${clc.bold("<publisherId>/<extensionId>")}'.`);
    }
    let filter = "";
    if (versionPredicate) {
        const { comparator, targetSemVer } = (0, versionHelper_1.parseVersionPredicate)(versionPredicate);
        filter = `id${comparator}"${targetSemVer}"`;
    }
    const extensionVersions = await (0, publisherApi_1.listExtensionVersions)(refs.toExtensionRef(extensionRef), filter);
    const filteredExtensionVersions = extensionVersions
        .sort((ev1, ev2) => {
        return -semver.compare(ev1.spec.version, ev2.spec.version);
    })
        .filter((extensionVersion) => {
        if (extensionVersion.state === "DEPRECATED" && !options.force) {
            return false;
        }
        const message = extensionVersion.state === "DEPRECATED" ? ", will overwrite deprecation message" : "";
        utils.logLabeledBullet(extensionVersion.ref, extensionVersion.state + message);
        return true;
    });
    if (filteredExtensionVersions.length > 0) {
        const consent = await (0, prompt_1.confirm)({
            message: "Continue?",
            default: false,
            force: options.force,
            nonInteractive: options.nonInteractive,
        });
        if (!consent) {
            throw new error_1.FirebaseError("Deprecation canceled.");
        }
    }
    else {
        throw new error_1.FirebaseError("No extension versions matched the version predicate.");
    }
    await utils.allSettled(filteredExtensionVersions.map(async (extensionVersion) => {
        await (0, publisherApi_1.deprecateExtensionVersion)(extensionVersion.ref, options.message);
    }));
    utils.logLabeledSuccess(extensionsHelper_1.logPrefix, "successfully deprecated extension version(s).");
}
