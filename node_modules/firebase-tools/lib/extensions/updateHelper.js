"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getExistingSourceOrigin = getExistingSourceOrigin;
exports.warningUpdateToOtherSource = warningUpdateToOtherSource;
exports.update = update;
exports.updateFromLocalSource = updateFromLocalSource;
exports.updateFromUrlSource = updateFromUrlSource;
exports.inferUpdateSource = inferUpdateSource;
const clc = require("colorette");
const semver = require("semver");
const error_1 = require("../error");
const logger_1 = require("../logger");
const extensionsApi = require("./extensionsApi");
const extensionsHelper_1 = require("./extensionsHelper");
const utils = require("../utils");
const displayExtensionInfo_1 = require("./displayExtensionInfo");
function invalidSourceErrMsgTemplate(instanceId, source) {
    return `Unable to update from the source \`${clc.bold(source)}\`. To update this instance, you can either:\n
  - Run \`${clc.bold("firebase ext:update " + instanceId)}\` to update from the published source.\n
  - Check your directory path or URL, then run \`${clc.bold("firebase ext:update " + instanceId + " <otherSource>")}\` to update from a local directory or URL source.`;
}
async function getExistingSourceOrigin(projectId, instanceId) {
    const instance = await extensionsApi.getInstance(projectId, instanceId);
    return instance && instance.config.extensionRef
        ? extensionsHelper_1.SourceOrigin.PUBLISHED_EXTENSION
        : extensionsHelper_1.SourceOrigin.LOCAL;
}
function showUpdateVersionInfo(instanceId, from, to, source) {
    if (source) {
        source = clc.bold(source);
    }
    else {
        source = "version";
    }
    utils.logLabeledBullet(extensionsHelper_1.logPrefix, `Updating ${clc.bold(instanceId)} from version ${clc.bold(from)} to ${source} (${clc.bold(to)})`);
    if (semver.lt(to, from)) {
        utils.logLabeledWarning(extensionsHelper_1.logPrefix, "The version you are updating to is less than the current version for this extension. This extension may not be backwards compatible.");
    }
    return;
}
function warningUpdateToOtherSource(sourceOrigin) {
    let targetText;
    if ([extensionsHelper_1.SourceOrigin.PUBLISHED_EXTENSION, extensionsHelper_1.SourceOrigin.PUBLISHED_EXTENSION_VERSION].includes(sourceOrigin)) {
        targetText = "published extension";
    }
    else if (sourceOrigin === extensionsHelper_1.SourceOrigin.LOCAL) {
        targetText = "local directory";
    }
    else if (sourceOrigin === extensionsHelper_1.SourceOrigin.URL) {
        targetText = "URL";
    }
    const warning = `All the instance's resources and logic will be overwritten to use the source code and files from the ${targetText}.\n`;
    logger_1.logger.info(warning);
}
async function update(updateOptions) {
    const { projectId, instanceId, source, extRef, params, canEmitEvents, allowedEventTypes, eventarcChannel, } = updateOptions;
    if (extRef) {
        return await extensionsApi.updateInstanceFromRegistry({
            projectId,
            instanceId,
            extRef,
            params,
            canEmitEvents,
            allowedEventTypes,
            eventarcChannel,
        });
    }
    else if (source) {
        return await extensionsApi.updateInstance({
            projectId,
            instanceId,
            extensionSource: source,
            params,
            canEmitEvents,
            allowedEventTypes,
            eventarcChannel,
        });
    }
    throw new error_1.FirebaseError(`Neither a source nor a version of the extension was supplied for ${instanceId}. Please make sure this is a valid extension and try again.`);
}
async function updateFromLocalSource(projectId, instanceId, localSource, existingSpec) {
    await (0, displayExtensionInfo_1.displayExtensionVersionInfo)({ spec: existingSpec });
    let source;
    try {
        source = await (0, extensionsHelper_1.createSourceFromLocation)(projectId, localSource);
    }
    catch (err) {
        throw new error_1.FirebaseError(invalidSourceErrMsgTemplate(instanceId, localSource));
    }
    utils.logLabeledBullet(extensionsHelper_1.logPrefix, `${clc.bold("You are updating this extension instance to a local source.")}`);
    showUpdateVersionInfo(instanceId, existingSpec.version, source.spec.version, localSource);
    warningUpdateToOtherSource(extensionsHelper_1.SourceOrigin.LOCAL);
    return source.name;
}
async function updateFromUrlSource(projectId, instanceId, urlSource, existingSpec) {
    await (0, displayExtensionInfo_1.displayExtensionVersionInfo)({ spec: existingSpec });
    let source;
    try {
        source = await (0, extensionsHelper_1.createSourceFromLocation)(projectId, urlSource);
    }
    catch (err) {
        throw new error_1.FirebaseError(invalidSourceErrMsgTemplate(instanceId, urlSource));
    }
    utils.logLabeledBullet(extensionsHelper_1.logPrefix, `${clc.bold("You are updating this extension instance to a URL source.")}`);
    showUpdateVersionInfo(instanceId, existingSpec.version, source.spec.version, urlSource);
    warningUpdateToOtherSource(extensionsHelper_1.SourceOrigin.URL);
    return source.name;
}
function inferUpdateSource(updateSource, existingRef) {
    if (!updateSource) {
        return `${existingRef}@latest`;
    }
    if (semver.valid(updateSource)) {
        return `${existingRef}@${updateSource}`;
    }
    if (!(0, extensionsHelper_1.isLocalOrURLPath)(updateSource) && updateSource.split("/").length < 2) {
        return updateSource.includes("@")
            ? `firebase/${updateSource}`
            : `firebase/${updateSource}@latest`;
    }
    if (!(0, extensionsHelper_1.isLocalOrURLPath)(updateSource) && !updateSource.includes("@")) {
        return `${updateSource}@latest`;
    }
    return updateSource;
}
