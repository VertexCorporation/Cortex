"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createNote = createNote;
exports.deleteNote = deleteNote;
exports.listNotes = listNotes;
const logger_1 = require("../logger");
const error_1 = require("../error");
const utils_1 = require("./utils");
async function createNote(appId, issueId, note) {
    const requestProjectNumber = (0, utils_1.parseProjectNumber)(appId);
    logger_1.logger.debug(`[crashlytics] createNote called with appId: ${appId}, issueId: ${issueId}, note: ${note}`);
    try {
        const response = await utils_1.CRASHLYTICS_API_CLIENT.request({
            method: "POST",
            headers: {
                "Content-Type": "application/json",
            },
            path: `/projects/${requestProjectNumber}/apps/${appId}/issues/${issueId}/notes`,
            body: { body: note },
            timeout: utils_1.TIMEOUT,
        });
        return response.body;
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to create note for issue ${issueId}, app ${appId}`, {
            original: (0, error_1.getError)(err),
        });
    }
}
async function deleteNote(appId, issueId, noteId) {
    const requestProjectNumber = (0, utils_1.parseProjectNumber)(appId);
    logger_1.logger.debug(`[crashlytics] deleteNote called with appId: ${appId}, issueId: ${issueId}, noteId: ${noteId}`);
    await utils_1.CRASHLYTICS_API_CLIENT.request({
        method: "DELETE",
        path: `/projects/${requestProjectNumber}/apps/${appId}/issues/${issueId}/notes/${noteId}`,
        timeout: utils_1.TIMEOUT,
    });
    return `Deleted note ${noteId}`;
}
async function listNotes(appId, issueId, pageSize = 20) {
    const requestProjectNumber = (0, utils_1.parseProjectNumber)(appId);
    const queryParams = new URLSearchParams();
    queryParams.set("page_size", `${pageSize}`);
    logger_1.logger.debug(`[crashlytics] listNotes called with appId: ${appId}, issueId: ${issueId}, pageSize: ${pageSize}`);
    const response = await utils_1.CRASHLYTICS_API_CLIENT.request({
        method: "GET",
        headers: {
            "Content-Type": "application/json",
        },
        path: `/projects/${requestProjectNumber}/apps/${appId}/issues/${issueId}/notes`,
        queryParams: queryParams,
        timeout: utils_1.TIMEOUT,
    });
    return response.body.notes || [];
}
