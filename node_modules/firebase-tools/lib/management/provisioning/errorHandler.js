"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.enhanceProvisioningError = enhanceProvisioningError;
const error_1 = require("../../error");
function isErrorInfo(detail) {
    return detail["@type"] === "type.googleapis.com/google.rpc.ErrorInfo";
}
function isHelpLinks(detail) {
    return detail["@type"] === "type.googleapis.com/google.rpc.Help";
}
function extractErrorDetails(err) {
    if (!(err instanceof Error)) {
        return "";
    }
    if (err instanceof error_1.FirebaseError && err.context) {
        const context = err.context;
        const errorBody = context.body?.error;
        if (errorBody?.details && Array.isArray(errorBody.details)) {
            const parts = [];
            for (const detail of errorBody.details) {
                if (isErrorInfo(detail)) {
                    parts.push(`Error details:`);
                    parts.push(`  Reason: ${detail.reason}`);
                    parts.push(`  Domain: ${detail.domain}`);
                    if (detail.metadata) {
                        parts.push(`  Additional Info: ${JSON.stringify(detail.metadata)}`);
                    }
                }
                else if (isHelpLinks(detail)) {
                    parts.push(`\nFor help resolving this issue:`);
                    for (const link of detail.links) {
                        parts.push(`  - ${link.description}`);
                        parts.push(`    ${link.url}`);
                    }
                }
            }
            return parts.length > 0 ? `\n\n${parts.join("\n")}` : "";
        }
    }
    return "";
}
function enhanceProvisioningError(err, contextMessage) {
    const originalError = (0, error_1.getError)(err);
    const errorDetails = extractErrorDetails(err);
    const fullMessage = errorDetails
        ? `${contextMessage}: ${originalError.message}${errorDetails}`
        : `${contextMessage}: ${originalError.message}`;
    return new error_1.FirebaseError(fullMessage, {
        exit: 2,
        original: originalError,
    });
}
