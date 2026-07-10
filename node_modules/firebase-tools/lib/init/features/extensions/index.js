"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.doSetup = doSetup;
const requirePermissions_1 = require("../../../requirePermissions");
const ensureApiEnabled_1 = require("../../../ensureApiEnabled");
const manifest = require("../../../extensions/manifest");
const api_1 = require("../../../api");
async function doSetup(setup, config, options) {
    const projectId = setup?.rcfile?.projects?.default;
    if (projectId) {
        await (0, requirePermissions_1.requirePermissions)({ ...options, project: projectId });
        await Promise.all([(0, ensureApiEnabled_1.ensure)(projectId, (0, api_1.extensionsOrigin)(), "unused", true)]);
    }
    return manifest.writeEmptyManifest(config, options);
}
