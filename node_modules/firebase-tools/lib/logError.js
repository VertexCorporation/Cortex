"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.logError = logError;
const logger_1 = require("./logger");
const clc = require("colorette");
function logError(error) {
    if (error.children && error.children.length) {
        logger_1.logger.error(clc.bold(clc.red("Error:")), clc.underline(error.message) + ":");
        error.children.forEach((child) => {
            let out = "- ";
            if (child.name) {
                out += clc.bold(child.name) + " ";
            }
            out += child.message;
            logger_1.logger.error(out);
        });
    }
    else {
        if (error.original) {
            logger_1.logger.debug(error.original.stack);
        }
        logger_1.logger.error();
        logger_1.logger.error(clc.bold(clc.red("Error:")), error.message);
    }
    if (error.context) {
        logger_1.logger.debug("Error Context:", JSON.stringify(error.context, undefined, 2));
    }
}
