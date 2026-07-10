"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getValidator = getValidator;
exports.getErrorMessage = getErrorMessage;
const fs = require("fs");
const path = require("path");
const ajv_1 = require("ajv");
const ajv_formats_1 = require("ajv-formats");
const ajv = new ajv_1.Ajv({ allowUnionTypes: true });
(0, ajv_formats_1.default)(ajv);
let _VALIDATOR = undefined;
function getValidator() {
    if (!_VALIDATOR) {
        const schemaStr = fs.readFileSync(path.resolve(__dirname, "../schema/firebase-config.json"), "utf-8");
        const schema = JSON.parse(schemaStr);
        _VALIDATOR = ajv.compile(schema);
    }
    return _VALIDATOR;
}
function getErrorMessage(e) {
    if (e.keyword === "additionalProperties") {
        return `Object "${e.instancePath}" in "firebase.json" has unknown property: ${JSON.stringify(e.params)}`;
    }
    else if (e.keyword === "required") {
        return `Object "${e.instancePath}" in "firebase.json" is missing required property: ${JSON.stringify(e.params)}`;
    }
    else {
        return `Field "${e.instancePath}" in "firebase.json" is possibly invalid: ${e.message}`;
    }
}
