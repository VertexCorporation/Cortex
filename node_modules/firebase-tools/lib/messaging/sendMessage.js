"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sendFcmMessage = sendFcmMessage;
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const logger_1 = require("../logger");
const error_1 = require("../error");
const TIMEOUT = 10000;
const apiClient = new apiv2_1.Client({
    urlPrefix: (0, api_1.messagingApiOrigin)(),
    apiVersion: "v1",
});
async function sendFcmMessage(projectId, options) {
    try {
        const notification = {
            title: options.title,
            body: options.body,
            image: options.image,
        };
        if (!options.token && !options.topic) {
            throw new error_1.FirebaseError("Must supply either token or topic to send FCM message.");
        }
        const message = options.token
            ? {
                token: options.token,
                notification: notification,
            }
            : {
                topic: options.topic,
                notification: notification,
            };
        const messageData = {
            message: message,
        };
        const res = await apiClient.request({
            method: "POST",
            path: `/projects/${projectId}/messages:send`,
            body: JSON.stringify(messageData),
            timeout: TIMEOUT,
        });
        return res.body;
    }
    catch (err) {
        logger_1.logger.debug(err.message);
        throw new error_1.FirebaseError(`Failed to send message to '${options.token || options.topic}' for the project '${projectId}'. `, { original: err });
    }
}
