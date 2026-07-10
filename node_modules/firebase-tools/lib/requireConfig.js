"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireConfig = requireConfig;
const error_1 = require("./error");
async function requireConfig(options) {
    return new Promise((resolve, reject) => options.config
        ? resolve()
        : reject(options.configError ??
            new error_1.FirebaseError("Not in a Firebase project directory (could not locate firebase.json)")));
}
