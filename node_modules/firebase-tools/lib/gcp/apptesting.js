"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.client = exports.API_VERSION = void 0;
exports.testEnvironmentCatalog = testEnvironmentCatalog;
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
exports.API_VERSION = "v1";
exports.client = new apiv2_1.Client({
    urlPrefix: (0, api_1.cloudTestingOrigin)(),
    auth: true,
    apiVersion: exports.API_VERSION,
});
async function testEnvironmentCatalog(projectId, environmentType) {
    const name = `testEnvironmentCatalog/${environmentType}`;
    const queryParams = { projectId };
    const res = await exports.client.get(name, { queryParams });
    return res.body;
}
