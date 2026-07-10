"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prepare = prepare;
const apps_1 = require("../../management/apps");
const logger_1 = require("../../logger");
const projectUtils_1 = require("../../projectUtils");
async function prepare(context, options) {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const config = options.config.src.auth;
    if (!config) {
        return;
    }
    const apps = await (0, apps_1.listFirebaseApps)(projectId, apps_1.AppPlatform.WEB);
    let app = apps.find((a) => a.displayName === "Default Web App");
    if (!app && apps.length > 0) {
        app = apps[0];
    }
    if (!app) {
        logger_1.logger.info("No Firebase Web App found. Creating 'Default Web App' for Auth provisioning...");
        app = await (0, apps_1.createWebApp)(projectId, {
            displayName: "Default Web App",
        });
    }
    context.auth = context.auth || {};
    context.auth.appId = app.appId;
}
