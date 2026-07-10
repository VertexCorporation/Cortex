"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.promptDeleteConnector = promptDeleteConnector;
exports.promptDeleteSchema = promptDeleteSchema;
const prompt_1 = require("../prompt");
const utils = require("../utils");
const client_1 = require("./client");
async function promptDeleteConnector(options, connectorName) {
    utils.logLabeledWarning("dataconnect", `Connector ${connectorName} exists but is not listed in dataconnect.yaml.`);
    const confirmDeletion = await (0, prompt_1.confirm)({
        default: false,
        message: `Do you want to delete ${connectorName}?`,
        force: options.force,
        nonInteractive: options.nonInteractive,
    });
    if (confirmDeletion) {
        await (0, client_1.deleteConnector)(connectorName);
        utils.logLabeledSuccess("dataconnect", `Connector ${connectorName} deleted`);
    }
}
async function promptDeleteSchema(options, schemaName) {
    utils.logLabeledWarning("dataconnect", `Schema ${schemaName} exists but is not listed in dataconnect.yaml.`);
    const confirmDeletion = await (0, prompt_1.confirm)({
        default: false,
        message: `Do you want to delete the schema ${schemaName}?`,
        force: options.force,
        nonInteractive: options.nonInteractive,
    });
    if (confirmDeletion) {
        await (0, client_1.deleteSchema)(schemaName);
        utils.logLabeledSuccess("dataconnect", `Schema ${schemaName} deleted`);
    }
}
