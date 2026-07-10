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
exports._fixNullables = _fixNullables;
exports._filterRequiredProperties = _filterRequiredProperties;
exports.generateRequestValidator = generateRequestValidator;
exports.generateResponseValidator = generateResponseValidator;
const ajv_1 = __importDefault(require("ajv"));
const json_schema_traverse_1 = __importDefault(require("json-schema-traverse"));
const json_schema_resolve_ref_1 = require("../../utils/json-schema-resolve-ref");
const jsonPaths = __importStar(require("../../utils/jsonPaths"));
const jsonSchema = __importStar(require("../../utils/jsonSchema"));
const mime_1 = require("../../utils/mime");
// urlencoded and form-data requests do not contain any type information;
// for example `?foo=9` doesn't tell us if `foo` is the number 9, or the string
// "9", so we need to use type coercion to make sure the data passed in matches
// our schema.
const REQUEST_TYPE_COERCION_ALLOWED = new mime_1.MimeTypeRegistry({
    'application/x-www-form-urlencoded': true,
    'multipart/form-data': true,
});
// TODO tests
// * readOnly
// * readOnly with additionalProperties and value supplied
// * readOnly not supplied but required
// * writeOnly (all cases as readOnly)
// * Make sure validation errors are correct format.
function assertNever(x) {
    throw new Error('Unexpected object: ' + x);
}
function getParameterDescription(parameterLocation) {
    let description = '';
    switch (parameterLocation.in) {
        case 'path':
        case 'server':
        case 'query':
        case 'cookie':
        case 'header':
            description = `${parameterLocation.in} parameter "${parameterLocation.name}"`;
            break;
        case 'request':
        case 'response':
            description = `${parameterLocation.in} body`;
            break;
        default:
            assertNever(parameterLocation.in);
    }
    return description;
}
function removeExamples(schema) {
    // ajv will print "schema id ignored" to stdout if an example contains a filed
    // named "id", so just axe all the examples.
    (0, json_schema_traverse_1.default)(schema, (childSchema) => {
        if (childSchema.example) {
            delete childSchema.example;
        }
    });
}
function _fixNullables(schema) {
    (0, json_schema_traverse_1.default)(schema, {
        cb: {
            post: (childSchema, _jsonPtr, rootSchema, _parentJsonPtr, parentKeyword, _parentSchema, keyIndex) => {
                if (childSchema.nullable) {
                    let ref = rootSchema;
                    let key = parentKeyword;
                    if (key && keyIndex) {
                        ref = ref[key];
                        key = `${keyIndex}`;
                    }
                    if (ref && key) {
                        ref[key] = {
                            anyOf: [{ type: 'null' }, childSchema],
                        };
                    }
                    else if (childSchema === schema) {
                        schema = {
                            anyOf: [{ type: 'null' }, schema],
                        };
                    }
                }
            },
        },
    });
    return schema;
}
function _filterRequiredProperties(schema, propNameToFilter) {
    (0, json_schema_traverse_1.default)(schema, (childSchema) => {
        if (childSchema.properties && childSchema.required) {
            for (const propName of Object.keys(childSchema.properties)) {
                const prop = childSchema.properties[propName];
                // Resolve the prop, in case it's a `{$ref: ....}`.
                const resolvedProp = (0, json_schema_resolve_ref_1.resolveRef)(schema, prop);
                if (resolvedProp && resolvedProp[propNameToFilter]) {
                    childSchema.required = childSchema.required.filter((r) => r !== propName);
                }
            }
        }
    });
}
function doValidate(schemaPtr, parameterLocation, parameterRequired, getAjvValidate, json) {
    const value = { value: json };
    let errors = null;
    if (json === null || json === undefined) {
        if (parameterRequired) {
            errors = [
                {
                    message: `Missing required ${getParameterDescription(parameterLocation)}`,
                    location: {
                        in: parameterLocation.in,
                        name: parameterLocation.name,
                        // docPath comes from parameter here, not schema, since the parameter
                        // is the one that defines it is required.
                        docPath: parameterLocation.docPath,
                        path: '',
                    },
                },
            ];
        }
    }
    if (!errors) {
        const ajvValidate = getAjvValidate();
        ajvValidate(value);
        if (ajvValidate.errors) {
            errors = ajvValidate.errors.map((err) => {
                let pathPtr = err.instancePath || '';
                if (pathPtr.startsWith('/value')) {
                    pathPtr = pathPtr.slice(6);
                }
                return {
                    message: err.message || 'Unspecified error',
                    location: {
                        in: parameterLocation.in,
                        name: parameterLocation.name,
                        docPath: schemaPtr,
                        path: pathPtr,
                    },
                    ajvError: err,
                };
            });
        }
    }
    return { errors, value: value.value };
}
function createValidateGetter(schema, ajv, lazy) {
    if (lazy) {
        let validate = null;
        return function () {
            if (!validate) {
                validate = ajv.compile(schema);
            }
            return validate;
        };
    }
    else {
        const validate = ajv.compile(schema);
        return function () {
            return validate;
        };
    }
}
function generateValidator(schemaContext, parameterLocation, parameterRequired, propNameToFilter, allowTypeCoercion) {
    const { openApiDoc, jsonPointer: schemaPtr } = schemaContext;
    const customFormats = schemaContext.options.customFormats;
    let schema = jsonSchema.extractSchema(openApiDoc, schemaPtr);
    _filterRequiredProperties(schema, propNameToFilter);
    removeExamples(schema);
    // TODO: Should we do this?  Or should we rely on the schema being correct in the first place?
    // schema = _fixNullables(schema);
    // So that we can replace the "root" value of the schema using ajv's type coercion...
    (0, json_schema_traverse_1.default)(schema, (node) => {
        if (node.$ref) {
            if (node.$ref.startsWith('#')) {
                node.$ref = `#/properties/value/${node.$ref.slice(2)}`;
            }
            else {
                node.$ref = jsonPaths.toUriFragment(`/properties/value/${node.$ref.slice(1)}`);
            }
        }
    });
    schema = {
        type: 'object',
        properties: {
            value: schema,
        },
    };
    const ajv = new ajv_1.default({
        useDefaults: true,
        coerceTypes: allowTypeCoercion ? 'array' : false,
        removeAdditional: allowTypeCoercion ? 'failing' : false,
        allErrors: schemaContext.options.allErrors,
        strict: schemaContext.options.strictValidation,
    });
    for (const key of Object.keys(customFormats)) {
        ajv.addFormat(key, customFormats[key]);
    }
    const getValidate = createValidateGetter(schema, ajv, schemaContext.options.lazyCompileValidationSchemas);
    return function (json) {
        return doValidate(schemaPtr, parameterLocation, parameterRequired, getValidate, json);
    };
}
function generateRequestValidator(schemaContext, parameterLocation, parameterRequired, mediaType) {
    const allowTypeCoercion = mediaType
        ? REQUEST_TYPE_COERCION_ALLOWED.get(mediaType) || false
        : false;
    return generateValidator(schemaContext, parameterLocation, parameterRequired, 'readOnly', allowTypeCoercion);
}
function generateResponseValidator(schemaContext, parameterLocation, parameterRequired) {
    return generateValidator(schemaContext, parameterLocation, parameterRequired, 'writeOnly', false);
}
//# sourceMappingURL=validators.js.map