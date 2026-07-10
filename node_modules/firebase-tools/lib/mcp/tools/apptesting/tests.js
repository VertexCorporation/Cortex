"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.check_status = exports.run_tests = void 0;
const zod_1 = require("zod");
const filters_1 = require("../../../crashlytics/filters");
const distribution_1 = require("../../../appdistribution/distribution");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const options_parser_util_1 = require("../../../appdistribution/options-parser-util");
const client_1 = require("../../../appdistribution/client");
const apptesting_1 = require("../../../gcp/apptesting");
const TestDeviceSchema = zod_1.z
    .object({
    model: zod_1.z.string(),
    version: zod_1.z.string(),
    locale: zod_1.z.string(),
    orientation: zod_1.z.string(),
})
    .describe(`Device to run automated test on. Can run 'gcloud firebase test android|ios models list' to see available devices.`);
const AiStepSchema = zod_1.z
    .object({
    goal: zod_1.z.string().describe("A goal to be accomplished during the test."),
    hint: zod_1.z
        .string()
        .optional()
        .describe("Hint text containing suggestions to help the agent accomplish the goal."),
    finalScreenAssertion: zod_1.z
        .string()
        .optional()
        .describe("A description of what the screen should look like at the end of the step, to determine if the goal has been successfully completed."),
})
    .describe("Step within a test case; run during the execution of the test.");
const defaultDevices = [
    {
        model: "MediumPhone.arm",
        version: "30",
        locale: "en_US",
        orientation: "portrait",
    },
];
exports.run_tests = (0, tool_1.tool)("apptesting", {
    name: "run_test",
    description: `Run a remote test.`,
    inputSchema: zod_1.z.object({
        appId: filters_1.ApplicationIdSchema,
        releaseBinaryFile: zod_1.z.string().describe("Path to the binary release (APK)."),
        testDevices: zod_1.z.array(TestDeviceSchema).default(defaultDevices),
        testCase: zod_1.z.object({
            steps: zod_1.z
                .array(AiStepSchema)
                .describe("Test case containing the steps that are run during its execution."),
        }),
    }),
    annotations: {
        title: "Run a Remote Test",
        readOnlyHint: false,
    },
}, async ({ appId, releaseBinaryFile, testDevices, testCase }) => {
    const devices = testDevices || defaultDevices;
    const client = new client_1.AppDistributionClient();
    const release = await (0, distribution_1.upload)(client, (0, options_parser_util_1.toAppName)(appId), new distribution_1.Distribution(releaseBinaryFile));
    return (0, util_1.toContent)(await client.createReleaseTest(release.name, devices, {
        aiInstructions: testCase,
    }));
});
exports.check_status = (0, tool_1.tool)("apptesting", {
    name: "check_status",
    description: "Check the status of an apptesting release test and/or get available devices that can be used for automated tests ",
    inputSchema: zod_1.z.object({
        release_test_name: zod_1.z
            .string()
            .optional()
            .describe("The name of the release test returned by the run_test tool. If set, the tool will fetch the release test"),
        getAvailableDevices: zod_1.z
            .boolean()
            .optional()
            .describe("If set to true, the tool will get the available devices that can be used for automated tests using the app testing agent"),
    }),
    annotations: {
        title: "Check Remote Test",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async ({ release_test_name, getAvailableDevices }, { projectId }) => {
    let devices = undefined;
    let releaseTest = undefined;
    if (release_test_name) {
        const client = new client_1.AppDistributionClient();
        releaseTest = await client.getReleaseTest(release_test_name);
    }
    if (getAvailableDevices) {
        devices = await (0, apptesting_1.testEnvironmentCatalog)(projectId || "", "ANDROID");
    }
    const result = {};
    if (devices)
        result.devices = devices;
    if (releaseTest)
        result.releaseTest = releaseTest;
    return (0, util_1.toContent)(result);
});
