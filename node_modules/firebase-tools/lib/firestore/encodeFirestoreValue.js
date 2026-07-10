"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.encodeFirestoreValue = encodeFirestoreValue;
const _ = require("lodash");
const error_1 = require("../error");
function isPlainObject(input) {
    return (typeof input === "object" &&
        input !== null &&
        _.isEqual(Object.getPrototypeOf(input), Object.prototype));
}
function encodeHelper(val) {
    if (typeof val === "string") {
        return { stringValue: val };
    }
    if (val === !!val) {
        return { booleanValue: val };
    }
    if (Number.isInteger(val)) {
        return { integerValue: val };
    }
    if (typeof val === "number") {
        return { doubleValue: val };
    }
    if (val instanceof Date && !Number.isNaN(val)) {
        return { timestampValue: val.toISOString() };
    }
    if (Array.isArray(val)) {
        const encodedElements = [];
        for (const v of val) {
            const enc = encodeHelper(v);
            if (enc) {
                encodedElements.push(enc);
            }
        }
        return {
            arrayValue: { values: encodedElements },
        };
    }
    if (val === null) {
        return { nullValue: "NULL_VALUE" };
    }
    if (val instanceof Buffer || val instanceof Uint8Array) {
        return { bytesValue: val };
    }
    if (isPlainObject(val)) {
        return {
            mapValue: { fields: encodeFirestoreValue(val) },
        };
    }
    throw new error_1.FirebaseError(`Cannot encode ${val} to a Firestore Value. ` +
        "The emulator does not yet support Firestore document reference values or geo points.");
}
function encodeFirestoreValue(data) {
    return Object.entries(data).reduce((acc, [key, val]) => {
        acc[key] = encodeHelper(val);
        return acc;
    }, {});
}
