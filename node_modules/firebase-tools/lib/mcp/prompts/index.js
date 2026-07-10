"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.availablePrompts = availablePrompts;
exports.markdownDocsOfPrompts = markdownDocsOfPrompts;
const core_1 = require("./core");
const dataconnect_1 = require("./dataconnect");
const crashlytics_1 = require("./crashlytics");
const apptesting_1 = require("./apptesting");
const firestore_1 = require("./firestore");
const storage_1 = require("./storage");
const prompts = {
    core: namespacePrompts(core_1.corePrompts, "core"),
    firestore: namespacePrompts(firestore_1.firestorePrompts, "firestore"),
    storage: namespacePrompts(storage_1.storagePrompts, "storage"),
    dataconnect: namespacePrompts(dataconnect_1.dataconnectPrompts, "dataconnect"),
    auth: [],
    messaging: [],
    functions: [],
    remoteconfig: [],
    crashlytics: namespacePrompts(crashlytics_1.crashlyticsPrompts, "crashlytics"),
    apptesting: namespacePrompts(apptesting_1.apptestingPrompts, "apptesting"),
    apphosting: [],
    database: [],
    developerknowledge: [],
};
function namespacePrompts(promptsToNamespace, feature) {
    return promptsToNamespace.map((p) => {
        const newPrompt = { ...p };
        newPrompt.mcp = { ...p.mcp };
        if (newPrompt.mcp.omitPrefix) {
        }
        else if (feature === "core") {
            newPrompt.mcp.name = `firebase:${p.mcp.name}`;
        }
        else {
            newPrompt.mcp.name = `${feature}:${p.mcp.name}`;
        }
        newPrompt.mcp._meta = { ...p.mcp._meta, feature };
        return newPrompt;
    });
}
async function availablePrompts(ctx, activeFeatures, detectedFeatures) {
    if (activeFeatures?.length) {
        return getAllPrompts(activeFeatures);
    }
    const allPrompts = getAllPrompts(detectedFeatures);
    const availabilities = await Promise.all(allPrompts.map((p) => {
        if (p.isAvailable) {
            return p.isAvailable(ctx);
        }
        return true;
    }));
    return allPrompts.filter((_, i) => availabilities[i]);
}
function getAllPrompts(activeFeatures) {
    const promptDefs = [];
    if (!activeFeatures?.length) {
        activeFeatures = Object.keys(prompts);
    }
    if (!activeFeatures.includes("core")) {
        activeFeatures.unshift("core");
    }
    for (const feature of activeFeatures) {
        promptDefs.push(...prompts[feature]);
    }
    return promptDefs;
}
function markdownDocsOfPrompts() {
    const allPrompts = getAllPrompts();
    let doc = `
| Prompt Name | Feature Group | Description |
| ----------- | ------------- | ----------- |`;
    for (const prompt of allPrompts) {
        const feature = prompt.mcp._meta?.feature || "";
        let description = prompt.mcp.description || "";
        if (prompt.mcp.arguments?.length) {
            const argsList = prompt.mcp.arguments.map((arg) => ` <br>&lt;${arg.name}&gt;${arg.required ? "" : " (optional)"}: ${arg.description || ""}`);
            description += ` <br><br>Arguments:${argsList.join("")}`;
        }
        description = description.replaceAll("\n", "<br>");
        doc += `
| ${prompt.mcp.name} | ${feature} | ${description} |`;
    }
    return doc;
}
