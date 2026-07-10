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
exports.command = new command_1.Command("ext:dev:undeprecate <extensionRef> <versionPredicate>")
    .description("undeprecate extension versions that match the version predicate")
    .before(requireAuth_1.requireAuth)
    .before(extensionsHelper_1.ensureExtensionsPublisherApiEnabled)
    .action(async (extensionRef, versionPredicate, options) => {
    const { publisherId, extensionId, version } = refs.parse(extensionRef);
    if (version) {
        throw new error_1.FirebaseError(`The input extension reference must be of the format ${clc.bold("<publisherId>/<extensionId>")}. Version should be supplied in the version predicate argument.`);
    }
    if (!publisherId || !extensionId) {
        throw new error_1.FirebaseError(`Error parsing publisher ID and extension ID from extension reference '${clc.bold(extensionRef)}'. Please use the format '${clc.bold("<publisherId>/<extensionId>")}'.`);
    }
    const { comparator, targetSemVer } = (0, versionHelper_1.parseVersionPredicate)(versionPredicate);
    const filter = `id${comparator}"${targetSemVer}"`;
    const extensionVersions = await (0, publisherApi_1.listExtensionVersions)(extensionRef, filter);
    extensionVersions
        .sort((ev1, ev2) => {
        return -semver.compare(ev1.spec.version, ev2.spec.version);
    })
        .forEach((extensionVersion) => {
        utils.logLabeledBullet(extensionVersion.ref, extensionVersion.state);
    });
    if (extensionVersions.length > 0) {
        if (!options.force) {
            const confirmMessage = "You are about to undeprecate these extension version(s). Do you wish to continue?";
            const consent = await (0, prompt_1.confirm)({
                message: confirmMessage,
                default: false,
            });
            if (!consent) {
                throw new error_1.FirebaseError("Undeprecation canceled.");
            }
        }
    }
    else {
        throw new error_1.FirebaseError("No extension versions matched the version predicate.");
    }
    await utils.allSettled(extensionVersions.map(async (extensionVersion) => {
        await (0, publisherApi_1.undeprecateExtensionVersion)(extensionVersion.ref);
    }));
    utils.logLabeledSuccess(extensionsHelper_1.logPrefix, "successfully undeprecated extension version(s).");
});
