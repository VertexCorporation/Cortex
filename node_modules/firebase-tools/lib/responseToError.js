"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.responseToError = responseToError;
const _ = require("lodash");
const error_1 = require("./error");
function responseToError(response, body, url) {
    const statusCode = (response.statusCode || response.status);
    if (statusCode < 400) {
        return;
    }
    if (typeof body === "string") {
        if (statusCode === 404) {
            body = {
                error: {
                    message: "Not Found",
                },
            };
        }
        else {
            body = {
                error: {
                    message: body,
                },
            };
        }
    }
    if (typeof body !== "object") {
        try {
            body = JSON.parse(body);
        }
        catch (e) {
            body = {};
        }
    }
    if (!body.error) {
        const errMessage = statusCode === 404 ? "Not Found" : "Unknown Error";
        body.error = {
            message: errMessage,
        };
    }
    let message = "HTTP Error: " + statusCode + ", " + (body.error.message || body.error);
    if (url) {
        message = "Request to " + url + " had " + message;
    }
    let exitCode;
    if (statusCode >= 500) {
        exitCode = 2;
    }
    else {
        exitCode = 1;
    }
    _.unset(response, "request.headers");
    return new error_1.FirebaseError(message, {
        context: {
            body: body,
            response: response,
        },
        exit: exitCode,
        status: statusCode,
    });
}
