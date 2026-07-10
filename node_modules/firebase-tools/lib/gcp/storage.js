"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ContentType = void 0;
exports.getDefaultBucket = getDefaultBucket;
exports.upload = upload;
exports.uploadObject = uploadObject;
exports.getObject = getObject;
exports.deleteObject = deleteObject;
exports.getBucket = getBucket;
exports.createBucket = createBucket;
exports.patchBucket = patchBucket;
exports.randomString = randomString;
exports.upsertBucket = upsertBucket;
exports.listBuckets = listBuckets;
exports.getServiceAccount = getServiceAccount;
exports.getDownloadUrl = getDownloadUrl;
const path = require("path");
const clc = require("colorette");
const crypto_1 = require("crypto");
const api_1 = require("../api");
const apiv2_1 = require("../apiv2");
const error_1 = require("../error");
const logger_1 = require("../logger");
const ensureApiEnabled_1 = require("../ensureApiEnabled");
const utils = require("../utils");
const proto_1 = require("./proto");
var ContentType;
(function (ContentType) {
    ContentType["ZIP"] = "ZIP";
    ContentType["TAR"] = "TAR";
})(ContentType || (exports.ContentType = ContentType = {}));
async function getDefaultBucket(projectId) {
    await (0, ensureApiEnabled_1.ensure)(projectId, (0, api_1.firebaseStorageOrigin)(), "storage", false);
    try {
        const localAPIClient = new apiv2_1.Client({
            urlPrefix: (0, api_1.firebaseStorageOrigin)(),
            apiVersion: "v1alpha",
        });
        const response = await localAPIClient.get(`/projects/${projectId}/defaultBucket`);
        if (!response.body?.bucket.name) {
            logger_1.logger.debug("Default storage bucket is undefined.");
            throw new error_1.FirebaseError("Your project is being set up. Please wait a minute before deploying again.");
        }
        return response.body.bucket.name.split("/").pop();
    }
    catch (err) {
        if (err?.status === 404) {
            throw new error_1.FirebaseError(`Firebase Storage has not been set up on project '${clc.bold(projectId)}'. Go to https://console.firebase.google.com/project/${projectId}/storage and click 'Get Started' to set up Firebase Storage.`);
        }
        logger_1.logger.info("\n\nUnexpected error when fetching default storage bucket.");
        throw err;
    }
}
async function upload(source, uploadUrl, extraHeaders, ignoreQuotaProject) {
    const url = new URL(uploadUrl, (0, api_1.storageOrigin)());
    const isSignedUrl = url.searchParams.has("GoogleAccessId");
    const localAPIClient = new apiv2_1.Client({ urlPrefix: url.origin, auth: !isSignedUrl });
    const res = await localAPIClient.request({
        method: "PUT",
        path: url.pathname,
        queryParams: url.searchParams,
        responseType: "xml",
        headers: {
            "content-type": "application/zip",
            ...extraHeaders,
        },
        body: source.stream,
        skipLog: { resBody: true },
        ignoreQuotaProject,
    });
    return {
        generation: res.response.headers.get("x-goog-generation"),
    };
}
async function uploadObject(source, bucketName, contentType) {
    switch (contentType) {
        case ContentType.TAR:
            if (!source.file.endsWith(".tar.gz")) {
                throw new error_1.FirebaseError(`Expected a file name ending in .tar.gz, got ${source.file}`);
            }
            break;
        default:
            if (path.extname(source.file) !== ".zip") {
                throw new error_1.FirebaseError(`Expected a file name ending in .zip, got ${source.file}`);
            }
    }
    const localAPIClient = new apiv2_1.Client({ urlPrefix: (0, api_1.storageOrigin)() });
    const location = `/${bucketName}/${path.basename(source.file)}`;
    const res = await localAPIClient.request({
        method: "PUT",
        path: location,
        headers: {
            "Content-Type": contentType === ContentType.TAR ? "application/octet-stream" : "application/zip",
            "x-goog-content-length-range": "0,123289600",
        },
        body: source.stream,
    });
    return {
        bucket: bucketName,
        object: path.basename(source.file),
        generation: res.response.headers.get("x-goog-generation"),
    };
}
async function getObject(bucketName, objectName) {
    const client = new apiv2_1.Client({ urlPrefix: (0, api_1.storageOrigin)() });
    const res = await client.get(`/storage/v1/b/${bucketName}/o/${objectName}`);
    return res.body;
}
function deleteObject(location) {
    const localAPIClient = new apiv2_1.Client({ urlPrefix: (0, api_1.storageOrigin)() });
    return localAPIClient.delete(location);
}
async function getBucket(bucketName) {
    try {
        const localAPIClient = new apiv2_1.Client({ urlPrefix: (0, api_1.storageOrigin)() });
        const result = await localAPIClient.get(`/storage/v1/b/${bucketName}`);
        return result.body;
    }
    catch (err) {
        logger_1.logger.debug(err);
        throw new error_1.FirebaseError("Failed to obtain the storage bucket", {
            original: err,
        });
    }
}
async function createBucket(projectId, req, projectPrivate) {
    const queryParams = {
        project: projectId,
    };
    if (projectPrivate) {
        queryParams["predefinedAcl"] = "projectPrivate";
        queryParams["predefinedDefaultObjectAcl"] = "projectPrivate";
    }
    try {
        const localAPIClient = new apiv2_1.Client({ urlPrefix: (0, api_1.storageOrigin)() });
        const result = await localAPIClient.post(`/storage/v1/b`, req, { queryParams });
        return result.body;
    }
    catch (err) {
        logger_1.logger.debug(err);
        throw new error_1.FirebaseError("Failed to create the storage bucket", {
            original: err,
        });
    }
}
async function patchBucket(bucketName, metadata) {
    try {
        const localAPIClient = new apiv2_1.Client({ urlPrefix: (0, api_1.storageOrigin)() });
        const mask = (0, proto_1.fieldMasks)(metadata, "labels", "acl", "defaultObjectAcl", "lifecycle");
        const result = await localAPIClient.patch(`/storage/v1/b/${bucketName}`, metadata, { queryParams: { updateMask: mask.join(",") } });
        return result.body;
    }
    catch (err) {
        logger_1.logger.debug(err);
        throw new error_1.FirebaseError("Failed to patch the storage bucket", {
            original: err,
        });
    }
}
function randomString(length) {
    const chars = "abcdefghijklmnopqrstuvwxyz0123456789";
    let result = "";
    for (let i = length; i > 0; --i) {
        result += chars[(0, crypto_1.randomInt)(chars.length)];
    }
    return result;
}
const dynamicDispatch = exports;
async function upsertBucket(opts) {
    const existingBuckets = await dynamicDispatch.listBuckets(opts.projectId);
    const managedBucket = existingBuckets.find((b) => opts.req.purposeLabel in (b.labels || {}));
    if (managedBucket) {
        return managedBucket.name;
    }
    const existingUnmanaged = existingBuckets.find((b) => b.name === opts.req.baseName);
    if (existingUnmanaged) {
        logger_1.logger.debug(`Found existing bucket ${existingUnmanaged.name} without purpose label. Because it is known not to be squatted, we can use it.`);
        const labels = { ...existingUnmanaged.labels, [opts.req.purposeLabel]: "true" };
        await dynamicDispatch.patchBucket(existingUnmanaged.name, { labels });
        return existingUnmanaged.name;
    }
    utils.logLabeledBullet(opts.product, opts.createMessage);
    for (let retryCount = 0; retryCount < 5; retryCount++) {
        const name = retryCount === 0
            ? opts.req.baseName
            : `${opts.req.baseName}-${dynamicDispatch.randomString(6)}`;
        try {
            await dynamicDispatch.createBucket(opts.projectId, {
                name,
                location: opts.req.location,
                lifecycle: opts.req.lifecycle,
                labels: {
                    [opts.req.purposeLabel]: "true",
                },
            }, true);
            return name;
        }
        catch (err) {
            if ((0, error_1.getErrStatus)(err.original) === 409) {
                utils.logLabeledBullet(opts.product, `Bucket ${name} already exists, creating a new bucket with a conflict-avoiding hash`);
                continue;
            }
            if ((0, error_1.getErrStatus)(err.original) === 403) {
                utils.logLabeledWarning(opts.product, "Failed to create Cloud Storage bucket because user does not have sufficient permissions. " +
                    "See https://cloud.google.com/storage/docs/access-control/iam-roles for more details on " +
                    "IAM roles that are able to create a Cloud Storage bucket, and ask your project administrator " +
                    "to grant you one of those roles.");
            }
            throw err;
        }
    }
    throw new error_1.FirebaseError("Failed to create a unique Cloud Storage bucket name after 5 attempts.");
}
async function listBuckets(projectId) {
    try {
        let buckets = [];
        const localAPIClient = new apiv2_1.Client({ urlPrefix: (0, api_1.storageOrigin)() });
        let pageToken;
        do {
            const result = await localAPIClient.get(`/storage/v1/b?project=${projectId}`, { queryParams: pageToken ? { pageToken } : {} });
            buckets = buckets.concat(result.body.items || []);
            pageToken = result.body.nextPageToken;
        } while (pageToken);
        return buckets;
    }
    catch (err) {
        logger_1.logger.debug(err);
        throw new error_1.FirebaseError("Failed to read the storage buckets", {
            original: err,
        });
    }
}
async function getServiceAccount(projectId) {
    try {
        const localAPIClient = new apiv2_1.Client({ urlPrefix: (0, api_1.storageOrigin)() });
        const response = await localAPIClient.get(`/storage/v1/projects/${projectId}/serviceAccount`);
        return response.body;
    }
    catch (err) {
        logger_1.logger.debug(err);
        throw new error_1.FirebaseError("Failed to obtain the Cloud Storage service agent", {
            original: err,
        });
    }
}
async function getDownloadUrl(bucketName, objectPath, emulatorUrl) {
    try {
        const origin = emulatorUrl || (0, api_1.firebaseStorageOrigin)();
        const localAPIClient = new apiv2_1.Client({ urlPrefix: origin });
        const response = await localAPIClient.get(`/v0/b/${bucketName}/o/${encodeURIComponent(objectPath)}`);
        if (emulatorUrl) {
            return `${origin}/v0/b/${bucketName}/o/${encodeURIComponent(objectPath)}?alt=media`;
        }
        if (!response.body.downloadTokens) {
            throw new Error(`no download tokens exist for ${objectPath}, please visit the Firebase console to make one`);
        }
        const [token] = response.body.downloadTokens.split(",");
        return `${origin}/v0/b/${bucketName}/o/${encodeURIComponent(objectPath)}?alt=media&token=${token}`;
    }
    catch (err) {
        logger_1.logger.error(err);
        throw new error_1.FirebaseError(`${err} Check that you have permission in the Firebase console to generate a download token`, {
            original: err,
        });
    }
}
