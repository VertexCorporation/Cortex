"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.assertHas = assertHas;
exports.assertHasOneOf = assertHasOneOf;
exports.assertEnum = assertEnum;
exports.assertType = assertType;
const clc = require("colorette");
const error_1 = require("../error");
function assertHas(obj, prop) {
    const objString = clc.cyan(JSON.stringify(obj));
    if (!obj[prop]) {
        throw new error_1.FirebaseError(`Must contain "${prop}": ${objString}`);
    }
}
function assertHasOneOf(obj, props) {
    const objString = clc.cyan(JSON.stringify(obj));
    let count = 0;
    props.forEach((prop) => {
        if (obj[prop]) {
            count++;
        }
    });
    if (count !== 1) {
        throw new error_1.FirebaseError(`Must contain exactly one of "${props.join(",")}": ${objString}`);
    }
}
function assertEnum(obj, prop, valid) {
    const objString = clc.cyan(JSON.stringify(obj));
    if (valid.indexOf(obj[prop]) < 0) {
        throw new error_1.FirebaseError(`Field "${prop}" must be one of ${valid.join(", ")}: ${objString}`);
    }
}
function assertType(prop, propValue, type) {
    if (typeof propValue !== type) {
        throw new error_1.FirebaseError(`Property "${prop}" must be of type ${type}`);
    }
}
