"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getEnvironmentName = getEnvironmentName;
exports.promptForAppHostingYaml = promptForAppHostingYaml;
exports.getAutoinitEnvVars = getAutoinitEnvVars;
const error_1 = require("../error");
const config_1 = require("./config");
const prompt = require("../prompt");
function getEnvironmentName(apphostingYamlFileName) {
    const found = apphostingYamlFileName.match(config_1.APPHOSTING_YAML_FILE_REGEX);
    if (!found || found.length < 2 || !found[1]) {
        throw new error_1.FirebaseError("Invalid apphosting environment file");
    }
    return found[1].replaceAll(".", "");
}
async function promptForAppHostingYaml(apphostingFileNameToPathMap, promptMessage = "Please select an App Hosting config:") {
    const fileNames = Array.from(apphostingFileNameToPathMap.keys());
    const baseFilePath = apphostingFileNameToPathMap.get(config_1.APPHOSTING_BASE_YAML_FILE);
    const listOptions = fileNames.map((fileName) => {
        if (fileName === config_1.APPHOSTING_BASE_YAML_FILE) {
            return {
                name: `base (${config_1.APPHOSTING_BASE_YAML_FILE})`,
                value: baseFilePath,
            };
        }
        const environment = getEnvironmentName(fileName);
        return {
            name: baseFilePath
                ? `${environment} (${config_1.APPHOSTING_BASE_YAML_FILE} + ${fileName})`
                : `${environment} (${fileName})`,
            value: apphostingFileNameToPathMap.get(fileName),
        };
    });
    const fileToExportPath = await prompt.select({
        message: promptMessage,
        choices: listOptions,
    });
    return fileToExportPath;
}
function getAutoinitEnvVars(webappConfig) {
    if (!webappConfig) {
        return {};
    }
    return {
        FIREBASE_WEBAPP_CONFIG: JSON.stringify(webappConfig),
        FIREBASE_CONFIG: JSON.stringify({
            databaseURL: webappConfig.databaseURL,
            storageBucket: webappConfig.storageBucket,
            projectId: webappConfig.projectId,
        }),
    };
}
