"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getToolsByFeature = getToolsByFeature;
exports.getRemoteToolsByFeature = getRemoteToolsByFeature;
exports.availableTools = availableTools;
exports.markdownDocsOfTools = markdownDocsOfTools;
const index_1 = require("../onemcp/index");
const index_2 = require("./apphosting/index");
const index_3 = require("./apptesting/index");
const index_4 = require("./auth/index");
const index_5 = require("./core/index");
const index_6 = require("./crashlytics/index");
const index_7 = require("./dataconnect/index");
const index_8 = require("./functions/index");
const index_9 = require("./messaging/index");
const index_10 = require("./realtime_database/index");
const index_11 = require("./remoteconfig/index");
const index_12 = require("./storage/index");
const index_13 = require("./firestore/index");
function addFeaturePrefix(feature, tools) {
    return tools.map((tool) => ({
        ...tool,
        mcp: {
            ...tool.mcp,
            name: `${feature}_${tool.mcp.name}`,
            _meta: {
                ...tool.mcp._meta,
                feature,
            },
        },
    }));
}
const tools = {
    apphosting: addFeaturePrefix("apphosting", index_2.appHostingTools),
    apptesting: addFeaturePrefix("apptesting", index_3.apptestingTools),
    auth: addFeaturePrefix("auth", index_4.authTools),
    core: addFeaturePrefix("firebase", index_5.coreTools),
    crashlytics: addFeaturePrefix("crashlytics", index_6.crashlyticsTools),
    database: addFeaturePrefix("realtimedatabase", index_10.realtimeDatabaseTools),
    dataconnect: addFeaturePrefix("dataconnect", index_7.dataconnectTools),
    firestore: addFeaturePrefix("firestore", index_13.firestoreTools),
    functions: addFeaturePrefix("functions", index_8.functionsTools),
    messaging: addFeaturePrefix("messaging", index_9.messagingTools),
    remoteconfig: addFeaturePrefix("remoteconfig", index_11.remoteConfigTools),
    storage: addFeaturePrefix("storage", index_12.storageTools),
    developerknowledge: [],
};
const allToolsMap = new Map(Object.values(tools)
    .flat()
    .sort((a, b) => a.mcp.name.localeCompare(b.mcp.name))
    .map((t) => [t.mcp.name, t]));
async function getToolsByName(names) {
    const selectedTools = new Set();
    const remoteTools = new Map((await getRemoteToolsByFeature()).map((t) => [t.mcp.name, t]));
    for (const toolName of names) {
        const tool = allToolsMap.get(toolName) || remoteTools.get(toolName);
        if (tool) {
            selectedTools.add(tool);
        }
    }
    return Array.from(selectedTools);
}
async function getToolsByFeature(serverFeatures) {
    const features = new Set(serverFeatures?.length
        ? serverFeatures
        : Object.keys({ ...tools, ...index_1.ONEMCP_SERVERS }));
    features.add("core");
    const featureList = Array.from(features);
    const localTools = featureList.flatMap((feature) => tools[feature] || []);
    const remoteTools = await getRemoteToolsByFeature(featureList);
    return [...localTools, ...remoteTools];
}
async function getRemoteToolsByFeature(features) {
    const remoteToolsPromises = [];
    const featureSet = new Set(features?.length ? features : Object.keys(index_1.ONEMCP_SERVERS));
    for (const feature of featureSet) {
        const server = index_1.ONEMCP_SERVERS[feature];
        if (server) {
            remoteToolsPromises.push(server.listTools());
        }
    }
    return Promise.all(remoteToolsPromises).then((tools) => tools.flat());
}
async function availableTools(ctx, activeFeatures, detectedFeatures, enabledTools) {
    if (enabledTools?.length) {
        return getToolsByName(enabledTools);
    }
    if (activeFeatures?.length) {
        return getToolsByFeature(activeFeatures);
    }
    const allTools = await getToolsByFeature(detectedFeatures);
    const availabilities = await Promise.all(allTools.map((t) => {
        if (t.isAvailable) {
            return t.isAvailable(ctx);
        }
        return true;
    }));
    return allTools.filter((_, i) => availabilities[i]);
}
async function markdownDocsOfTools() {
    const allTools = await getToolsByFeature([]);
    let doc = `
| Tool Name | Feature Group | Description |
| --------- | ------------- | ----------- |`;
    for (const tool of allTools) {
        let feature = tool.mcp?._meta?.feature || "";
        if (feature === "firebase") {
            feature = "core";
        }
        const description = (tool.mcp?.description || "").replaceAll("\n", "<br>");
        doc += `
| ${tool.mcp.name} | ${feature} | ${description} |`;
    }
    return doc;
}
