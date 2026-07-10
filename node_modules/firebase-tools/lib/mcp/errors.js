"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.NO_PROJECT_ERROR = void 0;
exports.noProjectDirectory = noProjectDirectory;
exports.mcpAuthError = mcpAuthError;
const util_1 = require("./util");
exports.NO_PROJECT_ERROR = (0, util_1.mcpError)("To proceed requires an active project. Use the `firebase_update_environment` tool to set a project ID", "PRECONDITION_FAILED");
function noProjectDirectory(projectRoot) {
    return (0, util_1.mcpError)(`The current project directory '${projectRoot || "<NO PROJECT DIRECTORY FOUND>"}' does not exist. Please use the 'update_firebase_environment' tool to target a different project directory.`);
}
function mcpAuthError(skipADC) {
    if (skipADC) {
        return (0, util_1.mcpError)(`The user is not currently logged into the Firebase CLI, which is required to use this tool. Please run the 'firebase_login' tool to log in.`);
    }
    return (0, util_1.mcpError)(`The user is not currently logged into the Firebase CLI, which is required to use this tool. Please run the 'firebase_login' tool to log in, or instruct the user to configure [Application Default Credentials][ADC] on their machine.
[ADC]: https://cloud.google.com/docs/authentication/application-default-credentials`);
}
