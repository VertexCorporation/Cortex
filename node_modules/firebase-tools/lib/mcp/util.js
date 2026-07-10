"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.toContent = toContent;
exports.applyAppMeta = applyAppMeta;
exports.mcpError = mcpError;
exports.checkFeatureActive = checkFeatureActive;
exports.cleanSchema = cleanSchema;
const js_yaml_1 = require("js-yaml");
const experiments = require("../experiments");
const api_1 = require("../api");
const ensureApiEnabled_1 = require("../ensureApiEnabled");
const timeout_1 = require("../timeout");
function toContent(data, options) {
    if (typeof data === "string")
        return { content: [{ type: "text", text: data }] };
    let text = "";
    const format = options?.format || "yaml";
    switch (format) {
        case "json":
            text = JSON.stringify(data);
            break;
        case "yaml":
            text = (0, js_yaml_1.dump)(data);
            break;
    }
    const prefix = options?.contentPrefix || "";
    const suffix = options?.contentSuffix || "";
    const result = {
        content: [{ type: "text", text: `${prefix}${text}${suffix}` }],
    };
    if (typeof data === "object" && data !== null && !Array.isArray(data)) {
        result.structuredContent = data;
    }
    return result;
}
function applyAppMeta(result, resourceUri) {
    if (experiments.isEnabled("mcpapps")) {
        return {
            ...result,
            _meta: {
                ...result._meta,
                ui: {
                    resourceUri,
                },
            },
        };
    }
    return result;
}
function mcpError(message, code) {
    let errorMessage = "unknown error";
    if (message instanceof Error) {
        errorMessage = message.message;
    }
    if (typeof message === "string") {
        errorMessage = message;
    }
    return {
        isError: true,
        content: [{ type: "text", text: `Error: ${code ? `${code}: ` : ""}${errorMessage}` }],
    };
}
const SERVER_FEATURE_APIS = {
    core: "",
    firestore: (0, api_1.firestoreOrigin)(),
    storage: (0, api_1.storageOrigin)(),
    dataconnect: (0, api_1.dataconnectOrigin)(),
    auth: (0, api_1.authManagementOrigin)(),
    messaging: (0, api_1.messagingApiOrigin)(),
    functions: (0, api_1.functionsOrigin)(),
    remoteconfig: (0, api_1.remoteConfigApiOrigin)(),
    crashlytics: (0, api_1.crashlyticsApiOrigin)(),
    apptesting: (0, api_1.appDistributionOrigin)(),
    apphosting: (0, api_1.apphostingOrigin)(),
    database: (0, api_1.realtimeOrigin)(),
    developerknowledge: (0, api_1.developerKnowledgeOrigin)(),
};
const DETECTED_API_FEATURES = {
    core: undefined,
    firestore: undefined,
    storage: undefined,
    dataconnect: undefined,
    auth: undefined,
    messaging: undefined,
    functions: undefined,
    remoteconfig: undefined,
    crashlytics: undefined,
    apptesting: undefined,
    apphosting: undefined,
    database: undefined,
    developerknowledge: undefined,
};
async function checkFeatureActive(feature, projectId, options) {
    if (feature in (options?.config?.data || {}))
        return true;
    if (DETECTED_API_FEATURES[feature] !== undefined)
        return DETECTED_API_FEATURES[feature];
    if (projectId) {
        try {
            const isActive = await (0, timeout_1.timeoutFallback)((0, ensureApiEnabled_1.check)(projectId, SERVER_FEATURE_APIS[feature], "", true), true, 3000);
            DETECTED_API_FEATURES[feature] = isActive;
            return isActive;
        }
        catch (e) {
            DETECTED_API_FEATURES[feature] = true;
            return true;
        }
    }
    DETECTED_API_FEATURES[feature] = false;
    return false;
}
function deepClean(obj, isRootLevel = false) {
    if (typeof obj !== "object" || obj === null) {
        return obj;
    }
    const cleanedObj = { ...obj };
    if (cleanedObj.hasOwnProperty("$schema")) {
        delete cleanedObj.$schema;
    }
    if (cleanedObj.hasOwnProperty("additionalProperties")) {
        delete cleanedObj.additionalProperties;
    }
    if (cleanedObj.hasOwnProperty("type")) {
        const currentType = cleanedObj.type;
        if (Array.isArray(currentType)) {
            let filteredTypes = currentType.filter((t) => t !== "null");
            if (isRootLevel) {
                filteredTypes = filteredTypes.filter((t) => t !== "array");
            }
            if (filteredTypes.length === 0) {
                return null;
            }
            else if (filteredTypes.length === 1) {
                cleanedObj.type = filteredTypes[0];
            }
            else {
                delete cleanedObj.type;
                cleanedObj.anyOf = filteredTypes
                    .map((t) => {
                    return deepClean({ type: t }, false);
                })
                    .filter((subSchema) => subSchema !== null);
                if (cleanedObj.anyOf.length === 0) {
                    return null;
                }
                if (cleanedObj.anyOf.length === 1) {
                    const singleSchema = cleanedObj.anyOf[0];
                    delete cleanedObj.anyOf;
                    Object.assign(cleanedObj, singleSchema);
                }
            }
        }
        else if (typeof currentType === "string") {
            if (currentType === "null") {
                return null;
            }
            if (isRootLevel && currentType === "array") {
                return null;
            }
        }
    }
    if (cleanedObj.hasOwnProperty("properties") &&
        typeof cleanedObj.properties === "object" &&
        cleanedObj.properties !== null) {
        const newProperties = {};
        for (const key in cleanedObj.properties) {
            if (cleanedObj.properties.hasOwnProperty(key)) {
                const cleanedPropertySchema = deepClean(cleanedObj.properties[key], false);
                if (cleanedPropertySchema !== null) {
                    newProperties[key] = cleanedPropertySchema;
                }
            }
        }
        if (Object.keys(newProperties).length === 0) {
            delete cleanedObj.properties;
        }
        else {
            cleanedObj.properties = newProperties;
        }
    }
    if (cleanedObj.hasOwnProperty("items") &&
        typeof cleanedObj.items === "object" &&
        cleanedObj.items !== null) {
        const cleanedItemsSchema = deepClean(cleanedObj.items, false);
        if (cleanedItemsSchema === null) {
            delete cleanedObj.items;
        }
        else {
            cleanedObj.items = cleanedItemsSchema;
        }
    }
    const defKeywords = ["$defs", "definitions"];
    for (const keyword of defKeywords) {
        if (cleanedObj.hasOwnProperty(keyword) &&
            typeof cleanedObj[keyword] === "object" &&
            cleanedObj[keyword] !== null) {
            const newDefs = {};
            for (const defKey in cleanedObj[keyword]) {
                if (cleanedObj[keyword].hasOwnProperty(defKey)) {
                    const cleanedDef = deepClean(cleanedObj[keyword][defKey], false);
                    if (cleanedDef !== null) {
                        newDefs[defKey] = cleanedDef;
                    }
                }
            }
            if (Object.keys(newDefs).length === 0) {
                delete cleanedObj[keyword];
            }
            else {
                cleanedObj[keyword] = newDefs;
            }
        }
    }
    const schemaArrayKeywords = ["anyOf", "allOf", "oneOf"];
    for (const keyword of schemaArrayKeywords) {
        if (cleanedObj.hasOwnProperty(keyword) && Array.isArray(cleanedObj[keyword])) {
            const newSchemaArray = cleanedObj[keyword]
                .map((subSchema) => deepClean(subSchema, false))
                .filter((subSchema) => subSchema !== null);
            if (newSchemaArray.length === 0) {
                delete cleanedObj[keyword];
            }
            else {
                cleanedObj[keyword] = newSchemaArray;
            }
        }
    }
    return cleanedObj;
}
function cleanSchema(schema) {
    if (schema && schema.hasOwnProperty("type")) {
        const topLevelType = schema.type;
        if (topLevelType === "array") {
            return {};
        }
        if (Array.isArray(topLevelType)) {
            const filteredRootTypes = topLevelType.filter((t) => t !== "null" && t !== "array");
            if (filteredRootTypes.length === 0 && topLevelType.includes("array")) {
                return {};
            }
        }
    }
    const result = deepClean(schema, true);
    return result === null ? {} : result;
}
