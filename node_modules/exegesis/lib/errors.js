"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.HttpPayloadTooLargeError = exports.HttpNotFoundError = exports.ValidationError = exports.HttpBadRequestError = exports.HttpError = exports.ExtendableError = void 0;
exports.asError = asError;
class ExtendableError extends Error {
    constructor(message) {
        super(message);
        this.name = this.constructor.name;
        if (typeof Error.captureStackTrace === 'function') {
            Error.captureStackTrace(this, this.constructor);
        }
        else {
            this.stack = new Error(message).stack;
        }
    }
}
exports.ExtendableError = ExtendableError;
class HttpError extends ExtendableError {
    constructor(status, message) {
        super(message);
        this.status = status;
    }
}
exports.HttpError = HttpError;
class HttpBadRequestError extends HttpError {
    constructor(message) {
        super(400, message);
    }
}
exports.HttpBadRequestError = HttpBadRequestError;
class ValidationError extends HttpBadRequestError {
    constructor(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }
        super(errors.length === 1 ? errors[0].message : 'Multiple validation errors');
        this.errors = errors;
    }
}
exports.ValidationError = ValidationError;
class HttpNotFoundError extends HttpError {
    constructor(message) {
        super(404, message);
    }
}
exports.HttpNotFoundError = HttpNotFoundError;
class HttpPayloadTooLargeError extends HttpError {
    constructor(message) {
        super(413, message);
    }
}
exports.HttpPayloadTooLargeError = HttpPayloadTooLargeError;
/**
 * Ensures the passed in `err` is of type Error.
 */
function asError(err) {
    if (err instanceof Error) {
        return err;
    }
    else {
        const newErr = new Error(err);
        if (err.status) {
            newErr.status = err.status;
        }
        return newErr;
    }
}
//# sourceMappingURL=errors.js.map