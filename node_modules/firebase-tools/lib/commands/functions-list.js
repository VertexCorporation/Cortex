"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const requirePermissions_1 = require("../requirePermissions");
const backend = require("../deploy/functions/backend");
const logger_1 = require("../logger");
const Table = require("cli-table3");
const PLATFORM_TO_DISPLAY_NAME = {
    gcfv1: "v1",
    gcfv2: "v2",
    run: "run",
};
exports.command = new command_1.Command("functions:list")
    .description("list all deployed functions in your Firebase project")
    .before(requirePermissions_1.requirePermissions, ["cloudfunctions.functions.list", "run.services.list"])
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const context = {
        projectId,
    };
    const existing = await backend.existingBackend(context);
    const endpoints = backend.allEndpoints(existing).sort(backend.compareFunctions);
    if (endpoints.length === 0) {
        logger_1.logger.info(`No functions found in project ${projectId}.`);
        return [];
    }
    const table = new Table({
        head: ["Function", "Version", "Trigger", "Location", "Memory", "Runtime"],
        style: { head: ["yellow"] },
    });
    for (const endpoint of endpoints) {
        const trigger = backend.endpointTriggerType(endpoint);
        const availableMemoryMb = endpoint.availableMemoryMb || "---";
        const entry = [
            endpoint.id,
            PLATFORM_TO_DISPLAY_NAME[endpoint.platform] || "v1",
            trigger,
            endpoint.region,
            availableMemoryMb,
            endpoint.runtime,
        ];
        table.push(entry);
    }
    logger_1.logger.info(table.toString());
    return endpoints;
});
