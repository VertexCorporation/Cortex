"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const names = require("../dataconnect/names");
const client = require("../dataconnect/client");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const ensureApis_1 = require("../dataconnect/ensureApis");
const Table = require("cli-table3");
exports.command = new command_1.Command("dataconnect:services:list")
    .description("list all deployed SQL Connect services")
    .before(requirePermissions_1.requirePermissions, [
    "dataconnect.services.list",
    "dataconnect.schemas.list",
    "dataconnect.connectors.list",
])
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    await (0, ensureApis_1.ensureApis)(projectId);
    const services = await client.listAllServices(projectId);
    const table = new Table({
        head: [
            "Service ID",
            "Location",
            "Data Source",
            "Schema Last Updated",
            "Connector ID",
            "Connector Last Updated",
        ],
        style: { head: ["yellow"] },
    });
    const jsonOutput = { services: [] };
    for (const service of services) {
        const schema = (await client.getSchema(service.name)) ?? {
            name: "",
            datasources: [{}],
            source: { files: [] },
        };
        const connectors = await client.listConnectors(service.name);
        const serviceName = names.parseServiceName(service.name);
        const postgresDatasource = schema?.datasources.find((d) => d.postgresql);
        const instanceName = postgresDatasource?.postgresql?.cloudSql?.instance ?? "";
        const instanceId = instanceName.split("/").pop();
        const dbId = postgresDatasource?.postgresql?.database ?? "";
        const dbName = `CloudSQL Instance: ${instanceId}\nDatabase: ${dbId}`;
        table.push([
            serviceName.serviceId,
            serviceName.location,
            dbName,
            schema?.updateTime ?? "",
            "",
            "",
        ]);
        const serviceJson = {
            serviceId: serviceName.serviceId,
            location: serviceName.location,
            datasource: dbName,
            schemaUpdateTime: schema?.updateTime,
            connectors: [],
        };
        for (const conn of connectors) {
            const connectorName = names.parseConnectorName(conn.name);
            table.push(["", "", "", "", connectorName.connectorId, conn.updateTime]);
            serviceJson.connectors.push({
                connectorId: connectorName.connectorId,
                connectorLastUpdated: conn.updateTime ?? "",
            });
        }
        jsonOutput.services.push(serviceJson);
    }
    logger_1.logger.info(table.toString());
    return jsonOutput;
});
