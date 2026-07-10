"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.askQuestions = askQuestions;
exports.actuate = actuate;
exports.addSchemaToDataConnectYaml = addSchemaToDataConnectYaml;
const clc = require("colorette");
const path_1 = require("path");
const yaml = require("yaml");
const prompt_1 = require("../../../prompt");
const utils_1 = require("../../../utils");
const load_1 = require("../../../dataconnect/load");
const names_1 = require("../../../dataconnect/names");
const experiments = require("../../../experiments");
const cloudbilling_1 = require("../../../gcp/cloudbilling");
const track_1 = require("../../../track");
const functions = require("../functions");
const templates_1 = require("../../../templates");
const SCHEMA_TEMPLATE = (0, templates_1.readTemplateSync)("init/dataconnect/secondary_schema.gql");
async function askQuestions(setup, config, options) {
    const resolverInfo = {
        id: "",
        uri: "",
        serviceInfo: {},
        shouldInitFunctions: false,
    };
    const serviceInfos = await (0, load_1.loadAll)(setup.projectId || "", config);
    if (!serviceInfos.length) {
        throw new Error(`No Firebase SQL Connect workspace found. Run ${clc.bold("firebase init dataconnect")} to set up a service and main schema.`);
    }
    else if (serviceInfos.length === 1) {
        resolverInfo.serviceInfo = serviceInfos[0];
    }
    else {
        const choices = serviceInfos.map((si) => {
            const serviceName = (0, names_1.parseServiceName)(si.serviceName);
            return {
                name: `${serviceName.location}/${serviceName.serviceId}`,
                value: si,
            };
        });
        resolverInfo.serviceInfo = await (0, prompt_1.select)({
            message: "Which service would you like to set up a custom resolver for?",
            choices,
        });
    }
    resolverInfo.id = await (0, prompt_1.input)({
        message: `What ID would you like to use for your custom resolver?`,
        default: (0, utils_1.newUniqueId)(`resolver`, resolverInfo.serviceInfo.dataConnectYaml.schemas?.map((sch) => sch.id || "") || []),
    });
    resolverInfo.uri = `https://${resolverInfo.id}-${setup.projectNumber || "PROJECT_NUMBER"}.${resolverInfo.serviceInfo.dataConnectYaml.location}.run.app/graphql`;
    (0, utils_1.logBullet)("Setting " +
        clc.bold(resolverInfo.uri) +
        " as the custom resolver URL. To change this, update your " +
        clc.bold(`dataconnect.yaml`) +
        " later.");
    resolverInfo.shouldInitFunctions = await (0, prompt_1.confirm)({
        message: "Would you like to proceed with initializing a functions codebase with sample custom resolvers code?",
        default: true,
    });
    setup.featureInfo = setup.featureInfo || {};
    setup.featureInfo.dataconnectResolver = resolverInfo;
    if (resolverInfo.shouldInitFunctions) {
        await functions.askQuestions(setup, config, options);
    }
}
async function actuate(setup, config) {
    if (!experiments.isEnabled("fdcwebhooks")) {
        return;
    }
    const resolverInfo = setup.featureInfo?.dataconnectResolver;
    if (!resolverInfo) {
        throw new Error("SQL Connect resolver feature ResolverRequiredInfo not provided");
    }
    const startTime = Date.now();
    try {
        actuateWithInfo(config, resolverInfo);
    }
    finally {
        const source = "init_resolver";
        void (0, track_1.trackGA4)("dataconnect_init", {
            source,
            project_status: setup.projectId
                ? (await (0, cloudbilling_1.isBillingEnabled)(setup))
                    ? "blaze"
                    : "spark"
                : "missing",
        }, Date.now() - startTime);
    }
    if (resolverInfo.shouldInitFunctions) {
        await functions.actuate(setup, config);
    }
}
function actuateWithInfo(config, info) {
    const dataConnectYaml = JSON.parse(JSON.stringify(info.serviceInfo?.dataConnectYaml));
    addSchemaToDataConnectYaml(dataConnectYaml, info);
    info.serviceInfo.dataConnectYaml = dataConnectYaml;
    const dataConnectYamlContents = yaml.stringify(dataConnectYaml);
    const dataConnectYamlPath = (0, path_1.join)(info.serviceInfo.sourceDirectory, "dataconnect.yaml");
    const dataConnectSchemaPath = (0, path_1.join)(info.serviceInfo.sourceDirectory, `schema_${info.id}`, "schema.gql");
    config.writeProjectFile((0, path_1.relative)(config.projectDir, dataConnectYamlPath), dataConnectYamlContents);
    config.writeProjectFile((0, path_1.relative)(config.projectDir, dataConnectSchemaPath), SCHEMA_TEMPLATE);
}
function addSchemaToDataConnectYaml(dataConnectYaml, info) {
    const secondarySchema = {
        source: `./schema_${info.id}`,
        id: info.id,
        datasource: {
            httpGraphql: {
                uri: info.uri,
            },
        },
    };
    if (!dataConnectYaml.schemas) {
        dataConnectYaml.schemas = [];
        if (dataConnectYaml.schema) {
            dataConnectYaml.schemas.push(dataConnectYaml.schema);
            dataConnectYaml.schema = undefined;
        }
    }
    dataConnectYaml.schemas.push(secondarySchema);
}
