"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DatabaseLocation = exports.DatabaseInstanceState = exports.DatabaseInstanceType = exports.APP_LIST_PAGE_SIZE = exports.MGMT_API_VERSION = void 0;
exports.populateInstanceDetails = populateInstanceDetails;
exports.getDatabaseInstanceDetails = getDatabaseInstanceDetails;
exports.createInstance = createInstance;
exports.checkInstanceNameAvailable = checkInstanceNameAvailable;
exports.parseDatabaseLocation = parseDatabaseLocation;
exports.listDatabaseInstances = listDatabaseInstances;
const apiv2_1 = require("../apiv2");
const constants_1 = require("../emulator/constants");
const error_1 = require("../error");
const logger_1 = require("../logger");
const api_1 = require("../api");
const utils = require("../utils");
exports.MGMT_API_VERSION = "v1beta";
exports.APP_LIST_PAGE_SIZE = 100;
const TIMEOUT_MILLIS = 10000;
const INSTANCE_RESOURCE_NAME_REGEX = /projects\/([^/]+?)\/locations\/([^/]+?)\/instances\/([^/]*)/;
var DatabaseInstanceType;
(function (DatabaseInstanceType) {
    DatabaseInstanceType["DATABASE_INSTANCE_TYPE_UNSPECIFIED"] = "unspecified";
    DatabaseInstanceType["DEFAULT_DATABASE"] = "default_database";
    DatabaseInstanceType["USER_DATABASE"] = "user_database";
})(DatabaseInstanceType || (exports.DatabaseInstanceType = DatabaseInstanceType = {}));
var DatabaseInstanceState;
(function (DatabaseInstanceState) {
    DatabaseInstanceState["LIFECYCLE_STATE_UNSPECIFIED"] = "unspecified";
    DatabaseInstanceState["ACTIVE"] = "active";
    DatabaseInstanceState["DISABLED"] = "disabled";
    DatabaseInstanceState["DELETED"] = "deleted";
})(DatabaseInstanceState || (exports.DatabaseInstanceState = DatabaseInstanceState = {}));
var DatabaseLocation;
(function (DatabaseLocation) {
    DatabaseLocation["US_CENTRAL1"] = "us-central1";
    DatabaseLocation["EUROPE_WEST1"] = "europe-west1";
    DatabaseLocation["ASIA_SOUTHEAST1"] = "asia-southeast1";
    DatabaseLocation["ANY"] = "-";
})(DatabaseLocation || (exports.DatabaseLocation = DatabaseLocation = {}));
const apiClient = new apiv2_1.Client({ urlPrefix: (0, api_1.rtdbManagementOrigin)(), apiVersion: exports.MGMT_API_VERSION });
async function populateInstanceDetails(options) {
    options.instanceDetails = await getDatabaseInstanceDetails(options.project, options.instance);
    return Promise.resolve();
}
async function getDatabaseInstanceDetails(projectId, instanceName) {
    try {
        const response = await apiClient.request({
            method: "GET",
            path: `/projects/${projectId}/locations/-/instances/${instanceName}`,
            timeout: TIMEOUT_MILLIS,
        });
        return convertDatabaseInstance(response.body);
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        const emulatorHost = process.env[constants_1.Constants.FIREBASE_DATABASE_EMULATOR_HOST];
        if (emulatorHost) {
            return Promise.resolve({
                name: instanceName,
                project: projectId,
                location: DatabaseLocation.ANY,
                databaseUrl: utils.getDatabaseUrl(emulatorHost, instanceName, ""),
                type: DatabaseInstanceType.DEFAULT_DATABASE,
                state: DatabaseInstanceState.ACTIVE,
            });
        }
        throw new error_1.FirebaseError(`Failed to get instance details for instance: ${instanceName}. See firebase-debug.log for more details.`, {
            exit: 2,
            original: err,
        });
    }
}
async function createInstance(projectId, instanceName, location, databaseType) {
    try {
        const response = await apiClient.request({
            method: "POST",
            path: `/projects/${projectId}/locations/${location}/instances`,
            queryParams: { databaseId: instanceName },
            body: { type: databaseType },
            timeout: TIMEOUT_MILLIS,
        });
        return convertDatabaseInstance(response.body);
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        return utils.reject(`Failed to create instance: ${instanceName}. See firebase-debug.log for more details.`, {
            code: 2,
            original: err,
        });
    }
}
async function checkInstanceNameAvailable(projectId, instanceName, databaseType, location) {
    if (!location) {
        location = DatabaseLocation.US_CENTRAL1;
    }
    try {
        await apiClient.request({
            method: "POST",
            path: `/projects/${projectId}/locations/${location}/instances`,
            queryParams: { databaseId: instanceName, validateOnly: "true" },
            body: { type: databaseType },
            timeout: TIMEOUT_MILLIS,
        });
        return { available: true };
    }
    catch (err) {
        logger_1.logger.debug(`Invalid Realtime Database instance name: ${instanceName}.${err.message ? " " + err.message : ""}`);
        const errBody = err.context.body.error;
        if (errBody?.details?.[0]?.metadata?.suggested_database_ids) {
            return {
                available: false,
                suggestedIds: errBody.details[0].metadata.suggested_database_ids.split(","),
            };
        }
        throw new error_1.FirebaseError(`Failed to validate Realtime Database instance name: ${instanceName}.`, {
            original: err,
        });
    }
}
function parseDatabaseLocation(location, defaultLocation) {
    if (!location) {
        return defaultLocation;
    }
    switch (location.toLowerCase()) {
        case "us-central1":
            return DatabaseLocation.US_CENTRAL1;
        case "europe-west1":
            return DatabaseLocation.EUROPE_WEST1;
        case "asia-southeast1":
            return DatabaseLocation.ASIA_SOUTHEAST1;
        case "":
            return defaultLocation;
        default:
            throw new error_1.FirebaseError(`Unexpected location value: ${location}. Only us-central1, europe-west1, and asia-southeast1 locations are supported`);
    }
}
async function listDatabaseInstances(projectId, location, pageSize = exports.APP_LIST_PAGE_SIZE) {
    const instances = [];
    try {
        let nextPageToken = "";
        do {
            const queryParams = { pageSize };
            if (nextPageToken) {
                queryParams.pageToken = nextPageToken;
            }
            const response = await apiClient.request({
                method: "GET",
                path: `/projects/${projectId}/locations/${location}/instances`,
                queryParams,
                timeout: TIMEOUT_MILLIS,
            });
            if (response.body.instances) {
                instances.push(...response.body.instances.map(convertDatabaseInstance));
            }
            nextPageToken = response.body.nextPageToken;
        } while (nextPageToken);
        return instances;
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to list Firebase Realtime Database instances${location === DatabaseLocation.ANY ? "" : ` for location ${location}`}` + ". See firebase-debug.log for more info.", {
            exit: 2,
            original: err,
        });
    }
}
function convertDatabaseInstance(serverInstance) {
    if (!serverInstance.name) {
        throw new error_1.FirebaseError(`DatabaseInstance response is missing field "name"`);
    }
    const m = serverInstance.name.match(INSTANCE_RESOURCE_NAME_REGEX);
    if (!m || m.length !== 4) {
        throw new error_1.FirebaseError(`Error parsing instance resource name: ${serverInstance.name}, matches: ${m}`);
    }
    return {
        name: m[3],
        location: parseDatabaseLocation(m[2], DatabaseLocation.ANY),
        project: serverInstance.project,
        databaseUrl: serverInstance.databaseUrl,
        type: serverInstance.type,
        state: serverInstance.state,
    };
}
