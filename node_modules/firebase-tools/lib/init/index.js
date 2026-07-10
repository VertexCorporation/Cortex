"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.init = init;
exports.actuate = actuate;
const lodash_1 = require("lodash");
const clc = require("colorette");
const error_1 = require("../error");
const logger_1 = require("../logger");
const features = require("./features");
const track_1 = require("../track");
const featuresList = [
    { name: "account", doSetup: features.account },
    {
        name: "database",
        askQuestions: features.databaseAskQuestions,
        actuate: features.databaseActuate,
    },
    {
        name: "firestore",
        askQuestions: features.firestoreAskQuestions,
        actuate: features.firestoreActuate,
    },
    {
        name: "dataconnect",
        askQuestions: features.dataconnectAskQuestions,
        actuate: features.dataconnectActuate,
    },
    {
        name: "dataconnect:sdk",
        askQuestions: features.dataconnectSdkAskQuestions,
        actuate: features.dataconnectSdkActuate,
    },
    {
        name: "dataconnect:resolver",
        askQuestions: features.dataconnectResolverAskQuestions,
        actuate: features.dataconnectResolverActuate,
    },
    {
        name: "functions",
        askQuestions: features.functionsAskQuestions,
        actuate: features.functionsActuate,
    },
    {
        name: "hosting",
        askQuestions: features.hostingAskQuestions,
        actuate: features.hostingActuate,
    },
    {
        name: "storage",
        askQuestions: features.storageAskQuestions,
        actuate: features.storageActuate,
    },
    { name: "emulators", doSetup: features.emulators },
    { name: "extensions", doSetup: features.extensions },
    { name: "project", doSetup: features.project },
    { name: "remoteconfig", doSetup: features.remoteconfig },
    { name: "hosting:github", doSetup: features.hostingGithub },
    { name: "genkit", doSetup: features.genkit },
    { name: "apphosting", displayName: "App Hosting", doSetup: features.apphosting },
    {
        name: "apptesting",
        askQuestions: features.apptestingAskQuestions,
        actuate: features.apptestingAcutate,
    },
    {
        name: "ailogic",
        askQuestions: features.aiLogicAskQuestions,
        actuate: features.aiLogicActuate,
    },
    { name: "aitools", displayName: "AI Tools", doSetup: features.aitools },
    {
        name: "auth",
        displayName: "Authentication",
        askQuestions: features.authAskQuestions,
        actuate: features.authActuate,
    },
    {
        name: "agentSkills",
        displayName: "Agent Skills",
        askQuestions: features.agentSkillsAskQuestions,
        actuate: features.agentSkillsActuate,
    },
];
const featureMap = new Map(featuresList.map((feature) => [feature.name, feature]));
async function init(setup, config, options) {
    const nextFeature = setup.features?.shift();
    if (nextFeature) {
        const start = process.uptime();
        const f = featureMap.get(nextFeature);
        if (!f) {
            const availableFeatures = Object.keys(features)
                .filter((f) => f !== "project")
                .join(", ");
            throw new error_1.FirebaseError(`${clc.bold(nextFeature)} is not a valid feature. Must be one of ${availableFeatures}`);
        }
        logger_1.logger.info(clc.bold(`\n${clc.white("===")} ${f.displayName || (0, lodash_1.capitalize)(nextFeature)} Setup`));
        if (f.doSetup) {
            await f.doSetup(setup, config, options);
        }
        else {
            if (f.askQuestions) {
                await f.askQuestions(setup, config, options);
            }
            if (f.actuate) {
                await f.actuate(setup, config, options);
            }
        }
        if (f.postSetup) {
            await f.postSetup(setup, config, options);
        }
        const duration = Math.floor((process.uptime() - start) * 1000);
        void (0, track_1.trackGA4)("product_init", { feature: nextFeature }, duration);
        return init(setup, config, options);
    }
}
async function actuate(setup, config, options) {
    const nextFeature = setup.features?.shift();
    if (nextFeature) {
        const start = process.uptime();
        const f = lookupFeature(nextFeature);
        logger_1.logger.info(clc.bold(`\n${clc.white("===")} ${(0, lodash_1.capitalize)(nextFeature)} Setup Actuation`));
        if (f.doSetup) {
            throw new error_1.FirebaseError(`The feature ${nextFeature} does not support actuate yet. Please run ${clc.bold("firebase init " + nextFeature)} instead.`);
        }
        else {
            if (f.actuate) {
                await f.actuate(setup, config, options);
            }
        }
        const duration = Math.floor((process.uptime() - start) * 1000);
        void (0, track_1.trackGA4)("product_init_mcp", { feature: nextFeature }, duration);
        return actuate(setup, config, options);
    }
}
function lookupFeature(feature) {
    const f = featureMap.get(feature);
    if (!f) {
        const availableFeatures = Object.keys(features)
            .filter((f) => f !== "project")
            .join(", ");
        throw new error_1.FirebaseError(`${clc.bold(feature)} is not a valid feature. Must be one of ${availableFeatures}`);
    }
    return f;
}
