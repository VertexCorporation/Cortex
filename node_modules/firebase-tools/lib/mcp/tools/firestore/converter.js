"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.convertInputToValue = convertInputToValue;
exports.firestoreDocumentToJson = firestoreDocumentToJson;
const logger_1 = require("../../../logger");
function convertInputToValue(inputValue) {
    if (inputValue === null) {
        return { nullValue: null };
    }
    else if (typeof inputValue === "boolean") {
        return { booleanValue: inputValue };
    }
    else if (typeof inputValue === "number") {
        if (Number.isInteger(inputValue)) {
            return { integerValue: inputValue.toString() };
        }
        else {
            return { doubleValue: inputValue };
        }
    }
    else if (typeof inputValue === "string") {
        return { stringValue: inputValue };
    }
    else if (Array.isArray(inputValue)) {
        const arrayValue = {
            values: inputValue.map((item) => convertInputToValue(item)),
        };
        return { arrayValue: arrayValue };
    }
    else if (typeof inputValue === "object") {
        if (inputValue.hasOwnProperty("latitude") &&
            typeof inputValue.latitude === "number" &&
            inputValue.hasOwnProperty("longitude") &&
            typeof inputValue.longitude === "number") {
            return { geoPointValue: inputValue };
        }
        const mapValue = {
            fields: {},
        };
        for (const key in inputValue) {
            if (Object.prototype.hasOwnProperty.call(inputValue, key)) {
                if (mapValue.fields) {
                    mapValue.fields[key] = convertInputToValue(inputValue[key]);
                }
            }
        }
        return { mapValue: mapValue };
    }
    return { nullValue: null };
}
function firestoreValueToJson(firestoreValue) {
    if ("nullValue" in firestoreValue)
        return null;
    if ("booleanValue" in firestoreValue)
        return firestoreValue.booleanValue;
    if ("integerValue" in firestoreValue) {
        const num = Number(firestoreValue.integerValue);
        if (num > Number.MAX_SAFE_INTEGER || num < Number.MIN_SAFE_INTEGER) {
            return firestoreValue.integerValue;
        }
        return num;
    }
    if ("doubleValue" in firestoreValue)
        return firestoreValue.doubleValue;
    if ("timestampValue" in firestoreValue)
        return { __type__: "Timestamp", value: firestoreValue.timestampValue };
    if ("stringValue" in firestoreValue)
        return firestoreValue.stringValue;
    if ("bytesValue" in firestoreValue)
        return firestoreValue.bytesValue;
    if ("referenceValue" in firestoreValue)
        return { __type__: "Reference", value: firestoreValue.referenceValue };
    if ("geoPointValue" in firestoreValue)
        return {
            __type__: "GeoPoint",
            value: [firestoreValue.geoPointValue.latitude, firestoreValue.geoPointValue.longitude],
        };
    if ("arrayValue" in firestoreValue)
        return firestoreValue.arrayValue.values?.map((v) => firestoreValueToJson(v)) ?? [];
    if ("mapValue" in firestoreValue) {
        const map = firestoreValue.mapValue.fields || {};
        const obj = {};
        for (const key of Object.keys(map)) {
            obj[key] = firestoreValueToJson(map[key]);
        }
        return obj;
    }
    logger_1.logger.warn("Unhandled Firestore Value type encountered:", firestoreValue);
    return undefined;
}
function firestoreDocumentToJson(firestoreDoc) {
    const nameParts = firestoreDoc.name.split("/documents/");
    const path = nameParts.length > 1 ? nameParts[nameParts.length - 1] : "";
    const result = { __path__: path };
    if (firestoreDoc.fields) {
        for (const key of Object.keys(firestoreDoc.fields)) {
            result[key] = firestoreValueToJson(firestoreDoc.fields[key]);
        }
    }
    return result;
}
