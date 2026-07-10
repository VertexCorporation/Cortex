"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const requireInteractive_1 = require("../requireInteractive");
const backend_1 = require("../apphosting/backend");
const apphosting_1 = require("../gcp/apphosting");
const firedata_1 = require("../gcp/firedata");
const requireTosAcceptance_1 = require("../requireTosAcceptance");
exports.command = new command_1.Command("apphosting:repos:create")
    .description("create a Firebase App Hosting Developer Connect Git Repository Link")
    .option("-l, --location <location>", "specify the location of the backend", "")
    .option("-g, --gitconnection <connection>", "id of the connection", "")
    .before(apphosting_1.ensureApiEnabled)
    .before(requireInteractive_1.default)
    .before((0, requireTosAcceptance_1.requireTosAcceptance)(firedata_1.APPHOSTING_TOS_ID))
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const location = options.location;
    const connection = options.gitconnection;
    await (0, backend_1.createGitRepoLink)(projectId, location, connection);
});
