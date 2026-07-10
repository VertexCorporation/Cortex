"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const fs = require("fs-extra");
const command_1 = require("../command");
const yaml_helper_1 = require("../appdistribution/yaml_helper");
const requireAuth_1 = require("../requireAuth");
const client_1 = require("../appdistribution/client");
const options_parser_util_1 = require("../appdistribution/options-parser-util");
const error_1 = require("../error");
const utils = require("../utils");
exports.command = new command_1.Command("appdistribution:testcases:export <test-cases-yaml-file>")
    .description("export test cases as a YAML file")
    .option("--app <app_id>", "the app id of your Firebase app")
    .before(requireAuth_1.requireAuth)
    .action(async (yamlFile, options) => {
    const appName = (0, options_parser_util_1.getAppName)(options);
    const appDistroClient = new client_1.AppDistributionClient();
    let testCases;
    try {
        testCases = await appDistroClient.listTestCases(appName);
    }
    catch (err) {
        throw new error_1.FirebaseError("Failed to list test cases.", {
            exit: 1,
            original: err,
        });
    }
    fs.writeFileSync(yamlFile, (0, yaml_helper_1.toYaml)(testCases), "utf8");
    utils.logSuccess(`Exported ${testCases.length} test cases to ${yamlFile}`);
    return { testCases };
});
