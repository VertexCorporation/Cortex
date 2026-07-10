"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createApp = createApp;
const cors = require("cors");
const express = require("express");
const exegesisExpress = require("exegesis-express");
const errors_1 = require("exegesis/lib/errors");
const _ = require("lodash");
const index_1 = require("./index");
const emulatorLogger_1 = require("../emulatorLogger");
const types_1 = require("../types");
const operations_1 = require("./operations");
const state_1 = require("./state");
const apiSpec_1 = require("./apiSpec");
const errors_2 = require("./errors");
const utils_1 = require("./utils");
const lodash_1 = require("lodash");
const handlers_1 = require("./handlers");
const bodyParser = require("body-parser");
const url_1 = require("url");
const jsonwebtoken_1 = require("jsonwebtoken");
const apiSpec = apiSpec_1.default;
const API_SPEC_PATH = "/emulator/openapi.json";
const AUTH_HEADER_PREFIX = "bearer ";
const SERVICE_ACCOUNT_TOKEN_PREFIX = "ya29.";
function specForRouter() {
    const paths = {};
    Object.entries(apiSpec.paths).forEach(([path, pathObj]) => {
        const servers = pathObj.servers ?? apiSpec.servers;
        if (!servers || !servers.length) {
            throw new Error("No servers defined in API spec.");
        }
        const pathWithNamespace = servers[0].url.replace("https://", "/") + path;
        paths[pathWithNamespace] = pathObj;
    });
    return {
        ...apiSpec,
        paths,
        servers: undefined,
        "x-exegesis-controller": "auth",
    };
}
function specWithEmulatorServer(protocol, host) {
    const paths = {};
    Object.entries(apiSpec.paths).forEach(([path, pathObj]) => {
        const servers = pathObj.servers;
        if (servers) {
            pathObj = {
                ...pathObj,
                servers: serversWithEmulators(servers),
            };
        }
        paths[path] = pathObj;
    });
    if (!apiSpec.servers) {
        throw new Error("No servers defined in API spec.");
    }
    return {
        ...apiSpec,
        servers: serversWithEmulators(apiSpec.servers),
        paths,
    };
    function serversWithEmulators(servers) {
        const result = [];
        for (const server of servers) {
            result.push({
                url: server.url ? server.url.replace("https://", "{EMULATOR}/") : "{EMULATOR}",
                variables: {
                    EMULATOR: {
                        default: host ? `${protocol}://${host}` : "",
                        description: "The protocol, hostname, and port of Firebase Auth Emulator.",
                    },
                },
            });
            if (server.url) {
                result.push(server);
            }
        }
        return result;
    }
}
async function createApp(defaultProjectId, singleProjectMode = index_1.SingleProjectMode.NO_WARNING, projectStateForId = new Map()) {
    const app = express();
    app.set("json spaces", 2);
    app.use("/", (req, res, next) => {
        if (req.headers["access-control-request-private-network"]) {
            res.setHeader("access-control-allow-private-network", "true");
        }
        next();
    });
    app.use(cors({ origin: true }));
    app.delete("*", (req, _, next) => {
        delete req.headers["content-type"];
        next();
    });
    app.get("/", (req, res) => {
        return res.json({
            authEmulator: {
                ready: true,
                docs: "https://firebase.google.com/docs/emulator-suite",
                apiSpec: API_SPEC_PATH,
            },
        });
    });
    app.get(API_SPEC_PATH, (req, res) => {
        res.json(specWithEmulatorServer(req.protocol, req.headers.host));
    });
    registerLegacyRoutes(app);
    (0, handlers_1.registerHandlers)(app, (apiKey, tenantId) => getProjectStateById(getProjectIdByApiKey(apiKey), tenantId));
    const apiKeyAuthenticator = (ctx, info) => {
        if (!info.name) {
            throw new Error("apiKey param/header name is undefined in API spec.");
        }
        let key;
        const req = ctx.req;
        switch (info.in) {
            case "header":
                key = req.get(info.name);
                break;
            case "query": {
                const q = req.query[info.name];
                key = typeof q === "string" ? q : undefined;
                break;
            }
            default:
                throw new Error('apiKey must be defined as in: "query" or "header" in API spec.');
        }
        if (key) {
            return { type: "success", user: getProjectIdByApiKey(key) };
        }
        else {
            return undefined;
        }
    };
    const oauth2Authenticator = (ctx) => {
        const authorization = ctx.req.headers["authorization"];
        if (!authorization || !authorization.toLowerCase().startsWith(AUTH_HEADER_PREFIX)) {
            return undefined;
        }
        const scopes = Object.keys(ctx.api.openApiDoc.components.securitySchemes.Oauth2.flows.authorizationCode.scopes);
        const token = authorization.substr(AUTH_HEADER_PREFIX.length);
        if (token.toLowerCase() === "owner") {
            return { type: "success", user: defaultProjectId, scopes };
        }
        else if (token.startsWith(SERVICE_ACCOUNT_TOKEN_PREFIX)) {
            emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.AUTH).log("WARN", `Received service account token ${token}. Assuming that it owns project "${defaultProjectId}".`);
            return { type: "success", user: defaultProjectId, scopes };
        }
        throw new errors_2.UnauthenticatedError("Request had invalid authentication credentials. Expected OAuth 2 access token, login cookie or other valid authentication credential. See https://developers.google.com/identity/sign-in/web/devconsole-project.", [
            {
                message: "Invalid Credentials",
                domain: "global",
                reason: "authError",
                location: "Authorization",
                locationType: "header",
            },
        ]);
    };
    const apis = await exegesisExpress.middleware(specForRouter(), {
        controllers: { auth: toExegesisController(operations_1.authOperations, getProjectStateById) },
        authenticators: {
            apiKeyQuery: apiKeyAuthenticator,
            apiKeyHeader: apiKeyAuthenticator,
            Oauth2: oauth2Authenticator,
        },
        autoHandleHttpErrors(err) {
            if (err.type === "entity.parse.failed") {
                const message = `Invalid JSON payload received. ${err.message}`;
                err = new errors_2.InvalidArgumentError(message, [
                    {
                        message,
                        domain: "global",
                        reason: "parseError",
                    },
                ]);
            }
            if (err instanceof errors_1.ValidationError) {
                const firstError = err.errors[0];
                let details;
                if (firstError.location) {
                    details = `${firstError.location.path} ${firstError.message}`;
                }
                else {
                    details = firstError.message;
                }
                err = new errors_2.InvalidArgumentError(`Invalid JSON payload received. ${details}`);
            }
            if (err.name === "HttpBadRequestError") {
                err = new errors_2.BadRequestError(err.message, "unknown");
            }
            throw err;
        },
        defaultMaxBodySize: 1024 * 1024 * 1024,
        validateDefaultResponses: true,
        onResponseValidationError({ errors }) {
            (0, utils_1.logError)(new Error(`An internal error occured when generating response. Details:\n${JSON.stringify(errors)}`));
            throw new errors_2.InternalError("An internal error occured when generating response.", "emulator-response-validation");
        },
        customFormats: {
            "google-datetime"() {
                return true;
            },
            "google-fieldmask"() {
                return true;
            },
            "google-duration"() {
                return true;
            },
            uint64() {
                return true;
            },
            uint32() {
                return true;
            },
            byte() {
                return true;
            },
        },
        plugins: [
            {
                info: { name: "test" },
                makeExegesisPlugin() {
                    return {
                        postSecurity(pluginContext) {
                            wrapValidateBody(pluginContext);
                            return Promise.resolve();
                        },
                        postController(ctx) {
                            if (ctx.res.statusCode === 401) {
                                const requirements = ctx.api.operationObject.security;
                                if (requirements?.some((req) => req.apiKeyQuery || req.apiKeyHeader)) {
                                    throw new errors_2.PermissionDeniedError("The request is missing a valid API key.");
                                }
                                else {
                                    throw new errors_2.UnauthenticatedError("Request is missing required authentication credential. Expected OAuth 2 access token, login cookie or other valid authentication credential. See https://developers.google.com/identity/sign-in/web/devconsole-project.", [
                                        {
                                            message: "Login Required.",
                                            domain: "global",
                                            reason: "required",
                                            location: "Authorization",
                                            locationType: "header",
                                        },
                                    ]);
                                }
                            }
                        },
                    };
                },
            },
        ],
    });
    app.use(apis);
    app.use(() => {
        throw new errors_2.NotFoundError();
    });
    app.use(((err, req, res, next) => {
        let apiError;
        if (err instanceof errors_2.ApiError) {
            apiError = err;
        }
        else if (!err.status || err.status === 500) {
            apiError = new errors_2.UnknownError(err.message || "Unknown error", err.name || "unknown");
        }
        else {
            return res.status(err.status).json(err);
        }
        if (apiError.code === 500) {
            (0, utils_1.logError)(err);
        }
        return res.status(apiError.code).json({ error: apiError });
    }));
    return app;
    function getProjectIdByApiKey(apiKey) {
        apiKey;
        return defaultProjectId;
    }
    function getProjectStateById(projectId, tenantId) {
        let agentState = projectStateForId.get(projectId);
        if (singleProjectMode !== index_1.SingleProjectMode.NO_WARNING &&
            projectId &&
            defaultProjectId !== projectId) {
            const errorString = `Multiple projectIds are not recommended in single project mode. ` +
                `Requested project ID ${projectId}, but the emulator is configured for ` +
                `${defaultProjectId}. To opt-out of single project mode add/set the ` +
                `\'"singleProjectMode"\' false' property in the firebase.json emulators config.`;
            emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.AUTH).log("WARN", errorString);
            if (singleProjectMode === index_1.SingleProjectMode.ERROR) {
                throw new errors_2.BadRequestError(errorString);
            }
        }
        if (!agentState) {
            agentState = new state_1.AgentProjectState(projectId);
            projectStateForId.set(projectId, agentState);
        }
        if (!tenantId) {
            return agentState;
        }
        return agentState.getTenantProject(tenantId);
    }
}
function registerLegacyRoutes(app) {
    const relyingPartyPrefix = "/www.googleapis.com/identitytoolkit/v3/relyingparty/";
    const v1Prefix = "/identitytoolkit.googleapis.com/v1/";
    for (const [oldPath, newPath] of [
        ["createAuthUri", "accounts:createAuthUri"],
        ["deleteAccount", "accounts:delete"],
        ["emailLinkSignin", "accounts:signInWithEmailLink"],
        ["getAccountInfo", "accounts:lookup"],
        ["getOobConfirmationCode", "accounts:sendOobCode"],
        ["getProjectConfig", "projects"],
        ["getRecaptchaParam", "recaptchaParams"],
        ["publicKeys", "publicKeys"],
        ["resetPassword", "accounts:resetPassword"],
        ["sendVerificationCode", "accounts:sendVerificationCode"],
        ["setAccountInfo", "accounts:update"],
        ["setProjectConfig", "setProjectConfig"],
        ["signupNewUser", "accounts:signUp"],
        ["verifyAssertion", "accounts:signInWithIdp"],
        ["verifyCustomToken", "accounts:signInWithCustomToken"],
        ["verifyPassword", "accounts:signInWithPassword"],
        ["verifyPhoneNumber", "accounts:signInWithPhoneNumber"],
    ]) {
        app.all(`${relyingPartyPrefix}${oldPath}`, (req, _, next) => {
            req.url = `${v1Prefix}${newPath}`;
            next();
        });
    }
    app.post(`${relyingPartyPrefix}signOutUser`, () => {
        throw new errors_2.NotImplementedError(`signOutUser is not implemented in the Auth Emulator.`);
    });
    for (const [oldPath, newMethod, newPath] of [
        ["downloadAccount", "GET", "accounts:batchGet"],
        ["uploadAccount", "POST", "accounts:batchCreate"],
    ]) {
        app.post(`${relyingPartyPrefix}${oldPath}`, bodyParser.json(), (req, res, next) => {
            req.body = convertKeysToCamelCase(req.body || {});
            const targetProjectId = req.body.targetProjectId;
            if (!targetProjectId) {
                return next(new errors_2.BadRequestError("INSUFFICIENT_PERMISSION"));
            }
            delete req.body.targetProjectId;
            req.method = newMethod;
            let qs = req.url.split("?", 2)[1] || "";
            if (newMethod === "GET") {
                Object.assign(req.query, req.body);
                const bodyAsQuery = new url_1.URLSearchParams(req.body).toString();
                qs = qs ? `${qs}&${bodyAsQuery}` : bodyAsQuery;
                delete req.body;
                delete req.headers["content-type"];
            }
            req.url = `${v1Prefix}projects/${encodeURIComponent(targetProjectId)}/${newPath}?${qs}`;
            next();
        });
    }
}
function toExegesisController(ops, getProjectStateById) {
    const result = {};
    processNested(ops, "");
    return new Proxy(result, {
        get: (obj, prop) => {
            if (typeof prop !== "string" || prop in obj) {
                return obj[prop];
            }
            const stub = () => {
                throw new errors_2.NotImplementedError(`${prop} is not implemented in the Auth Emulator.`);
            };
            return stub;
        },
    });
    function processNested(nested, prefix) {
        Object.entries(nested).forEach(([key, value]) => {
            if (typeof value === "function") {
                result[`${prefix}${key}`] = toExegesisOperation(value);
            }
            else {
                processNested(value, `${prefix}${key}.`);
                if (typeof value._ === "function") {
                    result[`${prefix}${key}`] = toExegesisOperation(value._);
                }
            }
        });
    }
    function toExegesisOperation(operation) {
        return (ctx) => {
            let targetProjectId = ctx.params.path.targetProjectId || ctx.requestBody?.targetProjectId;
            if (targetProjectId) {
                if (ctx.api.operationObject.security?.some((sec) => sec.Oauth2)) {
                    (0, errors_2.assert)(ctx.security?.Oauth2, "INSUFFICIENT_PERMISSION : Only authenticated requests can specify target_project_id.");
                }
            }
            else {
                targetProjectId = ctx.user;
            }
            let targetTenantId = undefined;
            if (ctx.params.path.tenantId && ctx.requestBody?.tenantId) {
                (0, errors_2.assert)(ctx.params.path.tenantId === ctx.requestBody.tenantId, "TENANT_ID_MISMATCH");
            }
            targetTenantId = ctx.params.path.tenantId || ctx.requestBody?.tenantId;
            if (ctx.requestBody?.idToken) {
                const idToken = ctx.requestBody?.idToken;
                const decoded = (0, jsonwebtoken_1.decode)(idToken, { complete: true });
                if (decoded?.payload.firebase.tenant && targetTenantId) {
                    (0, errors_2.assert)(decoded?.payload.firebase.tenant === targetTenantId, "TENANT_ID_MISMATCH");
                }
                targetTenantId = targetTenantId || decoded?.payload.firebase.tenant;
            }
            if (ctx.requestBody?.refreshToken) {
                const refreshTokenRecord = (0, state_1.decodeRefreshToken)(ctx.requestBody.refreshToken);
                if (refreshTokenRecord.tenantId && targetTenantId) {
                    (0, errors_2.assert)(refreshTokenRecord.tenantId === targetTenantId, "TENANT_ID_MISMATCH: ((Refresh token tenant ID does not match target tenant ID.))");
                }
                targetTenantId = targetTenantId || refreshTokenRecord.tenantId;
            }
            return operation(getProjectStateById(targetProjectId, targetTenantId), ctx.requestBody, ctx);
        };
    }
}
function wrapValidateBody(pluginContext) {
    const op = pluginContext._operation;
    if (op.validateBody && !op._authEmulatorValidateBodyWrapped) {
        const validateBody = op.validateBody.bind(op);
        op.validateBody = (body) => {
            return validateAndFixRestMappingRequestBody(validateBody, body);
        };
        op._authEmulatorValidateBodyWrapped = true;
    }
}
function validateAndFixRestMappingRequestBody(validate, body) {
    body = convertKeysToCamelCase(body);
    let result;
    let keepFixing = false;
    const fixedPaths = new Set();
    do {
        result = validate(body);
        if (!result.errors)
            return result;
        keepFixing = false;
        for (const error of result.errors) {
            const path = error.location?.path;
            const ajvError = error.ajvError;
            if (!path || fixedPaths.has(path) || !ajvError) {
                continue;
            }
            const dataPath = jsonPointerToPath(path);
            const value = _.get(body, dataPath);
            if (ajvError.keyword === "type" && ajvError.params.type === "string") {
                if (typeof value === "number") {
                    _.set(body, dataPath, value.toString());
                    keepFixing = true;
                }
            }
            else if (ajvError.keyword === "enum") {
                const params = ajvError.params;
                const enumValue = params.allowedValues[value];
                if (enumValue) {
                    _.set(body, dataPath, enumValue);
                    keepFixing = true;
                }
            }
        }
    } while (keepFixing);
    return result;
}
function convertKeysToCamelCase(body) {
    if (body == null || typeof body !== "object")
        return body;
    if (Array.isArray(body)) {
        return body.map(convertKeysToCamelCase);
    }
    const result = Object.create(null);
    for (const key of Object.keys(body)) {
        result[(0, lodash_1.camelCase)(key)] = convertKeysToCamelCase(body[key]);
    }
    return result;
}
function jsonPointerToPath(pointer) {
    const path = pointer.split("/").map((segment) => segment.replace(/~1/g, "/").replace(/~0/g, "~"));
    if (path[0] === "#" || path[0] === "") {
        path.shift();
    }
    return path;
}
