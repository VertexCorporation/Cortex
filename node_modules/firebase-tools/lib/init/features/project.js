"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.doSetup = doSetup;
const clc = require("colorette");
const _ = require("lodash");
const projects_1 = require("../../management/projects");
const logger_1 = require("../../logger");
const utils = require("../../utils");
const prompt = require("../../prompt");
const requireAuth_1 = require("../../requireAuth");
const constants_1 = require("../../emulator/constants");
const error_1 = require("../../error");
const OPTION_NO_PROJECT = "Don't set up a default project";
const OPTION_USE_PROJECT = "Use an existing project";
const OPTION_NEW_PROJECT = "Create a new project";
const OPTION_ADD_FIREBASE = "Add Firebase to an existing Google Cloud Platform project";
async function doSetup(setup, config, options) {
    setup.project = {};
    logger_1.logger.info();
    logger_1.logger.info(`First, let's associate this project directory with a Firebase project.`);
    logger_1.logger.info(`You can create multiple project aliases by running ${clc.bold("firebase use --add")}, `);
    logger_1.logger.info();
    if (options.project) {
        if (constants_1.Constants.isDemoProject(options.project)) {
            logger_1.logger.info(`Skipping Firebase project setup because a demo project is provided`);
            return;
        }
        await (0, requireAuth_1.requireAuth)(options);
        await usingProject(setup, config, options.project);
        return;
    }
    const projectFromRcFile = setup.rcfile?.projects?.default;
    if (projectFromRcFile) {
        await (0, requireAuth_1.requireAuth)(options);
        await usingProject(setup, config, projectFromRcFile, ".firebaserc");
        return;
    }
    const projectEnvVar = utils.envOverride("FIREBASE_PROJECT", "");
    if (projectEnvVar) {
        await (0, requireAuth_1.requireAuth)(options);
        await usingProject(setup, config, projectEnvVar, "$FIREBASE_PROJECT");
        return;
    }
    if (options.nonInteractive) {
        logger_1.logger.info("No default project found. Continuing without a project in non interactive mode.");
        return;
    }
    const choices = [OPTION_USE_PROJECT, OPTION_NEW_PROJECT, OPTION_ADD_FIREBASE, OPTION_NO_PROJECT];
    const projectSetupOption = await prompt.select({
        message: "Please select an option:",
        choices,
    });
    switch (projectSetupOption) {
        case OPTION_USE_PROJECT: {
            await (0, requireAuth_1.requireAuth)(options);
            const pm = await (0, projects_1.selectProjectInteractively)();
            return await usingProjectMetadata(setup, config, pm);
        }
        case OPTION_NEW_PROJECT: {
            utils.logBullet("If you want to create a project in a Google Cloud organization or folder, please use " +
                `"firebase projects:create" instead, and return to this command when you've created the project.`);
            await (0, requireAuth_1.requireAuth)(options);
            const { projectId, displayName } = await (0, projects_1.promptProjectCreation)(options);
            const pm = await (0, projects_1.createFirebaseProjectAndLog)(projectId, { displayName });
            return await usingProjectMetadata(setup, config, pm);
        }
        case OPTION_ADD_FIREBASE: {
            await (0, requireAuth_1.requireAuth)(options);
            const pm = await (0, projects_1.addFirebaseToCloudProjectAndLog)(await (0, projects_1.promptAvailableProjectId)());
            return await usingProjectMetadata(setup, config, pm);
        }
        default:
            return;
    }
}
async function usingProject(setup, config, projectId, from = "") {
    const pm = await (0, projects_1.getFirebaseProject)(projectId);
    const label = `${pm.projectId}` + (pm.displayName ? ` (${pm.displayName})` : "");
    utils.logBullet(`Using project ${label} ${from ? "from ${from}" : ""}.`);
    await usingProjectMetadata(setup, config, pm);
}
async function usingProjectMetadata(setup, config, pm) {
    if (!pm) {
        throw new error_1.FirebaseError("null FirebaseProjectMetadata");
    }
    _.set(setup.rcfile, "projects.default", pm.projectId);
    setup.projectId = pm.projectId;
    setup.projectNumber = pm.projectNumber;
    setup.instance = pm.resources?.realtimeDatabaseInstance;
    setup.projectLocation = pm.resources?.locationId;
    utils.makeActiveProject(config.projectDir, pm.projectId);
}
