"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = default_1;
const clc = require("colorette");
const loadCJSON_1 = require("../../loadCJSON");
const rulesDeploy_1 = require("../../rulesDeploy");
const utils = require("../../utils");
const fsConfig = require("../../firestore/fsConfig");
const logger_1 = require("../../logger");
const ensureApiEnabled_1 = require("../../ensureApiEnabled");
const api_1 = require("../../api");
const error_1 = require("../../error");
const types = require("../../firestore/api-types");
const api_2 = require("../../firestore/api");
function prepareRules(context, rulesDeploy, databaseId, rulesFile) {
    rulesDeploy.addFile(rulesFile, databaseId);
    context.firestore.rules.push({
        databaseId,
        rulesFile,
    });
}
function prepareIndexes(context, options, databaseId, indexesFileName) {
    const indexesPath = options.config.path(indexesFileName);
    const indexesRawSpec = (0, loadCJSON_1.loadCJSON)(indexesPath);
    utils.logBullet(`${clc.bold(clc.cyan("firestore:"))} reading indexes from ${clc.bold(indexesFileName)}...`);
    context.firestore.indexes.push({
        databaseId,
        indexesFileName,
        indexesRawSpec,
    });
}
async function createDatabase(context, options) {
    let firestoreCfg = options.config.data.firestore;
    if (Array.isArray(firestoreCfg)) {
        firestoreCfg = firestoreCfg[0];
    }
    if (!options.projectId) {
        throw new error_1.FirebaseError("Project ID is required to create a Firestore database.");
    }
    if (!firestoreCfg) {
        throw new error_1.FirebaseError("Firestore database configuration not found in firebase.json.");
    }
    if (!firestoreCfg.database) {
        firestoreCfg.database = "(default)";
    }
    let edition = types.DatabaseEdition.STANDARD;
    if (firestoreCfg.edition) {
        const upperEdition = firestoreCfg.edition.toUpperCase();
        if (upperEdition !== types.DatabaseEdition.STANDARD &&
            upperEdition !== types.DatabaseEdition.ENTERPRISE) {
            throw new error_1.FirebaseError(`Invalid edition specified for database in firebase.json: ${firestoreCfg.edition}`);
        }
        edition = upperEdition;
    }
    let firestoreDataAccessMode;
    let mongodbCompatibleDataAccessMode;
    if (firestoreCfg.dataAccessMode) {
        if (edition !== types.DatabaseEdition.ENTERPRISE) {
            throw new error_1.FirebaseError("dataAccessMode can only be specified for enterprise edition databases.");
        }
        if (firestoreCfg.dataAccessMode === "FIRESTORE_NATIVE") {
            firestoreDataAccessMode = types.DataAccessMode.ENABLED;
            mongodbCompatibleDataAccessMode = types.DataAccessMode.DISABLED;
        }
        else if (firestoreCfg.dataAccessMode === "MONGODB_COMPATIBLE") {
            firestoreDataAccessMode = types.DataAccessMode.DISABLED;
            mongodbCompatibleDataAccessMode = types.DataAccessMode.ENABLED;
        }
    }
    const api = new api_2.FirestoreApi();
    try {
        await api.getDatabase(options.projectId, firestoreCfg.database);
    }
    catch (e) {
        if (e.status === 404) {
            utils.logLabeledBullet("firestore", `Creating the new Firestore database ${firestoreCfg.database}...`);
            const createDatabaseReq = {
                project: options.projectId,
                databaseId: firestoreCfg.database,
                locationId: firestoreCfg.location || "nam5",
                type: types.DatabaseType.FIRESTORE_NATIVE,
                databaseEdition: edition,
                deleteProtectionState: types.DatabaseDeleteProtectionState.DISABLED,
                pointInTimeRecoveryEnablement: types.PointInTimeRecoveryEnablement.DISABLED,
                firestoreDataAccessMode,
                mongodbCompatibleDataAccessMode,
            };
            await api.createDatabase(createDatabaseReq);
        }
    }
}
async function default_1(context, options) {
    await (0, ensureApiEnabled_1.ensure)(context.projectId, (0, api_1.firestoreOrigin)(), "firestore");
    await (0, ensureApiEnabled_1.ensure)(context.projectId, (0, api_1.firestoreOrigin)(), "firestore");
    if (options.only) {
        const targets = options.only.split(",");
        const excludeRules = targets.indexOf("firestore:indexes") >= 0;
        const excludeIndexes = targets.indexOf("firestore:rules") >= 0;
        const includeRules = targets.indexOf("firestore:rules") >= 0;
        const includeIndexes = targets.indexOf("firestore:indexes") >= 0;
        const onlyFirestore = targets.indexOf("firestore") >= 0;
        context.firestoreIndexes = !excludeIndexes || includeIndexes || onlyFirestore;
        context.firestoreRules = !excludeRules || includeRules || onlyFirestore;
    }
    else {
        context.firestoreIndexes = true;
        context.firestoreRules = true;
    }
    const firestoreConfigs = fsConfig.getFirestoreConfig(context.projectId, options);
    if (!firestoreConfigs || firestoreConfigs.length === 0) {
        return;
    }
    context.firestore = context.firestore || {};
    context.firestore.indexes = [];
    context.firestore.rules = [];
    const rulesDeploy = new rulesDeploy_1.RulesDeploy(options, rulesDeploy_1.RulesetServiceType.CLOUD_FIRESTORE);
    context.firestore.rulesDeploy = rulesDeploy;
    await createDatabase(context, options);
    for (const firestoreConfig of firestoreConfigs) {
        if (firestoreConfig.indexes) {
            prepareIndexes(context, options, firestoreConfig.database, firestoreConfig.indexes);
        }
        if (firestoreConfig.rules) {
            prepareRules(context, rulesDeploy, firestoreConfig.database, firestoreConfig.rules);
        }
    }
    if (context.firestore.rules.length > 0) {
        await rulesDeploy.compile();
    }
    const rulesContext = context?.firestore?.rules;
    for (const ruleContext of rulesContext) {
        const databaseId = ruleContext.databaseId;
        const rulesFile = ruleContext.rulesFile;
        if (!rulesFile) {
            logger_1.logger.error(`Invalid firestore config for ${databaseId} database: ${JSON.stringify(options.config.src.firestore)}`);
        }
    }
}
