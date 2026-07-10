"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const requireAuth_1 = require("../requireAuth");
const error_1 = require("../error");
const utils_1 = require("../utils");
const apphosting = require("../gcp/apphosting");
const apphosting_backends_list_1 = require("./apphosting-backends-list");
exports.command = new command_1.Command("apphosting:backends:get <backend>")
    .description("print info about a Firebase App Hosting backend")
    .before(requireAuth_1.requireAuth)
    .before(apphosting.ensureApiEnabled)
    .action(async (backend, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    let backendsList = [];
    try {
        const resp = await apphosting.listBackends(projectId, "-");
        const allBackends = resp.backends || [];
        backendsList = allBackends.filter((bkd) => bkd.name.split("/").pop() === backend);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to get backend: ${backend}. Please check the parameters you have provided.`, { original: (0, error_1.getError)(err) });
    }
    if (backendsList.length === 0) {
        (0, utils_1.logWarning)(`Backend "${backend}" not found`);
        return;
    }
    if (backendsList.length > 1) {
        const regions = backendsList.map((b) => apphosting.parseBackendName(b.name).location);
        (0, utils_1.logWarning)(`Detected multiple backends with the same ${backend} ID in regions: ${regions.join(", ")}}. This is not allowed until we can support more locations.\n` +
            `Please delete and recreate any backends that share an ID with another backend. ` +
            `Use apphosting:backends:list to see all backends.\n Returning the following backend:`);
    }
    (0, apphosting_backends_list_1.printBackendsTable)(backendsList.slice(0, 1));
    return backendsList[0];
});
