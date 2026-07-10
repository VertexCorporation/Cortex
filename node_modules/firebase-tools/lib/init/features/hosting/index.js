"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.askQuestions = askQuestions;
exports.actuate = actuate;
const clc = require("colorette");
const path_1 = require("path");
const apiv2_1 = require("../../../apiv2");
const frameworks_1 = require("../../../frameworks");
const github = require("./github");
const prompt_1 = require("../../../prompt");
const logger_1 = require("../../../logger");
const getDefaultHostingSite_1 = require("../../../getDefaultHostingSite");
const utils_1 = require("../../../utils");
const interactive_1 = require("../../../hosting/interactive");
const templates_1 = require("../../../templates");
const error_1 = require("../../../error");
const api_1 = require("../../../hosting/api");
const INDEX_TEMPLATE = (0, templates_1.readTemplateSync)("init/hosting/index.html");
const MISSING_TEMPLATE = (0, templates_1.readTemplateSync)("init/hosting/404.html");
const DEFAULT_IGNORES = ["firebase.json", "**/.*", "**/node_modules/**"];
async function askQuestions(setup, config, options) {
    var _a, _b;
    const discoveredFramework = await (0, frameworks_1.discover)(config.projectDir, false);
    if (discoveredFramework && discoveredFramework.mayWantBackend) {
        const frameworkName = frameworks_1.WebFrameworks[discoveredFramework.framework]?.name ?? discoveredFramework.framework;
        switch (discoveredFramework.framework) {
            case "next":
            case "angular":
            case "nuxt":
            case "nuxt2":
            case "express":
            case "svelekit":
            case "sveltekit":
                logger_1.logger.info();
                const useAppHosting = await (0, prompt_1.confirm)({
                    message: `Detected a ${frameworkName} codebase with SSR features. We can't guarantee that ` +
                        `this site will work on Firebase Hosting, which is optimized for static sites. Another ` +
                        `product, Firebase App Hosting, was designed for SSR web apps. Would ` +
                        `you like to use App Hosting instead? Learn more here: ` +
                        `https://firebase.google.com/docs/app-hosting/product-comparison#hostings`,
                    default: true,
                });
                if (useAppHosting) {
                    setup.featureInfo || (setup.featureInfo = {});
                    setup.featureInfo.hosting = { redirectToAppHosting: true };
                    setup.features?.unshift("apphosting");
                    return;
                }
                break;
            default:
                logger_1.logger.info();
                logger_1.logger.info(`Detected a ${frameworkName} codebase with SSR features. We can't guarantee that ` +
                    `this site will work on Firebase Hosting, which is optimized for static sites. Another ` +
                    `product, Firebase App Hosting, was designed for SSR web apps.`);
                logger_1.logger.info(`Learn about App Hosting here: https://firebase.google.com/docs/app-hosting/product-comparison#hostings`);
                logger_1.logger.info(`Learn how to deploy frameworks with App Hosting here: https://firebase.blog/posts/2025/06/app-hosting-frameworks/`);
                const continueWithHosting = await (0, prompt_1.confirm)({
                    message: `Would you like to continue setting up Firebase Hosting?`,
                    default: false,
                });
                if (!continueWithHosting) {
                    throw new error_1.FirebaseError("Hosting initialization cancelled.", { exit: 1 });
                }
                break;
        }
    }
    setup.featureInfo = setup.featureInfo || {};
    setup.featureInfo.hosting = {};
    if (setup.projectId) {
        let hasHostingSite = true;
        try {
            await (0, getDefaultHostingSite_1.getDefaultHostingSite)({ projectId: setup.projectId });
        }
        catch (err) {
            if (err !== getDefaultHostingSite_1.errNoDefaultSite) {
                throw err;
            }
            hasHostingSite = false;
        }
        if (!hasHostingSite &&
            (await (0, prompt_1.confirm)({
                message: "A Firebase Hosting site is required to deploy. Would you like to create one now?",
                default: true,
            }))) {
            const createOptions = {
                projectId: setup.projectId,
                nonInteractive: options.nonInteractive,
            };
            setup.featureInfo.hosting.newSiteId = await (0, interactive_1.pickHostingSiteName)("", createOptions);
        }
    }
    logger_1.logger.info();
    logger_1.logger.info(`Your ${clc.bold("public")} directory is the folder (relative to your project directory) that`);
    logger_1.logger.info(`will contain Hosting assets to be uploaded with ${clc.bold("firebase deploy")}. If you`);
    logger_1.logger.info("have a build process for your assets, use your build's output directory.");
    logger_1.logger.info();
    (_a = setup.featureInfo.hosting).public ?? (_a.public = await (0, prompt_1.input)({
        message: "What do you want to use as your public directory?",
        default: "public",
    }));
    (_b = setup.featureInfo.hosting).spa ?? (_b.spa = await (0, prompt_1.confirm)("Configure as a single-page app (rewrite all urls to /index.html)?"));
    if (await (0, prompt_1.confirm)("Set up automatic builds and deploys with GitHub?")) {
        return github.initGitHub(setup);
    }
}
async function actuate(setup, config, options) {
    const hostingInfo = setup.featureInfo?.hosting;
    if (!hostingInfo) {
        throw new error_1.FirebaseError("Could not find hosting info in setup.featureInfo.hosting. This should not happen.", { exit: 2 });
    }
    if (hostingInfo.redirectToAppHosting) {
        return;
    }
    if (hostingInfo.newSiteId && setup.projectId) {
        await (0, api_1.createSite)(setup.projectId, hostingInfo.newSiteId);
        logger_1.logger.info();
        (0, utils_1.logSuccess)(`Firebase Hosting site ${hostingInfo.newSiteId} created!`);
        logger_1.logger.info();
    }
    setup.config.hosting = {
        public: hostingInfo.public,
        ignore: DEFAULT_IGNORES,
    };
    if (hostingInfo.spa) {
        setup.config.hosting.rewrites = [{ source: "**", destination: "/index.html" }];
    }
    else {
        await config.askWriteProjectFile((0, path_1.join)(hostingInfo.public ?? "public", "404.html"), MISSING_TEMPLATE, !!options.force);
    }
    const c = new apiv2_1.Client({ urlPrefix: "https://www.gstatic.com", auth: false });
    const response = await c.get("/firebasejs/releases.json");
    await config.askWriteProjectFile((0, path_1.join)(hostingInfo.public ?? "public", "index.html"), INDEX_TEMPLATE.replace(/{{VERSION}}/g, response.body.current.version), !!options.force);
}
