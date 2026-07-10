"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.requireHostingSite = requireHostingSite;
const getDefaultHostingSite_1 = require("./getDefaultHostingSite");
async function requireHostingSite(options) {
    if (options.site) {
        return Promise.resolve();
    }
    const site = await (0, getDefaultHostingSite_1.getDefaultHostingSite)(options);
    options.site = site;
}
