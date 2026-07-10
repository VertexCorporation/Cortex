"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = requireInteractive;
const error_1 = require("./error");
function requireInteractive(options) {
    if (options.nonInteractive) {
        return Promise.reject(new error_1.FirebaseError("This command cannot run in non-interactive mode", {
            exit: 1,
        }));
    }
    return Promise.resolve();
}
