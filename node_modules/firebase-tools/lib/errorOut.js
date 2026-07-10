"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.errorOut = errorOut;
const logError_1 = require("./logError");
const error_1 = require("./error");
function errorOut(error) {
    let fbError;
    if (error instanceof error_1.FirebaseError) {
        fbError = error;
    }
    else {
        fbError = new error_1.FirebaseError("An unexpected error has occurred.", {
            original: error,
            exit: 2,
        });
    }
    (0, logError_1.logError)(fbError);
    process.exitCode = fbError.exit || 2;
    setTimeout(() => {
        process.exit();
    }, 250);
}
