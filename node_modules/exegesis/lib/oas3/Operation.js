"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const deep_freeze_1 = __importDefault(require("deep-freeze"));
const lodash_1 = __importDefault(require("lodash"));
const promise_breaker_1 = __importDefault(require("promise-breaker"));
const mime_1 = require("../utils/mime");
const oasUtils_1 = require("./oasUtils");
const Parameter_1 = __importDefault(require("./Parameter"));
const parameterParsers_1 = require("./parameterParsers");
const extensions_1 = require("./extensions");
const Responses_1 = __importDefault(require("./Responses"));
const SecuritySchemes_1 = __importDefault(require("./SecuritySchemes"));
// `delete` might have a body. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/DELETE
const METHODS_WITH_BODY = ['post', 'put', 'patch', 'delete'];
function isAuthenticationFailure(result) {
    return !!(result.type === 'invalid' || result.type === 'missing');
}
function getMissing(required, have) {
    if (!have || have.length === 0) {
        return required;
    }
    else {
        return required.filter((r) => !have.includes(r));
    }
}
function validateController(context, controller, operationId) {
    if (!controller && !context.options.allowMissingControllers) {
        throw new Error(`Missing ${extensions_1.EXEGESIS_CONTROLLER} for ${context.jsonPointer}`);
    }
    if (!operationId && !context.options.allowMissingControllers) {
        throw new Error(`Missing operationId or ${extensions_1.EXEGESIS_OPERATION_ID} for ${context.jsonPointer}`);
    }
    if (controller && operationId) {
        if (!context.options.controllers[controller]) {
            throw new Error(`Could not find controller ${controller} defined in ${context.jsonPointer}`);
        }
        else if (!context.options.controllers[controller][operationId]) {
            throw new Error(`Could not find operation ${controller}#${operationId} defined in ${context.jsonPointer}`);
        }
    }
}
/*
 * Validate that all operations/request bodies have a controller and
 * operationId defined.
 */
function validateControllers(context, requestBody, opController, operationId) {
    if (requestBody) {
        for (const mediaType of Object.keys(requestBody.content)) {
            const mediaContext = context.childContext(['requestBody', 'content', mediaType]);
            const mediaTypeObject = requestBody.content[mediaType];
            const mediaController = mediaTypeObject[extensions_1.EXEGESIS_CONTROLLER] || opController;
            const mediaOperationId = mediaTypeObject[extensions_1.EXEGESIS_OPERATION_ID] || operationId;
            validateController(mediaContext, mediaController, mediaOperationId);
        }
    }
    else {
        validateController(context, opController, operationId);
    }
}
class Operation {
    constructor(context, oaOperation, oaPath, method, exegesisController, parentParameters) {
        this.context = context;
        this.oaOperation = oaOperation;
        this.oaPath = oaPath;
        this.exegesisController = oaOperation[extensions_1.EXEGESIS_CONTROLLER] || exegesisController;
        this.operationId = oaOperation[extensions_1.EXEGESIS_OPERATION_ID] || oaOperation.operationId;
        this.securityRequirements = oaOperation.security || context.openApiDoc.security || [];
        this._securitySchemes = new SecuritySchemes_1.default(context.openApiDoc);
        this._responses = new Responses_1.default(context.childContext('responses'), oaOperation.responses);
        for (const securityRequirement of this.securityRequirements) {
            for (const schemeName of Object.keys(securityRequirement)) {
                if (!context.options.authenticators[schemeName]) {
                    throw new Error(`Operation ${context.jsonPointer} references security scheme "${schemeName}" ` +
                        `but no authenticator was provided.`);
                }
            }
        }
        const requestBody = oaOperation.requestBody && METHODS_WITH_BODY.includes(method)
            ? context.resolveRef(oaOperation.requestBody)
            : undefined;
        validateControllers(context, requestBody, this.exegesisController, this.operationId);
        if (requestBody) {
            this.validRequestContentTypes = Object.keys(requestBody.content);
            this.bodyRequired = requestBody.required || false;
            const contentContext = context.childContext(['requestBody', 'content']);
            this._requestBodyContentTypes = (0, oasUtils_1.contentToRequestMediaTypeRegistry)(contentContext, { in: 'request', name: 'body', docPath: contentContext.jsonPointer }, requestBody.required || false, requestBody.content);
        }
        else {
            this._requestBodyContentTypes = new mime_1.MimeTypeRegistry();
            this.bodyRequired = false;
        }
        const localParameters = (this.oaOperation.parameters || []).map((parameter, index) => new Parameter_1.default(context.childContext(['parameters', '' + index]), parameter));
        const allParameters = parentParameters.concat(localParameters);
        this._parameters = allParameters.reduce((result, parameter) => {
            result[parameter.oaParameter.in].push(parameter);
            return result;
        }, { query: [], header: [], path: [], server: [], cookie: [] });
        this.parameterLocations = (0, deep_freeze_1.default)(allParameters.reduce((result, parameter) => {
            result[parameter.oaParameter.in] = parameter.location;
            return result;
        }, { query: {}, header: {}, path: {}, cookie: {} }));
    }
    /**
     * Given a 'content-type' from a request, return a `MediaType` object that
     * matches, or `undefined` if no objects match.
     *
     * @param contentType - The content type from the 'content-type' header on
     *   a request.
     * @returns - The MediaType object to handle this request, or undefined if
     *   no MediaType is set for the given contentType.
     */
    getRequestMediaType(contentType) {
        return this._requestBodyContentTypes.get(contentType);
    }
    /**
     * Parse parameters for this operation.
     * @param params - Raw headers, raw path params and server params from
     *   `PathResolver`, and the raw queryString.
     * @returns parsed parameters.
     */
    parseParameters(params) {
        const { headers, rawPathParams, queryString } = params;
        return {
            query: (0, parameterParsers_1.parseQueryParameters)(this._parameters.query, queryString),
            header: (0, parameterParsers_1.parseParameterGroup)(this._parameters.header, headers || {}),
            server: params.serverParams || {},
            path: rawPathParams ? (0, parameterParsers_1.parseParameterGroup)(this._parameters.path, rawPathParams) : {},
            cookie: {},
        };
    }
    validateParameters(parameterValues) {
        // TODO: We could probably make this a lot more efficient by building the schema
        // for the parameter tree.
        let errors = null;
        for (const parameterLocation of Object.keys(parameterValues)) {
            const parameters = this._parameters[parameterLocation];
            const values = parameterValues[parameterLocation];
            for (const parameter of parameters) {
                const innerResult = parameter.validate(values[parameter.oaParameter.name]);
                if (innerResult && innerResult.errors && innerResult.errors.length > 0) {
                    errors = errors || [];
                    errors = errors.concat(innerResult.errors);
                }
                else {
                    values[parameter.oaParameter.name] = innerResult.value;
                }
            }
        }
        return errors;
    }
    /**
     * Validate a response.
     *
     * @param response - The response generated by a controller.
     * @param validateDefaultResponses - true to validate all responses, false
     *   to only validate non-default responses.
     */
    validateResponse(response, validateDefaultResponses) {
        return this._responses.validateResponse(response.statusCode, response.headers, response.body, validateDefaultResponses);
    }
    _runAuthenticator(schemeName, triedSchemes, exegesisContext, requiredScopes) {
        return __awaiter(this, void 0, void 0, function* () {
            if (!(schemeName in triedSchemes)) {
                const authenticator = this.context.options.authenticators[schemeName];
                const info = this._securitySchemes.getInfo(schemeName);
                const result = (yield promise_breaker_1.default.call(authenticator, null, exegesisContext, info)) || { type: 'missing', status: 401 };
                if (result.type !== 'success' &&
                    result.type !== 'invalid' &&
                    result.type !== 'missing') {
                    throw new Error(`Invalid result ${result.type} from authenticator for ${schemeName}`);
                }
                if (isAuthenticationFailure(result)) {
                    result.status = result.status || 401;
                    if (result.status === 401 && !result.challenge) {
                        result.challenge = this._securitySchemes.getChallenge(schemeName);
                    }
                }
                triedSchemes[schemeName] = result;
            }
            let result = triedSchemes[schemeName];
            if (!isAuthenticationFailure(result)) {
                // For OAuth3, need to verify we have the oauth scopes defined in the API doc.
                const missingScopes = getMissing(requiredScopes, result.scopes);
                if (missingScopes.length > 0) {
                    result = {
                        type: 'invalid',
                        status: 403,
                        message: `Authenticated using '${schemeName}' but missing ` +
                            `required scopes: ${missingScopes.join(', ')}.`,
                    };
                }
            }
            return result;
        });
    }
    /**
     * Checks a single security requirement from an OAS3 `security` field.
     *
     * @param triedSchemes - A cache where keys are names of security schemes
     *   we've already tried, and values are the results returned by the
     *   authenticator.
     * @param errors - An array of strings - we can push any errors we encounter
     *   to this list.
     * @param securityRequirement - The security requirement to check.
     * @param exegesisContext - The context for the request to check.
     * @returns - If the security requirement matches, this returns a
     *   `{type: 'authenticated', result}` object, where result is an object
     *   where keys are security schemes and the values are the results from
     *   the authenticator.  If the requirements are not met, returns a
     *   `{type: 'missing', failure}` object or a `{type: 'invalid', failure}`,
     *   object where `failure` is the the failure that caused this security
     *   requirement to not pass.
     */
    _checkSecurityRequirement(triedSchemes, securityRequirement, exegesisContext) {
        return __awaiter(this, void 0, void 0, function* () {
            const requiredSchemes = Object.keys(securityRequirement);
            const result = Object.create(null);
            let failure;
            let failedSchemeName;
            for (const scheme of requiredSchemes) {
                if (exegesisContext.isResponseFinished()) {
                    // Some authenticator has written a response.  We're done.  :(
                    break;
                }
                const requiredScopes = securityRequirement[scheme];
                const authResult = yield this._runAuthenticator(scheme, triedSchemes, exegesisContext, requiredScopes);
                if (isAuthenticationFailure(authResult)) {
                    // Couldn't authenticate.  Try the next one.
                    failure = authResult;
                    failedSchemeName = scheme;
                    break;
                }
                result[scheme] = authResult;
            }
            if (failure) {
                return { type: failure.type, failure, failedSchemeName };
            }
            else if (result) {
                return { type: 'authenticated', result };
            }
            else {
                return undefined;
            }
        });
    }
    authenticate(exegesisContext) {
        return __awaiter(this, void 0, void 0, function* () {
            if (this.securityRequirements.length === 0) {
                // No auth required
                return {};
            }
            let firstFailureResult;
            const challenges = {};
            let firstAuthenticatedResult;
            const triedSchemes = Object.create(null);
            for (const securityRequirement of this.securityRequirements) {
                const securityRequirementResult = yield this._checkSecurityRequirement(triedSchemes, securityRequirement, exegesisContext);
                if (!securityRequirementResult) {
                    break;
                }
                else if (securityRequirementResult.type === 'authenticated') {
                    firstAuthenticatedResult =
                        firstAuthenticatedResult || securityRequirementResult.result;
                }
                else if (securityRequirementResult.type === 'missing' ||
                    securityRequirementResult.type === 'invalid') {
                    const failure = securityRequirementResult.failure;
                    if (!failure) {
                        throw new Error('Missing failure.');
                    }
                    if (!securityRequirementResult.failedSchemeName) {
                        throw new Error('Missing failed scheme name.');
                    }
                    // No luck with this security requirement.
                    if (failure.status === 401 && failure.challenge) {
                        challenges[securityRequirementResult.failedSchemeName] = failure.challenge;
                    }
                    if (securityRequirementResult.type === 'invalid') {
                        firstFailureResult = firstFailureResult || failure;
                        break;
                    }
                }
                else {
                    /* istanbul ignore this */
                    throw new Error('Invalid result from `_checkSecurityRequirement()`');
                }
                if (exegesisContext.isResponseFinished()) {
                    // We're done!
                    break;
                }
            }
            if (firstAuthenticatedResult && !firstFailureResult) {
                // Successs!
                return firstAuthenticatedResult;
            }
            else if (exegesisContext.isResponseFinished()) {
                // Someone already wrote a response.
                return undefined;
            }
            else {
                const authSchemes = this.securityRequirements.map((requirement) => {
                    const schemes = Object.keys(requirement);
                    return schemes.length === 1 ? schemes[0] : `(${schemes.join(' + ')})`;
                });
                const authChallenges = (0, lodash_1.default)(this.securityRequirements)
                    .map((requirement) => Object.keys(requirement))
                    .flatten()
                    .map((schemeName) => challenges[schemeName] || this._securitySchemes.getChallenge(schemeName))
                    .filter((challenge) => challenge !== undefined)
                    .value();
                const message = (firstFailureResult && firstFailureResult.message) ||
                    `Must authenticate using one of the following schemes: ${authSchemes.join(', ')}.`;
                exegesisContext.res
                    .setStatus((firstFailureResult && firstFailureResult.status) || 401)
                    .set('WWW-Authenticate', authChallenges)
                    .setBody({ message });
                return undefined;
            }
        });
    }
}
exports.default = Operation;
//# sourceMappingURL=Operation.js.map