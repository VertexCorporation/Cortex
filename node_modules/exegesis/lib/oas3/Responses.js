"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const Response_1 = __importDefault(require("./Response"));
class Responses {
    constructor(context, responses) {
        this.context = context;
        this._location = {
            in: 'response',
            name: 'body',
            docPath: this.context.jsonPointer,
        };
        this._responses = {};
        for (const statusCode of Object.keys(responses)) {
            const response = context.resolveRef(responses[statusCode]);
            this._responses[statusCode] = new Response_1.default(context.childContext(statusCode), response);
        }
    }
    validateResponse(statusCode, headers, body, validateDefaultResponses) {
        const responseObject = this._responses[statusCode] || this._responses.default;
        if (!responseObject) {
            return {
                errors: [
                    {
                        location: this._location,
                        message: `No response defined for status code ${statusCode}.`,
                    },
                ],
                isDefault: false,
            };
        }
        else {
            const isDefault = !this._responses[statusCode];
            if (isDefault && !validateDefaultResponses) {
                return { errors: null, isDefault };
            }
            else {
                return {
                    errors: responseObject.validateResponse(statusCode, headers, body),
                    isDefault,
                };
            }
        }
    }
}
exports.default = Responses;
//# sourceMappingURL=Responses.js.map