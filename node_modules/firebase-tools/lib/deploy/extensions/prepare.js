"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prepareDynamicExtensions = prepareDynamicExtensions;
exports.prepare = prepare;
const planner = require("./planner");
const deploymentSummary = require("./deploymentSummary");
const prompt = require("../../prompt");
const refs = require("../../extensions/refs");
const projectUtils_1 = require("../../projectUtils");
const logger_1 = require("../../logger");
const error_1 = require("../../error");
const requirePermissions_1 = require("../../requirePermissions");
const extensionsHelper_1 = require("../../extensions/extensionsHelper");
const secretsUtils_1 = require("../../extensions/secretsUtils");
const secrets_1 = require("./secrets");
const warnings_1 = require("../../extensions/warnings");
const etags_1 = require("../../extensions/etags");
const v2FunctionHelper_1 = require("./v2FunctionHelper");
const tos_1 = require("../../extensions/tos");
const common_1 = require("../../extensions/runtimes/common");
const functionsDeployHelper_1 = require("../functions/functionsDeployHelper");
const projectConfig_1 = require("../../functions/projectConfig");
const utils_1 = require("../../utils");
const matchesInstanceId = (dep) => (test) => {
    return dep.instanceId === test.instanceId;
};
const isUpdate = (dep) => (test) => {
    return dep.instanceId === test.instanceId && !refs.equal(dep.ref, test.ref);
};
const isConfigure = (dep) => (test) => {
    return dep.instanceId === test.instanceId && refs.equal(dep.ref, test.ref);
};
async function prepareHelper(context, options, payload, wantExtensions, haveExtensions, isDynamic) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    context.want = wantExtensions;
    context.have = haveExtensions;
    const etagsChanged = (0, etags_1.detectEtagChanges)(options.rc, projectId, context.have);
    if (etagsChanged.length) {
        const wantChangedIds = wantExtensions
            .map((e) => e.instanceId)
            .filter((id) => etagsChanged.includes(id));
        if (wantChangedIds.length) {
            (0, warnings_1.outOfBandChangesWarning)(wantChangedIds, isDynamic);
            if (!(await prompt.confirm({
                message: `Do you wish to continue deploying these extension instances?`,
                default: false,
                nonInteractive: options.nonInteractive,
                force: options.force,
            }))) {
                throw new error_1.FirebaseError("Deployment cancelled");
            }
        }
    }
    const usingSecrets = await Promise.all(context.want?.map(secrets_1.checkSpecForSecrets));
    if (usingSecrets.some((i) => i)) {
        await (0, secretsUtils_1.ensureSecretManagerApiEnabled)(options);
    }
    const usingV2Functions = await Promise.all(context.want?.map(v2FunctionHelper_1.checkSpecForV2Functions));
    if (usingV2Functions) {
        await (0, v2FunctionHelper_1.ensureNecessaryV2ApisAndRoles)(options);
    }
    payload.instancesToCreate = context.want.filter((i) => !context.have?.some(matchesInstanceId(i)));
    payload.instancesToConfigure = context.want.filter((i) => context.have?.some(isConfigure(i)));
    payload.instancesToUpdate = context.want.filter((i) => context.have?.some(isUpdate(i)));
    payload.instancesToDelete = context.have.filter((i) => !context.want?.some(matchesInstanceId(i)));
    if (await (0, warnings_1.displayWarningsForDeploy)(payload.instancesToCreate)) {
        if (!(await prompt.confirm({
            message: `Do you wish to continue deploying these extension instances?`,
            default: true,
            nonInteractive: options.nonInteractive,
            force: options.force,
        }))) {
            throw new error_1.FirebaseError("Deployment cancelled");
        }
    }
    const permissionsNeeded = [];
    if (payload.instancesToCreate.length) {
        permissionsNeeded.push("firebaseextensions.instances.create");
        logger_1.logger.info(deploymentSummary.createsSummary(payload.instancesToCreate));
    }
    if (payload.instancesToUpdate.length) {
        permissionsNeeded.push("firebaseextensions.instances.update");
        logger_1.logger.info(deploymentSummary.updatesSummary(payload.instancesToUpdate, context.have));
    }
    if (payload.instancesToConfigure.length) {
        permissionsNeeded.push("firebaseextensions.instances.update");
        logger_1.logger.info(deploymentSummary.configuresSummary(payload.instancesToConfigure));
    }
    if (payload.instancesToDelete.length) {
        logger_1.logger.info(deploymentSummary.deletesSummary(payload.instancesToDelete, isDynamic));
        if (options.dryRun) {
            logger_1.logger.info("On your next deploy, you will be asked if you want to delete these instances.");
            logger_1.logger.info("If you deploy --force, they will be deleted.");
        }
        if (!options.dryRun &&
            !(await prompt.confirm({
                message: `Would you like to delete ${payload.instancesToDelete
                    .map((i) => i.instanceId)
                    .join(", ")}?`,
                default: false,
                nonInteractive: options.nonInteractive,
                force: options.force,
            }))) {
            payload.instancesToDelete = [];
        }
        else {
            permissionsNeeded.push("firebaseextensions.instances.delete");
        }
    }
    await (0, requirePermissions_1.requirePermissions)(options, permissionsNeeded);
    if (options.dryRun) {
        const appDevTos = await (0, tos_1.getAppDeveloperTOSStatus)(projectId);
        if (!appDevTos.lastAcceptedVersion) {
            logger_1.logger.info("On your next deploy, you will be asked to accept the Firebase Extensions App Developer Terms of Service");
        }
    }
    else {
        await (0, tos_1.acceptLatestAppDeveloperTOS)(options, projectId, context.want.map((i) => i.instanceId));
    }
}
async function prepareDynamicExtensions(context, options, payload, builds) {
    const functionsConfig = (0, projectConfig_1.normalizeAndValidate)(options.config.src.functions);
    const filters = (0, functionsDeployHelper_1.getEndpointFilters)(options, functionsConfig);
    const extensions = (0, common_1.extractExtensionsFromBuilds)(builds, filters);
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    let haveExtensions = [];
    try {
        await (0, extensionsHelper_1.ensureExtensionsApiEnabled)(options);
        await (0, requirePermissions_1.requirePermissions)(options, ["firebaseextensions.instances.list"]);
        haveExtensions = await planner.haveDynamic(projectId);
        haveExtensions = haveExtensions.filter((e) => (0, common_1.extensionMatchesAnyFilter)(e.labels?.codebase, e.instanceId, filters));
    }
    catch (err) {
        (0, utils_1.logLabeledError)("extensions", "Failed to fetch the list of extensions. Assuming for now that there are no existing extensions. " +
            "If you are trying to install an extension through Firebase Functions this may fail later.");
        return;
    }
    if (Object.keys(extensions).length === 0 && haveExtensions.length === 0) {
        return;
    }
    const dynamicWant = await planner.wantDynamic({
        projectId,
        projectNumber,
        extensions,
    });
    return prepareHelper(context, options, payload, dynamicWant, haveExtensions, true);
}
async function prepare(context, options, payload) {
    context.extensionsStartTime = Date.now();
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    const aliases = (0, projectUtils_1.getAliases)(options, projectId);
    const projectDir = options.config.projectDir;
    await (0, extensionsHelper_1.ensureExtensionsApiEnabled)(options);
    await (0, requirePermissions_1.requirePermissions)(options, ["firebaseextensions.instances.list"]);
    const wantExtensions = await planner.want({
        projectId,
        projectNumber,
        aliases,
        projectDir,
        extensions: options.config.get("extensions", {}),
    });
    const haveExtensions = await planner.have(projectId);
    return prepareHelper(context, options, payload, wantExtensions, haveExtensions, false);
}
