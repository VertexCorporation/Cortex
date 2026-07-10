"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.askQuestions = askQuestions;
exports.actuate = actuate;
const clc = require("colorette");
const prompt_1 = require("../../prompt");
const logger_1 = require("../../logger");
async function askQuestions(setup) {
    const authConfig = setup.config.auth;
    const choices = [
        {
            name: "Google Sign-In",
            value: "google",
            checked: !!authConfig?.providers?.googleSignIn,
        },
        {
            name: "Email/Password",
            value: "email",
            checked: !!authConfig?.providers?.emailPassword,
        },
        {
            name: "Anonymous",
            value: "anonymous",
            checked: !!authConfig?.providers?.anonymous,
        },
    ];
    const providers = await (0, prompt_1.checkbox)({
        message: "Which providers would you like to enable? If you don't see a provider here, go to the Firebase Console to set it up.",
        choices: choices,
    });
    const providersConfig = {};
    if (providers.includes("anonymous")) {
        providersConfig.anonymous = true;
    }
    if (providers.includes("email")) {
        providersConfig.emailPassword = true;
    }
    if (providers.includes("google")) {
        logger_1.logger.info("");
        logger_1.logger.info("Configuring Google Sign-In...");
        const oAuthBrandDisplayName = await (0, prompt_1.input)({
            message: "What display name would you like to use for your OAuth brand?",
            default: authConfig?.providers?.googleSignIn?.oAuthBrandDisplayName ||
                setup.project?.projectId ||
                "My App",
        });
        const supportEmail = await (0, prompt_1.input)({
            message: "What support email would you like to register for your OAuth brand?",
            default: authConfig?.providers?.googleSignIn?.supportEmail ||
                (setup.project ? `support@${setup.project.projectId}.firebaseapp.com` : undefined),
        });
        providersConfig.googleSignIn = {
            oAuthBrandDisplayName,
            supportEmail,
        };
    }
    if (!setup.featureInfo) {
        setup.featureInfo = {};
    }
    setup.featureInfo.auth = { providers: providersConfig };
}
async function actuate(setup, config) {
    const authConfig = setup.featureInfo?.auth;
    if (!authConfig) {
        return;
    }
    config.set("auth", authConfig);
    config.writeProjectFile("firebase.json", config.src);
    logger_1.logger.info("");
    logger_1.logger.info("Generated firebase.json with auth configuration.");
    logger_1.logger.info("Run " + clc.bold("firebase deploy") + " to enable these providers.");
}
