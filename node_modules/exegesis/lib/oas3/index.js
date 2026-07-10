"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.OpenApi = void 0;
exports.compile = compile;
const OpenApi_1 = __importDefault(require("./OpenApi"));
exports.OpenApi = OpenApi_1.default;
/**
 * Reads an OpenAPI document from a YAML or JSON file.
 *
 * @param openApiDocFile - The file containing the OpenAPI document.
 * @returns - Returns the parsed OpenAPI document.
 */
function compile(openApiDoc, options) {
    return __awaiter(this, void 0, void 0, function* () {
        return new OpenApi_1.default(openApiDoc, options);
    });
}
//# sourceMappingURL=index.js.map