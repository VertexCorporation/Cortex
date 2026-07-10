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
var __exportStar = (this && this.__exportStar) || function(m, exports) {
    for (var p in m) if (p !== "default" && !Object.prototype.hasOwnProperty.call(exports, p)) __createBinding(exports, m, p);
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.generateParser = generateParser;
exports.parseParameterGroup = parseParameterGroup;
exports.parseQueryParameters = parseQueryParameters;
const lodash_1 = __importDefault(require("lodash"));
const querystring_1 = __importDefault(require("querystring"));
const qs_1 = __importDefault(require("qs"));
const errors_1 = require("../../errors");
const delimitedParser_1 = require("./delimitedParser");
const structuredParser_1 = require("./structuredParser");
const simpleStringParser_1 = require("./simpleStringParser");
const pathStyleParser_1 = require("./pathStyleParser");
__exportStar(require("./types"), exports);
function isMediaTypeParameterDescriptor(descriptor) {
    return descriptor && descriptor.contentType && descriptor.parser;
}
function generateParser(parameterDescriptor) {
    let answer;
    if (isMediaTypeParameterDescriptor(parameterDescriptor)) {
        answer = generateMediaTypeParser(parameterDescriptor);
    }
    else {
        answer = generateStyleParser(parameterDescriptor);
    }
    return answer;
}
function generateMediaTypeParser(parameterDescriptor) {
    // request and response are here for application/x-www-form-urlencoded.
    let answer = (location, values) => {
        try {
            let value = values[location.name];
            if (value === undefined || value === null) {
                return value;
            }
            if (parameterDescriptor.uriEncoded) {
                if (Array.isArray(value)) {
                    value = value.map(decodeURIComponent);
                }
                else {
                    value = decodeURIComponent(value);
                }
            }
            if (Array.isArray(value)) {
                return value.map((v) => parameterDescriptor.parser.parseString(v));
            }
            else {
                return parameterDescriptor.parser.parseString(value);
            }
        }
        catch (err) {
            throw new errors_1.ValidationError({
                message: `Error parsing parameter ${location.name} of ` +
                    `type ${parameterDescriptor.contentType}: ${err}`,
                location,
            });
        }
    };
    if (parameterDescriptor.schema && parameterDescriptor.schema.default) {
        answer = setDefault(answer, parameterDescriptor.schema.default);
    }
    return answer;
}
function generateStyleParser(descriptor) {
    const { schema, explode } = descriptor;
    let answer;
    switch (descriptor.style) {
        case 'simple':
            answer = toStructuredParser((0, simpleStringParser_1.getSimpleStringParser)(schema, explode));
            break;
        case 'form':
            answer = (0, structuredParser_1.generateStructuredParser)(schema, explode);
            break;
        case 'matrix':
            answer = (0, pathStyleParser_1.generatePathStyleParser)(schema, explode);
            break;
        case 'spaceDelimited':
            answer = delimitedParser_1.spaceDelimitedParser;
            break;
        case 'pipeDelimited':
            answer = delimitedParser_1.pipeDelimitedParser;
            break;
        case 'deepObject':
            answer = deepObjectParser;
            break;
        default:
            throw new Error(`Don't know how to parse parameters with style ${descriptor.style}`);
    }
    if ('default' in descriptor.schema) {
        answer = setDefault(answer, descriptor.schema.default);
    }
    return answer;
}
function setDefault(parser, def) {
    return function addDefault(location, rawParamValues, rawValue, parserContext) {
        const answer = parser(location, rawParamValues, rawValue, parserContext);
        if (answer !== undefined) {
            return answer;
        }
        else {
            return lodash_1.default.cloneDeep(def);
        }
    };
}
function toStructuredParser(parser) {
    return (location, rawParamValues) => {
        const value = rawParamValues[location.name];
        if (Array.isArray(value)) {
            return value.map(parser);
        }
        else {
            return parser(value);
        }
    };
}
function deepObjectParser(location, _rawParamValues, rawValue, parserContext) {
    if (!parserContext.qsParsed) {
        parserContext.qsParsed = qs_1.default.parse(rawValue);
    }
    const qsParsed = parserContext.qsParsed;
    return qsParsed[location.name];
}
function _parseParameterGroup(params, rawValues, rawQueryString) {
    const parserContext = {};
    return params.reduce((result, { location, parser }) => {
        result[location.name] = parser(location, rawValues, rawQueryString, parserContext);
        return result;
    }, {});
}
function parseParameterGroup(params, rawValues) {
    return _parseParameterGroup(params, rawValues, '');
}
function parseQueryParameters(params, query) {
    const rawValues = querystring_1.default.parse(query || '', '&', '=', {
        decodeURIComponent: (val) => val,
    });
    return _parseParameterGroup(params, rawValues, query || '');
}
//# sourceMappingURL=index.js.map