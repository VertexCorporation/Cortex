"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prompt = prompt;
const availability_1 = require("./util/availability");
function prompt(feature, options, fn, isAvailable) {
    return {
        mcp: options,
        fn,
        isAvailable: (ctx) => {
            const isAvailableFunc = isAvailable || (0, availability_1.getDefaultFeatureAvailabilityCheck)(feature);
            return isAvailableFunc(ctx);
        },
    };
}
