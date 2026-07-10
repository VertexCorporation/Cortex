"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DayOfWeek = void 0;
exports.getDatabase = getDatabase;
exports.listCollectionIds = listCollectionIds;
exports.getDocuments = getDocuments;
exports.queryCollection = queryCollection;
exports.deleteDocument = deleteDocument;
exports.deleteDocuments = deleteDocuments;
exports.createBackupSchedule = createBackupSchedule;
exports.updateBackupSchedule = updateBackupSchedule;
exports.deleteBackup = deleteBackup;
exports.deleteBackupSchedule = deleteBackupSchedule;
exports.listBackups = listBackups;
exports.getBackup = getBackup;
exports.listBackupSchedules = listBackupSchedules;
exports.getBackupSchedule = getBackupSchedule;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const logger_1 = require("../logger");
const proto_1 = require("./proto");
const error_1 = require("../error");
const prodOnlyClient = new apiv2_1.Client({
    auth: true,
    apiVersion: "v1",
    urlPrefix: (0, api_1.firestoreOrigin)(),
});
function getClient(emulatorUrl) {
    if (emulatorUrl) {
        return new apiv2_1.Client({
            auth: true,
            apiVersion: "v1",
            urlPrefix: emulatorUrl,
        });
    }
    return prodOnlyClient;
}
var DayOfWeek;
(function (DayOfWeek) {
    DayOfWeek["MONDAY"] = "MONDAY";
    DayOfWeek["TUEDAY"] = "TUESDAY";
    DayOfWeek["WEDNESDAY"] = "WEDNESDAY";
    DayOfWeek["THURSDAY"] = "THURSDAY";
    DayOfWeek["FRIDAY"] = "FRIDAY";
    DayOfWeek["SATURDAY"] = "SATURDAY";
    DayOfWeek["SUNDAY"] = "SUNDAY";
})(DayOfWeek || (exports.DayOfWeek = DayOfWeek = {}));
async function getDatabase(project, database, emulatorUrl) {
    const apiClient = getClient(emulatorUrl);
    const url = `projects/${project}/databases/${database}`;
    try {
        const resp = await apiClient.get(url);
        return resp.body;
    }
    catch (err) {
        logger_1.logger.info(`There was an error retrieving the Firestore database. Currently, the database id is set to ${database}, make sure it exists.`);
        throw err;
    }
}
function listCollectionIds(project, databaseId = "(default)", emulatorUrl) {
    const apiClient = getClient(emulatorUrl);
    const url = `projects/${project}/databases/${databaseId}/documents:listCollectionIds`;
    const data = {
        pageSize: 2147483647,
    };
    return apiClient.post(url, data).then((res) => {
        return res.body.collectionIds || [];
    });
}
async function getDocuments(project, paths, databaseId = "(default)", emulatorUrl) {
    const apiClient = getClient(emulatorUrl);
    const basePath = `projects/${project}/databases/${databaseId}/documents`;
    const url = `${basePath}:batchGet`;
    const fullPaths = paths.map((p) => `${basePath}/${p}`);
    const res = await apiClient.post(url, { documents: fullPaths });
    const out = { documents: [], missing: [] };
    res.body.map((r) => (r.missing ? out.missing.push(r.missing) : out.documents.push(r.found)));
    return out;
}
async function queryCollection(project, structuredQuery, databaseId = "(default)", emulatorUrl) {
    const apiClient = getClient(emulatorUrl);
    const basePath = `projects/${project}/databases/${databaseId}/documents`;
    const url = `${basePath}:runQuery`;
    try {
        const res = await apiClient.post(url, {
            structuredQuery: structuredQuery,
            explainOptions: { analyze: true },
            newTransaction: { readOnly: { readTime: new Date().toISOString() } },
        });
        const out = { documents: [] };
        res.body.map((r) => {
            if (r.document) {
                out.documents.push(r.document);
            }
        });
        return out;
    }
    catch (err) {
        throw JSON.stringify(err);
    }
}
async function deleteDocument(doc, emulatorUrl) {
    const apiClient = getClient(emulatorUrl);
    return apiClient.delete(doc.name);
}
async function deleteDocuments(project, docs, databaseId = "(default)", emulatorUrl) {
    const apiClient = getClient(emulatorUrl);
    const url = `projects/${project}/databases/${databaseId}/documents:commit`;
    const writes = docs.map((doc) => {
        return { delete: doc.name };
    });
    const data = { writes };
    const res = await apiClient.post(url, data, {
        retries: 10,
        retryCodes: [429, 409, 503],
        retryMaxTimeout: 20 * 1000,
    });
    return res.body.writeResults.length;
}
async function createBackupSchedule(project, databaseId, retention, dailyRecurrence, weeklyRecurrence) {
    const url = `projects/${project}/databases/${databaseId}/backupSchedules`;
    const data = {
        retention: (0, proto_1.durationFromSeconds)(retention),
        dailyRecurrence,
        weeklyRecurrence,
    };
    (0, proto_1.assertOneOf)("BackupSchedule", data, "recurrence", "dailyRecurrence", "weeklyRecurrence");
    const res = await prodOnlyClient.post(url, data);
    return res.body;
}
async function updateBackupSchedule(backupScheduleName, retention) {
    const data = {
        retention: (0, proto_1.durationFromSeconds)(retention),
    };
    const res = await prodOnlyClient.patch(backupScheduleName, data);
    return res.body;
}
async function deleteBackup(backupName) {
    await prodOnlyClient.delete(backupName);
}
async function deleteBackupSchedule(backupScheduleName) {
    await prodOnlyClient.delete(backupScheduleName);
}
async function listBackups(project, location) {
    const url = `/projects/${project}/locations/${location}/backups`;
    const res = await prodOnlyClient.get(url);
    return res.body;
}
async function getBackup(backupName) {
    const res = await prodOnlyClient.get(backupName);
    const backup = res.body;
    if (!backup) {
        throw new error_1.FirebaseError("Not found");
    }
    return backup;
}
async function listBackupSchedules(project, database) {
    const url = `/projects/${project}/databases/${database}/backupSchedules`;
    const res = await prodOnlyClient.get(url);
    const backupSchedules = res.body.backupSchedules;
    if (!backupSchedules) {
        return [];
    }
    return backupSchedules;
}
async function getBackupSchedule(backupScheduleName) {
    const res = await prodOnlyClient.get(backupScheduleName);
    const backupSchedule = res.body;
    if (!backupSchedule) {
        throw new error_1.FirebaseError("Not found");
    }
    return backupSchedule;
}
