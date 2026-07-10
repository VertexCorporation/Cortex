"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dataconnectPrompts = void 0;
const experiments_1 = require("../../../experiments");
const schema_1 = require("./schema");
exports.dataconnectPrompts = [];
if ((0, experiments_1.isEnabled)("mcpalpha")) {
    exports.dataconnectPrompts.push(schema_1.schema);
}
