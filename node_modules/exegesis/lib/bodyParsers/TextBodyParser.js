"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const body_parser_1 = __importDefault(require("body-parser"));
class TextBodyParser {
    constructor(maxBodySize) {
        // FIXME: https://github.com/expressjs/body-parser/issues/304
        this._bodyParserMiddlware = body_parser_1.default.text({
            inflate: true,
            limit: maxBodySize,
            type: '*/*',
        });
    }
    parseString(value) {
        return value;
    }
    parseReq(req, res, done) {
        this._bodyParserMiddlware(req, res, done);
    }
}
exports.default = TextBodyParser;
//# sourceMappingURL=TextBodyParser.js.map