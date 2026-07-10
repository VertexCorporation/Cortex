"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const lodash_1 = __importDefault(require("lodash"));
const json_schema_resolve_ref_1 = require("../utils/json-schema-resolve-ref");
class SecuritySchemes {
    constructor(openApiDoc) {
        const securitySchemes = (openApiDoc.components && openApiDoc.components.securitySchemes) || {};
        this._securitySchemes = securitySchemes.ref
            ? (0, json_schema_resolve_ref_1.resolveRef)(openApiDoc, securitySchemes)
            : securitySchemes;
        this._challenges = lodash_1.default.mapValues(this._securitySchemes, (scheme) => {
            if (scheme.type === 'http') {
                return scheme.scheme || 'Basic';
            }
            if (scheme.type === 'oauth2' || scheme.type === 'openIdConnect') {
                return 'Bearer';
            }
            return undefined;
        });
        this._infos = lodash_1.default.mapValues(this._securitySchemes, (scheme) => {
            if (scheme.type === 'apiKey') {
                return {
                    in: scheme.in,
                    name: scheme.name,
                };
            }
            else if (scheme.type === 'http') {
                return {
                    scheme: scheme.scheme,
                };
            }
            else {
                return {};
            }
        });
    }
    getChallenge(schemeName) {
        return this._challenges[schemeName];
    }
    getInfo(schemeName) {
        return this._infos[schemeName];
    }
}
exports.default = SecuritySchemes;
//# sourceMappingURL=SecuritySchemes.js.map