"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getRulesFromConsole = getRulesFromConsole;
const gcp = require("../../../gcp");
const utils = require("../../../utils");
async function getRulesFromConsole(projectId) {
    const defaultBucket = await gcp.storage.getDefaultBucket(projectId);
    const releases = await gcp.rules.listAllReleases(projectId);
    const name = await gcp.rules.getLatestRulesetName(projectId, "firebase.storage", releases, defaultBucket);
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
