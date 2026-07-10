"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getEnvironmentVariablesHash = getEnvironmentVariablesHash;
exports.getSourceHash = getSourceHash;
exports.getSecretsHash = getSecretsHash;
exports.getEndpointHash = getEndpointHash;
const promises_1 = require("node:fs/promises");
const crypto = require("crypto");
const secrets_1 = require("../../../functions/secrets");
function getEnvironmentVariablesHash(backend) {
    return createHash(JSON.stringify(backend.environmentVariables || {}));
}
async function getSourceHash(pathToFile) {
    const data = await (0, promises_1.readFile)(pathToFile);
    return createHash(data);
}
function getSecretsHash(endpoint) {
    const secretVersions = (0, secrets_1.getSecretVersions)(endpoint);
    return createHash(JSON.stringify(secretVersions || {}));
}
function getEndpointHash(sourceHash, envHash, secretsHash) {
    const combined = [sourceHash, envHash, secretsHash].filter((hash) => !!hash).join("");
    return createHash(combined);
}
function createHash(data, algorithm = "sha1") {
    const hash = crypto.createHash(algorithm);
    hash.update(data);
    return hash.digest("hex");
}
