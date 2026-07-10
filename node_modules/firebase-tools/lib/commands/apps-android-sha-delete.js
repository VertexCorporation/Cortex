"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const apps_1 = require("../management/apps");
const requireAuth_1 = require("../requireAuth");
const utils_1 = require("../utils");
exports.command = new command_1.Command("apps:android:sha:delete <appId> <shaId>")
    .description("delete a SHA certificate hash for a given app id")
    .before(requireAuth_1.requireAuth)
    .action(async (appId = "", shaId = "", options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    await (0, utils_1.promiseWithSpinner)(async () => await (0, apps_1.deleteAppAndroidSha)(projectId, appId, shaId), `Deleting Android SHA certificate hash with SHA id ${clc.bold(shaId)} and Android app Id ${clc.bold(appId)}`);
});
