"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const url_1 = require("url");
const semver = __importStar(require("semver"));
const Paths_1 = __importDefault(require("./Paths"));
const Servers_1 = __importDefault(require("./Servers"));
const Oas3CompileContext_1 = __importDefault(require("./Oas3CompileContext"));
const extensions_1 = require("./extensions");
const errors_1 = require("../errors");
const httpUtils_1 = require("../utils/httpUtils");
const Path_1 = require("./Path");
class OpenApi {
    /**
     * Creates a new OpenApi object.
     *
     * @param openApiDoc - The complete JSON definition of the API.
     *   The passed in definition should be a complete JSON object with no $refs.
     */
    constructor(openApiDoc, options) {
        if (!openApiDoc.openapi) {
            throw new Error("OpenAPI definition is missing 'openapi' field");
        }
        if (!semver.satisfies(openApiDoc.openapi, '>=3.0.0 <4.0.0')) {
            throw new Error(`OpenAPI version ${openApiDoc.openapi} not supported`);
        }
        this.openApiDoc = openApiDoc;
        this._options = options;
        // TODO: Optimize this case when no `servers` were present in openApi doc,
        // or where we don't need to match servers (only server is {url: '/'})?
        if (!options.ignoreServers && openApiDoc.servers) {
            this._servers = new Servers_1.default(openApiDoc.servers);
        }
        const exegesisController = openApiDoc[extensions_1.EXEGESIS_CONTROLLER];
        this._paths = new Paths_1.default(new Oas3CompileContext_1.default(openApiDoc, ['paths'], options), exegesisController);
    }
    resolve(method, url, headers) {
        const parsedUrl = (0, url_1.parse)(url);
        const pathname = parsedUrl.pathname || '';
        const host = parsedUrl.hostname || headers['host'] || '';
        const contentType = headers['content-type'];
        let pathToResolve;
        let oaServer;
        let serverParams;
        let baseUrl = '';
        if (!this._servers) {
            pathToResolve = pathname;
        }
        else {
            const serverData = this._servers.resolveServer(host, pathname);
            if (serverData) {
                oaServer = serverData.oaServer;
                pathToResolve = serverData.pathnameRest;
                serverParams = serverData.serverParams;
                baseUrl = serverData.baseUrl;
            }
        }
        if (pathToResolve) {
            const resolvedPath = this._paths.resolvePath(pathToResolve);
            if (resolvedPath) {
                const { path, rawPathParams } = resolvedPath;
                const operation = path.getOperation(method);
                let mediaType;
                if (operation && contentType) {
                    mediaType = operation.getRequestMediaType(contentType);
                    if (!mediaType && ((0, httpUtils_1.httpHasBody)(headers) || (0, httpUtils_1.requestMayHaveBody)(method))) {
                        throw new errors_1.HttpBadRequestError(`Invalid content-type: ${contentType}`);
                    }
                }
                else if (operation &&
                    operation.bodyRequired &&
                    operation.validRequestContentTypes) {
                    throw new errors_1.HttpBadRequestError(`Missing content-type. ` +
                        `Expected one of: ${operation.validRequestContentTypes}`);
                }
                let resolvedOperation;
                if (operation) {
                    const parseParameters = function () {
                        return operation.parseParameters({
                            headers,
                            rawPathParams,
                            serverParams,
                            queryString: parsedUrl.query || undefined,
                        });
                    };
                    const validateParameters = (parameterValues) => operation.validateParameters(parameterValues);
                    const bodyParser = mediaType && mediaType.parser;
                    const validateBody = mediaType && mediaType.validator;
                    const validateResponse = (response, validateDefaultResponses) => operation.validateResponse(response, validateDefaultResponses);
                    const exegesisControllerName = (mediaType && mediaType.oaMediaType[extensions_1.EXEGESIS_CONTROLLER]) ||
                        operation.exegesisController;
                    const operationId = (mediaType && mediaType.oaMediaType[extensions_1.EXEGESIS_OPERATION_ID]) ||
                        operation.operationId;
                    const controllerModule = exegesisControllerName && this._options.controllers[exegesisControllerName];
                    const controller = operationId && controllerModule && controllerModule[operationId];
                    const authenticate = (context) => {
                        return operation.authenticate(context);
                    };
                    resolvedOperation = {
                        parseParameters,
                        validateParameters,
                        parameterLocations: operation.parameterLocations,
                        bodyParser,
                        validateBody,
                        validateResponse,
                        exegesisControllerName,
                        operationId,
                        controllerModule,
                        controller,
                        authenticate,
                    };
                }
                const allowedMethods = Path_1.HTTP_METHODS.filter((method) => path.getOperation(method));
                return {
                    operation: resolvedOperation,
                    api: {
                        openApiDoc: this.openApiDoc,
                        serverPtr: undefined, // FIXME
                        serverObject: oaServer,
                        pathItemPtr: path.context.jsonPointer,
                        pathItemObject: path.oaPath,
                        operationPtr: operation && operation.context.jsonPointer,
                        operationObject: operation && operation.oaOperation,
                        requestBodyMediaTypePtr: mediaType && mediaType.context.jsonPointer,
                        requestBodyMediaTypeObject: mediaType && mediaType.oaMediaType,
                    },
                    allowedMethods,
                    path: resolvedPath.pathKey,
                    baseUrl,
                };
            }
        }
        return undefined;
    }
}
exports.default = OpenApi;
//# sourceMappingURL=OpenApi.js.map