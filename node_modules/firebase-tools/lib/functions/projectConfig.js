"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DEFAULT_CODEBASE = void 0;
exports.normalize = normalize;
exports.validateCodebase = validateCodebase;
exports.validatePrefix = validatePrefix;
exports.assertUnique = assertUnique;
exports.validate = validate;
exports.normalizeAndValidate = normalizeAndValidate;
exports.configForCodebase = configForCodebase;
exports.isLocalConfig = isLocalConfig;
exports.isRemoteConfig = isRemoteConfig;
exports.requireLocal = requireLocal;
exports.resolveConfigDir = resolveConfigDir;
exports.shouldUseRuntimeConfig = shouldUseRuntimeConfig;
const error_1 = require("../error");
exports.DEFAULT_CODEBASE = "default";
function normalize(config) {
    if (!config) {
        throw new error_1.FirebaseError("No valid functions configuration detected in firebase.json");
    }
    if (Array.isArray(config)) {
        if (config.length < 1) {
            throw new error_1.FirebaseError("Requires at least one functions.source in firebase.json.");
        }
        return config;
    }
    return [config];
}
function validateCodebase(codebase) {
    if (codebase.length === 0 || codebase.length > 63 || !/^[a-z0-9_-]+$/.test(codebase)) {
        throw new error_1.FirebaseError("Invalid codebase name. Codebase must be less than 64 characters and " +
            "can contain only lowercase letters, numeric characters, underscores, and dashes.");
    }
}
function validatePrefix(prefix) {
    if (prefix.length > 30) {
        throw new error_1.FirebaseError("Invalid prefix. Prefix must be 30 characters or less.");
    }
    if (!/^[a-z](?:[a-z0-9-]*[a-z0-9])?$/.test(prefix)) {
        throw new error_1.FirebaseError("Invalid prefix. Prefix must start with a lowercase letter, can contain only lowercase letters, numeric characters, and dashes, and cannot start or end with a dash.");
    }
}
function validateSingle(config) {
    const { source, remoteSource, runtime, codebase: providedCodebase, ...rest } = config;
    if (source && remoteSource) {
        throw new error_1.FirebaseError("Cannot specify both 'source' and 'remoteSource' in a single functions config. Please choose one.");
    }
    if (!source && !remoteSource) {
        throw new error_1.FirebaseError("codebase source must be specified. Must specify either 'source' or 'remoteSource' in a functions config.");
    }
    const codebase = providedCodebase ?? exports.DEFAULT_CODEBASE;
    validateCodebase(codebase);
    if (config.prefix) {
        validatePrefix(config.prefix);
    }
    const commonConfig = { codebase, ...rest };
    if (source) {
        return {
            ...commonConfig,
            source,
            ...(runtime ? { runtime } : {}),
        };
    }
    else if (remoteSource) {
        if (!remoteSource.repository || !remoteSource.ref) {
            throw new error_1.FirebaseError("remoteSource requires 'repository' and 'ref' to be specified.");
        }
        if (!runtime) {
            throw new error_1.FirebaseError("functions.runtime is required when using remoteSource in firebase.json.");
        }
        return {
            ...commonConfig,
            remoteSource,
            runtime,
        };
    }
    throw new error_1.FirebaseError("Invalid functions config.");
}
function assertUnique(config, property, propval) {
    const values = new Set();
    if (propval) {
        values.add(propval);
    }
    for (const single of config) {
        const value = single[property];
        if (values.has(value)) {
            throw new error_1.FirebaseError(`functions.${property} must be unique but '${value}' was used more than once.`);
        }
        values.add(value);
    }
}
function assertUniqueSourcePrefixPair(config) {
    const sourcePrefixPairs = new Set();
    for (const c of config) {
        let sourceIdentifier;
        let sourceDescription;
        if (c.source) {
            sourceIdentifier = c.source;
            sourceDescription = `source directory ('${c.source}')`;
        }
        else if (c.remoteSource) {
            sourceIdentifier = `remote:${c.remoteSource.repository}#${c.remoteSource.ref}@dir:${c.remoteSource.dir || "."}`;
            sourceDescription = `remote source ('${c.remoteSource.repository}')`;
        }
        else {
            continue;
        }
        const key = JSON.stringify({ source: sourceIdentifier, prefix: c.prefix || "" });
        if (sourcePrefixPairs.has(key)) {
            throw new error_1.FirebaseError(`More than one functions config specifies the same ${sourceDescription} and prefix ('${c.prefix ?? ""}'). Please add a unique 'prefix' to each function configuration that shares this source to resolve the conflict.`);
        }
        sourcePrefixPairs.add(key);
    }
}
function validate(config) {
    const validated = config.map((cfg) => validateSingle(cfg));
    assertUnique(validated, "codebase");
    assertUniqueSourcePrefixPair(validated);
    return validated;
}
function normalizeAndValidate(config) {
    return validate(normalize(config));
}
function configForCodebase(config, codebase) {
    const codebaseCfg = config.find((c) => c.codebase === codebase);
    if (!codebaseCfg) {
        throw new error_1.FirebaseError(`No functions config found for codebase ${codebase}`);
    }
    return codebaseCfg;
}
function isLocalConfig(c) {
    return c.source !== undefined;
}
function isRemoteConfig(c) {
    return c.remoteSource !== undefined;
}
function requireLocal(c, purpose) {
    if (!isLocalConfig(c)) {
        const msg = purpose ??
            "This operation requires a local functions source directory, but the codebase is configured with a remote source.";
        throw new error_1.FirebaseError(msg);
    }
    return c;
}
function resolveConfigDir(c) {
    return c.configDir || c.source;
}
function shouldUseRuntimeConfig(cfg) {
    return isLocalConfig(cfg) && cfg.disallowLegacyRuntimeConfig !== true;
}
