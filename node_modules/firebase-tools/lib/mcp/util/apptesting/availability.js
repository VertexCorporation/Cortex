"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isAppTestingAvailable = isAppTestingAvailable;
const api_1 = require("../../../api");
const appUtils_1 = require("../../../appUtils");
const ensureApiEnabled_1 = require("../../../ensureApiEnabled");
const timeout_1 = require("../../../timeout");
async function isAppTestingAvailable(ctx) {
    const host = ctx.host;
    const projectDir = ctx.config.projectDir;
    const platforms = await (0, appUtils_1.getPlatformsFromFolder)(projectDir);
    const supportedPlatforms = [appUtils_1.Platform.FLUTTER, appUtils_1.Platform.ANDROID, appUtils_1.Platform.IOS];
    if (!platforms.some((p) => supportedPlatforms.includes(p))) {
        host.logger.debug("Found no supported App Testing platforms.");
        return false;
    }
    try {
        return await (0, timeout_1.timeoutFallback)((0, ensureApiEnabled_1.check)(ctx.projectId, (0, api_1.appDistributionOrigin)(), "", true), true, 3000);
    }
    catch (e) {
        return true;
    }
}
