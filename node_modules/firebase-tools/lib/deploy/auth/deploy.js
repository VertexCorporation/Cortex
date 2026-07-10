"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.deploy = deploy;
const projectUtils_1 = require("../../projectUtils");
const provision_1 = require("../../management/provisioning/provision");
const apps_1 = require("../../management/apps");
const types_1 = require("../../management/provisioning/types");
const logger_1 = require("../../logger");
const utils_1 = require("../../utils");
async function deploy(context, options) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const config = options.config.src.auth;
    if (!config) {
        return;
    }
    const appId = context.auth?.appId;
    if (!appId) {
        return;
    }
    const authInput = {};
    const providers = config.providers;
    const logMsg = [];
    if (providers) {
        if (providers.anonymous === true) {
            logMsg.push("anonymous");
            authInput.anonymousAuthProviderMode = types_1.ProviderMode.PROVIDER_ENABLED;
        }
        if (providers.emailPassword === true) {
            logMsg.push("email/password");
            authInput.emailAuthProviderMode = types_1.ProviderMode.PROVIDER_ENABLED;
        }
        if (providers.googleSignIn) {
            logMsg.push("Google sign-in");
            authInput.googleSigninProviderMode = types_1.ProviderMode.PROVIDER_ENABLED;
            authInput.googleSigninProviderConfig = {
                publicDisplayName: providers.googleSignIn.oAuthBrandDisplayName,
                customerSupportEmail: providers.googleSignIn.supportEmail,
                oauthRedirectUris: providers.googleSignIn.authorizedRedirectUris,
            };
        }
    }
    if (Object.keys(authInput).length === 0) {
        logger_1.logger.debug("[auth] No auth providers configured to enable.");
        return;
    }
    logger_1.logger.info(`Enabling auth providers: ${logMsg.join(", ")}...`);
    await (0, provision_1.provisionFirebaseApp)({
        project: {
            parent: {
                type: "existing_project",
                projectId: projectId,
            },
        },
        app: {
            platform: apps_1.AppPlatform.WEB,
            appId: appId,
        },
        features: {
            firebaseAuthInput: authInput,
        },
    });
    (0, utils_1.logSuccess)(`Auth providers enabled: ${logMsg.join(", ")}`);
}
