"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.filterOnly = filterOnly;
exports.filterExcept = filterExcept;
exports.extract = extract;
exports.validate = validate;
exports.resolveTargets = resolveTargets;
exports.normalize = normalize;
exports.hostingConfig = hostingConfig;
const colorette_1 = require("colorette");
const utils_1 = require("../utils");
const error_1 = require("../error");
const functional_1 = require("../functional");
const fsutils_1 = require("../fsutils");
const projectPath_1 = require("../projectPath");
const path = require("node:path");
const logger_1 = require("../logger");
function matchingConfigs(configs, targets, assertMatches) {
    const matches = [];
    const [hasSite, hasTarget] = (0, functional_1.partition)(configs, (c) => "site" in c);
    for (const target of targets) {
        const siteMatch = hasSite.find((c) => c.site === target);
        const targetMatch = hasTarget.find((c) => c.target === target);
        if (siteMatch) {
            matches.push(siteMatch);
        }
        else if (targetMatch) {
            matches.push(targetMatch);
        }
        else if (assertMatches) {
            throw new error_1.FirebaseError(`Hosting site or target ${(0, colorette_1.bold)(target)} not detected in firebase.json`);
        }
    }
    return matches;
}
function filterOnly(configs, onlyString) {
    if (!onlyString) {
        return configs;
    }
    let onlyTargets = onlyString.split(",");
    if (onlyTargets.includes("hosting")) {
        return configs;
    }
    onlyTargets = onlyTargets
        .filter((target) => target.startsWith("hosting:"))
        .map((target) => target.replace("hosting:", ""));
    return matchingConfigs(configs, onlyTargets, true);
}
function filterExcept(configs, exceptOption) {
    if (!exceptOption) {
        return configs;
    }
    const exceptTargets = exceptOption.split(",");
    if (exceptTargets.includes("hosting")) {
        return [];
    }
    const exceptValues = exceptTargets
        .filter((t) => t.startsWith("hosting:"))
        .map((t) => t.replace("hosting:", ""));
    const toReject = matchingConfigs(configs, exceptValues, false);
    return configs.filter((c) => !toReject.find((r) => c.site === r.site && c.target === r.target));
}
function extract(options) {
    const config = options.config.src;
    if (!config.hosting) {
        return [];
    }
    const assertOneTarget = (config) => {
        if (config.target && config.site) {
            throw new error_1.FirebaseError(`Hosting configs should only include either "site" or "target", not both.`);
        }
    };
    if (!Array.isArray(config.hosting)) {
        const res = (0, utils_1.cloneDeep)(config.hosting);
        if (!res.target && !res.site) {
            res.site = options.site;
        }
        assertOneTarget(res);
        return [res];
    }
    else {
        config.hosting.forEach(assertOneTarget);
        return (0, utils_1.cloneDeep)(config.hosting);
    }
}
function validate(configs, options) {
    for (const config of configs) {
        validateOne(config, options);
    }
}
function validateOne(config, options) {
    const hasAnyStaticRewrites = !!config.rewrites?.find((rw) => "destination" in rw);
    const hasAnyDynamicRewrites = !!config.rewrites?.find((rw) => !("destination" in rw));
    const hasAnyRedirects = !!config.redirects?.length;
    if (config.source && config.public) {
        throw new error_1.FirebaseError('Can only specify "source" or "public" in a Hosting config, not both');
    }
    const root = config.source || config.public;
    if (!root && hasAnyStaticRewrites) {
        throw new error_1.FirebaseError(`Must supply a "public" or "source" directory when using "destination" rewrites.`);
    }
    if (!root && !hasAnyDynamicRewrites && !hasAnyRedirects) {
        throw new error_1.FirebaseError(`Must supply a "public" or "source" directory or at least one rewrite or redirect in each "hosting" config.`);
    }
    if (root && !(0, fsutils_1.dirExistsSync)((0, projectPath_1.resolveProjectPath)(options, root))) {
        logger_1.logger.debug(`Specified "${config.source ? "source" : "public"}" directory "${root}" does not exist; Deploy to Hosting site "${config.site || config.target || ""}" may fail or be empty.`);
    }
    const regionWithoutFunction = (rewrite) => typeof rewrite.region === "string" && typeof rewrite.function !== "string";
    const violation = config.rewrites?.find(regionWithoutFunction);
    if (violation) {
        throw new error_1.FirebaseError("Rewrites only support 'region' as a top-level field when 'function' is set as a string");
    }
    if (config.i18n) {
        if (!root) {
            throw new error_1.FirebaseError(`Must supply a "public" or "source" directory when using "i18n" configuration.`);
        }
        if (!config.i18n.root) {
            throw new error_1.FirebaseError('Must supply a "root" in "i18n" config.');
        }
        const i18nPath = path.join(root, config.i18n.root);
        if (!(0, fsutils_1.dirExistsSync)((0, projectPath_1.resolveProjectPath)(options, i18nPath))) {
            (0, utils_1.logLabeledWarning)("hosting", `Couldn't find specified i18n root directory ${(0, colorette_1.bold)(config.i18n.root)} in public directory ${(0, colorette_1.bold)(root)}`);
        }
    }
}
function resolveTargets(configs, options) {
    return configs.map((config) => {
        const newConfig = (0, utils_1.cloneDeep)(config);
        if (config.site) {
            return newConfig;
        }
        if (!config.target) {
            throw new error_1.FirebaseError("Assertion failed: resolving hosting target of a site with no site name " +
                "or target name. This should have caused an error earlier", { exit: 2 });
        }
        if (!options.project) {
            throw new error_1.FirebaseError("Assertion failed: options.project is not set. Commands depending on hosting.config should use requireProject", { exit: 2 });
        }
        const matchingTargets = options.rc.requireTarget(options.project, "hosting", config.target);
        if (matchingTargets.length > 1) {
            throw new error_1.FirebaseError(`Hosting target ${(0, colorette_1.bold)(config.target)} is linked to multiple sites, ` +
                `but only one is permitted. ` +
                `To clear, run:\n\n  ${(0, colorette_1.bold)(`firebase target:clear hosting ${config.target}`)}`);
        }
        newConfig.site = matchingTargets[0];
        return newConfig;
    });
}
function isLegacyFunctionsRewrite(rewrite) {
    return "function" in rewrite && typeof rewrite.function === "string";
}
function normalize(configs) {
    for (const config of configs) {
        config.rewrites = config.rewrites?.map((rewrite) => {
            if (!("function" in rewrite)) {
                return rewrite;
            }
            if (isLegacyFunctionsRewrite(rewrite)) {
                const modern = {
                    ...rewrite,
                    function: {
                        functionId: rewrite.function,
                    },
                };
                delete modern.region;
                if ("region" in rewrite && typeof rewrite.region === "string") {
                    modern.function.region = rewrite.region;
                }
                if (rewrite.region) {
                    modern.function.region = rewrite.region;
                }
                return modern;
            }
            return rewrite;
        });
    }
}
function hostingConfig(options) {
    if (!options.normalizedHostingConfig) {
        let configs = extract(options);
        configs = filterOnly(configs, options.only);
        configs = filterExcept(configs, options.except);
        normalize(configs);
        validate(configs, options);
        const resolved = resolveTargets(configs, options);
        options.normalizedHostingConfig = resolved;
    }
    return options.normalizedHostingConfig;
}
