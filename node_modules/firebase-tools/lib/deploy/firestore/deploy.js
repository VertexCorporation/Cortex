"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = default_1;
const clc = require("colorette");
const api_1 = require("../../firestore/api");
const logger_1 = require("../../logger");
const utils = require("../../utils");
const rulesDeploy_1 = require("../../rulesDeploy");
const utils_1 = require("../../utils");
async function deployRules(context) {
    const rulesDeploy = context?.firestore?.rulesDeploy;
    if (!context.firestoreRules || !rulesDeploy) {
        return;
    }
    await rulesDeploy.createRulesets(rulesDeploy_1.RulesetServiceType.CLOUD_FIRESTORE);
}
async function deployIndexes(context, options) {
    if (!context.firestoreIndexes) {
        return;
    }
    const indexesContext = context?.firestore?.indexes;
    utils.logBullet(clc.bold(clc.cyan("firestore: ")) + "deploying indexes...");
    const firestoreIndexes = new api_1.FirestoreApi();
    await Promise.all(indexesContext.map(async (indexContext) => {
        const { databaseId, indexesFileName, indexesRawSpec } = indexContext;
        if (!indexesRawSpec) {
            logger_1.logger.debug(`No Firestore indexes present for ${databaseId} database.`);
            return;
        }
        const indexes = indexesRawSpec.indexes;
        if (!indexes) {
            logger_1.logger.error(`${databaseId} database index file must contain "indexes" property.`);
            return;
        }
        const fieldOverrides = indexesRawSpec.fieldOverrides || [];
        try {
            await firestoreIndexes.deploy(options, indexes, fieldOverrides, databaseId);
        }
        catch (err) {
            if (err.status !== 404) {
                throw err;
            }
            await (0, utils_1.sleep)(1000);
            await firestoreIndexes.deploy(options, indexes, fieldOverrides, databaseId);
        }
        utils.logSuccess(`${clc.bold(clc.green("firestore:"))} deployed indexes in ${clc.bold(indexesFileName)} successfully for ${databaseId} database`);
    }));
}
async function default_1(context, options) {
    await deployRules(context);
    await deployIndexes(context, options);
}
