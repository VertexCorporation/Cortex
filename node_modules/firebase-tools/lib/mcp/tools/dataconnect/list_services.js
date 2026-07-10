"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.list_services = void 0;
const zod_1 = require("zod");
const path = require("path");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const client = require("../../../dataconnect/client");
const load_1 = require("../../../dataconnect/load");
const types_1 = require("../../../dataconnect/types");
const js_yaml_1 = require("js-yaml");
const logger_1 = require("../../../logger");
exports.list_services = (0, tool_1.tool)("dataconnect", {
    name: "list_services",
    description: "Use this to list existing local and backend Firebase SQL Connect services",
    inputSchema: zod_1.z.object({}),
    annotations: {
        title: "List existing Firebase SQL Connect services",
        readOnlyHint: true,
    },
    _meta: {
        requiresProject: false,
        requiresAuth: false,
    },
}, async (_, { projectId, config }) => {
    const localServiceInfos = await (0, load_1.loadAll)(projectId, config);
    const serviceInfos = new Map();
    for (const l of localServiceInfos) {
        serviceInfos.set(`locations/${l.dataConnectYaml.location}/services/${l.dataConnectYaml.serviceId}`, { local: l });
    }
    if (projectId) {
        try {
            const [services, schemas, connectors] = await Promise.all([
                client.listAllServices(projectId),
                client.listSchemas(`projects/${projectId}/locations/-/services/-`),
                client.listConnectors(`projects/${projectId}/locations/-/services/-`),
            ]);
            console.log(services, schemas, connectors);
            for (const s of services) {
                const k = s.name.split("/").slice(2, 6).join("/");
                const st = serviceInfos.get(k) || {};
                st.deployed = st.deployed || {};
                st.deployed.service = s;
                serviceInfos.set(k, st);
            }
            for (const s of schemas) {
                const k = s.name.split("/").slice(2, 6).join("/");
                const st = serviceInfos.get(k) || {};
                st.deployed = st.deployed || {};
                st.deployed.schemas = st.deployed.schemas || [];
                st.deployed.schemas.push(s);
                serviceInfos.set(k, st);
            }
            for (const s of connectors) {
                const k = s.name.split("/").slice(2, 6).join("/");
                const st = serviceInfos.get(k) || {};
                st.deployed = st.deployed || {};
                st.deployed.connectors = st.deployed.connectors || [];
                st.deployed.connectors.push(s);
                serviceInfos.set(k, st);
            }
        }
        catch (e) {
            logger_1.logger.debug("cannot fetch dataconnect resources in the backend", e);
        }
    }
    const localServices = Array.from(serviceInfos.values()).filter((s) => s.local);
    const remoteOnlyServices = Array.from(serviceInfos.values()).filter((s) => !s.local);
    const output = [];
    function includeDeployedServiceInfo(deployed) {
        if (deployed.schemas?.length) {
            output.push(`### Schemas`);
            for (const s of deployed.schemas) {
                clearCCFEFields(s);
                output.push((0, js_yaml_1.dump)(s));
            }
        }
        if (deployed.connectors?.length) {
            output.push(`### Connectors`);
            for (const c of deployed.connectors) {
                clearCCFEFields(c);
                output.push((0, js_yaml_1.dump)(c));
            }
        }
    }
    if (localServices.length) {
        output.push(`# Local SQL Connect Sources`);
        for (const s of localServices) {
            const local = s.local;
            output.push((0, js_yaml_1.dump)(local.dataConnectYaml));
            const schemaDir = path.join(local.sourceDirectory, (0, types_1.mainSchemaYaml)(local.dataConnectYaml).source);
            output.push(`You can find all of schema sources under ${schemaDir}/`);
            if (s.deployed) {
                output.push(`It's already deployed in the backend:\n`);
                includeDeployedServiceInfo(s.deployed);
            }
        }
    }
    if (remoteOnlyServices.length) {
        output.push(`# SQL Connect Services in project ${projectId}`);
        for (const s of remoteOnlyServices) {
            if (s.deployed) {
                includeDeployedServiceInfo(s.deployed);
            }
        }
    }
    output.push(`\n# What's next?`);
    if (!localServices.length) {
        output.push(`- There is no local SQL Connect service in the local workspace. Consider use the \`firebase_init\` MCP tool to setup one.`);
    }
    output.push(`- You can use the \`dataconnect_compile\` tool to compile all local SQL Connect schemas and query sources.`);
    output.push(`- You run \`firebase deploy\` in command line to deploy the SQL Connect schemas, connector and perform SQL migrations.`);
    return (0, util_1.toContent)(output.join("\n"));
});
function clearCCFEFields(r) {
    const fieldsToClear = ["updateTime", "uid", "etag"];
    for (const k of fieldsToClear) {
        delete r[k];
    }
}
