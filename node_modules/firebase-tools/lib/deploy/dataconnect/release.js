"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = default_1;
const utils = require("../../utils");
const types_1 = require("../../dataconnect/types");
const client_1 = require("../../dataconnect/client");
const prompts_1 = require("../../dataconnect/prompts");
const schemaMigration_1 = require("../../dataconnect/schemaMigration");
const projectUtils_1 = require("../../projectUtils");
const names_1 = require("../../dataconnect/names");
const logger_1 = require("../../logger");
async function default_1(context, options) {
    const dataconnect = context.dataconnect;
    if (!dataconnect) {
        throw new Error("dataconnect.prepare must be run before dataconnect.release");
    }
    const project = (0, projectUtils_1.needProjectId)(options);
    const serviceInfos = dataconnect.serviceInfos;
    const filters = dataconnect.filters;
    const wantMainSchemas = serviceInfos
        .filter((si) => {
        return (!filters ||
            filters.some((f) => {
                return f.serviceId === si.dataConnectYaml.serviceId && (f.schemaOnly || f.fullService);
            }));
    })
        .map((s) => ({
        schema: (0, types_1.mainSchema)(s.schemas),
        validationMode: (0, types_1.mainSchemaYaml)(s.dataConnectYaml).datasource?.postgresql?.schemaValidation,
    }));
    const wantConnectors = serviceInfos.flatMap((si) => si.connectorInfo
        .filter((c) => {
        return (!filters ||
            filters.some((f) => {
                return (f.serviceId === si.dataConnectYaml.serviceId &&
                    (f.connectorId === c.connectorYaml.connectorId || f.fullService));
            }));
    })
        .map((c) => c.connector));
    const remainingConnectors = await Promise.all(wantConnectors.map(async (c) => {
        try {
            await (0, client_1.upsertConnector)(c);
        }
        catch (err) {
            logger_1.logger.debug("Error pre-deploying connector", c.name, err);
            return c;
        }
        utils.logLabeledSuccess("dataconnect", `Deployed connector ${c.name}`);
        dataconnect.deployStats.numConnectorUpdatedBeforeSchema++;
        return undefined;
    }));
    for (const s of wantMainSchemas) {
        await (0, schemaMigration_1.migrateSchema)({
            options,
            schema: s.schema,
            validateOnly: false,
            schemaValidation: s.validationMode,
            stats: dataconnect.deployStats,
        });
        utils.logLabeledSuccess("dataconnect", `Migrated schema ${s.schema.name}`);
        dataconnect.deployStats.numSchemaMigrated++;
    }
    const wantSecondarySchemas = serviceInfos
        .filter((si) => {
        return (!filters ||
            filters.some((f) => {
                return f.serviceId === si.dataConnectYaml.serviceId && (f.schemaOnly || f.fullService);
            }));
    })
        .map((s) => s.schemas.filter((s) => !(0, types_1.isMainSchema)(s)))
        .flatMap((s) => s);
    for (const schema of wantSecondarySchemas) {
        await (0, schemaMigration_1.upsertSecondarySchema)({ options, schema, stats: dataconnect.deployStats });
        utils.logLabeledSuccess("dataconnect", `Deployed schema ${schema.name}`);
        dataconnect.deployStats.numSchemaMigrated++;
    }
    await Promise.all(remainingConnectors.map(async (c) => {
        if (c) {
            await (0, client_1.upsertConnector)(c);
            utils.logLabeledSuccess("dataconnect", `Deployed connector ${c.name}`);
            dataconnect.deployStats.numConnectorUpdatedAfterSchema++;
        }
    }));
    const allConnectors = await deployedConnectors(serviceInfos);
    const connectorsToDelete = filters
        ? []
        : allConnectors.filter((h) => !wantConnectors.some((w) => w.name === h.name));
    for (const c of connectorsToDelete) {
        await (0, prompts_1.promptDeleteConnector)(options, c.name);
    }
    const allSchemas = await deployedSchemas(serviceInfos);
    const schemasToDelete = filters
        ? []
        : allSchemas.filter((s) => !wantSecondarySchemas.some((w) => w.name === s.name) && !(0, types_1.isMainSchema)(s));
    for (const s of schemasToDelete) {
        await (0, prompts_1.promptDeleteSchema)(options, s.name);
    }
    let consolePath = "/dataconnect";
    if (serviceInfos.length === 1) {
        const sn = (0, names_1.parseServiceName)(serviceInfos[0].serviceName);
        consolePath += `/locations/${sn.location}/services/${sn.serviceId}/schema`;
    }
    utils.logLabeledSuccess("dataconnect", `Deployment complete! View your deployed schema and connectors at

    ${utils.consoleUrl(project, consolePath)}
`);
    return;
}
async function deployedConnectors(serviceInfos) {
    let connectors = [];
    for (const si of serviceInfos) {
        connectors = connectors.concat(await (0, client_1.listConnectors)(si.serviceName));
    }
    return connectors;
}
async function deployedSchemas(serviceInfos) {
    const schemasPerService = await Promise.all(serviceInfos.map((si) => (0, client_1.listSchemas)(si.serviceName)));
    return schemasPerService.flat();
}
