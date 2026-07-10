"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const apiv2_1 = require("../apiv2");
const command_1 = require("../command");
const api_1 = require("../api");
const prompt_1 = require("../prompt");
const requireHostingSite_1 = require("../requireHostingSite");
const requirePermissions_1 = require("../requirePermissions");
const utils = require("../utils");
exports.command = new command_1.Command("hosting:disable")
    .description("stop serving web traffic to your Firebase Hosting site")
    .option("-f, --force", "skip confirmation")
    .option("-s, --site <siteName>", "the site to disable")
    .before(requirePermissions_1.requirePermissions, ["firebasehosting.sites.update"])
    .before(requireHostingSite_1.requireHostingSite)
    .action(async (options) => {
    const siteToDisable = options.site;
    const confirmed = await (0, prompt_1.confirm)({
        message: `Are you sure you want to disable Firebase Hosting for the site ${clc.underline(siteToDisable)}\n${clc.underline("This will immediately make your site inaccessible!")}`,
        force: options.force,
        nonInteractive: options.nonInteractive,
    });
    if (!confirmed) {
        return;
    }
    const c = new apiv2_1.Client({ urlPrefix: (0, api_1.hostingApiOrigin)(), apiVersion: "v1beta1", auth: true });
    await c.post(`/sites/${siteToDisable}/releases`, { type: "SITE_DISABLE" });
    utils.logSuccess(`Hosting has been disabled for ${clc.bold(siteToDisable)}. Deploy a new version to re-enable.`);
});
