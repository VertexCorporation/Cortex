"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initDeployStats = initDeployStats;
exports.deployStatsParams = deployStatsParams;
function initDeployStats() {
    return {
        numBuildErrors: 0,
        numBuildWarnings: new Map(),
        numServiceCreated: 0,
        numSchemaMigrated: 0,
        numConnectorUpdatedBeforeSchema: 0,
        numConnectorUpdatedAfterSchema: 0,
        numSchemaSkippedDueToPendingCreate: 0,
        numSchemaSqlDiffs: 0,
        numSchemaInvalidConnectors: 0,
    };
}
function deployStatsParams(stats) {
    const buildWarnings = {};
    for (const [type, num] of stats.numBuildWarnings.entries()) {
        buildWarnings[`num_build_warnings_${type}`] = num;
    }
    return {
        missing_billing: (!!stats.missingBilling).toString(),
        num_service_created: stats.numServiceCreated,
        num_schema_migrated: stats.numSchemaMigrated,
        num_connector_updated_before_schema: stats.numConnectorUpdatedBeforeSchema,
        num_connector_updated_after_schema: stats.numConnectorUpdatedAfterSchema,
        num_schema_skipped_due_to_pending_create: stats.numSchemaSkippedDueToPendingCreate,
        num_schema_sql_diffs: stats.numSchemaSqlDiffs,
        num_schema_invalid_connectors: stats.numSchemaInvalidConnectors,
        num_build_errors: stats.numBuildErrors,
        ...buildWarnings,
    };
}
