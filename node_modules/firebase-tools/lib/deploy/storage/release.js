"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = default_1;
const lodash_1 = require("lodash");
const rulesDeploy_1 = require("../../rulesDeploy");
async function default_1(context, options) {
    const rulesConfigsToDeploy = (0, lodash_1.get)(context, "storage.rulesConfigsToDeploy", []);
    const rulesDeploy = (0, lodash_1.get)(context, "storage.rulesDeploy");
    if (!rulesConfigsToDeploy.length || !rulesDeploy) {
        return [];
    }
    const toRelease = [];
    for (const ruleConfig of rulesConfigsToDeploy) {
        if (ruleConfig.target) {
            options.rc.target(options.project, "storage", ruleConfig.target).forEach((bucket) => {
                toRelease.push({ bucket: bucket, rules: ruleConfig.rules });
            });
        }
        else {
            toRelease.push({ bucket: ruleConfig.bucket, rules: ruleConfig.rules });
        }
    }
    await Promise.all(toRelease.map((r) => {
        return rulesDeploy.release(r.rules, rulesDeploy_1.RulesetServiceType.FIREBASE_STORAGE, r.bucket);
    }));
    return toRelease.map((r) => r.bucket);
}
