"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = default_1;
const clc = require("colorette");
const load_1 = require("../../dataconnect/load");
const logger_1 = require("../../logger");
const utils = require("../../utils");
const projectUtils_1 = require("../../projectUtils");
const filters_1 = require("../../dataconnect/filters");
const build_1 = require("../../dataconnect/build");
const ensureApis_1 = require("../../dataconnect/ensureApis");
const requireTosAcceptance_1 = require("../../requireTosAcceptance");
const firedata_1 = require("../../gcp/firedata");
const provisionCloudSql_1 = require("../../dataconnect/provisionCloudSql");
const names_1 = require("../../dataconnect/names");
const error_1 = require("../../error");
const types_1 = require("../../dataconnect/types");
const schemaMigration_1 = require("../../dataconnect/schemaMigration");
const cloudbilling_1 = require("../../gcp/cloudbilling");
const context_1 = require("./context");
async function default_1(context, options) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    await (0, ensureApis_1.ensureApis)(projectId);
    context.dataconnect = {
        serviceInfos: await (0, load_1.loadAll)(projectId, options.config),
        filters: (0, filters_1.getResourceFilters)(options),
        deployStats: (0, context_1.initDeployStats)(),
    };
    const { serviceInfos, filters, deployStats } = context.dataconnect;
    if (!(await (0, cloudbilling_1.checkBillingEnabled)(projectId))) {
        deployStats.missingBilling = true;
    }
    await (0, requireTosAcceptance_1.requireTosAcceptance)(firedata_1.DATA_CONNECT_TOS_ID)(options);
    for (const si of serviceInfos) {
        si.deploymentMetadata = await (0, build_1.build)(options, si.sourceDirectory, deployStats);
    }
    const unmatchedFilters = filters?.filter((f) => {
        const serviceMatched = serviceInfos.some((s) => s.dataConnectYaml.serviceId === f.serviceId);
        const connectorMatched = f.connectorId
            ? serviceInfos.some((s) => {
                return (s.dataConnectYaml.serviceId === f.serviceId &&
                    s.connectorInfo.some((c) => c.connectorYaml.connectorId === f.connectorId));
            })
            : true;
        return !serviceMatched || !connectorMatched;
    });
    if (unmatchedFilters?.length) {
        throw new error_1.FirebaseError(`The following filters were specified in --only but didn't match anything in this project: ${unmatchedFilters.map(filters_1.toString).map(clc.bold).join(", ")}`);
    }
    utils.logLabeledBullet("dataconnect", `Successfully compiled schema and connectors`);
    if (options.dryRun) {
        for (const si of serviceInfos) {
            await (0, schemaMigration_1.diffSchema)(options, (0, types_1.mainSchema)(si.schemas), si.dataConnectYaml.schema?.datasource?.postgresql?.schemaValidation);
        }
        utils.logLabeledBullet("dataconnect", "Checking for CloudSQL resources...");
        await Promise.all(serviceInfos
            .filter((si) => {
            return !filters || filters?.some((f) => si.dataConnectYaml.serviceId === f.serviceId);
        })
            .map(async (s) => {
            const postgresDatasource = (0, types_1.mainSchema)(s.schemas).datasources.find((d) => d.postgresql);
            if (postgresDatasource) {
                const instanceId = postgresDatasource.postgresql?.cloudSql?.instance.split("/").pop();
                const databaseId = postgresDatasource.postgresql?.database;
                if (!instanceId || !databaseId) {
                    return Promise.resolve();
                }
                return (0, provisionCloudSql_1.setupCloudSql)({
                    projectId,
                    location: (0, names_1.parseServiceName)(s.serviceName).location,
                    instanceId,
                    databaseId,
                    requireGoogleMlIntegration: (0, types_1.requiresVector)(s.deploymentMetadata),
                    dryRun: true,
                    source: "deploy",
                });
            }
        }));
    }
    logger_1.logger.debug(JSON.stringify(context.dataconnect, null, 2));
    return;
}
