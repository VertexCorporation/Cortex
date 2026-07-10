"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DockerHelper = exports.ContainerRegistryCleaner = exports.NoopArtifactRegistryCleaner = exports.ArtifactRegistryCleaner = void 0;
exports.cleanupBuildImages = cleanupBuildImages;
exports.listGcfPaths = listGcfPaths;
exports.deleteGcfArtifacts = deleteGcfArtifacts;
const clc = require("colorette");
const error_1 = require("../../error");
const api_1 = require("../../api");
const logger_1 = require("../../logger");
const artifactregistry = require("../../gcp/artifactregistry");
const backend = require("./backend");
const docker = require("../../gcp/docker");
const utils = require("../../utils");
const poller = require("../../operation-poller");
async function retry(func) {
    const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));
    const MAX_RETRIES = 3;
    const INITIAL_BACKOFF = 100;
    const TIMEOUT_MS = 10000;
    let retry = 0;
    while (true) {
        try {
            const timeout = new Promise((resolve, reject) => {
                setTimeout(() => reject(new Error("Timeout")), TIMEOUT_MS);
            });
            return await Promise.race([func(), timeout]);
        }
        catch (err) {
            logger_1.logger.debug("Failed docker command with error ", err);
            retry += 1;
            if (retry >= MAX_RETRIES) {
                throw new error_1.FirebaseError("Failed to clean up artifacts", { original: err });
            }
            await sleep(Math.pow(INITIAL_BACKOFF, retry - 1));
        }
    }
}
async function cleanupBuildImages(haveFunctions, deletedFunctions, cleaners = {}) {
    utils.logBullet(clc.bold(clc.cyan("functions: ")) + "cleaning up build files...");
    const failedDomains = new Set();
    const cleanup = [];
    const arCleaner = cleaners.ar || new ArtifactRegistryCleaner();
    cleanup.push(...haveFunctions.map(async (func) => {
        try {
            await arCleaner.cleanupFunction(func);
        }
        catch (err) {
            const path = `${func.project}/${func.region}/gcf-artifacts`;
            failedDomains.add(`https://console.cloud.google.com/artifacts/docker/${path}`);
        }
    }));
    cleanup.push(...deletedFunctions.map(async (func) => {
        try {
            await arCleaner.cleanupFunction(func);
        }
        catch (err) {
            const path = `${func.project}/${func.region}/gcf-artifacts`;
            failedDomains.add(`https://console.cloud.google.com/artifacts/docker/${path}`);
        }
    }));
    const gcrCleaner = cleaners.gcr || new ContainerRegistryCleaner();
    cleanup.push(...[...haveFunctions, ...deletedFunctions].map(async (func) => {
        try {
            await gcrCleaner.cleanupFunction(func);
        }
        catch (err) {
            const path = `${func.project}/${docker.GCR_SUBDOMAIN_MAPPING[func.region]}/gcf`;
            failedDomains.add(`https://console.cloud.google.com/gcr/images/${path}`);
        }
    }));
    await Promise.all(cleanup);
    if (failedDomains.size) {
        let message = "Unhandled error cleaning up build images. This could result in a small monthly bill if not corrected. ";
        message +=
            "You can attempt to delete these images by redeploying or you can delete them manually at";
        if (failedDomains.size === 1) {
            message += " " + failedDomains.values().next().value;
        }
        else {
            message += [...failedDomains].map((domain) => "\n\t" + domain).join("");
        }
        utils.logLabeledWarning("functions", message);
    }
}
class ArtifactRegistryCleaner {
    static packagePath(func) {
        const encodedId = func.platform === "gcfv2"
            ? ArtifactRegistryCleaner.encodePackageNameV2(func)
            : ArtifactRegistryCleaner.encodePackageNameV1(func);
        return `projects/${func.project}/locations/${func.region}/repositories/gcf-artifacts/packages/${encodedId}`;
    }
    static encodePart(part) {
        return part
            .replace(/_/g, "__")
            .replace(/-/g, "--")
            .replace(/^[A-Z]/, (first) => `${first.toLowerCase()}-${first.toLowerCase()}`)
            .replace(/[A-Z]/g, (upper) => `_${upper.toLowerCase()}`);
    }
    static encodePackageNameV1(func) {
        return ArtifactRegistryCleaner.encodePart(func.id);
    }
    static encodePackageNameV2(func) {
        return [
            ArtifactRegistryCleaner.encodePart(func.project),
            ArtifactRegistryCleaner.encodePart(func.region),
            ArtifactRegistryCleaner.encodePart(func.id),
        ].join("__");
    }
    async cleanupFunction(func) {
        let op;
        try {
            op = await artifactregistry.deletePackage(ArtifactRegistryCleaner.packagePath(func));
        }
        catch (err) {
            if (err.status === 404) {
                return;
            }
            throw err;
        }
        if (op.done) {
            return;
        }
        await poller.pollOperation({
            ...ArtifactRegistryCleaner.POLLER_OPTIONS,
            pollerName: `cleanup-${func.region}-${func.id}`,
            operationResourceName: op.name,
        });
    }
}
exports.ArtifactRegistryCleaner = ArtifactRegistryCleaner;
ArtifactRegistryCleaner.POLLER_OPTIONS = {
    apiOrigin: (0, api_1.artifactRegistryDomain)(),
    apiVersion: artifactregistry.API_VERSION,
    masterTimeout: 5 * 60 * 1000,
};
class NoopArtifactRegistryCleaner extends ArtifactRegistryCleaner {
    cleanupFunction() {
        return Promise.resolve();
    }
}
exports.NoopArtifactRegistryCleaner = NoopArtifactRegistryCleaner;
class ContainerRegistryCleaner {
    constructor() {
        this.helpers = {};
    }
    helper(location) {
        const subdomain = docker.GCR_SUBDOMAIN_MAPPING[location] || "us";
        if (!this.helpers[subdomain]) {
            const origin = `https://${subdomain}.${(0, api_1.containerRegistryDomain)()}`;
            this.helpers[subdomain] = new DockerHelper(origin);
        }
        return this.helpers[subdomain];
    }
    async cleanupFunction(func) {
        const helper = this.helper(func.region);
        const uuids = (await helper.ls(`${func.project}/gcf/${func.region}`)).children;
        const uuidTags = {};
        const loadUuidTags = [];
        for (const uuid of uuids) {
            loadUuidTags.push((async () => {
                const path = `${func.project}/gcf/${func.region}/${uuid}`;
                const tags = (await helper.ls(path)).tags;
                uuidTags[path] = tags;
            })());
        }
        await Promise.all(loadUuidTags);
        const extractFunction = /^(.*)_version-\d+$/;
        const entry = Object.entries(uuidTags).find(([, tags]) => {
            return tags.find((tag) => extractFunction.exec(tag)?.[1] === func.id);
        });
        if (!entry) {
            logger_1.logger.debug("Could not find image for function", backend.functionName(func));
            return;
        }
        await helper.rm(entry[0]);
    }
}
exports.ContainerRegistryCleaner = ContainerRegistryCleaner;
function getHelper(cache, subdomain) {
    if (!cache[subdomain]) {
        cache[subdomain] = new DockerHelper(`https://${subdomain}.${(0, api_1.containerRegistryDomain)()}`);
    }
    return cache[subdomain];
}
async function listGcfPaths(projectId, locations, dockerHelpers = {}) {
    if (!locations) {
        locations = Object.keys(docker.GCR_SUBDOMAIN_MAPPING);
    }
    const invalidRegion = locations.find((loc) => !docker.GCR_SUBDOMAIN_MAPPING[loc]);
    if (invalidRegion) {
        throw new error_1.FirebaseError(`Invalid region ${invalidRegion} supplied`);
    }
    const locationsSet = new Set(locations);
    const subdomains = new Set(Object.values(docker.GCR_SUBDOMAIN_MAPPING));
    const failedSubdomains = [];
    const listAll = [];
    for (const subdomain of subdomains) {
        listAll.push((async () => {
            try {
                return getHelper(dockerHelpers, subdomain).ls(`${projectId}/gcf`);
            }
            catch (err) {
                failedSubdomains.push(subdomain);
                logger_1.logger.debug(err);
                const stat = {
                    children: [],
                    digests: [],
                    tags: [],
                };
                return Promise.resolve(stat);
            }
        })());
    }
    const gcfDirs = (await Promise.all(listAll))
        .map((results) => results.children)
        .reduce((acc, val) => [...acc, ...val], [])
        .filter((loc) => locationsSet.has(loc));
    if (failedSubdomains.length === subdomains.size) {
        throw new error_1.FirebaseError("Failed to search all subdomains.");
    }
    else if (failedSubdomains.length > 0) {
        throw new error_1.FirebaseError(`Failed to search the following subdomains: ${failedSubdomains.join(",")}`);
    }
    return gcfDirs.map((loc) => {
        return `${docker.GCR_SUBDOMAIN_MAPPING[loc]}.${(0, api_1.containerRegistryDomain)()}/${projectId}/gcf/${loc}`;
    });
}
async function deleteGcfArtifacts(projectId, locations, dockerHelpers = {}) {
    if (!locations) {
        locations = Object.keys(docker.GCR_SUBDOMAIN_MAPPING);
    }
    const invalidRegion = locations.find((loc) => !docker.GCR_SUBDOMAIN_MAPPING[loc]);
    if (invalidRegion) {
        throw new error_1.FirebaseError(`Invalid region ${invalidRegion} supplied`);
    }
    const subdomains = new Set(Object.values(docker.GCR_SUBDOMAIN_MAPPING));
    const failedSubdomains = [];
    const deleteLocations = locations.map((loc) => {
        const subdomain = docker.GCR_SUBDOMAIN_MAPPING[loc];
        try {
            return getHelper(dockerHelpers, subdomain).rm(`${projectId}/gcf/${loc}`);
        }
        catch (err) {
            failedSubdomains.push(subdomain);
            logger_1.logger.debug(err);
        }
    });
    await Promise.all(deleteLocations);
    if (failedSubdomains.length === subdomains.size) {
        throw new error_1.FirebaseError("Failed to search all subdomains.");
    }
    else if (failedSubdomains.length > 0) {
        throw new error_1.FirebaseError(`Failed to search the following subdomains: ${failedSubdomains.join(",")}`);
    }
}
class DockerHelper {
    constructor(origin) {
        this.cache = {};
        this.client = new docker.Client(origin);
    }
    async ls(path) {
        if (!(path in this.cache)) {
            this.cache[path] = retry(() => this.client.listTags(path)).then((res) => {
                return {
                    tags: res.tags,
                    digests: Object.keys(res.manifest),
                    children: res.child,
                };
            });
        }
        return this.cache[path];
    }
    async rm(path) {
        let toThrowLater = undefined;
        const stat = await this.ls(path);
        const recursive = stat.children.map(async (child) => {
            try {
                await this.rm(`${path}/${child}`);
                stat.children.splice(stat.children.indexOf(child), 1);
            }
            catch (err) {
                toThrowLater = err;
            }
        });
        const deleteTags = stat.tags.map(async (tag) => {
            try {
                await retry(() => this.client.deleteTag(path, tag));
                stat.tags.splice(stat.tags.indexOf(tag), 1);
            }
            catch (err) {
                logger_1.logger.debug("Got error trying to remove docker tag:", err);
                toThrowLater = err;
            }
        });
        await Promise.all(deleteTags);
        const deleteImages = stat.digests.map(async (digest) => {
            try {
                await retry(() => this.client.deleteImage(path, digest));
                stat.digests.splice(stat.digests.indexOf(digest), 1);
            }
            catch (err) {
                logger_1.logger.debug("Got error trying to remove docker image:", err);
                toThrowLater = err;
            }
        });
        await Promise.all(deleteImages);
        await Promise.all(recursive);
        if (toThrowLater) {
            throw toThrowLater;
        }
    }
}
exports.DockerHelper = DockerHelper;
