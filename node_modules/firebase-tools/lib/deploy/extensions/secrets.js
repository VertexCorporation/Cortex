"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleSecretParams = handleSecretParams;
exports.checkSpecForSecrets = checkSpecForSecrets;
const clc = require("colorette");
const secretUtils = require("../../extensions/secretsUtils");
const secretManager = require("../../gcp/secretManager");
const planner_1 = require("./planner");
const askUserForParam_1 = require("../../extensions/askUserForParam");
const types_1 = require("../../extensions/types");
const error_1 = require("../../error");
const logger_1 = require("../../logger");
const utils_1 = require("../../utils");
async function handleSecretParams(payload, have, nonInteractive) {
    for (const i of payload.instancesToCreate ?? []) {
        if (await checkSpecForSecrets(i)) {
            (0, utils_1.logLabeledBullet)("extensions", `Verifying secret params for ${clc.bold(i.instanceId)}`);
            await handleSecretsCreateInstance(i, nonInteractive);
        }
    }
    const updates = [...(payload.instancesToUpdate ?? []), ...(payload.instancesToConfigure ?? [])];
    for (const i of updates) {
        if (await checkSpecForSecrets(i)) {
            (0, utils_1.logLabeledBullet)("extensions", `Verifying secret params for ${clc.bold(i.instanceId)}`);
            const previousSpec = have.find((h) => h.instanceId === i.instanceId);
            await handleSecretsUpdateInstance(i, previousSpec, nonInteractive);
        }
    }
}
async function checkSpecForSecrets(i) {
    const extensionSpec = await (0, planner_1.getExtensionSpec)(i);
    return secretUtils.usesSecrets(extensionSpec);
}
const secretsInSpec = (spec) => {
    return spec.params.filter((p) => p.type === types_1.ParamType.SECRET);
};
async function handleSecretsCreateInstance(i, nonInteractive) {
    const spec = await (0, planner_1.getExtensionSpec)(i);
    const secretParams = secretsInSpec(spec);
    for (const s of secretParams) {
        await handleSecretParamForCreate(s, i, nonInteractive);
    }
}
async function handleSecretsUpdateInstance(i, prevSpec, nonInteractive) {
    const extensionVersion = await (0, planner_1.getExtensionVersion)(i);
    const prevExtensionVersion = await (0, planner_1.getExtensionVersion)(prevSpec);
    const secretParams = secretsInSpec(extensionVersion.spec);
    for (const s of secretParams) {
        const prevParam = prevExtensionVersion.spec.params.find((p) => p.param === s.param);
        if (prevParam?.type === types_1.ParamType.SECRET && prevSpec.params[prevParam?.param]) {
            await handleSecretParamForUpdate(s, i, prevSpec.params[prevParam?.param], nonInteractive);
        }
        else {
            await handleSecretParamForCreate(s, i, nonInteractive);
        }
    }
}
async function handleSecretParamForCreate(secretParam, i, nonInteractive) {
    const providedValue = i.params[secretParam.param];
    if (!providedValue) {
        return;
    }
    const [, projectId, , secretName, , version] = providedValue.split("/");
    if (!projectId || !secretName || !version) {
        throw new error_1.FirebaseError(`${clc.bold(i.instanceId)}: Found '${providedValue}' for secret param ${secretParam.param}, but expected a secret version.`);
    }
    const secretInfo = await getSecretInfo(projectId, secretName, version);
    if (!secretInfo.secret) {
        await promptForCreateSecret({
            projectId,
            secretName,
            instanceId: i.instanceId,
            secretParam,
            nonInteractive,
        });
        return;
    }
    else if (!secretInfo.secretVersion) {
        throw new error_1.FirebaseError(`${clc.bold(i.instanceId)}: Found '${providedValue}' for secret param ${secretParam.param}. ` +
            `projects/${projectId}/secrets/${secretName} exists, but version ${version} does not. ` +
            `See more information about this secret at ${secretManager.secretManagerConsoleUri(projectId)}`);
    }
    if (!!secretInfo?.secret?.labels &&
        !!secretInfo?.secret.labels[secretUtils.SECRET_LABEL] &&
        secretInfo.secret.labels[secretUtils.SECRET_LABEL] !== i.instanceId) {
        throw new error_1.FirebaseError(`${clc.bold(i.instanceId)}: Found '${providedValue}' for secret param ${secretParam.param}. ` +
            `projects/${projectId}/secrets/${secretName} is managed by a different extension instance (${secretInfo.secret.labels[secretUtils.SECRET_LABEL]}), so reusing it here can lead to unexpected behavior. ` +
            "Please choose a different name for this secret, and rerun this command.");
    }
    await secretUtils.grantFirexServiceAgentSecretAdminRole(secretInfo.secret);
}
async function handleSecretParamForUpdate(secretParam, i, prevValue, nonInteractive) {
    const providedValue = i.params[secretParam.param];
    if (!providedValue) {
        return;
    }
    const [, projectId, , secretName, , version] = providedValue.split("/");
    if (!projectId || !secretName || !version) {
        throw new error_1.FirebaseError(`${clc.bold(i.instanceId)}: Found '${providedValue}' for secret param ${secretParam.param}, but expected a secret version.`);
    }
    const [, prevProjectId, , prevSecretName] = prevValue.split("/");
    if (prevSecretName !== secretName) {
        throw new error_1.FirebaseError(`${clc.bold(i.instanceId)}: Found '${providedValue}' for secret param ${secretParam.param}, ` +
            `but this instance was previously using a different secret projects/${prevProjectId}/secrets/${prevSecretName}.\n` +
            `Changing secrets is not supported. If you want to change the value of this secret, ` +
            `use a new version of projects/${prevProjectId}/secrets/${prevSecretName}.` +
            `You can create a new version at ${secretManager.secretManagerConsoleUri(projectId)}`);
    }
    const secretInfo = await getSecretInfo(projectId, secretName, version);
    if (!secretInfo.secret) {
        i.params[secretParam.param] = await promptForCreateSecret({
            projectId,
            secretName,
            instanceId: i.instanceId,
            secretParam,
            nonInteractive,
        });
        return;
    }
    else if (!secretInfo.secretVersion) {
        throw new error_1.FirebaseError(`${clc.bold(i.instanceId)}: Found '${providedValue}' for secret param ${secretParam.param}. ` +
            `projects/${projectId}/secrets/${secretName} exists, but version ${version} does not. ` +
            `See more information about this secret at ${secretManager.secretManagerConsoleUri(projectId)}`);
    }
    i.params[secretParam.param] = secretManager.toSecretVersionResourceName(secretInfo.secretVersion);
    await secretUtils.grantFirexServiceAgentSecretAdminRole(secretInfo.secret);
}
async function getSecretInfo(projectId, secretName, version) {
    const secretInfo = {};
    try {
        secretInfo.secret = await secretManager.getSecret(projectId, secretName);
        secretInfo.secretVersion = await secretManager.getSecretVersion(projectId, secretName, version);
    }
    catch (err) {
        if (err.status !== 404) {
            throw err;
        }
    }
    return secretInfo;
}
async function promptForCreateSecret(args) {
    logger_1.logger.info(`${clc.bold(args.instanceId)}: Secret ${args.projectId}/${args.secretName} doesn't exist yet.`);
    if (args.nonInteractive) {
        throw new error_1.FirebaseError(`To create this secret, run this command in interactive mode, or go to ${secretManager.secretManagerConsoleUri(args.projectId)}`);
    }
    return (0, askUserForParam_1.promptCreateSecret)(args.projectId, args.instanceId, args.secretParam, args.secretName);
}
