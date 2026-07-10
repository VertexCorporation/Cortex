"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.setEnvVarsForEmulators = setEnvVarsForEmulators;
exports.getCredentialsEnvironment = getCredentialsEnvironment;
exports.maybeUsePortForwarding = maybeUsePortForwarding;
const constants_1 = require("./constants");
const types_1 = require("./types");
const functionsEmulatorShared_1 = require("./functionsEmulatorShared");
const defaultCredentials_1 = require("../defaultCredentials");
function setEnvVarsForEmulators(env, emulators) {
    for (const emu of emulators) {
        const host = (0, functionsEmulatorShared_1.formatHost)(emu);
        switch (emu.name) {
            case types_1.Emulators.FIRESTORE:
                env[constants_1.Constants.FIRESTORE_EMULATOR_HOST] = host;
                env[constants_1.Constants.FIRESTORE_EMULATOR_ENV_ALT] = host;
                break;
            case types_1.Emulators.DATABASE:
                env[constants_1.Constants.FIREBASE_DATABASE_EMULATOR_HOST] = host;
                break;
            case types_1.Emulators.STORAGE:
                env[constants_1.Constants.FIREBASE_STORAGE_EMULATOR_HOST] = host;
                env[constants_1.Constants.CLOUD_STORAGE_EMULATOR_HOST] = `http://${host}`;
                break;
            case types_1.Emulators.AUTH:
                env[constants_1.Constants.FIREBASE_AUTH_EMULATOR_HOST] = host;
                break;
            case types_1.Emulators.HUB:
                env[constants_1.Constants.FIREBASE_EMULATOR_HUB] = host;
                break;
            case types_1.Emulators.PUBSUB:
                env[constants_1.Constants.PUBSUB_EMULATOR_HOST] = host;
                break;
            case types_1.Emulators.EVENTARC:
                env[constants_1.Constants.CLOUD_EVENTARC_EMULATOR_HOST] = `http://${host}`;
                break;
            case types_1.Emulators.TASKS:
                env[constants_1.Constants.CLOUD_TASKS_EMULATOR_HOST] = host;
                break;
            case types_1.Emulators.DATACONNECT:
                env[constants_1.Constants.FIREBASE_DATACONNECT_EMULATOR_HOST] = `http://${host}`;
                env[constants_1.Constants.FIREBASE_DATACONNECT_ENV_ALT] = host;
                env["FIREBASE_DATACONNECT_EMULATOR_HOST"] = host;
        }
    }
}
async function getCredentialsEnvironment(account, logger, logLabel, silent = false) {
    const credentialEnv = {};
    if (await (0, defaultCredentials_1.hasDefaultCredentials)()) {
        !silent &&
            logger.logLabeled("WARN", logLabel, `Application Default Credentials detected. Non-emulated services will access production using these credentials. Be careful!`);
    }
    else if (account) {
        const defaultCredPath = await (0, defaultCredentials_1.getCredentialPathAsync)(account);
        if (defaultCredPath) {
            logger.log("DEBUG", `Setting GAC to ${defaultCredPath}`);
            credentialEnv.GOOGLE_APPLICATION_CREDENTIALS = defaultCredPath;
        }
    }
    return credentialEnv;
}
function maybeUsePortForwarding(i) {
    const portForwardingHost = process.env.WEB_HOST;
    if (portForwardingHost) {
        const info = { ...i };
        if (info.host.includes(portForwardingHost)) {
            return info;
        }
        const url = `${info.port}-${portForwardingHost}`;
        info.host = url;
        info.listen = info.listen?.map((listen) => {
            const l = { ...listen };
            l.address = url;
            l.port = 443;
            return l;
        });
        info.port = 443;
        const fsInfo = info;
        if (fsInfo.webSocketPort) {
            fsInfo.webSocketHost = `${fsInfo.webSocketPort}-${portForwardingHost}`;
            fsInfo.webSocketPort = 443;
        }
        return info;
    }
    return i;
}
