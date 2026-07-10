"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.listEvents = listEvents;
exports.batchGetEvents = batchGetEvents;
const logger_1 = require("../logger");
const error_1 = require("../error");
const utils_1 = require("./utils");
const filters_1 = require("./filters");
async function listEvents(appId, filter, pageSize = 1) {
    var _a;
    const requestProjectNumber = (0, utils_1.parseProjectNumber)(appId);
    const queryParams = (0, filters_1.filterToUrlSearchParams)(filter);
    queryParams.set("page_size", `${pageSize}`);
    logger_1.logger.debug(`[crashlytics] listEvents called with appId: ${appId}, filter: ${queryParams.toString()}, pageSize: ${pageSize}`);
    const response = await utils_1.CRASHLYTICS_API_CLIENT.request({
        method: "GET",
        headers: {
            "Content-Type": "application/json",
        },
        path: `/projects/${requestProjectNumber}/apps/${appId}/events`,
        queryParams: queryParams,
        timeout: utils_1.TIMEOUT,
    });
    (_a = response.body).events ?? (_a.events = []);
    return response.body;
}
async function batchGetEvents(appId, eventNames) {
    var _a;
    const requestProjectNumber = (0, utils_1.parseProjectNumber)(appId);
    if (eventNames.length > 100)
        throw new error_1.FirebaseError("Too many events in batchGet request");
    logger_1.logger.debug(`[crashlytics] batchGetEvents called with appId: ${appId}, eventNames: ${eventNames.join(", ")}`);
    const queryParams = new URLSearchParams();
    eventNames.forEach((en) => {
        queryParams.append("names", en);
    });
    const response = await utils_1.CRASHLYTICS_API_CLIENT.request({
        method: "GET",
        headers: {
            "Content-Type": "application/json",
        },
        path: `/projects/${requestProjectNumber}/apps/${appId}/events:batchGet`,
        queryParams: queryParams,
        timeout: utils_1.TIMEOUT,
    });
    (_a = response.body).events ?? (_a.events = []);
    return response.body;
}
