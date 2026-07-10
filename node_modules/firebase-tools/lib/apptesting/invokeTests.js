"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.invokeTests = invokeTests;
exports.pollInvocationStatus = pollInvocationStatus;
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
const operationPoller = require("../operation-poller");
const error_1 = require("../error");
const apiClient = new apiv2_1.Client({ urlPrefix: (0, api_1.appTestingOrigin)(), apiVersion: "v1alpha" });
async function invokeTests(appId, startUri, testDefs) {
    const appResource = `projects/${appId.split(":")[1]}/apps/${appId}`;
    try {
        const invocationResponse = await apiClient.post(`${appResource}/testInvocations:invokeTestCases`, buildInvokeTestCasesRequest(testDefs));
        return invocationResponse.body;
    }
    catch (err) {
        throw new error_1.FirebaseError("Test invocation failed", { original: (0, error_1.getError)(err) });
    }
}
function buildInvokeTestCasesRequest(testCaseInvocations) {
    return {
        resource: {
            testInvocation: {},
            testCaseInvocations,
        },
    };
}
async function pollInvocationStatus(operationName, onPoll, backoff = 30 * 1000) {
    return operationPoller.pollOperation({
        pollerName: "App Testing Invocation Poller",
        apiOrigin: (0, api_1.appTestingOrigin)(),
        apiVersion: "v1alpha",
        operationResourceName: operationName,
        masterTimeout: 30 * 60 * 1000,
        backoff,
        maxBackoff: 15 * 1000,
        onPoll,
    });
}
