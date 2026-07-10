"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.setupCloudSql = setupCloudSql;
exports.cloudSQLBeingCreated = cloudSQLBeingCreated;
exports.getUpdateReason = getUpdateReason;
const clc = require("colorette");
const cloudSqlAdminClient = require("../gcp/cloudsql/cloudsqladmin");
const logger_1 = require("../logger");
const checkIam_1 = require("./checkIam");
const freeTrial_1 = require("./freeTrial");
const utils_1 = require("../utils");
const track_1 = require("../track");
const utils = require("../utils");
const cloudbilling_1 = require("../gcp/cloudbilling");
const GOOGLE_ML_INTEGRATION_ROLE = "roles/aiplatform.user";
async function setupCloudSql(args) {
    const { projectId, instanceId, requireGoogleMlIntegration, dryRun } = args;
    const startTime = Date.now();
    const stats = { action: "get" };
    let success = false;
    try {
        await upsertInstance(stats, { ...args });
        success = true;
    }
    finally {
        if (!dryRun) {
            void (0, track_1.trackGA4)("dataconnect_cloud_sql", {
                source: args.source,
                action: success ? stats.action : `${stats.action}_error`,
                location: args.location,
                enable_google_ml_integration: args.requireGoogleMlIntegration.toString(),
                database_version: stats.databaseVersion?.toLowerCase() || "unknown",
                dataconnect_label: stats.dataconnectLabel || "unknown",
            }, Date.now() - startTime);
        }
    }
    if (requireGoogleMlIntegration && !dryRun) {
        await (0, checkIam_1.grantRolesToCloudSqlServiceAccount)(projectId, instanceId, [GOOGLE_ML_INTEGRATION_ROLE]);
    }
}
async function upsertInstance(stats, args) {
    const { projectId, instanceId, requireGoogleMlIntegration, dryRun } = args;
    try {
        const existingInstance = await cloudSqlAdminClient.getInstance(projectId, instanceId);
        utils.logLabeledBullet("dataconnect", `Found existing Cloud SQL instance ${clc.bold(instanceId)}.`);
        stats.databaseVersion = existingInstance.databaseVersion;
        stats.dataconnectLabel =
            existingInstance.settings?.userLabels?.["firebase-data-connect"] || "absent";
        const why = getUpdateReason(existingInstance, requireGoogleMlIntegration);
        if (why) {
            if (dryRun) {
                utils.logLabeledBullet("dataconnect", `Cloud SQL instance ${clc.bold(instanceId)} settings are not compatible with Firebase SQL Connect. ` +
                    `It will be updated on your next deploy.` +
                    why);
            }
            else {
                utils.logLabeledBullet("dataconnect", `Cloud SQL instance ${clc.bold(instanceId)} settings are not compatible with Firebase SQL Connect. ` +
                    why);
                stats.action = "update";
                await (0, utils_1.promiseWithSpinner)(() => cloudSqlAdminClient.updateInstanceForDataConnect(existingInstance, requireGoogleMlIntegration), "Updating your Cloud SQL instance...");
            }
        }
        await upsertDatabase({ ...args });
    }
    catch (err) {
        if (err.status !== 404) {
            throw err;
        }
        stats.action = "create";
        stats.databaseVersion = cloudSqlAdminClient.DEFAULT_DATABASE_VERSION;
        const freeTrialUsed = await (0, freeTrial_1.checkFreeTrialInstanceUsed)(projectId);
        stats.dataconnectLabel = freeTrialUsed ? "nt" : "ft";
        await createInstance({ ...args, freeTrialLabel: stats.dataconnectLabel });
    }
}
async function createInstance(args) {
    const { projectId, location, instanceId, requireGoogleMlIntegration, dryRun, freeTrialLabel } = args;
    if (dryRun) {
        utils.logLabeledBullet("dataconnect", `Cloud SQL Instance ${clc.bold(instanceId)} not found. It will be created on your next deploy.`);
    }
    else {
        await cloudSqlAdminClient.createInstance({
            projectId,
            location,
            instanceId,
            enableGoogleMlIntegration: requireGoogleMlIntegration,
            freeTrialLabel,
        });
        utils.logLabeledBullet("dataconnect", cloudSQLBeingCreated(projectId, instanceId, freeTrialLabel === "ft", await (0, cloudbilling_1.checkBillingEnabled)(projectId)));
    }
}
function cloudSQLBeingCreated(projectId, instanceId, isFreeTrial, billingEnabled) {
    return (`Cloud SQL Instance ${clc.bold(instanceId)} is being created.` +
        (isFreeTrial
            ? `\nThis instance is provided under the terms of the SQL Connect no-cost trial ${(0, freeTrial_1.freeTrialTermsLink)()}`
            : "") +
        `\n
   Meanwhile, your data are saved in a temporary database and will be migrated once complete.` +
        (isFreeTrial && !billingEnabled
            ? ` 
   Your free trial instance won't show in google cloud console until a billing account is added.
   However, you can still use the gcloud cli to monitor your database instance:\n\n\te.g. gcloud sql instances list --project ${projectId}\n`
            : ` 
   Monitor its progress at\n\n\t${cloudSqlAdminClient.instanceConsoleLink(projectId, instanceId)}\n`));
}
async function upsertDatabase(args) {
    const { projectId, instanceId, databaseId, dryRun } = args;
    try {
        await cloudSqlAdminClient.getDatabase(projectId, instanceId, databaseId);
        utils.logLabeledBullet("dataconnect", `Found existing Postgres Database ${databaseId}.`);
    }
    catch (err) {
        if (err.status !== 404) {
            logger_1.logger.debug(`Unexpected error from Cloud SQL: ${err}`);
            utils.logLabeledWarning("dataconnect", `Postgres Database ${databaseId} is not accessible.`);
            return;
        }
        if (dryRun) {
            utils.logLabeledBullet("dataconnect", `Postgres Database ${databaseId} not found. It will be created on your next deploy.`);
        }
        else {
            await cloudSqlAdminClient.createDatabase(projectId, instanceId, databaseId);
            utils.logLabeledBullet("dataconnect", `Postgres Database ${databaseId} created.`);
        }
    }
}
function getUpdateReason(instance, requireGoogleMlIntegration) {
    let reason = "";
    const settings = instance.settings;
    if (!settings.ipConfiguration?.ipv4Enabled) {
        utils.logLabeledWarning("dataconnect", `Cloud SQL instance ${clc.bold(instance.name)} does not have a public IP.
    ${clc.bold("firebase dataconnect:sql:migrate")} will only work within its VPC (e.g. GCE, GKE).`);
        if (settings.ipConfiguration?.privateNetwork &&
            !settings.ipConfiguration?.enablePrivatePathForGoogleCloudServices) {
            reason += "\n - to enable Private Path for Google Cloud Services.";
        }
    }
    if (requireGoogleMlIntegration) {
        if (!settings.enableGoogleMlIntegration) {
            reason += "\n - to enable Google ML integration.";
        }
        if (!settings.databaseFlags?.some((f) => f.name === "cloudsql.enable_google_ml_integration" && f.value === "on")) {
            reason += "\n - to enable Google ML integration database flag.";
        }
    }
    const isIamEnabled = settings.databaseFlags?.some((f) => f.name === "cloudsql.iam_authentication" && f.value === "on") ?? false;
    if (!isIamEnabled) {
        reason += "\n - to enable IAM authentication database flag.";
    }
    return reason;
}
