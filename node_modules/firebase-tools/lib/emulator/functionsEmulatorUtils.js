"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.extractParamsFromPath = extractParamsFromPath;
exports.isValidWildcardMatch = isValidWildcardMatch;
exports.trimSlashes = trimSlashes;
exports.removePathSegments = removePathSegments;
exports.parseRuntimeVersion = parseRuntimeVersion;
exports.parseVersionString = parseVersionString;
exports.compareVersionStrings = compareVersionStrings;
exports.isLocalHost = isLocalHost;
const wildcardRegex = new RegExp("{[^/{}]*}");
const wildcardKeyRegex = new RegExp("^{(.+)}$");
function extractParamsFromPath(wildcardPath, snapshotPath) {
    if (!isValidWildcardMatch(wildcardPath, snapshotPath)) {
        return {};
    }
    const wildcardChunks = trimSlashes(wildcardPath).split("/");
    const snapshotChunks = trimSlashes(snapshotPath).split("/");
    return wildcardChunks
        .slice(-snapshotChunks.length)
        .reduce((params, chunk, index) => {
        const match = wildcardKeyRegex.exec(chunk);
        if (match) {
            const wildcardKey = match[1];
            const potentialWildcardValue = snapshotChunks[index];
            if (!wildcardKeyRegex.exec(potentialWildcardValue)) {
                params[wildcardKey] = potentialWildcardValue;
            }
        }
        return params;
    }, {});
}
function isValidWildcardMatch(wildcardPath, snapshotPath) {
    const wildcardChunks = trimSlashes(wildcardPath).split("/");
    const snapshotChunks = trimSlashes(snapshotPath).split("/");
    if (snapshotChunks.length > wildcardChunks.length) {
        return false;
    }
    const mismatchedChunks = wildcardChunks.slice(-snapshotChunks.length).filter((chunk, index) => {
        return !(wildcardRegex.exec(chunk) || chunk === snapshotChunks[index]);
    });
    return mismatchedChunks.length === 0;
}
function trimSlashes(str) {
    return str
        .split("/")
        .filter((c) => c)
        .join("/");
}
function removePathSegments(path, count) {
    return trimSlashes(path).split("/").slice(count).join("/");
}
function parseRuntimeVersion(runtime) {
    if (!runtime) {
        return undefined;
    }
    const runtimeRe = /(nodejs)?([0-9]+)/;
    const match = runtimeRe.exec(runtime);
    if (match) {
        return Number.parseInt(match[2]);
    }
    return undefined;
}
function parseVersionString(version) {
    const parts = (version || "0").split(".");
    parts.push("0");
    parts.push("0");
    return {
        major: parseInt(parts[0], 10),
        minor: parseInt(parts[1], 10),
        patch: parseInt(parts[2], 10),
    };
}
function compareVersionStrings(a, b) {
    const versionA = parseVersionString(a);
    const versionB = parseVersionString(b);
    if (versionA.major !== versionB.major) {
        return versionA.major - versionB.major;
    }
    if (versionA.minor !== versionB.minor) {
        return versionA.minor - versionB.minor;
    }
    if (versionA.patch !== versionB.patch) {
        return versionA.patch - versionB.patch;
    }
    return 0;
}
function isLocalHost(href) {
    return !!href.match(/^(http(s)?:\/\/)?(localhost|127.0.0.1|\[::1])/);
}
