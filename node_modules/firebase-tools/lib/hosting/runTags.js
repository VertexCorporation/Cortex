"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.TODO_TAG_NAME = void 0;
exports.gcTagsForServices = gcTagsForServices;
exports.setGarbageCollectionThreshold = setGarbageCollectionThreshold;
exports.setRewriteTags = setRewriteTags;
exports.ensureLatestRevisionTagged = ensureLatestRevisionTagged;
const node_path_1 = require("node:path");
const run = require("../gcp/run");
const api = require("./api");
const error_1 = require("../error");
const functional_1 = require("../functional");
exports.TODO_TAG_NAME = "this is an invalid tag name so it cannot be real";
async function gcTagsForServices(project, services) {
    const validTagsByServiceByRegion = {};
    const sites = await api.listSites(project);
    const allVersionsNested = await Promise.all(sites.map((site) => api.listVersions(node_path_1.posix.basename(site.name))));
    const activeVersions = [...(0, functional_1.flattenArray)(allVersionsNested)].filter((version) => {
        return version.status === "CREATED" || version.status === "FINALIZED";
    });
    for (const version of activeVersions) {
        for (const rewrite of version?.config?.rewrites || []) {
            if (!("run" in rewrite) || !rewrite.run.tag) {
                continue;
            }
            validTagsByServiceByRegion[rewrite.run.region] =
                validTagsByServiceByRegion[rewrite.run.region] || {};
            validTagsByServiceByRegion[rewrite.run.region][rewrite.run.serviceId] =
                validTagsByServiceByRegion[rewrite.run.region][rewrite.run.serviceId] || new Set();
            validTagsByServiceByRegion[rewrite.run.region][rewrite.run.serviceId].add(rewrite.run.tag);
        }
    }
    for (const service of services) {
        const { region, serviceId } = run.gcpIds(service);
        service.spec.traffic = (service.spec.traffic || []).filter((traffic) => {
            if (traffic.percent) {
                return true;
            }
            if (!traffic.tag) {
                return true;
            }
            if (!traffic.tag.startsWith("fh-")) {
                return true;
            }
            if (validTagsByServiceByRegion[region]?.[serviceId]?.has(traffic.tag)) {
                return true;
            }
            return false;
        });
    }
}
let garbageCollectionThreshold = 500;
function setGarbageCollectionThreshold(threshold) {
    garbageCollectionThreshold = threshold;
}
async function setRewriteTags(rewrites, project, version) {
    const services = await Promise.all(rewrites
        .map((rewrite) => {
        if (!("run" in rewrite)) {
            return null;
        }
        if (rewrite.run.tag !== exports.TODO_TAG_NAME) {
            return null;
        }
        return run.getService(`projects/${project}/locations/${rewrite.run.region}/services/${rewrite.run.serviceId}`);
    })
        .filter((s) => s !== null));
    if (!services.length) {
        return;
    }
    const needsGC = services
        .map((service) => {
        return service.spec.traffic.filter((traffic) => traffic.tag).length;
    })
        .some((length) => length >= garbageCollectionThreshold);
    if (needsGC) {
        await exports.gcTagsForServices(project, services);
    }
    const tags = await exports.ensureLatestRevisionTagged(services, `fh-${version}`);
    for (const rewrite of rewrites) {
        if (!("run" in rewrite) || rewrite.run.tag !== exports.TODO_TAG_NAME) {
            continue;
        }
        const tag = tags[rewrite.run.region][rewrite.run.serviceId];
        rewrite.run.tag = tag;
    }
}
async function ensureLatestRevisionTagged(services, defaultTag) {
    const tags = {};
    const updateServices = [];
    for (const service of services) {
        const { projectNumber, region, serviceId } = run.gcpIds(service);
        tags[region] = tags[region] || {};
        const latestRevision = service.status?.latestReadyRevisionName;
        if (!latestRevision) {
            throw new error_1.FirebaseError(`Assertion failed: service ${service.metadata.name} has no ready revision`);
        }
        const alreadyTagged = service.spec.traffic.find((target) => target.revisionName === latestRevision && target.tag);
        if (alreadyTagged) {
            tags[region][serviceId] = alreadyTagged.tag;
            continue;
        }
        tags[region][serviceId] = defaultTag;
        service.spec.traffic.push({
            revisionName: latestRevision,
            tag: defaultTag,
        });
        updateServices.push(run.updateService(`projects/${projectNumber}/locations/${region}/services/${serviceId}`, service));
    }
    await Promise.all(updateServices);
    return tags;
}
