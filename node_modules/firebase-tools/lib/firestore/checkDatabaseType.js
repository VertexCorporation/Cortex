"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.checkDatabaseType = checkDatabaseType;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const logger_1 = require("../logger");
const error_1 = require("../error");
async function checkDatabaseType(projectId, databaseId = "(default)") {
    try {
        const client = new apiv2_1.Client({ urlPrefix: (0, api_1.firestoreOrigin)(), apiVersion: "v1" });
        const resp = await client.get(`/projects/${projectId}/databases/${databaseId}`);
        return resp.body.type;
    }
    catch (err) {
        logger_1.logger.debug("error getting database type: ", err);
        if (err instanceof error_1.FirebaseError) {
            if (err.status === 404) {
                logger_1.logger.info(`${databaseId} does not exist in project ${projectId}.`);
                return "DATABASE_DOES_NOT_EXIST";
            }
        }
        return undefined;
    }
}
