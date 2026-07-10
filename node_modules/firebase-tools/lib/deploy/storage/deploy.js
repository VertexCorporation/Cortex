"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = default_1;
const lodash_1 = require("lodash");
const rulesDeploy_1 = require("../../rulesDeploy");
async function default_1(context) {
    const rulesDeploy = (0, lodash_1.get)(context, "storage.rulesDeploy");
    if (!rulesDeploy) {
        return;
    }
    await rulesDeploy.createRulesets(rulesDeploy_1.RulesetServiceType.FIREBASE_STORAGE);
}
