"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const fs = require("fs-extra");
const command_1 = require("../command");
const yaml_helper_1 = require("../appdistribution/yaml_helper");
const requireAuth_1 = require("../requireAuth");
const client_1 = require("../appdistribution/client");
const options_parser_util_1 = require("../appdistribution/options-parser-util");
const utils = require("../utils");
const error_1 = require("../error");
exports.command = new command_1.Command("appdistribution:testcases:import <test-cases-yaml-file>")
    .description("import test cases from YAML file")
    .option("--app <app_id>", "the app id of your Firebase app")
    .before(requireAuth_1.requireAuth)
    .action(async (yamlFile, options) => {
    const appName = (0, options_parser_util_1.getAppName)(options);
    const appDistroClient = new client_1.AppDistributionClient();
    (0, options_parser_util_1.ensureFileExists)(yamlFile);
    const testCases = (0, yaml_helper_1.fromYaml)(appName, fs.readFileSync(yamlFile, "utf8"));
    const testCasesWithoutName = testCases.filter((tc) => !tc.name);
    const creationResults = await Promise.allSettled(testCasesWithoutName.map((tc) => appDistroClient.createTestCase(appName, tc)));
    const failed = creationResults.filter((r) => r.status === "rejected");
    if (failed.length > 0) {
        for (const f of failed) {
            utils.logWarning(f.reason);
        }
        const succeeded = creationResults.length - failed.length;
        throw new error_1.FirebaseError(`Created ${succeeded} test case(s), but failed to create ${failed.length}.`);
    }
    const testCasesWithName = testCases.filter((tc) => !!tc.name);
    await appDistroClient.batchUpsertTestCases(appName, testCasesWithName);
    utils.logSuccess(`Imported ${testCases.length} test cases from ${yamlFile}`);
});
