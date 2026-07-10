"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ensureApis = ensureApis;
const api = require("../api");
const ensureApiEnabled_1 = require("../ensureApiEnabled");
const prefix = "dataconnect";
async function ensureApis(projectId, silent = false) {
    await Promise.all([
        (0, ensureApiEnabled_1.ensure)(projectId, api.dataconnectOrigin(), prefix, silent),
        (0, ensureApiEnabled_1.ensure)(projectId, api.cloudSQLAdminOrigin(), prefix, silent),
    ]);
}
