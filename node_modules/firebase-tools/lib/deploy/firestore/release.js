"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = default_1;
const rulesDeploy_1 = require("../../rulesDeploy");
async function default_1(context) {
    const rulesDeploy = context?.firestore?.rulesDeploy;
    if (!context.firestoreRules || !rulesDeploy) {
        return;
    }
    const rulesContext = context?.firestore?.rules;
    await Promise.all(rulesContext.map(async (ruleContext) => {
        const databaseId = ruleContext.databaseId;
        const rulesFile = ruleContext.rulesFile;
        if (rulesFile) {
            return rulesDeploy.release(rulesFile, rulesDeploy_1.RulesetServiceType.CLOUD_FIRESTORE, databaseId);
        }
    }));
}
