"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEFAULT_RULES_FILE = void 0;
exports.getDefaultRules = getDefaultRules;
exports.initRules = initRules;
const clc = require("colorette");
const gcp = require("../../../gcp");
const prompt_1 = require("../../../prompt");
const logger_1 = require("../../../logger");
const utils = require("../../../utils");
const templates_1 = require("../../../templates");
exports.DEFAULT_RULES_FILE = "firestore.rules";
const RULES_TEMPLATE = (0, templates_1.readTemplateSync)("init/firestore/firestore.rules");
function getDefaultRules() {
    const date = utils.thirtyDaysFromNow();
    const formattedForRules = `${date.getFullYear()}, ${date.getMonth() + 1}, ${date.getDate()}`;
    return RULES_TEMPLATE.replace(/{{IN_30_DAYS}}/g, formattedForRules);
}
async function initRules(setup, config, info) {
    logger_1.logger.info();
    logger_1.logger.info("Firestore Security Rules allow you to define how and when to allow");
    logger_1.logger.info("requests. You can keep these rules in your project directory");
    logger_1.logger.info("and publish them with " + clc.bold("firebase deploy") + ".");
    logger_1.logger.info();
    info.rulesFilename =
        info.rulesFilename ||
            (await (0, prompt_1.input)({
                message: "What file should be used for Firestore Rules?",
                default: exports.DEFAULT_RULES_FILE,
            }));
    info.rules = getDefaultRules();
    if (setup.projectId) {
        const downloadedRules = await getRulesFromConsole(setup.projectId);
        if (downloadedRules) {
            info.rules = downloadedRules;
            utils.logBullet(`Downloaded the existing Firestore Security Rules from the Firebase console`);
        }
    }
    info.writeRules = await config.confirmWriteProjectFile(info.rulesFilename, info.rules);
}
async function getRulesFromConsole(projectId) {
    const releases = await gcp.rules.listAllReleases(projectId);
    const name = await gcp.rules.getLatestRulesetName(projectId, "cloud.firestore", releases);
    if (!name) {
        return null;
    }
    const rules = await gcp.rules.getRulesetContent(name);
    if (rules.length <= 0) {
        return utils.reject("Ruleset has no files", { exit: 1 });
    }
    if (rules.length > 1) {
        return utils.reject("Ruleset has too many files: " + rules.length, { exit: 1 });
    }
    return rules[0].content;
}
