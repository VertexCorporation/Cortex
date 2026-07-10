"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.findEndpointForRewrite = findEndpointForRewrite;
exports.convertConfig = convertConfig;
const error_1 = require("../../error");
const backend = require("../functions/backend");
const utils_1 = require("../../utils");
const proto = require("../../gcp/proto");
const colorette_1 = require("colorette");
const runTags = require("../../hosting/runTags");
const functional_1 = require("../../functional");
const experiments = require("../../experiments");
const logger_1 = require("../../logger");
function extractPattern(type, source) {
    let glob;
    let regex;
    if ("source" in source) {
        glob = source.source;
    }
    if ("glob" in source) {
        glob = source.glob;
    }
    if ("regex" in source) {
        regex = source.regex;
    }
    if (glob && regex) {
        throw new error_1.FirebaseError(`Cannot specify a ${type} pattern with both a glob and regex.`);
    }
    else if (glob) {
        return { glob };
    }
    else if (regex) {
        return { regex };
    }
    throw new error_1.FirebaseError(`Cannot specify a ${type} with no pattern (either a glob or regex required).`);
}
function findEndpointForRewrite(site, targetBackend, id, region) {
    const endpoints = backend.allEndpoints(targetBackend).filter((e) => e.id === id);
    if (endpoints.length === 0) {
        return { matchingEndpoint: undefined, foundMatchingId: false };
    }
    if (endpoints.length === 1) {
        if (region && region !== endpoints[0].region) {
            return { matchingEndpoint: undefined, foundMatchingId: true };
        }
        return { matchingEndpoint: endpoints[0], foundMatchingId: true };
    }
    if (!region) {
        const us = endpoints.find((e) => e.region === "us-central1");
        if (!us) {
            throw new error_1.FirebaseError(`More than one backend found for function name: ${id}. If the function is deployed in multiple regions, you must specify a region.`);
        }
        (0, utils_1.logLabeledBullet)(`hosting[${site}]`, `Function \`${id}\` found in multiple regions, defaulting to \`us-central1\`. ` +
            `To rewrite to a different region, specify a \`region\` for the rewrite in \`firebase.json\`.`);
        return { matchingEndpoint: us, foundMatchingId: true };
    }
    return {
        matchingEndpoint: endpoints.find((e) => e.region === region),
        foundMatchingId: true,
    };
}
async function convertConfig(context, functionsPayload, deploy) {
    const config = {};
    const hasBackends = !!deploy.config.rewrites?.some((r) => "function" in r || "run" in r);
    const wantBackend = backend.merge(...Object.values(functionsPayload.functions || {}).map((c) => c.wantBackend));
    let haveBackend = backend.empty();
    if (hasBackends) {
        try {
            haveBackend = await backend.existingBackend(context);
        }
        catch (err) {
            if (err instanceof error_1.FirebaseError) {
                if (err.status === 403) {
                    logger_1.logger.debug(`Deploying hosting site ${deploy.config.site}, did not have permissions to check for backends: `, err);
                }
            }
            else {
                throw err;
            }
        }
    }
    config.rewrites = deploy.config.rewrites?.map((rewrite) => {
        const target = extractPattern("rewrite", rewrite);
        if ("destination" in rewrite) {
            return {
                ...target,
                path: rewrite.destination,
            };
        }
        if ("function" in rewrite) {
            if (typeof rewrite.function === "string") {
                throw new error_1.FirebaseError("Expected firebase config to be normalized, but got legacy functions format");
            }
            const id = rewrite.function.functionId;
            const region = rewrite.function.region;
            const deployingEndpointSearch = findEndpointForRewrite(deploy.config.site, wantBackend, id, region);
            const existingEndpointSearch = !deployingEndpointSearch.foundMatchingId && !deployingEndpointSearch.matchingEndpoint
                ? findEndpointForRewrite(deploy.config.site, haveBackend, id, region)
                : undefined;
            const endpoint = deployingEndpointSearch.matchingEndpoint
                ? deployingEndpointSearch.matchingEndpoint
                : existingEndpointSearch?.matchingEndpoint;
            if (!endpoint) {
                if (deployingEndpointSearch.foundMatchingId || existingEndpointSearch?.foundMatchingId) {
                    throw new error_1.FirebaseError(`Unable to find a valid endpoint for function. Functions matching the rewrite
  are present but in the wrong region.`);
                }
                (0, utils_1.logLabeledWarning)(`hosting[${deploy.config.site}]`, `Unable to find a valid endpoint for function \`${id}\`, but still including it in the config`);
                const apiRewrite = { ...target, function: id };
                if (region) {
                    apiRewrite.functionRegion = region;
                }
                return apiRewrite;
            }
            if (endpoint.platform === "gcfv1") {
                if (!backend.isHttpsTriggered(endpoint) && !backend.isCallableTriggered(endpoint)) {
                    throw new error_1.FirebaseError(`Function ${endpoint.id} is a 1st gen function and therefore must be an https function type`);
                }
                if (rewrite.function.pinTag) {
                    throw new error_1.FirebaseError(`Function ${endpoint.id} is a 1st gen function and therefore does not support the ${(0, colorette_1.bold)("pinTag")} option`);
                }
                return {
                    ...target,
                    function: endpoint.id,
                    functionRegion: endpoint.region,
                };
            }
            const apiRewrite = {
                ...target,
                run: {
                    serviceId: endpoint.runServiceId ?? endpoint.id,
                    region: endpoint.region,
                },
            };
            if (rewrite.function.pinTag) {
                if (endpoint.minInstances) {
                    throw new error_1.FirebaseError(`Function ${endpoint.id} has minInstances set and is in a rewrite ` +
                        "pinTags=true. These features are not currently compatible with each " +
                        "other.");
                }
                experiments.assertEnabled("pintags", "pin a function version");
                apiRewrite.run.tag = runTags.TODO_TAG_NAME;
            }
            return apiRewrite;
        }
        if ("dynamicLinks" in rewrite) {
            if (!rewrite.dynamicLinks) {
                throw new error_1.FirebaseError("Can only set dynamicLinks to true in a rewrite");
            }
            return { ...target, dynamicLinks: true };
        }
        if ("run" in rewrite) {
            const apiRewrite = {
                ...target,
                run: {
                    serviceId: rewrite.run.serviceId,
                    region: rewrite.run.region || "us-central1",
                },
            };
            if (rewrite.run.pinTag) {
                experiments.assertEnabled("pintags", "pin to a run service revision");
                apiRewrite.run.tag = runTags.TODO_TAG_NAME;
            }
            return apiRewrite;
        }
        try {
            (0, functional_1.assertExhaustive)(rewrite);
        }
        catch (e) {
            throw new error_1.FirebaseError("Invalid hosting rewrite config in firebase.json. " +
                "A rewrite config must specify 'destination', 'function', 'dynamicLinks', or 'run'");
        }
    });
    if (config.rewrites) {
        const versionId = (0, utils_1.last)(deploy.version.split("/"));
        await runTags.setRewriteTags(config.rewrites, context.projectId, versionId);
    }
    config.redirects = deploy.config.redirects?.map((redirect) => {
        const apiRedirect = {
            ...extractPattern("redirect", redirect),
            location: redirect.destination,
        };
        if (redirect.type) {
            apiRedirect.statusCode = redirect.type;
        }
        return apiRedirect;
    });
    config.headers = deploy.config.headers?.map((header) => {
        const headers = {};
        for (const { key, value } of header.headers || []) {
            headers[key] = value;
        }
        return {
            ...extractPattern("header", header),
            headers,
        };
    });
    proto.copyIfPresent(config, deploy.config, "cleanUrls", "appAssociation", "i18n");
    proto.convertIfPresent(config, deploy.config, "trailingSlashBehavior", "trailingSlash", (b) => b ? "ADD" : "REMOVE");
    proto.pruneUndefiends(config);
    return config;
}
