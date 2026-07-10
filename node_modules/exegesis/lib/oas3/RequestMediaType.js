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
const lodash_1 = __importDefault(require("lodash"));
const validators_1 = require("./Schema/validators");
const urlEncodedBodyParser = __importStar(require("./urlEncodedBodyParser"));
function generateAddDefaultParser(parser, def) {
    return {
        parseReq(req, res, next) {
            parser.parseReq(req, res, (err, result) => {
                if (err) {
                    return next(err);
                }
                // TODO: How to test this?  How do you even get here?  If there's
                // no 'content-type' you'll never get to a RequestMediaType in
                // the first place.  If the type is `application/json`, a 0-length
                // body will be invalid.  If the type is `text/plain`, a 0-length
                // body is the empty string, which is not undefined.  I don't
                // think this is ever going to be called.
                if (result === undefined && req.body === undefined) {
                    req.body = lodash_1.default.cloneDeep(def);
                    next(null, req.body);
                }
                else {
                    next(err, result);
                }
            });
        },
    };
}
class RequestMediaType {
    constructor(context, oaMediaType, mediaType, parameterLocation, parameterRequired) {
        this.context = context;
        this.oaMediaType = oaMediaType;
        let parser = this.context.options.bodyParsers.get(mediaType);
        // OAS3 has special handling for 'application/x-www-form-urlencoded'.
        if (!parser && mediaType === 'application/x-www-form-urlencoded') {
            parser = urlEncodedBodyParser.generateBodyParser(context, oaMediaType, parameterLocation);
        }
        if (!parser) {
            throw new Error('Unable to find suitable mime type parser for ' +
                `type ${mediaType} in ${context.jsonPointer}`);
        }
        const schema = oaMediaType.schema && context.resolveRef(oaMediaType.schema);
        if (schema && 'default' in schema) {
            this.parser = generateAddDefaultParser(parser, schema.default);
        }
        else {
            this.parser = parser;
        }
        if (schema) {
            const schemaContext = context.childContext('schema');
            this.validator = (0, validators_1.generateRequestValidator)(schemaContext, parameterLocation, parameterRequired, mediaType);
        }
        else {
            this.validator = (value) => ({ errors: null, value });
        }
    }
}
exports.default = RequestMediaType;
//# sourceMappingURL=RequestMediaType.js.map