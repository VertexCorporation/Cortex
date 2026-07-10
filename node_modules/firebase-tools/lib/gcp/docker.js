"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Client = exports.GCR_SUBDOMAIN_MAPPING = void 0;
const error_1 = require("../error");
const api = require("../apiv2");
exports.GCR_SUBDOMAIN_MAPPING = {
    "us-west1": "us",
    "us-west2": "us",
    "us-west3": "us",
    "us-west4": "us",
    "us-central1": "us",
    "us-central2": "us",
    "us-east1": "us",
    "us-east4": "us",
    "northamerica-northeast1": "us",
    "southamerica-east1": "us",
    "europe-west1": "eu",
    "europe-west2": "eu",
    "europe-west3": "eu",
    "europe-west4": "eu",
    "europe-west5": "eu",
    "europe-west6": "eu",
    "europe-central2": "eu",
    "europe-north1": "eu",
    "asia-east1": "asia",
    "asia-east2": "asia",
    "asia-northeast1": "asia",
    "asia-northeast2": "asia",
    "asia-northeast3": "asia",
    "asia-south1": "asia",
    "asia-southeast2": "asia",
    "australia-southeast1": "asia",
};
function isErrors(response) {
    return !!response && Object.prototype.hasOwnProperty.call(response, "errors");
}
const API_VERSION = "v2";
class Client {
    constructor(origin) {
        this.client = new api.Client({
            apiVersion: API_VERSION,
            auth: true,
            urlPrefix: origin,
        });
    }
    async listTags(path) {
        const response = await this.client.get(`${path}/tags/list`);
        if (isErrors(response.body)) {
            throw new error_1.FirebaseError(`Failed to list GCR tags at ${path}`, {
                children: response.body.errors,
            });
        }
        return response.body;
    }
    async deleteTag(path, tag) {
        const response = await this.client.delete(`${path}/manifests/${tag}`);
        if (!response.body) {
            return;
        }
        if (response.body.errors?.length !== 0) {
            throw new error_1.FirebaseError(`Failed to delete tag ${tag} at path ${path}`, {
                children: response.body.errors,
            });
        }
    }
    async deleteImage(path, digest) {
        const response = await this.client.delete(`${path}/manifests/${digest}`);
        if (!response.body) {
            return;
        }
        if (response.body.errors?.length !== 0) {
            throw new error_1.FirebaseError(`Failed to delete image ${digest} at path ${path}`, {
                children: response.body.errors,
            });
        }
    }
}
exports.Client = Client;
