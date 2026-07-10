"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.invokeController = invokeController;
const promise_breaker_1 = __importDefault(require("promise-breaker"));
const typeUtils_1 = require("../utils/typeUtils");
function invokeController(controllerModule, controller, context) {
    return promise_breaker_1.default.apply(controller, controllerModule, [context]).then((result) => {
        if (!context.res.ended) {
            if (result === undefined || result === null) {
                context.res.end();
            }
            else if (typeof result === 'string' ||
                result instanceof Buffer ||
                (0, typeUtils_1.isReadable)(result)) {
                context.res.setBody(result);
            }
            else if (context.options.treatReturnedJsonAsPure) {
                context.res.pureJson(result);
            }
            else {
                context.res.json(result);
            }
        }
        return result;
    });
}
//# sourceMappingURL=invoke.js.map