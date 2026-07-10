"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const error_1 = require("../error");
const logger_1 = require("../logger");
const auth = require("../auth");
const utils = require("../utils");
exports.command = new command_1.Command("login:ci")
    .description("generate an access token for use in non-interactive environments")
    .option("--no-localhost", "copy and paste a code instead of starting a local server for authentication")
    .action(async (options) => {
    if (options.nonInteractive) {
        throw new error_1.FirebaseError("Cannot run login:ci in non-interactive mode.");
    }
    utils.logWarning("Authenticating with a `login:ci` token is deprecated and will be removed in a future major version of `firebase-tools`. " +
        "Instead, use a service account key with `GOOGLE_APPLICATION_CREDENTIALS`: https://cloud.google.com/docs/authentication/getting-started");
    const userCredentials = await auth.loginGoogle(options.localhost);
    logger_1.logger.info();
    utils.logSuccess("Success! Use this token to login on a CI server:\n\n" +
        clc.bold(userCredentials.tokens.refresh_token || "") +
        '\n\nExample: firebase deploy --token "$FIREBASE_TOKEN"\n');
    return userCredentials;
});
