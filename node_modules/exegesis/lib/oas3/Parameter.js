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
Object.defineProperty(exports, "__esModule", { value: true });
const jsonSchema_1 = require("../utils/jsonSchema");
const validators_1 = require("./Schema/validators");
const oasUtils_1 = require("./oasUtils");
const parameterParsers_1 = require("./parameterParsers");
const urlEncodedBodyParser = __importStar(require("./urlEncodedBodyParser"));
const DEFAULT_STYLE = {
    path: 'simple',
    query: 'form',
    cookie: 'form',
    header: 'simple',
};
function getDefaultExplode(style) {
    return style === 'form';
}
function generateSchemaParser(self, schema) {
    const style = self.oaParameter.style || DEFAULT_STYLE[self.oaParameter.in];
    const explode = self.oaParameter.explode === null || self.oaParameter.explode === undefined
        ? getDefaultExplode(style)
        : self.oaParameter.explode;
    const allowReserved = self.oaParameter.allowReserved || false;
    return (0, parameterParsers_1.generateParser)({
        required: self.oaParameter.required,
        style,
        explode,
        allowReserved,
        schema,
    });
}
class Parameter {
    constructor(context, oaParameter) {
        const resOaParameter = (0, oasUtils_1.isReferenceObject)(oaParameter)
            ? context.resolveRef(oaParameter.$ref)
            : oaParameter;
        this.location = {
            in: resOaParameter.in,
            name: resOaParameter.name,
            docPath: context.jsonPointer,
            path: '',
        };
        this.name = resOaParameter.name;
        this.context = context;
        this.oaParameter = resOaParameter;
        this.validate = (value) => ({ errors: null, value });
        // Find the schema for this parameter.
        if (resOaParameter.schema) {
            const schemaContext = context.childContext('schema');
            const schema = (0, jsonSchema_1.extractSchema)(context.openApiDoc, schemaContext.jsonPointer, {
                resolveRef: context.resolveRef.bind(context),
            });
            this.parser = generateSchemaParser(this, schema);
            this.validate = (0, validators_1.generateRequestValidator)(schemaContext, this.location, resOaParameter.required || false, 'application/x-www-form-urlencoded');
        }
        else if (resOaParameter.content) {
            // `parameter.content` must have exactly one key
            const mediaTypeString = Object.keys(resOaParameter.content)[0];
            const oaMediaType = resOaParameter.content[mediaTypeString];
            const mediaTypeContext = context.childContext(['content', mediaTypeString]);
            let parser = context.options.parameterParsers.get(mediaTypeString);
            // OAS3 has special handling for 'application/x-www-form-urlencoded'.
            if (!parser && mediaTypeString === 'application/x-www-form-urlencoded') {
                parser = urlEncodedBodyParser.generateStringParser(mediaTypeContext, oaMediaType, this.location);
            }
            if (!parser) {
                throw new Error('Unable to find suitable mime type parser for ' +
                    `type ${mediaTypeString} in ${context.jsonPointer}/content`);
            }
            // FIXME: We don't handle 'application/x-www-form-urlencoded' here
            // correctly.
            this.parser = (0, parameterParsers_1.generateParser)({
                required: resOaParameter.required || false,
                schema: oaMediaType.schema,
                contentType: mediaTypeString,
                parser,
                uriEncoded: ['query', 'path'].includes(resOaParameter.in),
            });
            if (oaMediaType.schema) {
                this.validate = (0, validators_1.generateRequestValidator)(mediaTypeContext.childContext('schema'), this.location, resOaParameter.required || false, mediaTypeString);
            }
        }
        else {
            throw new Error(`Parameter ${resOaParameter.name} should have a 'schema' or a 'content'`);
        }
    }
}
exports.default = Parameter;
//# sourceMappingURL=Parameter.js.map