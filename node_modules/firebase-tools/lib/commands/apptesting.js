"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const requireAuth_1 = require("../requireAuth");
const command_1 = require("../command");
const parseTestFiles_1 = require("../apptesting/parseTestFiles");
const ora = require("ora");
const error_1 = require("../error");
const client_1 = require("../appdistribution/client");
const distribution_1 = require("../appdistribution/distribution");
const options_parser_util_1 = require("../appdistribution/options-parser-util");
const utils = require("../utils");
const fsutils_1 = require("../fsutils");
const path = require("path");
const defaultDevices = [
    {
        model: "MediumPhone.arm",
        version: "36",
        locale: "en_US",
        orientation: "portrait",
    },
];
exports.command = new command_1.Command("apptesting:execute [release-binary-file]")
    .description("Run mobile automated tests written in natural language driven by AI")
    .option("--app <app_id>", "The app id of your Firebase web app. Optional if the project contains exactly one web app.")
    .option("--test-file-pattern <pattern>", "Test file pattern. Only tests contained in files that match this pattern will be executed.")
    .option("--test-name-pattern <pattern>", "Test name pattern. Only tests with names that match this pattern will be executed.")
    .option("--test-dir <test_dir>", "Directory where tests can be found. Defaults to './tests'.")
    .option("--test-devices <string>", "Semicolon-separated list of devices to run automated tests on, in the format 'model=<model-id>,version=<os-version-id>,locale=<locale>,orientation=<orientation>'. Run 'gcloud firebase test android|ios models list' to see available devices. Note: This feature is in beta.")
    .option("--test-devices-file <string>", "Path to file containing a list of semicolon- or newline-separated devices to run automated tests on, in the format 'model=<model-id>,version=<os-version-id>,locale=<locale>,orientation=<orientation>'. Run 'gcloud firebase test android|ios models list' to see available devices. Note: This feature is in beta.")
    .option("--test-non-blocking", "Run automated tests without waiting for them to complete. Visit the Firebase console for the test results.")
    .option("--results-bucket <bucket>", "The name of a Google Cloud Storage bucket where raw test results will be stored. If this flag is not set, Firebase creates a default bucket for you. Note that the bucket must be owned by a billing-enabled project, and that using a non-default bucket will result in billing charges for the storage used.")
    .option("--test-username <string>", "username for automatic login")
    .option("--test-password <string>", "password for automatic login. If using a real password, use --test-password-file instead to avoid putting sensitive info in history and logs.")
    .option("--test-password-file <string>", "path to file containing password for automatic login")
    .before(requireAuth_1.requireAuth)
    .action(async (target, options) => {
    const appName = (0, options_parser_util_1.getAppName)(options);
    const resultsBucket = (0, options_parser_util_1.getResultsBucket)(options.resultsBucket, appName);
    const testDir = path.resolve(options.testDir || "tests");
    if (!(0, fsutils_1.dirExistsSync)(testDir)) {
        throw new error_1.FirebaseError(`Tests directory not found: ${testDir}. Use the --test-dir flag to choose a different directory.`);
    }
    const tests = await (0, parseTestFiles_1.parseTestFiles)(testDir, undefined, options.testFilePattern, options.testNamePattern);
    const testDevices = (0, options_parser_util_1.parseTestDevices)(options.testDevices, options.testDevicesFile);
    const loginCredential = (0, options_parser_util_1.getLoginCredential)({
        username: options.testUsername,
        password: options.testPassword,
        passwordFile: options.testPasswordFile,
    });
    if (!tests.length) {
        throw new error_1.FirebaseError(`No tests found under test directory ${testDir}`);
    }
    utils.logBullet(`Found ${(0, parseTestFiles_1.pluralizeTests)(tests.length)} to run under test directory ${testDir}`);
    const invokeSpinner = ora("Requesting test execution");
    const client = new client_1.AppDistributionClient();
    let releaseTests;
    let release;
    try {
        if (target) {
            release = await (0, distribution_1.upload)(client, appName, new distribution_1.Distribution(target));
        }
        else {
            utils.logBullet("release-binary-file not provided, using the latest App Distribution release.");
            const latestRelease = await client.getLatestRelease(appName);
            if (!latestRelease) {
                throw new error_1.FirebaseError(`No app binary found for ${appName}. Call apptesting:execute with a local app binary file, or upload a release to App Distribution.`);
            }
            release = latestRelease;
            utils.logBullet(`Using release ${release.displayVersion} created at ${release.createTime}`);
        }
        invokeSpinner.start();
        releaseTests = await invokeTests(client, release.name, tests, !testDevices.length ? defaultDevices : testDevices, resultsBucket, loginCredential);
        invokeSpinner.text = `${(0, parseTestFiles_1.pluralizeTests)(releaseTests.length)} started successfully!`;
        invokeSpinner.succeed();
    }
    catch (ex) {
        invokeSpinner.fail("Failed to request test execution");
        throw ex;
    }
    if (options.testNonBlocking) {
        utils.logBullet(`View progress and results in the Firebase Console:\n${release.firebaseConsoleUri}`);
    }
    else {
        await (0, distribution_1.awaitTestResults)(releaseTests, client);
        utils.logBullet(`View detailed results in the Firebase Console:\n${release.firebaseConsoleUri}`);
    }
});
async function invokeTests(client, releaseName, testDefs, devices, resultsBucket, loginCredential) {
    try {
        const releaseTests = [];
        for (const testDef of testDefs) {
            const aiInstructions = {
                steps: testDef.testCase.steps,
            };
            releaseTests.push(await client.createReleaseTest(releaseName, devices, {
                aiInstructions,
                displayName: testDef.testCase.displayName,
                resultsBucket,
                loginCredential,
            }));
        }
        return releaseTests;
    }
    catch (err) {
        throw new error_1.FirebaseError("Test invocation failed", { original: (0, error_1.getError)(err) });
    }
}
