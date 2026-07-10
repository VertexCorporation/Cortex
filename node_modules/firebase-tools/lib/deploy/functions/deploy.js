"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createReadStream = createReadStream;
exports.uploadSourceV2 = uploadSourceV2;
exports.deploy = deploy;
exports.shouldUploadBeSkipped = shouldUploadBeSkipped;
const tmp_1 = require("tmp");
const clc = require("colorette");
const fs = require("fs");
const checkIam_1 = require("./checkIam");
const utils_1 = require("../../utils");
const projectConfig_1 = require("../../functions/projectConfig");
const gcs = require("../../gcp/storage");
const gcf = require("../../gcp/cloudfunctions");
const gcfv2 = require("../../gcp/cloudfunctionsv2");
const backend = require("./backend");
const experiments = require("../../experiments");
const supported = require("./runtimes/supported");
const backend_1 = require("./backend");
const extensions_1 = require("../extensions");
const getProjectNumber_1 = require("../../getProjectNumber");
const path = require("path");
(0, tmp_1.setGracefulCleanup)();
async function uploadSourceV1(projectId, source, wantBackend) {
    const v1Endpoints = backend.allEndpoints(wantBackend).filter((e) => e.platform === "gcfv1");
    if (v1Endpoints.length === 0) {
        return;
    }
    const region = v1Endpoints[0].region;
    const uploadUrl = await gcf.generateUploadUrl(projectId, region);
    const uploadOpts = {
        file: source.functionsSourceV1,
        stream: fs.createReadStream(source.functionsSourceV1),
    };
    if (process.env.GOOGLE_CLOUD_QUOTA_PROJECT) {
        (0, utils_1.logLabeledWarning)("functions", "GOOGLE_CLOUD_QUOTA_PROJECT is not usable when uploading source for Cloud Functions.");
    }
    await gcs.upload(uploadOpts, uploadUrl, {
        "x-goog-content-length-range": "0,104857600",
    }, true);
    return uploadUrl;
}
function createReadStream(filePath) {
    return fs.createReadStream(filePath);
}
async function uploadSourceV2(projectId, projectNumber, source, wantBackend) {
    const v2Endpoints = backend
        .allEndpoints(wantBackend)
        .filter((e) => e.platform === "gcfv2" || e.platform === "run");
    if (v2Endpoints.length === 0) {
        return;
    }
    const region = v2Endpoints[0].region;
    const uploadOpts = {
        file: source.functionsSourceV2,
        stream: exports.createReadStream(source.functionsSourceV2),
    };
    const isDart = v2Endpoints.some((e) => supported.runtimeIsLanguage(e.runtime, "dart"));
    const useApiOnly = experiments.isEnabled("functionsrunapionly") ||
        (isDart && experiments.isEnabled("dartfunctions"));
    if (!useApiOnly && !v2Endpoints.some((e) => e.platform === "run")) {
        if (process.env.GOOGLE_CLOUD_QUOTA_PROJECT) {
            (0, utils_1.logLabeledWarning)("functions", "GOOGLE_CLOUD_QUOTA_PROJECT is not usable when uploading source for Cloud Functions.");
        }
        const res = await gcfv2.generateUploadUrl(projectId, region);
        await gcs.upload(uploadOpts, res.uploadUrl, undefined, true);
        return res.storageSource;
    }
    const baseName = `firebase-functions-src-${projectNumber}`;
    const bucketName = await gcs.upsertBucket({
        product: "functions",
        projectId,
        createMessage: `Creating Cloud Storage bucket in ${region} to store Functions source code uploads at ${baseName}...`,
        req: {
            baseName,
            location: region,
            purposeLabel: `functions-source-${region.toLowerCase()}`,
            lifecycle: {
                rule: [
                    {
                        action: { type: "Delete" },
                        condition: { age: 1 },
                    },
                ],
            },
        },
    });
    const objectPath = `${source.functionsSourceV2Hash}${path.extname(source.functionsSourceV2)}`;
    await gcs.upload(uploadOpts, `${bucketName}/${objectPath}`, undefined, true);
    return {
        bucket: bucketName,
        object: objectPath,
    };
}
async function uploadCodebase(context, projectNumber, codebase, wantBackend) {
    const source = context.sources?.[codebase];
    if (!source || (!source.functionsSourceV1 && !source.functionsSourceV2)) {
        return;
    }
    const uploads = [];
    try {
        uploads.push(uploadSourceV1(context.projectId, source, wantBackend));
        uploads.push(uploadSourceV2(context.projectId, projectNumber, source, wantBackend));
        const [sourceUrl, storage] = await Promise.all(uploads);
        if (sourceUrl) {
            source.sourceUrl = sourceUrl;
        }
        if (storage) {
            source.storage = storage;
        }
        const cfg = (0, projectConfig_1.configForCodebase)(context.config, codebase);
        const label = cfg.source ?? cfg.remoteSource?.dir ?? "remote";
        if (uploads.length) {
            (0, utils_1.logLabeledSuccess)("functions", `${clc.bold(label)} source uploaded successfully`);
        }
    }
    catch (err) {
        (0, utils_1.logWarning)(clc.yellow("functions:") + " Upload Error: " + err.message);
        throw err;
    }
}
async function deploy(context, options, payload) {
    if (payload.extensions && context.extensions) {
        await (0, extensions_1.deploy)(context.extensions, options, payload.extensions);
    }
    if (payload.functions && context.config) {
        await (0, checkIam_1.checkHttpIam)(context, options, payload);
        const uploads = [];
        for (const [codebase, { wantBackend, haveBackend }] of Object.entries(payload.functions)) {
            if (shouldUploadBeSkipped(context, wantBackend, haveBackend)) {
                continue;
            }
            const projectNumber = options.projectNumber || (await (0, getProjectNumber_1.getProjectNumber)(context.projectId));
            uploads.push(uploadCodebase(context, projectNumber, codebase, wantBackend));
        }
        await Promise.all(uploads);
    }
}
function shouldUploadBeSkipped(context, wantBackend, haveBackend) {
    if (context.filters && context.filters.length > 0) {
        return false;
    }
    const wantEndpoints = backend.allEndpoints(wantBackend);
    const haveEndpoints = backend.allEndpoints(haveBackend);
    if (wantEndpoints.length !== haveEndpoints.length) {
        return false;
    }
    return wantEndpoints.every((wantEndpoint) => {
        const haveEndpoint = (0, backend_1.findEndpoint)(haveBackend, (endpoint) => endpoint.id === wantEndpoint.id);
        if (!haveEndpoint) {
            return false;
        }
        return (haveEndpoint.hash &&
            wantEndpoint.hash &&
            haveEndpoint.hash === wantEndpoint.hash &&
            haveEndpoint.state === "ACTIVE");
    });
}
