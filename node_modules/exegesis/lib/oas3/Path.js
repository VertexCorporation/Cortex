"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.HTTP_METHODS = void 0;
const Operation_1 = __importDefault(require("./Operation"));
const Parameter_1 = __importDefault(require("./Parameter"));
const extensions_1 = require("./extensions");
// CONNECT not included, as it is not valid for OpenAPI 3.0.1.
exports.HTTP_METHODS = [
    'get',
    'head',
    'post',
    'put',
    'delete',
    'options',
    'trace',
    'patch',
];
class Path {
    constructor(context, oaPath, exegesisController) {
        this.context = context;
        if (oaPath.$ref) {
            this.oaPath = context.resolveRef(oaPath.$ref);
        }
        else {
            this.oaPath = oaPath;
        }
        const parameters = (oaPath.parameters || []).map((p, i) => new Parameter_1.default(context.childContext(['parameters', '' + i]), p));
        exegesisController = oaPath[extensions_1.EXEGESIS_CONTROLLER] || exegesisController;
        this._operations = exports.HTTP_METHODS.reduce((result, method) => {
            const operation = oaPath[method];
            if (operation) {
                result[method] = new Operation_1.default(context.childContext(method), operation, oaPath, method, exegesisController, parameters);
            }
            return result;
        }, Object.create(null));
    }
    getOperation(method) {
        return this._operations[method.toLowerCase()];
    }
}
exports.default = Path;
//# sourceMappingURL=Path.js.map