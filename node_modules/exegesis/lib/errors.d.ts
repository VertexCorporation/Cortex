import { IValidationError } from './types';
export declare class ExtendableError extends Error {
    constructor(message: string);
}
export declare class HttpError extends ExtendableError {
    readonly status: number;
    constructor(status: number, message: string);
}
export declare class HttpBadRequestError extends HttpError {
    constructor(message: string);
}
export declare class ValidationError extends HttpBadRequestError {
    errors: IValidationError[];
    constructor(errors: IValidationError[] | IValidationError);
}
export declare class HttpNotFoundError extends HttpError {
    constructor(message: string);
}
export declare class HttpPayloadTooLargeError extends HttpError {
    constructor(message: string);
}
/**
 * Ensures the passed in `err` is of type Error.
 */
export declare function asError(err: any): Error;
