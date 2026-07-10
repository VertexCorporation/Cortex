"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.isSpecificationExtension = isSpecificationExtension;
exports.isReferenceObject = isReferenceObject;
exports.contentToRequestMediaTypeRegistry = contentToRequestMediaTypeRegistry;
const mime_1 = require("../../utils/mime");
const RequestMediaType_1 = __importDefault(require("../RequestMediaType"));
function isSpecificationExtension(key) {
    return key.startsWith('x-');
}
function isReferenceObject(obj) {
    return !!obj.$ref;
}
/**
 *
 * @param openApiDoc - The openApiDocument this `content` object is from.
 * @param path - The path to the `content` object.
 * @param content - The `content` object.
 */
function contentToRequestMediaTypeRegistry(context, parameterLocation, parameterRequired, content) {
    const answer = new mime_1.MimeTypeRegistry();
    if (content) {
        for (const mediaType of Object.keys(content)) {
            const oaMediaType = content[mediaType];
            answer.set(mediaType, new RequestMediaType_1.default(context.childContext(mediaType), oaMediaType, mediaType, parameterLocation, parameterRequired));
        }
    }
    return answer;
}
//# sourceMappingURL=index.js.map