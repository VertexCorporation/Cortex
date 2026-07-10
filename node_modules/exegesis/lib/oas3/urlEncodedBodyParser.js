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
exports.generateStringParser = generateStringParser;
exports.generateBodyParser = generateBodyParser;
const jsonPtr = __importStar(require("json-ptr"));
const querystring_1 = __importDefault(require("querystring"));
const BodyParserWrapper_1 = __importDefault(require("../bodyParsers/BodyParserWrapper"));
const json_schema_resolve_ref_1 = require("../utils/json-schema-resolve-ref");
const jsonSchema_1 = require("../utils/jsonSchema");
const parameterParsers_1 = require("./parameterParsers");
// OAS3 has special handling for 'application/x-www-form-urlencoded'.  Parameters
// and bodies of this type are allowed to define an `encoding` section with
// special treatment for specific properties.  This handles generating a parser
// for this content-type.
// Find a property in a JSON Schema.
function findProperty(path, schema, propertyName) {
    if (schema.properties && schema.properties[propertyName]) {
        return path;
    }
    const allOf = schema.allOf || [];
    for (let index = 0; index < allOf.length; index++) {
        const childSchema = (0, json_schema_resolve_ref_1.resolveRef)(schema, allOf[index]);
        const answer = findProperty(path.concat(['allOf', `${index}`]), childSchema, propertyName);
        if (answer) {
            return answer;
        }
    }
    return undefined;
}
function generateStringParser(context, mediaType, parameterLocation) {
    const parameterParsers = [];
    if (mediaType.encoding) {
        if (!mediaType.schema) {
            throw new Error(`Media Type Object ${context.jsonPointer} with 'content' must have a 'schema'`);
        }
        // Find the schema object for the mediaType.
        const schema = (0, json_schema_resolve_ref_1.resolveRef)(context.openApiDoc, `${context.jsonPointer}/schema`);
        // The encoding object describes how parameters should be parsed from the document.
        for (const parameterName of Object.keys(mediaType.encoding)) {
            const encoding = mediaType.encoding[parameterName];
            const parameterSchemaPath = findProperty([], schema, parameterName);
            if (!parameterSchemaPath) {
                throw new Error(`Cannot find parameter ${parameterName} in schema for ${context.jsonPointer}`);
            }
            const parameterSchema = (0, jsonSchema_1.extractSchema)(context.openApiDoc, jsonPtr.encodePointer(parameterSchemaPath));
            let parameterDescriptor;
            if (encoding.contentType) {
                const parser = context.options.parameterParsers.get(encoding.contentType);
                if (!parser) {
                    throw new Error(`No string parser found for ${encoding.contentType} in ${context.jsonPointer}`);
                }
                parameterDescriptor = {
                    contentType: encoding.contentType,
                    parser,
                    uriEncoded: true,
                    schema: parameterSchema,
                };
            }
            else {
                parameterDescriptor = {
                    style: encoding.style || 'form',
                    explode: encoding.explode || false,
                    allowReserved: encoding.allowReserved || false,
                    schema: parameterSchema,
                };
            }
            parameterParsers.push({
                location: {
                    in: parameterLocation.in,
                    name: parameterName,
                    docPath: context.childContext(['encoding', parameterName]).jsonPointer,
                },
                parser: (0, parameterParsers_1.generateParser)(parameterDescriptor),
            });
        }
    }
    return {
        parseString(encoded) {
            const rawResult = querystring_1.default.parse(encoded);
            const parsedResult = (0, parameterParsers_1.parseQueryParameters)(parameterParsers, encoded);
            return Object.assign(rawResult, parsedResult);
        },
    };
}
function generateBodyParser(context, mediaType, parameterLocation) {
    const stringParser = generateStringParser(context, mediaType, parameterLocation);
    return new BodyParserWrapper_1.default(stringParser, context.options.defaultMaxBodySize);
}
//# sourceMappingURL=urlEncodedBodyParser.js.map