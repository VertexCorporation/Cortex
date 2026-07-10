"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const content_type_1 = __importDefault(require("content-type"));
const raw_body_1 = __importDefault(require("raw-body"));
const httpUtils_1 = require("../utils/httpUtils");
class BodyParserWrapper {
    constructor(parser, maxBodySize) {
        this._parser = parser;
        this._maxBodySize = maxBodySize;
    }
    parseString(value) {
        return this._parser.parseString(value);
    }
    parseReq(req, _res, done) {
        if (req.body) {
            // Already parsed;
            return done();
        }
        // Make sure we have a body to parse
        if (!(0, httpUtils_1.httpHasBody)(req.headers)) {
            return done();
        }
        // Work out the encoding
        let encoding = 'utf-8';
        const parsedContentType = content_type_1.default.parse(req);
        if (parsedContentType && parsedContentType.parameters) {
            encoding = (parsedContentType.parameters.encoding || encoding).toLowerCase();
        }
        // Read the body
        (0, raw_body_1.default)(req, { limit: this._maxBodySize, encoding }, (err, str) => {
            if (err) {
                return done(err);
            }
            req.body = this._parser.parseString(str);
            done(null, req.body);
        });
    }
}
exports.default = BodyParserWrapper;
//# sourceMappingURL=BodyParserWrapper.js.map