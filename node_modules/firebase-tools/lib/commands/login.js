"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const logger_1 = require("../logger");
const configstore_1 = require("../configstore");
const utils = require("../utils");
const error_1 = require("../error");
const prompt_1 = require("../prompt");
const auth = require("../auth");
const utils_1 = require("../utils");
exports.command = new command_1.Command("login")
    .description("log the CLI into Firebase")
    .option("--no-localhost", "login from a device without an accessible localhost")
    .option("--reauth", "force reauthentication even if already logged in")
    .action(async (options) => {
    if (options.nonInteractive && !options.prototyperLogin) {
        throw new error_1.FirebaseError("Cannot run login in non-interactive mode. See " +
            clc.bold("login:ci") +
            " to generate a token for use in non-interactive environments.", { exit: 1 });
    }
    const user = options.user;
    const tokens = options.tokens;
    if (user && tokens?.refresh_token && !options.reauth) {
        logger_1.logger.info("Already logged in as", clc.bold(user.email));
        return user;
    }
    if (options.consent) {
        options.consent?.metrics ?? configstore_1.configstore.set("usage", options.consent.metrics);
        options.consent?.gemini ?? configstore_1.configstore.set("gemini", options.consent.gemini);
    }
    else if (!options.reauth && !options.prototyperLogin) {
        utils.logBullet("The Firebase CLI’s MCP server feature can optionally make use of Gemini in Firebase. " +
            "Learn more about Gemini in Firebase and how it uses your data: https://firebase.google.com/docs/gemini-in-firebase#how-gemini-in-firebase-uses-your-data");
        const geminiUsage = await (0, prompt_1.confirm)("Enable Gemini in Firebase features?");
        configstore_1.configstore.set("gemini", geminiUsage);
        logger_1.logger.info();
        utils.logBullet("Firebase optionally collects CLI and Emulator Suite usage and error reporting information to help improve our products. Data is collected in accordance with Google's privacy policy (https://policies.google.com/privacy) and is not used to identify you.");
        const collectUsage = await (0, prompt_1.confirm)("Allow Firebase to collect CLI and Emulator Suite usage and error reporting information?");
        configstore_1.configstore.set("usage", collectUsage);
        if (geminiUsage || collectUsage) {
            logger_1.logger.info();
            utils.logBullet("To change your preferences at any time, run `firebase logout` and `firebase login` again.");
        }
    }
    if (options.prototyperLogin) {
        return auth.loginPrototyper();
    }
    const useLocalhost = !(0, utils_1.isCloudEnvironment)() && !!options.localhost;
    const result = await auth.loginGoogle(useLocalhost, user?.email);
    auth.recordCredentials(result);
    logger_1.logger.info();
    if (typeof result.user !== "string") {
        utils.logSuccess("Success! Logged in as " + clc.bold(result.user.email));
    }
    else {
        logger_1.logger.debug("Unexpected string for UserCredentials.user. Maybe an auth response JWT didn't parse right?");
        utils.logSuccess("Success! Logged in");
    }
    return auth;
});
