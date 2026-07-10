"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.askQuestions = askQuestions;
exports.actuate = actuate;
const rules = require("./rules");
const indexes = require("./indexes");
const error_1 = require("../../../error");
const api_1 = require("../../../firestore/api");
const prompt_1 = require("../../../prompt");
const ensureApiEnabled_1 = require("../../../ensureApiEnabled");
const api_2 = require("../../../api");
async function askQuestions(setup, config) {
    const firestore = !Array.isArray(setup.config.firestore) ? setup.config.firestore : undefined;
    const info = {
        databaseId: firestore?.database || "",
        locationId: firestore?.location || "",
        rulesFilename: firestore?.rules || "",
        rules: "",
        writeRules: true,
        indexesFilename: firestore?.indexes || "",
        indexes: "",
        writeIndexes: true,
    };
    if (setup.projectId) {
        await (0, ensureApiEnabled_1.ensure)(setup.projectId, (0, api_2.firestoreOrigin)(), "firestore");
        info.databaseId = info.databaseId || "(default)";
        const api = new api_1.FirestoreApi();
        const databases = await api.listDatabases(setup.projectId);
        const nativeDatabaseNames = databases
            .filter((db) => db.type === "FIRESTORE_NATIVE")
            .map((db) => db.name.split("/")[3]);
        if (nativeDatabaseNames.length === 0) {
            if (databases.length > 0) {
                throw new error_1.FirebaseError(`It looks like this project is using Cloud Firestore in ${databases[0].type}. The Firebase CLI can only manage projects using Cloud Firestore in Native mode. For more information, visit https://cloud.google.com/datastore/docs/firestore-or-datastore`, { exit: 1 });
            }
            info.databaseId = "(default)";
            const locations = await api.locations(setup.projectId);
            const choice = await (0, prompt_1.select)({
                message: "Please select the location of your Firestore database:",
                choices: locations.map((location) => location.name.split("/")[3]),
                default: "nam5",
            });
            info.locationId = choice;
        }
        else if (nativeDatabaseNames.length === 1) {
            info.databaseId = nativeDatabaseNames[0];
            info.locationId = databases
                .filter((db) => db.name.endsWith(`databases/${info.databaseId}`))
                .map((db) => db.locationId)[0];
        }
        else if (nativeDatabaseNames.length > 1) {
            const choice = await (0, prompt_1.select)({
                message: "Please select the name of the Native Firestore database you would like to use:",
                choices: nativeDatabaseNames,
            });
            info.databaseId = choice;
            info.locationId = databases
                .filter((db) => db.name.endsWith(`databases/${info.databaseId}`))
                .map((db) => db.locationId)[0];
        }
    }
    await rules.initRules(setup, config, info);
    await indexes.initIndexes(setup, config, info);
    setup.featureInfo = setup.featureInfo || {};
    setup.featureInfo.firestore = info;
}
async function actuate(setup, config) {
    const info = setup.featureInfo?.firestore;
    if (!info) {
        throw new error_1.FirebaseError("Firestore featureInfo is not found");
    }
    info.databaseId = info.databaseId || "(default)";
    info.locationId = info.locationId || "nam5";
    info.rules = info.rules || rules.getDefaultRules();
    info.rulesFilename = info.rulesFilename || rules.DEFAULT_RULES_FILE;
    info.indexes = info.indexes || indexes.INDEXES_TEMPLATE;
    info.indexesFilename = info.indexesFilename || indexes.DEFAULT_INDEXES_FILE;
    setup.config.firestore = {
        database: info.databaseId,
        location: info.locationId,
        rules: info.rulesFilename,
        indexes: info.indexesFilename,
    };
    if (info.writeRules) {
        config.writeProjectFile(info.rulesFilename, info.rules);
    }
    if (info.writeIndexes) {
        config.writeProjectFile(info.indexesFilename, info.indexes);
    }
}
