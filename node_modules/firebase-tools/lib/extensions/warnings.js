"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.displayWarningsForDeploy = displayWarningsForDeploy;
exports.outOfBandChangesWarning = outOfBandChangesWarning;
const clc = require("colorette");
const extensionsHelper_1 = require("./extensionsHelper");
const deploymentSummary_1 = require("../deploy/extensions/deploymentSummary");
const planner_1 = require("../deploy/extensions/planner");
const logger_1 = require("../logger");
const utils = require("../utils");
const toListEntry = (i) => {
    const idAndRef = (0, deploymentSummary_1.humanReadable)(i);
    const sourceCodeLink = `\n\t[Source Code](${i.extensionVersion?.buildSourceUri ?? i.extensionVersion?.sourceDownloadUri})`;
    const githubLink = i.extensionVersion?.spec?.sourceUrl
        ? `\n\t[Publisher Contact](${i.extensionVersion?.spec.sourceUrl})`
        : "";
    return `${idAndRef}${sourceCodeLink}${githubLink}`;
};
async function displayWarningsForDeploy(instancesToCreate) {
    const uploadedExtensionInstances = instancesToCreate.filter((i) => i.ref);
    for (const i of uploadedExtensionInstances) {
        await (0, planner_1.getExtensionVersion)(i);
    }
    const unpublishedExtensions = uploadedExtensionInstances.filter((i) => i.extensionVersion?.listing?.state !== "APPROVED");
    if (unpublishedExtensions.length) {
        const humanReadableList = unpublishedExtensions.map(toListEntry).join("\n");
        utils.logLabeledBullet(extensionsHelper_1.logPrefix, `The following extension versions have not been published to the Firebase Extensions Hub:\n${humanReadableList}\n.` +
            "Unpublished extensions have not been reviewed by " +
            "Firebase. Please make sure you trust the extension publisher before installing this extension.");
    }
    return unpublishedExtensions.length > 0;
}
function outOfBandChangesWarning(instanceIds, isDynamic) {
    const extra = isDynamic
        ? ""
        : " To avoid this, run `firebase ext:export` to sync these changes to your local extensions manifest.";
    logger_1.logger.warn("The following instances may have been changed in the Firebase console or by another machine since the last deploy from this machine.\n\t" +
        clc.bold(instanceIds.join("\n\t")) +
        `\nIf you proceed with this deployment, those changes will be overwritten.${extra}`);
}
