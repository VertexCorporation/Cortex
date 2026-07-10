"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.askQuestions = askQuestions;
exports.actuate = actuate;
const clc = require("colorette");
const logger_1 = require("../../../logger");
const prompt_1 = require("../../../prompt");
const templates_1 = require("../../../templates");
const error_1 = require("../../../error");
const rules_1 = require("./rules");
const RULES_TEMPLATE = (0, templates_1.readTemplateSync)("init/storage/storage.rules");
const DEFAULT_RULES_FILE = "storage.rules";
async function askQuestions(setup, config) {
    logger_1.logger.info();
    logger_1.logger.info("Firebase Storage Security Rules allow you to define how and when to allow");
    logger_1.logger.info("uploads and downloads. You can keep these rules in your project directory");
    logger_1.logger.info("and publish them with " + clc.bold("firebase deploy") + ".");
    logger_1.logger.info();
    const info = {
        rulesFilename: DEFAULT_RULES_FILE,
        rules: RULES_TEMPLATE,
        writeRules: true,
    };
    if (setup.projectId) {
        const downloadedRules = await (0, rules_1.getRulesFromConsole)(setup.projectId);
        if (downloadedRules) {
            info.rules = downloadedRules;
            logger_1.logger.info(`Downloaded the existing Storage Security Rules from the Firebase console`);
        }
    }
    info.rulesFilename = await (0, prompt_1.input)({
        message: "What file should be used for Storage Rules?",
        default: DEFAULT_RULES_FILE,
    });
    info.writeRules = await config.confirmWriteProjectFile(info.rulesFilename, info.rules);
    setup.featureInfo = setup.featureInfo || {};
    setup.featureInfo.storage = info;
}
async function actuate(setup, config) {
    const info = setup.featureInfo?.storage;
    if (!info) {
        throw new error_1.FirebaseError("storage featureInfo is not found");
    }
    info.rules = info.rules || RULES_TEMPLATE;
    info.rulesFilename = info.rulesFilename || DEFAULT_RULES_FILE;
    setup.config.storage = {
        rules: info.rulesFilename,
    };
    if (info.writeRules) {
        config.writeProjectFile(info.rulesFilename, info.rules);
    }
}
