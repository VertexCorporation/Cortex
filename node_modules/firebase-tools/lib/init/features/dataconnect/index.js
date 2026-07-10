"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.newUniqueId = exports.FDC_DEFAULT_REGION = void 0;
exports.askQuestions = askQuestions;
exports.actuate = actuate;
exports.toDNSCompatibleId = toDNSCompatibleId;
const path_1 = require("path");
const clc = require("colorette");
const fs = require("fs-extra");
const prompt_1 = require("../../../prompt");
const provisionCloudSql_1 = require("../../../dataconnect/provisionCloudSql");
const freeTrial_1 = require("../../../dataconnect/freeTrial");
const cloudsql = require("../../../gcp/cloudsql/cloudsqladmin");
const ensureApis_1 = require("../../../dataconnect/ensureApis");
const experiments = require("../../../experiments");
const client_1 = require("../../../dataconnect/client");
const types_1 = require("../../../dataconnect/types");
const names_1 = require("../../../dataconnect/names");
const logger_1 = require("../../../logger");
const templates_1 = require("../../../templates");
const utils_1 = require("../../../utils");
Object.defineProperty(exports, "newUniqueId", { enumerable: true, get: function () { return utils_1.newUniqueId; } });
const cloudbilling_1 = require("../../../gcp/cloudbilling");
const sdk = require("./sdk");
const fdcExperience_1 = require("../../../gemini/fdcExperience");
const configstore_1 = require("../../../configstore");
const track_1 = require("../../../track");
const experiments_1 = require("../../../experiments");
exports.FDC_DEFAULT_REGION = "us-east4";
const DATACONNECT_YAML_TEMPLATE = (0, templates_1.readTemplateSync)("init/dataconnect/dataconnect.yaml");
const DATACONNECT_WEBHOOKS_YAML_TEMPLATE = (0, templates_1.readTemplateSync)("init/dataconnect/dataconnect-fdcwebhooks.yaml");
const SECONDARY_SCHEMA_YAML_TEMPLATE = (0, templates_1.readTemplateSync)("init/dataconnect/secondary_schema.yaml");
const CONNECTOR_YAML_TEMPLATE = (0, templates_1.readTemplateSync)("init/dataconnect/connector.yaml");
const SCHEMA_TEMPLATE = (0, templates_1.readTemplateSync)("init/dataconnect/schema.gql");
const QUERIES_TEMPLATE = (0, templates_1.readTemplateSync)("init/dataconnect/queries.gql");
const MUTATIONS_TEMPLATE = (0, templates_1.readTemplateSync)("init/dataconnect/mutations.gql");
const SEED_DATA_TEMPLATE = (0, templates_1.readTemplateSync)("init/dataconnect/seed_data.gql");
const templateServiceInfo = {
    schemaGql: [{ path: "schema.gql", content: SCHEMA_TEMPLATE }],
    connectors: [
        {
            id: "example",
            path: "./example",
            files: [
                {
                    path: "queries.gql",
                    content: QUERIES_TEMPLATE,
                },
                {
                    path: "mutations.gql",
                    content: MUTATIONS_TEMPLATE,
                },
            ],
        },
    ],
    seedDataGql: SEED_DATA_TEMPLATE,
};
async function askQuestions(setup, config, options) {
    const info = {
        flow: "",
        appDescription: "",
        serviceId: "",
        locationId: "",
        cloudSqlInstanceId: "",
        cloudSqlDatabase: "",
        shouldProvisionCSQL: false,
    };
    if (setup.projectId) {
        await (0, ensureApis_1.ensureApis)(setup.projectId);
        await promptForExistingServices(setup, info, options);
        if (!info.serviceGql && !options.nonInteractive) {
            if (!configstore_1.configstore.get("gemini")) {
                (0, utils_1.logBullet)("Learn more about Gemini in Firebase and how it uses your data: https://firebase.google.com/docs/gemini-in-firebase#how-gemini-in-firebase-uses-your-data");
            }
            const wantToGenerate = await (0, prompt_1.confirm)({
                message: "Do you want to generate schema and queries with Gemini?",
                default: false,
                nonInteractive: options.nonInteractive,
            });
            if (wantToGenerate) {
                configstore_1.configstore.set("gemini", true);
                info.appDescription = await (0, prompt_1.input)({
                    message: `Describe your app idea:`,
                    validate: async (s) => {
                        if (s.length > 0) {
                            return true;
                        }
                        return "Please enter a description for your app idea.";
                    },
                    nonInteractive: options.nonInteractive,
                });
            }
        }
        await promptForCloudSQL(setup, info, options);
    }
    setup.featureInfo = setup.featureInfo || {};
    setup.featureInfo.dataconnect = info;
    await sdk.askQuestions(setup, config, options);
}
async function actuate(setup, config, options) {
    const dir = config.get("dataconnect.source", "dataconnect");
    const dataDir = config.get("emulators.dataconnect.dataDir", `${dir}/.dataconnect/pgliteData`);
    config.set("emulators.dataconnect.dataDir", dataDir);
    const info = setup.featureInfo?.dataconnect;
    if (!info) {
        throw new Error("SQL Connect feature RequiredInfo is not provided");
    }
    info.serviceId = info.serviceId || defaultServiceId();
    info.cloudSqlInstanceId = info.cloudSqlInstanceId || `${info.serviceId.toLowerCase()}-fdc`;
    info.locationId = info.locationId || exports.FDC_DEFAULT_REGION;
    info.cloudSqlDatabase = info.cloudSqlDatabase || `fdcdb`;
    const startTime = Date.now();
    try {
        await actuateWithInfo(setup, config, info, options);
        await sdk.actuate(setup, config);
    }
    finally {
        const sdkInfo = setup.featureInfo?.dataconnectSdk;
        const source = setup.featureInfo?.dataconnectSource || "init";
        void (0, track_1.trackGA4)("dataconnect_init", {
            source,
            flow: info.flow.substring(1),
            project_status: setup.projectId
                ? (await (0, cloudbilling_1.isBillingEnabled)(setup))
                    ? info.shouldProvisionCSQL
                        ? "blaze_provisioned_csql"
                        : "blaze"
                    : "spark"
                : "missing",
            ...(sdkInfo ? sdk.initAppCounters(sdkInfo) : {}),
        }, Date.now() - startTime);
    }
    if (info.appDescription) {
        setup.instructions.push(`You can visualize the SQL Connect Schema in Firebase Console:

    https://console.firebase.google.com/project/${setup.projectId}/dataconnect/locations/${info.locationId}/services/${info.serviceId}/schema`);
    }
    setup.instructions.push(`Install the SQL Connect VS Code Extensions. You can explore SQL Connect Query on local pgLite and Cloud SQL Postgres Instance.`);
}
async function actuateWithInfo(setup, config, info, options) {
    const projectId = setup.projectId;
    if (!projectId) {
        info.flow += "_save_template";
        return await writeFiles(config, info, templateServiceInfo, options);
    }
    await (0, ensureApis_1.ensureApis)(projectId, true);
    if (info.shouldProvisionCSQL) {
        await (0, provisionCloudSql_1.setupCloudSql)({
            projectId: projectId,
            location: info.locationId,
            instanceId: info.cloudSqlInstanceId,
            databaseId: info.cloudSqlDatabase,
            requireGoogleMlIntegration: false,
            source: setup.featureInfo?.dataconnectSource || "init",
        });
    }
    const serviceName = `projects/${projectId}/locations/${info.locationId}/services/${info.serviceId}`;
    if (!info.appDescription) {
        if (!info.serviceGql) {
            await downloadService(info, serviceName);
        }
        if (info.serviceGql) {
            info.flow += "_save_downloaded";
            return await writeFiles(config, info, info.serviceGql, options);
        }
        info.flow += "_save_template";
        return await writeFiles(config, info, templateServiceInfo, options);
    }
    const serviceAlreadyExists = !(await (0, client_1.createService)(projectId, info.locationId, info.serviceId));
    const schemaGql = await (0, utils_1.promiseWithSpinner)(() => (0, fdcExperience_1.generateSchema)(info.appDescription, projectId, info.locationId), "Generating the SQL Connect Schema...");
    const schemaFiles = [{ path: "schema.gql", content: schemaGql }];
    if (serviceAlreadyExists) {
        (0, utils_1.logLabeledError)("dataconnect", `SQL Connect Service ${serviceName} already exists. Skip saving them...`);
        info.flow += "_save_gemini_service_already_exists";
        return await writeFiles(config, info, { schemaGql: schemaFiles, connectors: [] }, options);
    }
    const schemas = [
        {
            name: `${serviceName}/schemas/${types_1.MAIN_SCHEMA_ID}`,
            datasources: [],
            source: {
                files: schemaFiles,
            },
        },
    ];
    let operationGql = "";
    let seedDataGql = "";
    let genOperationsSuccess = false;
    let genOperationsError = null;
    await (0, utils_1.promiseWithSpinner)(async () => {
        const deployPromise = (async () => {
            const [saveSchemaGql, waitForCloudSQLProvision] = schemasDeploySequence(projectId, info, schemaFiles, info.shouldProvisionCSQL);
            await (0, client_1.upsertSchema)(saveSchemaGql);
            if (waitForCloudSQLProvision) {
                void (0, client_1.upsertSchema)(waitForCloudSQLProvision);
            }
        })();
        const opPromise = (async () => {
            try {
                const [op, seed] = await Promise.all([
                    (0, fdcExperience_1.generateOperation)(fdcExperience_1.PROMPT_GENERATE_CONNECTOR, serviceName, projectId, schemas),
                    (0, fdcExperience_1.generateOperation)(fdcExperience_1.PROMPT_GENERATE_SEED_DATA, serviceName, projectId, schemas),
                ]);
                return { op, seed, success: true };
            }
            catch (err) {
                (0, utils_1.logLabeledError)("dataconnect", `Deployment failed: ${err instanceof Error ? err.message : String(err)}`);
                return { success: false, error: err };
            }
        })();
        const [, opResult] = await Promise.all([deployPromise, opPromise]);
        if (opResult.success && opResult.op && opResult.seed) {
            operationGql = opResult.op;
            seedDataGql = opResult.seed;
            genOperationsSuccess = true;
        }
        else {
            (0, utils_1.logLabeledError)("dataconnect", `Operation Generation failed...`);
            genOperationsError = opResult.error;
        }
    }, "Saving the SQL Connect Schema and generating operations...");
    if (genOperationsSuccess) {
        const connectors = [
            {
                id: "example",
                path: "./example",
                files: [
                    {
                        path: "queries.gql",
                        content: operationGql,
                    },
                ],
            },
        ];
        info.flow += "_save_gemini";
        await writeFiles(config, info, { schemaGql: schemaFiles, connectors: connectors, seedDataGql: seedDataGql }, options);
    }
    else {
        info.flow += "_save_gemini_operation_error";
        await writeFiles(config, info, { schemaGql: schemaFiles, connectors: [] }, options);
    }
    if (genOperationsError) {
        throw genOperationsError;
    }
}
function schemasDeploySequence(projectId, info, schemaFiles, linkToCloudSql) {
    const serviceName = `projects/${projectId}/locations/${info.locationId}/services/${info.serviceId}`;
    if (!linkToCloudSql) {
        return [
            {
                name: `${serviceName}/schemas/${types_1.MAIN_SCHEMA_ID}`,
                datasources: [{ postgresql: {} }],
                source: {
                    files: schemaFiles,
                },
            },
        ];
    }
    return [
        {
            name: `${serviceName}/schemas/${types_1.MAIN_SCHEMA_ID}`,
            datasources: [
                {
                    postgresql: {
                        database: info.cloudSqlDatabase,
                        cloudSql: {
                            instance: `projects/${projectId}/locations/${info.locationId}/instances/${info.cloudSqlInstanceId}`,
                        },
                        schemaValidation: "NONE",
                    },
                },
            ],
            source: {
                files: schemaFiles,
            },
        },
        {
            name: `${serviceName}/schemas/${types_1.MAIN_SCHEMA_ID}`,
            datasources: [
                {
                    postgresql: {
                        database: info.cloudSqlDatabase,
                        cloudSql: {
                            instance: `projects/${projectId}/locations/${info.locationId}/instances/${info.cloudSqlInstanceId}`,
                        },
                        schemaMigration: "MIGRATE_COMPATIBLE",
                    },
                },
            ],
            source: {
                files: schemaFiles,
            },
        },
    ];
}
async function writeFiles(config, info, serviceGql, options) {
    const dir = config.get("dataconnect.source") || "dataconnect";
    const subbedDataconnectYaml = subDataconnectYamlValues({
        ...info,
        connectorDirs: serviceGql.connectors.map((c) => c.path),
    }, serviceGql.secondarySchemaGqls?.map((sch) => ({ id: sch.id, uri: sch.uri })));
    config.set("dataconnect", { source: dir });
    await config.askWriteProjectFile((0, path_1.join)(dir, "dataconnect.yaml"), subbedDataconnectYaml, !!options.force, true);
    if (serviceGql.seedDataGql) {
        await config.askWriteProjectFile((0, path_1.join)(dir, "seed_data.gql"), serviceGql.seedDataGql, !!options.force);
    }
    if (serviceGql.schemaGql.length) {
        for (const f of serviceGql.schemaGql) {
            await config.askWriteProjectFile((0, path_1.join)(dir, "schema", f.path), f.content, !!options.force);
        }
    }
    else {
        fs.ensureFileSync((0, path_1.join)(dir, "schema", "schema.gql"));
    }
    if (serviceGql.secondarySchemaGqls?.length) {
        for (const sch of serviceGql.secondarySchemaGqls) {
            for (const f of sch.files) {
                await config.askWriteProjectFile((0, path_1.join)(dir, `schema_${sch.id}`, f.path), f.content, !!options.force);
            }
        }
    }
    for (const c of serviceGql.connectors) {
        await writeConnectorFiles(config, c, options);
    }
}
async function writeConnectorFiles(config, connectorInfo, options) {
    const subbedConnectorYaml = subConnectorYamlValues({ connectorId: connectorInfo.id });
    const dir = config.get("dataconnect.source") || "dataconnect";
    await config.askWriteProjectFile((0, path_1.join)(dir, connectorInfo.path, "connector.yaml"), subbedConnectorYaml, !!options.force, true);
    for (const f of connectorInfo.files) {
        await config.askWriteProjectFile((0, path_1.join)(dir, connectorInfo.path, f.path), f.content, !!options.force);
    }
}
function subDataconnectYamlValues(replacementValues, secondarySchemas) {
    const replacements = {
        serviceId: "__serviceId__",
        locationId: "__location__",
        cloudSqlDatabase: "__cloudSqlDatabase__",
        cloudSqlInstanceId: "__cloudSqlInstanceId__",
        connectorDirs: "__connectorDirs__",
        secondarySchemaId: "__secondarySchemaId__",
        secondarySchemaSource: "__secondarySchemaSource__",
        secondarySchemaUri: "__secondarySchemaUri__",
    };
    let replaced = experiments.isEnabled("fdcwebhooks")
        ? DATACONNECT_WEBHOOKS_YAML_TEMPLATE
        : DATACONNECT_YAML_TEMPLATE;
    if (secondarySchemas && secondarySchemas.length > 0) {
        let secondaryReplaced = "";
        for (const schema of secondarySchemas) {
            secondaryReplaced += SECONDARY_SCHEMA_YAML_TEMPLATE;
            secondaryReplaced = secondaryReplaced.replace(replacements.secondarySchemaId, JSON.stringify(schema.id));
            secondaryReplaced = secondaryReplaced.replace(replacements.secondarySchemaSource, `"./schema_${schema.id}"`);
            secondaryReplaced = secondaryReplaced.replace(replacements.secondarySchemaUri, JSON.stringify(schema.uri));
        }
        replaced = replaced.replace("#__secondarySchemaPlaceholder__\n", secondaryReplaced);
    }
    else {
        replaced = replaced.replace("#__secondarySchemaPlaceholder__\n", "");
    }
    for (const [k, v] of Object.entries(replacementValues)) {
        replaced = replaced.replace(replacements[k], JSON.stringify(v));
    }
    return replaced;
}
function subConnectorYamlValues(replacementValues) {
    const replacements = {
        connectorId: "__connectorId__",
    };
    let replaced = CONNECTOR_YAML_TEMPLATE;
    for (const [k, v] of Object.entries(replacementValues)) {
        replaced = replaced.replace(replacements[k], JSON.stringify(v));
    }
    return replaced;
}
async function promptForExistingServices(setup, info, options) {
    if (!setup.projectId) {
        return;
    }
    const existingServices = await (0, client_1.listAllServices)(setup.projectId);
    if (!existingServices.length) {
        return;
    }
    const choice = await chooseExistingService(existingServices, options);
    if (!choice) {
        const existingServiceIds = existingServices.map((s) => s.name.split("/").pop());
        info.serviceId = (0, utils_1.newUniqueId)(defaultServiceId(), existingServiceIds);
        info.flow += "_pick_new_service";
        return;
    }
    info.flow += "_pick_existing_service";
    const serviceName = (0, names_1.parseServiceName)(choice.name);
    info.serviceId = serviceName.serviceId;
    info.locationId = serviceName.location;
    await downloadService(info, choice.name);
}
async function downloadService(info, serviceName) {
    let schemas = [];
    try {
        schemas = await (0, client_1.listSchemas)(serviceName, [
            "schemas.name",
            "schemas.datasources",
            "schemas.source",
        ]);
    }
    catch (err) {
        if (err.status !== 404) {
            throw err;
        }
    }
    if (!schemas.length) {
        return;
    }
    info.serviceGql = {
        schemaGql: [],
        connectors: [
            {
                id: "example",
                path: "./example",
                files: [],
            },
        ],
    };
    for (const sch of schemas) {
        if ((0, types_1.isMainSchema)(sch)) {
            const primaryDatasource = sch.datasources.find((d) => d.postgresql);
            if (primaryDatasource?.postgresql?.cloudSql?.instance) {
                const instanceName = (0, names_1.parseCloudSQLInstanceName)(primaryDatasource.postgresql.cloudSql.instance);
                info.cloudSqlInstanceId = instanceName.instanceId;
            }
            info.cloudSqlDatabase = primaryDatasource?.postgresql?.database ?? "";
            if (sch.source.files?.length) {
                info.serviceGql.schemaGql = sch.source.files;
            }
        }
        else {
            if (!info.serviceGql.secondarySchemaGqls) {
                info.serviceGql.secondarySchemaGqls = [];
            }
            info.serviceGql.secondarySchemaGqls.push({
                id: sch.name.split("/").pop(),
                files: sch.source.files || [],
                uri: sch.datasources[0].httpGraphql?.uri ?? "",
            });
        }
    }
    const connectors = await (0, client_1.listConnectors)(serviceName, [
        "connectors.name",
        "connectors.source.files",
    ]);
    if (connectors.length) {
        info.serviceGql.connectors = connectors.map((c) => {
            const id = c.name.split("/").pop();
            return {
                id,
                path: connectors.length === 1 ? "./example" : `./${id}`,
                files: c.source.files || [],
            };
        });
    }
}
async function chooseExistingService(existing, options) {
    const fdcConnector = (0, utils_1.envOverride)("FDC_CONNECTOR", "");
    const fdcService = (0, utils_1.envOverride)("FDC_SERVICE", "");
    const serviceEnvVar = fdcConnector || fdcService;
    if (serviceEnvVar) {
        const [serviceLocationFromEnvVar, serviceIdFromEnvVar] = serviceEnvVar.split("/");
        const serviceFromEnvVar = existing.find((s) => {
            const serviceName = (0, names_1.parseServiceName)(s.name);
            return (serviceName.serviceId === serviceIdFromEnvVar &&
                serviceName.location === serviceLocationFromEnvVar);
        });
        if (serviceFromEnvVar) {
            (0, utils_1.logBullet)(`Picking up the existing service ${clc.bold(serviceLocationFromEnvVar + "/" + serviceIdFromEnvVar)}.`);
            return serviceFromEnvVar;
        }
        const envVarName = fdcConnector ? "FDC_CONNECTOR" : "FDC_SERVICE";
        (0, utils_1.logWarning)(`Unable to pick up an existing service based on ${envVarName}=${serviceEnvVar}.`);
    }
    const choices = existing.map((s) => {
        const serviceName = (0, names_1.parseServiceName)(s.name);
        return {
            name: `${serviceName.location}/${serviceName.serviceId}`,
            value: s,
        };
    });
    choices.push({ name: "Create a new service", value: undefined });
    return await (0, prompt_1.select)({
        message: "Your project already has existing services. Which would you like to set up local files for?",
        choices,
        default: choices[0].value,
        nonInteractive: options.nonInteractive,
    });
}
async function promptForCloudSQL(setup, info, options) {
    if (!setup.projectId) {
        return;
    }
    const instrumentlessTrialEnabled = (0, experiments_1.isEnabled)("fdcift");
    const billingEnabled = await (0, cloudbilling_1.isBillingEnabled)(setup);
    const freeTrialUsed = await (0, freeTrial_1.checkFreeTrialInstanceUsed)(setup.projectId);
    const freeTrialAvailable = !freeTrialUsed && (billingEnabled || instrumentlessTrialEnabled);
    if (!billingEnabled && !instrumentlessTrialEnabled) {
        setup.instructions.push((0, freeTrial_1.upgradeInstructions)(setup.projectId || "your-firebase-project", false));
        return;
    }
    if (freeTrialUsed) {
        (0, utils_1.logLabeledWarning)("dataconnect", "CloudSQL no cost trial has already been used on this project.");
    }
    else if (instrumentlessTrialEnabled || billingEnabled) {
        (0, utils_1.logLabeledSuccess)("dataconnect", "CloudSQL no cost trial available!");
    }
    if (info.cloudSqlInstanceId === "") {
        const instances = await cloudsql.listInstances(setup.projectId);
        let choices = instances.map((i) => {
            let display = `${i.name} (${i.region})`;
            if (i.settings.userLabels?.["firebase-data-connect"] === "ft") {
                display += " (no cost trial)";
            }
            return { name: display, value: i.name, location: i.region };
        });
        choices = choices.filter((c) => info.locationId === "" || info.locationId === c.location);
        if (choices.length) {
            if (freeTrialAvailable) {
                choices.push({ name: "Create a new free trial instance", value: "", location: "" });
            }
            else {
                choices.push({
                    name: `Create a new CloudSQL instance${billingEnabled ? "" : " (requires billing account)"}`,
                    value: "",
                    location: "",
                });
            }
            info.cloudSqlInstanceId = await (0, prompt_1.select)({
                message: `Which CloudSQL instance would you like to use?`,
                choices,
                default: choices[0].value,
                nonInteractive: options.nonInteractive,
            });
            if (info.cloudSqlInstanceId !== "") {
                info.flow += "_pick_existing_csql";
                info.locationId = choices.find((c) => c.value === info.cloudSqlInstanceId).location;
            }
            else {
                info.flow += "_pick_new_csql";
                if (!billingEnabled && freeTrialUsed) {
                    setup.instructions.push((0, freeTrial_1.upgradeInstructions)(setup.projectId || "your-firebase-project", true));
                    return;
                }
                info.cloudSqlInstanceId = await (0, prompt_1.input)({
                    message: `What ID would you like to use for your new CloudSQL instance?`,
                    default: (0, utils_1.newUniqueId)(`${defaultServiceId().toLowerCase()}-fdc`, instances.map((i) => i.name)),
                    nonInteractive: options.nonInteractive,
                });
            }
        }
    }
    if (info.locationId === "") {
        await promptForLocation(setup, info, options);
        info.shouldProvisionCSQL =
            !options.nonInteractive &&
                (await (0, prompt_1.confirm)({
                    message: `Would you like to provision your ${freeTrialAvailable ? "free trial " : ""}Cloud SQL instance and database now?`,
                    default: !options.nonInteractive,
                    nonInteractive: options.nonInteractive,
                }));
    }
    if (info.cloudSqlInstanceId !== "" && info.cloudSqlDatabase === "") {
        try {
            const dbs = await cloudsql.listDatabases(setup.projectId, info.cloudSqlInstanceId);
            const existing = dbs.map((d) => d.name);
            info.cloudSqlDatabase = (0, utils_1.newUniqueId)("fdcdb", existing);
        }
        catch (err) {
            logger_1.logger.debug(`[dataconnect] Cannot list databases during init: ${err}`);
        }
    }
    return;
}
async function promptForLocation(setup, info, options) {
    if (info.locationId === "") {
        const choices = await locationChoices(setup);
        info.locationId = await (0, prompt_1.select)({
            message: "What location would you like to use?",
            choices,
            default: exports.FDC_DEFAULT_REGION,
            nonInteractive: options.nonInteractive,
        });
    }
}
async function locationChoices(setup) {
    if (setup.projectId) {
        const locations = await (0, client_1.listLocations)(setup.projectId);
        return locations.map((l) => {
            return { name: l, value: l };
        });
    }
    else {
        return [
            { name: "asia-east1", value: "asia-east1" },
            { name: "asia-east2", value: "asia-east2" },
            { name: "asia-northeast1", value: "asia-northeast1" },
            { name: "asia-northeast2", value: "asia-northeast2" },
            { name: "asia-northeast3", value: "asia-northeast3" },
            { name: "asia-south1", value: "asia-south1" },
            { name: "asia-southeast1", value: "asia-southeast1" },
            { name: "asia-southeast2", value: "asia-southeast2" },
            { name: "australia-southeast1", value: "australia-southeast1" },
            { name: "australia-southeast2", value: "australia-southeast2" },
            { name: "europe-central2", value: "europe-central2" },
            { name: "europe-north1", value: "europe-north1" },
            { name: "europe-southwest1", value: "europe-southwest1" },
            { name: "europe-west1", value: "europe-west1" },
            { name: "europe-west2", value: "europe-west2" },
            { name: "europe-west3", value: "europe-west3" },
            { name: "europe-west4", value: "europe-west4" },
            { name: "europe-west6", value: "europe-west6" },
            { name: "europe-west8", value: "europe-west8" },
            { name: "europe-west9", value: "europe-west9" },
            { name: "me-west1", value: "me-west1" },
            { name: "northamerica-northeast1", value: "northamerica-northeast1" },
            { name: "northamerica-northeast2", value: "northamerica-northeast2" },
            { name: "southamerica-east1", value: "southamerica-east1" },
            { name: "southamerica-west1", value: "southamerica-west1" },
            { name: "us-central1", value: "us-central1" },
            { name: "us-east1", value: "us-east1" },
            { name: "us-east4", value: "us-east4" },
            { name: "us-south1", value: "us-south1" },
            { name: "us-west1", value: "us-west1" },
            { name: "us-west2", value: "us-west2" },
            { name: "us-west3", value: "us-west3" },
            { name: "us-west4", value: "us-west4" },
        ];
    }
}
function defaultServiceId() {
    return toDNSCompatibleId((0, path_1.basename)(process.cwd()));
}
function toDNSCompatibleId(id) {
    id = (0, path_1.basename)(id)
        .toLowerCase()
        .replaceAll(/[^a-z0-9-]/g, "")
        .slice(0, 63);
    while (id.endsWith("-") && id.length) {
        id = id.slice(0, id.length - 1);
    }
    while (id.startsWith("-") && id.length) {
        id = id.slice(1, id.length);
    }
    return id || "app";
}
