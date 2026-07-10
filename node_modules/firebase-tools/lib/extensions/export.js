"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.parameterizeProject = parameterizeProject;
exports.setSecretParamsToLatest = setSecretParamsToLatest;
exports.displayExportInfo = displayExportInfo;
const planner_1 = require("../deploy/extensions/planner");
const deploymentSummary_1 = require("../deploy/extensions/deploymentSummary");
const logger_1 = require("../logger");
const secretManager_1 = require("../gcp/secretManager");
const secretsUtils_1 = require("./secretsUtils");
function parameterizeProject(projectId, projectNumber, spec) {
    const newParams = {};
    for (const [key, val] of Object.entries(spec.params)) {
        const p1 = val.replace(projectId, "${param:PROJECT_ID}");
        const p2 = p1.replace(projectNumber, "${param:PROJECT_NUMBER}");
        newParams[key] = p2;
    }
    const newSpec = { ...spec };
    newSpec.params = newParams;
    return newSpec;
}
async function setSecretParamsToLatest(spec) {
    const newParams = { ...spec.params };
    const extensionVersion = await (0, planner_1.getExtensionVersion)(spec);
    const activeSecrets = (0, secretsUtils_1.getActiveSecrets)(extensionVersion.spec, newParams);
    for (const [key, val] of Object.entries(newParams)) {
        if (activeSecrets.includes(val)) {
            const parsed = (0, secretManager_1.parseSecretVersionResourceName)(val);
            parsed.versionId = "latest";
            newParams[key] = (0, secretManager_1.toSecretVersionResourceName)(parsed);
        }
    }
    return { ...spec, params: newParams };
}
function displayExportInfo(withRef, withoutRef) {
    logger_1.logger.info("The following Extension instances will be saved locally:");
    logger_1.logger.info("");
    displaySpecs(withRef);
    if (withoutRef.length) {
        logger_1.logger.info(`Your project also has the following instances installed from local sources. These will not be saved to firebase.json:`);
        for (const spec of withoutRef) {
            logger_1.logger.info(spec.instanceId);
        }
    }
}
function displaySpecs(specs) {
    for (let i = 0; i < specs.length; i++) {
        const spec = specs[i];
        logger_1.logger.info(`${i + 1}. ${(0, deploymentSummary_1.humanReadable)(spec)}`);
        logger_1.logger.info(`Configuration will be written to 'extensions/${spec.instanceId}.env'`);
        for (const p of Object.entries(spec.params)) {
            logger_1.logger.info(`\t${p[0]}=${p[1]}`);
        }
        if (spec.allowedEventTypes?.length) {
            logger_1.logger.info(`\tALLOWED_EVENTS=${spec.allowedEventTypes}`);
        }
        if (spec.eventarcChannel) {
            logger_1.logger.info(`\tEVENTARC_CHANNEL=${spec.eventarcChannel}`);
        }
        logger_1.logger.info("");
    }
}
