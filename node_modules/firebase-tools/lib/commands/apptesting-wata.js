"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const requireAuth_1 = require("../requireAuth");
const command_1 = require("../command");
const requireConfig_1 = require("../requireConfig");
const logger_1 = require("../logger");
const clc = require("colorette");
const parseTestFiles_1 = require("../apptesting/parseTestFiles");
const ora = require("ora");
const invokeTests_1 = require("../apptesting/invokeTests");
const error_1 = require("../error");
const marked_1 = require("marked");
const projectUtils_1 = require("../projectUtils");
const utils_1 = require("../utils");
const apps_1 = require("../management/apps");
exports.command = new command_1.Command("apptesting:wata <target>")
    .description("Run automated tests written in natural language driven by AI")
    .option("--app <app_id>", "The app id of your Firebase web app. Optional if the project contains exactly one web app.")
    .option("--test-file-pattern <pattern>", "Test file pattern. Only tests contained in files that match this pattern will be executed.")
    .option("--test-name-pattern <pattern>", "Test name pattern. Only tests with names that match this pattern will be executed.")
    .option("--tests-non-blocking", "Request test execution without waiting for them to complete.")
    .before(requireAuth_1.requireAuth)
    .before(requireConfig_1.requireConfig)
    .action(async (target, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const apps = await (0, apps_1.listFirebaseApps)(projectId, apps_1.AppPlatform.WEB);
    (0, apps_1.checkForApps)(apps, apps_1.AppPlatform.WEB);
    let app = apps.find((a) => a.appId === options.app);
    if (!app) {
        if (options.app) {
            throw new error_1.FirebaseError(`App with ID '${options.app}' was not found in project ${projectId}. You can list available apps with 'firebase apps:list'.`);
        }
        if (apps.length === 1) {
            app = apps[0];
        }
        else {
            throw new error_1.FirebaseError(`Project ${projectId} has multiple apps, must specify a web app id with '--app', you can list available apps with 'firebase apps:list'.`);
        }
    }
    const testDir = options.config.src.apptesting?.testDir || "tests";
    const tests = await (0, parseTestFiles_1.parseTestFiles)(testDir, target, options.testFilePattern, options.testNamePattern);
    if (!tests.length) {
        throw new error_1.FirebaseError("No tests found");
    }
    const invokeSpinner = ora("Requesting test execution");
    invokeSpinner.start();
    let invocationOperation;
    try {
        invocationOperation = await (0, invokeTests_1.invokeTests)(app.appId, target, tests);
        invokeSpinner.text = "Test execution requested";
        invokeSpinner.succeed();
    }
    catch (ex) {
        invokeSpinner.fail("Failed to request test execution");
        throw ex;
    }
    logger_1.logger.info(clc.bold(`\n${clc.white("===")} Running ${pluralizeTests(tests.length)}`));
    const invocationId = invocationOperation.name?.split("/").pop();
    const appWebId = app.webId;
    const url = (0, utils_1.consoleUrl)(projectId, `/apptesting/app/web:${appWebId}/invocations/${invocationId}`);
    logger_1.logger.info(await (0, marked_1.marked)(`**Invocation ID:** ${invocationId}`));
    logger_1.logger.info(await (0, marked_1.marked)(`View progress and results in the [Firebase Console](${url})`));
    if (options.testsNonBlocking) {
        logger_1.logger.info("Not waiting for results");
        return;
    }
    if (!invocationOperation.metadata) {
        throw new error_1.FirebaseError("Invocation details unavailable");
    }
    const executionSpinner = ora(getOutput(invocationOperation.metadata));
    executionSpinner.start();
    const invocationOp = await (0, invokeTests_1.pollInvocationStatus)(invocationOperation.name, (operation) => {
        if (!operation.done) {
            executionSpinner.text = getOutput(operation.metadata);
        }
    });
    const response = invocationOp.resource.testInvocation;
    executionSpinner.text = `Testing complete\n${getOutput(response)}`;
    if (response.failedExecutions || response.cancelledExecutions) {
        executionSpinner.fail();
        throw new error_1.FirebaseError("Testing complete with errors");
    }
    else {
        executionSpinner.succeed();
    }
});
function pluralizeTests(numTests) {
    return `${numTests} test${numTests === 1 ? "" : "s"}`;
}
function getOutput(invocation) {
    const output = [];
    if (invocation.runningExecutions) {
        output.push(`${pluralizeTests(invocation.runningExecutions)} running (this may take a while)...`);
    }
    if (invocation.succeededExecutions) {
        output.push(`✔ ${pluralizeTests(invocation.succeededExecutions)} passed`);
    }
    if (invocation.failedExecutions) {
        output.push(`✖ ${pluralizeTests(invocation.failedExecutions)} failed`);
    }
    if (invocation.cancelledExecutions) {
        output.push(`⊝ ${pluralizeTests(invocation.cancelledExecutions)} cancelled`);
    }
    return output.length ? output.join("\n") : "Tests are starting";
}
