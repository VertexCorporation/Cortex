"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateStructuredParser = generateStructuredParser;
exports.structuredStringParser = structuredStringParser;
exports.structuredArrayParser = structuredArrayParser;
exports.explodedStructuredArrayParser = explodedStructuredArrayParser;
const lodash_1 = __importDefault(require("lodash"));
const common_1 = require("./common");
const json_schema_infer_types_1 = __importDefault(require("../../utils/json-schema-infer-types"));
const simpleStringParser_1 = require("./simpleStringParser");
/**
 * A structured parser is a parser that handles RFC6570 path-style and
 * form-style query expansions.
 *
 * @param schema - The JSON Schema this parser is expecting.
 * @param explode - True if this is a parser for an "exploded" expansion.
 */
function generateStructuredParser(schema, explode) {
    const allowedTypes = (0, common_1.removeSimpleTypes)((0, json_schema_infer_types_1.default)(schema));
    if (allowedTypes.length === 1 && allowedTypes[0] === 'string') {
        return structuredStringParser;
    }
    else if (allowedTypes.length === 1 && allowedTypes[0] === 'array') {
        if (explode) {
            return explodedStructuredArrayParser;
        }
        else {
            return structuredArrayParser;
        }
    }
    else if (!explode) {
        return generateGenericStructuredParser(schema);
    }
    else {
        return generateGenericExplodedStructuredParser(schema);
    }
}
function structuredStringParser(location, rawParamValues) {
    const value = rawParamValues[location.name];
    if (!value) {
        return value;
    }
    else if (Array.isArray(value)) {
        // This is supposed to be a string.  -_-
        return value.map(decodeURIComponent);
    }
    else {
        return value ? (0, simpleStringParser_1.simpleStringParser)(value) : value;
    }
}
function structuredArrayParser(location, rawParamValues) {
    const value = rawParamValues[location.name];
    if (value === undefined || value === null) {
        return value;
    }
    else if (Array.isArray(value)) {
        // We *should* not receive multiple form headers.  If this happens,
        // it's probably because the client used explode when they shouldn't
        // have.
        return explodedStructuredArrayParser(location, rawParamValues);
    }
    else {
        return value ? (0, simpleStringParser_1.simpleArrayParser)(value) : value;
    }
}
function explodedStructuredArrayParser(location, rawParamValues) {
    const value = rawParamValues[location.name];
    if (value === undefined || value === null) {
        return value;
    }
    else if (Array.isArray(value)) {
        return value.map(decodeURIComponent);
    }
    else {
        return [decodeURIComponent(value)];
    }
}
function generateGenericStructuredParser(schema) {
    const genericSimpleParser = (0, simpleStringParser_1.generateGenericSimpleParser)(schema, false);
    return function genericStructuredParser(location, rawParamValues) {
        const value = rawParamValues[location.name];
        if (value === undefined || value === null) {
            return value;
        }
        if (Array.isArray(value)) {
            // Unexploded parameters should not be an array.  Parse each member
            // of the array, and return an array of arrays?
            return value.map(genericSimpleParser);
        }
        return genericSimpleParser(value);
    };
}
function explodedKeysStructuredParser(values) {
    return lodash_1.default.mapValues(values, (v) => {
        if (Array.isArray(v)) {
            return v.map(decodeURIComponent);
        }
        else if (v) {
            return decodeURIComponent(v);
        }
        else {
            return v;
        }
    });
}
function generateGenericExplodedStructuredParser(schema) {
    const allowedTypes = (0, common_1.removeSimpleTypes)((0, json_schema_infer_types_1.default)(schema));
    const allowedTypesMap = (0, common_1.allowedTypesToMap)(allowedTypes);
    return function genericStructuredParser(location, rawParamValues) {
        const value = rawParamValues[location.name];
        if (value === undefined || value === null) {
            if (allowedTypesMap.object) {
                // TODO: Could use a list of allowed parameters to control what we return here.
                return explodedKeysStructuredParser(rawParamValues);
            }
            else {
                return value;
            }
        }
        // We have a parameter with the same name as the one we're looking for - probably not an object.
        if (Array.isArray(value)) {
            if (!allowedTypesMap.array) {
                return explodedKeysStructuredParser(rawParamValues);
            }
            else {
                return value.map(simpleStringParser_1.simpleStringParser);
            }
        }
        else if (allowedTypesMap.string) {
            return (0, simpleStringParser_1.simpleStringParser)(value);
        }
        else if (allowedTypesMap.array) {
            return [(0, simpleStringParser_1.simpleStringParser)(value)];
        }
        else {
            return explodedKeysStructuredParser(rawParamValues);
        }
    };
}
//# sourceMappingURL=structuredParser.js.map