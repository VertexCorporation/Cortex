"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.GENKIT_MONITORING_ROLES = exports.EVENTARC_EVENT_RECEIVER_ROLE = exports.RUN_INVOKER_ROLE = exports.SERVICE_ACCOUNT_TOKEN_CREATOR_ROLE = void 0;
exports.checkServiceAccountIam = checkServiceAccountIam;
exports.checkHttpIam = checkHttpIam;
exports.obtainPubSubServiceAgentBindings = obtainPubSubServiceAgentBindings;
exports.obtainDefaultComputeServiceAgentBindings = obtainDefaultComputeServiceAgentBindings;
exports.ensureGenkitMonitoringRoles = ensureGenkitMonitoringRoles;
exports.ensureServiceAgentRoles = ensureServiceAgentRoles;
const colorette_1 = require("colorette");
const logger_1 = require("../../logger");
const functionsDeployHelper_1 = require("./functionsDeployHelper");
const error_1 = require("../../error");
const functional_1 = require("../../functional");
const iam = require("../../gcp/iam");
const gce = require("../../gcp/computeEngine");
const backend = require("./backend");
const track_1 = require("../../track");
const utils = require("../../utils");
const resourceManager_1 = require("../../gcp/resourceManager");
const services_1 = require("./services");
const PERMISSION = "cloudfunctions.functions.setIamPolicy";
exports.SERVICE_ACCOUNT_TOKEN_CREATOR_ROLE = "roles/iam.serviceAccountTokenCreator";
exports.RUN_INVOKER_ROLE = "roles/run.invoker";
exports.EVENTARC_EVENT_RECEIVER_ROLE = "roles/eventarc.eventReceiver";
exports.GENKIT_MONITORING_ROLES = [
    "roles/monitoring.metricWriter",
    "roles/cloudtrace.agent",
    "roles/logging.logWriter",
];
async function checkServiceAccountIam(projectId) {
    const saEmail = `${projectId}@appspot.gserviceaccount.com`;
    let passed = false;
    try {
        const iamResult = await iam.testResourceIamPermissions("https://iam.googleapis.com", "v1", `projects/${projectId}/serviceAccounts/${saEmail}`, ["iam.serviceAccounts.actAs"]);
        passed = iamResult.passed;
    }
    catch (err) {
        logger_1.logger.debug("[functions] service account IAM check errored, deploy may fail:", err);
        return;
    }
    if (!passed) {
        throw new error_1.FirebaseError(`Missing permissions required for functions deploy. You must have permission ${(0, colorette_1.bold)("iam.serviceAccounts.ActAs")} on service account ${(0, colorette_1.bold)(saEmail)}.\n\n` +
            `To address this error, ask a project Owner to assign your account the "Service Account User" role from this URL:\n\n` +
            `https://console.cloud.google.com/iam-admin/iam?project=${projectId}`);
    }
}
async function checkHttpIam(context, options, payload) {
    if (!payload.functions) {
        return;
    }
    const filters = context.filters || (0, functionsDeployHelper_1.getEndpointFilters)(options, context.config);
    const wantBackends = Object.values(payload.functions).map(({ wantBackend }) => wantBackend);
    const httpEndpoints = [...(0, functional_1.flattenArray)(wantBackends.map((b) => backend.allEndpoints(b)))]
        .filter((f) => backend.isHttpsTriggered(f) || backend.isDataConnectGraphqlTriggered(f))
        .filter((f) => (0, functionsDeployHelper_1.endpointMatchesAnyFilter)(f, filters))
        .filter((f) => f.platform !== "run");
    const existing = await backend.existingBackend(context);
    const newHttpsEndpoints = httpEndpoints.filter(backend.missingEndpoint(existing));
    if (newHttpsEndpoints.length === 0) {
        return;
    }
    logger_1.logger.debug("[functions] found", newHttpsEndpoints.length, "new HTTP functions, testing setIamPolicy permission...");
    let passed = true;
    try {
        const iamResult = await iam.testIamPermissions(context.projectId, [PERMISSION]);
        passed = iamResult.passed;
    }
    catch (e) {
        logger_1.logger.debug("[functions] failed http create setIamPolicy permission check. deploy may fail:", e);
        return;
    }
    if (!passed) {
        void (0, track_1.trackGA4)("error", {
            error_type: "Error (User)",
            details: "deploy:functions:http_create_missing_iam",
        });
        throw new error_1.FirebaseError(`Missing required permission on project ${(0, colorette_1.bold)(context.projectId)} to deploy new HTTPS functions. The permission ${(0, colorette_1.bold)(PERMISSION)} is required to deploy the following functions:\n\n- ` +
            newHttpsEndpoints.map((func) => func.id).join("\n- ") +
            `\n\nTo address this error, please ask a project Owner to assign your account the "Cloud Functions Admin" role at the following URL:\n\nhttps://console.cloud.google.com/iam-admin/iam?project=${context.projectId}`);
    }
    logger_1.logger.debug("[functions] found setIamPolicy permission, proceeding with deploy");
}
function getPubsubServiceAgent(projectNumber) {
    return `service-${projectNumber}@gcp-sa-pubsub.iam.gserviceaccount.com`;
}
function reduceEventsToServices(services, endpoint) {
    const service = (0, services_1.serviceForEndpoint)(endpoint);
    if (service.requiredProjectBindings && !services.find((s) => s.name === service.name)) {
        services.push(service);
    }
    return services;
}
function isGenkitEndpoint(endpoint) {
    return (backend.isCallableTriggered(endpoint) && endpoint.callableTrigger.genkitAction !== undefined);
}
function obtainPubSubServiceAgentBindings(projectNumber) {
    const serviceAccountTokenCreatorBinding = {
        role: exports.SERVICE_ACCOUNT_TOKEN_CREATOR_ROLE,
        members: [`serviceAccount:${getPubsubServiceAgent(projectNumber)}`],
    };
    return [serviceAccountTokenCreatorBinding];
}
async function obtainDefaultComputeServiceAgentBindings(projectNumber) {
    const defaultComputeServiceAgent = `serviceAccount:${await gce.getDefaultServiceAccount(projectNumber)}`;
    const runInvokerBinding = {
        role: exports.RUN_INVOKER_ROLE,
        members: [defaultComputeServiceAgent],
    };
    const eventarcEventReceiverBinding = {
        role: exports.EVENTARC_EVENT_RECEIVER_ROLE,
        members: [defaultComputeServiceAgent],
    };
    return [runInvokerBinding, eventarcEventReceiverBinding];
}
async function ensureGenkitMonitoringRoles(projectId, projectNumber, want, have, dryRun) {
    const wantEndpoints = backend.allEndpoints(want).filter(isGenkitEndpoint);
    const newEndpoints = wantEndpoints.filter(backend.missingEndpoint(have));
    if (newEndpoints.length === 0) {
        return;
    }
    const serviceAccounts = newEndpoints
        .map((endpoint) => endpoint.serviceAccount || "")
        .filter((value, index, self) => self.indexOf(value) === index);
    const defaultServiceAccountIndex = serviceAccounts.indexOf("");
    if (defaultServiceAccountIndex !== -1) {
        serviceAccounts[defaultServiceAccountIndex] = await gce.getDefaultServiceAccount(projectNumber);
    }
    const members = serviceAccounts.filter((sa) => !!sa).map((sa) => `serviceAccount:${sa}`);
    const requiredBindings = [];
    for (const monitoringRole of exports.GENKIT_MONITORING_ROLES) {
        requiredBindings.push({
            role: monitoringRole,
            members: members,
        });
    }
    await ensureBindings(projectId, projectNumber, requiredBindings, newEndpoints.map((endpoint) => endpoint.id), dryRun);
}
async function ensureServiceAgentRoles(projectId, projectNumber, want, have, dryRun) {
    const wantServices = backend.allEndpoints(want).reduce(reduceEventsToServices, []);
    const haveServices = backend.allEndpoints(have).reduce(reduceEventsToServices, []);
    const newServices = wantServices.filter((wantS) => !haveServices.find((haveS) => wantS.name === haveS.name));
    if (newServices.length === 0) {
        return;
    }
    const requiredBindingsPromises = [];
    for (const service of newServices) {
        requiredBindingsPromises.push(service.requiredProjectBindings(projectNumber));
    }
    const nestedRequiredBindings = await Promise.all(requiredBindingsPromises);
    const requiredBindings = [...(0, functional_1.flattenArray)(nestedRequiredBindings)];
    if (haveServices.length === 0) {
        requiredBindings.push(...obtainPubSubServiceAgentBindings(projectNumber));
        requiredBindings.push(...(await obtainDefaultComputeServiceAgentBindings(projectNumber)));
    }
    if (requiredBindings.length === 0) {
        return;
    }
    await ensureBindings(projectId, projectNumber, requiredBindings, newServices.map((service) => service.api), dryRun);
}
async function ensureBindings(projectId, projectNumber, requiredBindings, newServicesOrEndpoints, dryRun) {
    let policy;
    try {
        policy = await (0, resourceManager_1.getIamPolicy)(projectNumber);
    }
    catch (err) {
        iam.printManualIamConfig(requiredBindings, projectId, "functions");
        utils.logLabeledBullet("functions", "Could not verify the necessary IAM configuration for the following newly-integrated services: " +
            `${newServicesOrEndpoints.join(", ")}` +
            ". Deployment may fail.", "warn");
        return;
    }
    const hasUpdatedBindings = iam.mergeBindings(policy, requiredBindings);
    if (!hasUpdatedBindings) {
        return;
    }
    try {
        if (dryRun) {
            logger_1.logger.info(`On your next deploy, the following required roles will be granted: ${requiredBindings.map((b) => `${b.members.join(", ")}: ${(0, colorette_1.bold)(b.role)}`)}`);
        }
        else {
            await (0, resourceManager_1.setIamPolicy)(projectNumber, policy, "bindings");
        }
    }
    catch (err) {
        iam.printManualIamConfig(requiredBindings, projectId, "functions");
        throw new error_1.FirebaseError("We failed to modify the IAM policy for the project. The functions " +
            "deployment requires specific roles to be granted to service agents," +
            " otherwise the deployment will fail.", { original: err });
    }
}
