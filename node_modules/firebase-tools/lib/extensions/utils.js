"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.convertExtensionOptionToLabeledList = convertExtensionOptionToLabeledList;
exports.getRandomString = getRandomString;
exports.formatTimestamp = formatTimestamp;
exports.getResourceRuntime = getResourceRuntime;
const types_1 = require("./types");
function convertExtensionOptionToLabeledList(options) {
    return options.map((option) => {
        return {
            checked: false,
            name: option.label,
            value: option.value,
        };
    });
}
function getRandomString(length) {
    const SUFFIX_CHAR_SET = "abcdefghijklmnopqrstuvwxyz0123456789";
    let result = "";
    for (let i = 0; i < length; i++) {
        result += SUFFIX_CHAR_SET.charAt(Math.floor(Math.random() * SUFFIX_CHAR_SET.length));
    }
    return result;
}
function formatTimestamp(timestamp) {
    if (!timestamp) {
        return "";
    }
    const withoutMs = timestamp.split(".")[0];
    return withoutMs.replace("T", " ");
}
function getResourceRuntime(resource) {
    switch (resource.type) {
        case types_1.FUNCTIONS_RESOURCE_TYPE:
            return resource.properties?.runtime;
        case types_1.FUNCTIONS_V2_RESOURCE_TYPE:
            return resource.properties?.buildConfig?.runtime;
        default:
            return undefined;
    }
}
