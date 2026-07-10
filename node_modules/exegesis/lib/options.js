"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.compileOptions = compileOptions;
const ajv_formats_1 = __importDefault(require("ajv-formats"));
const lodash_1 = __importDefault(require("lodash"));
const BodyParserWrapper_1 = __importDefault(require("./bodyParsers/BodyParserWrapper"));
const JsonBodyParser_1 = __importDefault(require("./bodyParsers/JsonBodyParser"));
const TextBodyParser_1 = __importDefault(require("./bodyParsers/TextBodyParser"));
const loadControllers_1 = require("./controllers/loadControllers");
const mime_1 = require("./utils/mime");
// See the OAS 3.0 specification for full details about supported formats:
//      https://github.com/OAI/OpenAPI-Specification/blob/3.0.2/versions/3.0.2.md#data-types
const defaultValidators = {
    // TODO: Support async validators so we don't need all this casting.
    int32: ajv_formats_1.default.get('int32'),
    int64: ajv_formats_1.default.get('int64'),
    double: ajv_formats_1.default.get('double'),
    float: ajv_formats_1.default.get('float'),
    // Nothing to do for 'password'; this is just a hint for docs.
    password: () => true,
    // Impossible to validate "binary".
    binary: () => true,
    byte: ajv_formats_1.default.get('byte'),
    // Not defined by OAS 3, but it's used throughout OAS 3.0.1, so we put it
    // here as an alias for 'byte' just in case.
    base64: ajv_formats_1.default.get('byte'),
    // Various formats we're supposed to support per the JSON Schema RFC.
    // https://datatracker.ietf.org/doc/html/draft-bhutton-json-schema-validation-00#section-7.3
    date: ajv_formats_1.default.get('date'),
    time: ajv_formats_1.default.get('time'),
    'date-time': ajv_formats_1.default.get('date-time'),
    duration: ajv_formats_1.default.get('duration'),
};
function compileOptions(options = {}) {
    var _a, _b;
    const maxBodySize = options.defaultMaxBodySize || 100000;
    const mimeTypeParsers = Object.assign({
        'text/*': new TextBodyParser_1.default(maxBodySize),
        'application/json': new JsonBodyParser_1.default(maxBodySize),
    }, options.mimeTypeParsers || {});
    const wrappedBodyParsers = lodash_1.default.mapValues(mimeTypeParsers, (p) => {
        if ('parseReq' in p) {
            return p;
        }
        else if ('parseString' in p) {
            return new BodyParserWrapper_1.default(p, maxBodySize);
        }
        else {
            return undefined;
        }
    });
    const bodyParsers = new mime_1.MimeTypeRegistry(wrappedBodyParsers);
    const parameterParsers = new mime_1.MimeTypeRegistry(lodash_1.default.pickBy(mimeTypeParsers, (p) => !!p.parseString));
    const customFormats = Object.assign({}, defaultValidators, options.customFormats || {});
    const contollersPattern = options.controllersPattern || '**/*.js';
    const controllers = typeof options.controllers === 'string'
        ? (0, loadControllers_1.loadControllersSync)(options.controllers, contollersPattern)
        : options.controllers || {};
    const allowMissingControllers = 'allowMissingControllers' in options ? !!options.allowMissingControllers : true;
    const authenticators = options.authenticators || {};
    let autoHandleHttpErrors = true;
    if (options.autoHandleHttpErrors !== undefined) {
        if (options.autoHandleHttpErrors instanceof Function) {
            autoHandleHttpErrors = options.autoHandleHttpErrors;
        }
        else {
            autoHandleHttpErrors = !!options.autoHandleHttpErrors;
        }
    }
    const validateDefaultResponses = 'validateDefaultResponses' in options ? !!options.validateDefaultResponses : true;
    return {
        bodyParsers,
        controllers,
        authenticators,
        customFormats,
        parameterParsers,
        defaultMaxBodySize: maxBodySize,
        ignoreServers: options.ignoreServers || false,
        allowMissingControllers,
        autoHandleHttpErrors,
        onResponseValidationError: options.onResponseValidationError || (() => void 0),
        validateDefaultResponses,
        allErrors: options.allErrors || false,
        treatReturnedJsonAsPure: options.treatReturnedJsonAsPure || false,
        strictValidation: (_a = options.strictValidation) !== null && _a !== void 0 ? _a : false,
        lazyCompileValidationSchemas: (_b = options.lazyCompileValidationSchemas) !== null && _b !== void 0 ? _b : false,
    };
}
//# sourceMappingURL=options.js.map