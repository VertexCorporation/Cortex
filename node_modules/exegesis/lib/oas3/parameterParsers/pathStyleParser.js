"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.generatePathStyleParser = generatePathStyleParser;
const querystring_1 = __importDefault(require("querystring"));
const structuredParser_1 = require("./structuredParser");
function parsePathParameter(location, value, structuredParser) {
    if (value.startsWith(';')) {
        value = value.slice(1);
    }
    const queryParsedValue = querystring_1.default.parse(value, ';', '=', {
        decodeURIComponent: (val) => val,
    });
    return structuredParser(location, queryParsedValue, value, {});
}
function generatePathStyleParser(schema, explode) {
    const structuredParser = (0, structuredParser_1.generateStructuredParser)(schema, explode);
    return function pathStyleParser(location, rawParamValues) {
        const value = rawParamValues[location.name];
        let answer;
        if (value === null || value === undefined) {
            answer = value;
        }
        else if (Array.isArray(value)) {
            // This will never happen, since "matrix" parameters are only
            // allowed in the path, and no one is going to define some
            // crazy path like "/foo/{bar}/{bar}".
            answer = value.map((v) => parsePathParameter(location, v, structuredParser));
        }
        else {
            answer = parsePathParameter(location, value, structuredParser);
        }
        return answer;
    };
}
//# sourceMappingURL=pathStyleParser.js.map