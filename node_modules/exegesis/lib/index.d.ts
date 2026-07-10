import * as http from 'http';
import * as oas3 from 'openapi3-ts';
import { ApiInterface, ExegesisOptions, Callback, ExegesisRunner, HttpResult, MiddlewareFunction, OAS3ApiInfo } from './types';
export { HttpError, ValidationError } from './errors';
export * from './types';
/**
 * Compiles an API interface for the given openApiDoc using the options.
 * @param openApiDoc - A string, representing a path to the OpenAPI document,
 *   or a JSON object.
 * @param options - Options.  See docs/options.md
 * @returns - a Promise which returns the compiled API interface
 */
export declare function compileApiInterface(openApiDoc: string | oas3.OpenAPIObject, options: ExegesisOptions): Promise<ApiInterface<OAS3ApiInfo>>;
/**
 * Compiles an API interface for the given openApiDoc using the options.
 * @param openApiDoc - A string, representing a path to the OpenAPI document,
 *   or a JSON object.
 * @param options - Options.  See docs/options.md
 * @param done Callback which returns the compiled API interface
 */
export declare function compileApiInterface(openApiDoc: string | oas3.OpenAPIObject, options: ExegesisOptions, done: Callback<ApiInterface<OAS3ApiInfo>>): void;
/**
 * Returns a "runner" function - call `runner(req, res)` to get back a
 * `HttpResult` object.
 *
 * @param openApiDoc - A string, representing a path to the OpenAPI document,
 *   or a JSON object.
 * @param [options] - Options.  See docs/options.md
 * @returns - a Promise<ExegesisRunner>.  ExegesisRunner is a
 *   `function(req, res)` which will handle an API call, and return an
 *   `HttpResult`, or `undefined` if the request could not be handled.
 */
export declare function compileRunner(openApiDoc: string | oas3.OpenAPIObject, options?: ExegesisOptions): Promise<ExegesisRunner>;
/**
 * Returns a "runner" function - call `runner(req, res)` to get back a
 * `HttpResult` object.
 *
 * @param openApiDoc - A string, representing a path to the OpenAPI document,
 *   or a JSON object.
 * @param options - Options.  See docs/options.md
 * @param done - Callback which retunrs an ExegesisRunner.  ExegesisRunner is a
 *   `function(req, res)` which will handle an API call, and return an
 *   `HttpResult`, or `undefined` if the request could not be handled.
 */
export declare function compileRunner(openApiDoc: string | oas3.OpenAPIObject, options: ExegesisOptions | undefined, done: Callback<ExegesisRunner>): void;
/**
 * Convenience function which writes an `HttpResult` obtained from an
 * ExegesisRunner out to an HTTP response.
 *
 * @param httpResult - Result to write.
 * @param res - The response to write to.
 * @returns - a Promise which resolves on completion.
 */
export declare function writeHttpResult(httpResult: HttpResult, res: http.ServerResponse): Promise<void>;
/**
 * Convenience function which writes an `HttpResult` obtained from an
 * ExegesisRunner out to an HTTP response.
 *
 * @param httpResult - Result to write.
 * @param res - The response to write to.
 * @param callback - Callback to call on completetion.
 */
export declare function writeHttpResult(httpResult: HttpResult, res: http.ServerResponse, done: Callback<void>): void;
/**
 * Returns a connect/express middleware function which implements the API.
 *
 * @param openApiDoc - A string, representing a path to the OpenAPI document,
 *   or a JSON object.
 * @param [options] - Options.  See docs/options.md
 * @returns - a Promise<MiddlewareFunction>.
 */
export declare function compileApi(openApiDoc: string | oas3.OpenAPIObject, options?: ExegesisOptions): Promise<MiddlewareFunction>;
/**
 * Returns a connect/express middleware function which implements the API.
 *
 * @param openApiDoc - A string, representing a path to the OpenAPI document,
 *   or a JSON object.
 * @param options - Options.  See docs/options.md
 * @param done - callback which returns the MiddlewareFunction.
 */
export declare function compileApi(openApiDoc: string | oas3.OpenAPIObject, options: ExegesisOptions | undefined, done: Callback<MiddlewareFunction>): void;
