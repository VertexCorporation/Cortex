"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.hasMessage = exports.FirebaseError = void 0;
exports.getErrMsg = getErrMsg;
exports.getErrStack = getErrStack;
exports.isObject = isObject;
exports.getErrStatus = getErrStatus;
exports.getError = getError;
exports.isBillingError = isBillingError;
const lodash_1 = require("lodash");
const DEFAULT_CHILDREN = [];
const DEFAULT_EXIT = 1;
const DEFAULT_STATUS = 500;
class FirebaseError extends Error {
    constructor(message, options = {}) {
        super();
        this.name = "FirebaseError";
        this.children = (0, lodash_1.defaultTo)(options.children, DEFAULT_CHILDREN);
        this.context = options.context;
        this.exit = (0, lodash_1.defaultTo)(options.exit, DEFAULT_EXIT);
        this.message = message;
        this.original = options.original;
        this.status = (0, lodash_1.defaultTo)(options.status, DEFAULT_STATUS);
    }
}
exports.FirebaseError = FirebaseError;
function getErrMsg(err, defaultMsg) {
    if (err instanceof Error) {
        return err.message;
    }
    else if (typeof err === "string") {
        return err;
    }
    else if (defaultMsg) {
        return defaultMsg;
    }
    return JSON.stringify(err);
}
function getErrStack(err) {
    if (err instanceof Error) {
        return err.stack || err.message;
    }
    return getErrMsg(err);
}
function isObject(value) {
    return typeof value === "object" && value !== null;
}
function getErrStatus(err, defaultStatus) {
    if (isObject(err) && err.status && typeof err.status === "number") {
        return err.status;
    }
    return defaultStatus || DEFAULT_STATUS;
}
function getError(err) {
    if (err instanceof Error) {
        return err;
    }
    return Error(getErrMsg(err));
}
function isBillingError(e) {
    return !!e.context?.body?.error?.details?.find((d) => {
        return (d.violations?.find((v) => v.type === "serviceusage/billing-enabled") ||
            d.reason === "UREQ_PROJECT_BILLING_NOT_FOUND");
    });
}
const hasMessage = (e) => !!e?.message;
exports.hasMessage = hasMessage;
