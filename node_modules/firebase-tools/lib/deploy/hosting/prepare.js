"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.hasPinnedFunctions = hasPinnedFunctions;
exports.addPinnedFunctionsToOnlyString = addPinnedFunctionsToOnlyString;
exports.prepare = prepare;
exports.unsafePins = unsafePins;
const error_1 = require("../../error");
const api = require("../../hosting/api");
const config = require("../../hosting/config");
const deploymentTool = require("../../deploymentTool");
const clc = require("colorette");
const functional_1 = require("../../functional");
const track_1 = require("../../track");
const utils = require("../../utils");
const backend = require("../functions/backend");
const ensureTargeted_1 = require("../../functions/ensureTargeted");
const frameworks_1 = require("../../frameworks");
function handlePublicDirectoryFlag(options) {
    if (options.public) {
        if (Array.isArray(options.config.get("hosting"))) {
            throw new error_1.FirebaseError("Cannot specify --public option with multi-site configuration.");
        }
        options.config.set("hosting.public", options.public);
    }
}
function hasPinnedFunctions(options) {
    handlePublicDirectoryFlag(options);
    for (const c of config.hostingConfig(options)) {
        for (const r of c.rewrites || []) {
            if ("function" in r && typeof r.function === "object" && r.function.pinTag) {
                return true;
            }
        }
    }
    return false;
}
async function addPinnedFunctionsToOnlyString(context, options) {
    if (!options.only) {
        return false;
    }
    handlePublicDirectoryFlag(options);
    const addedFunctions = [];
    for (const c of config.hostingConfig(options)) {
        const addedFunctionsPerSite = [];
        for (const r of c.rewrites || []) {
            if (!("function" in r) || typeof r.function !== "object" || !r.function.pinTag) {
                continue;
            }
            const endpoint = (await backend.existingBackend(context)).endpoints[r.function.region || "us-central1"]?.[r.function.functionId];
            if (endpoint) {
                options.only = (0, ensureTargeted_1.ensureTargeted)(options.only, endpoint.codebase || "default", endpoint.id);
            }
            else if (c.webFramework) {
                options.only = (0, ensureTargeted_1.ensureTargeted)(options.only, (0, frameworks_1.generateSSRCodebaseId)(c.site), r.function.functionId);
            }
            else {
                options.only = (0, ensureTargeted_1.ensureTargeted)(options.only, r.function.functionId);
            }
            addedFunctionsPerSite.push(r.function.functionId);
        }
        if (addedFunctionsPerSite.length) {
            utils.logLabeledBullet("hosting", "The following function(s) are pinned to site " +
                `${clc.bold(c.site)} and will be deployed as well: ` +
                addedFunctionsPerSite.map(clc.bold).join(","));
            addedFunctions.push(...addedFunctionsPerSite);
        }
    }
    return addedFunctions.length !== 0;
}
async function prepare(context, options) {
    handlePublicDirectoryFlag(options);
    const configs = config.hostingConfig(options);
    if (configs.length === 0) {
        return Promise.resolve();
    }
    const versions = await Promise.all(configs.map(async (config) => {
        await api.getSite(context.projectId, config.site);
        const labels = {
            ...deploymentTool.labels(),
        };
        if (config.webFramework) {
            labels["firebase-web-framework"] = config.webFramework;
        }
        const unsafe = await unsafePins(context, config);
        if (unsafe.length) {
            const msg = `Cannot deploy site ${clc.bold(config.site)} to channel ` +
                `${clc.bold(context.hostingChannel)} because it would modify one or ` +
                `more rewrites in "live" that are not pinned, breaking production. ` +
                `Please pin "live" before pinning other channels.`;
            utils.logLabeledError("Hosting", msg);
            throw new Error(msg);
        }
        const runPins = config.rewrites
            ?.filter((r) => "run" in r && r.run.pinTag)
            ?.map((r) => r.run.serviceId);
        if (runPins?.length) {
            utils.logLabeledBullet("hosting", `The site ${clc.bold(config.site)} will pin rewrites to the current ` +
                `latest revision of service(s) ${runPins.map(clc.bold).join(",")}`);
        }
        const version = {
            status: "CREATED",
            labels,
        };
        const [, versionName] = await Promise.all([
            (0, track_1.trackGA4)("hosting_version", {
                framework: config.webFramework || "classic",
            }),
            api.createVersion(config.site, version),
        ]);
        return versionName;
    }));
    context.hosting = {
        deploys: [],
    };
    for (const [config, version] of configs.map((0, functional_1.zipIn)(versions))) {
        context.hosting.deploys.push({ config, version });
    }
}
function rewriteTarget(source) {
    if ("glob" in source) {
        return source.glob;
    }
    else if ("source" in source) {
        return source.source;
    }
    else if ("regex" in source) {
        return source.regex;
    }
    else {
        (0, functional_1.assertExhaustive)(source);
    }
}
async function unsafePins(context, config) {
    if ((context.hostingChannel || "live") === "live") {
        return [];
    }
    const targetTaggedRewrites = {};
    for (const rewrite of config.rewrites || []) {
        const target = rewriteTarget(rewrite);
        if ("run" in rewrite && rewrite.run.pinTag) {
            targetTaggedRewrites[target] = `${rewrite.run.region || "us-central1"}/${rewrite.run.serviceId}`;
        }
        if ("function" in rewrite && typeof rewrite.function === "object" && rewrite.function.pinTag) {
            const region = rewrite.function.region || "us-central1";
            const endpoint = (await backend.existingBackend(context)).endpoints[region]?.[rewrite.function.functionId];
            if (!endpoint) {
                continue;
            }
            targetTaggedRewrites[target] = `${region}/${endpoint.runServiceId || endpoint.id}`;
        }
    }
    if (!Object.keys(targetTaggedRewrites).length) {
        return [];
    }
    const channelConfig = await api.getChannel(context.projectId, config.site, "live");
    const existingUntaggedRewrites = {};
    for (const rewrite of channelConfig?.release?.version?.config?.rewrites || []) {
        if ("run" in rewrite && !rewrite.run.tag) {
            existingUntaggedRewrites[rewriteTarget(rewrite)] =
                `${rewrite.run.region}/${rewrite.run.serviceId}`;
        }
    }
    return Object.keys(targetTaggedRewrites).filter((target) => targetTaggedRewrites[target] === existingUntaggedRewrites[target]);
}
