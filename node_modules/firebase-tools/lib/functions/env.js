"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.KeyValidationError = void 0;
exports.parse = parse;
exports.validateKey = validateKey;
exports.parseStrict = parseStrict;
exports.hasUserEnvs = hasUserEnvs;
exports.writeUserEnvs = writeUserEnvs;
exports.checkForDuplicateKeys = checkForDuplicateKeys;
exports.loadUserEnvs = loadUserEnvs;
exports.loadFirebaseEnvs = loadFirebaseEnvs;
exports.writeResolvedParams = writeResolvedParams;
const clc = require("colorette");
const fs = require("fs");
const path = require("path");
const error_1 = require("../error");
const logger_1 = require("../logger");
const utils_1 = require("../utils");
const FUNCTIONS_EMULATOR_DOTENV = ".env.local";
const RESERVED_PREFIXES = ["X_GOOGLE_", "FIREBASE_", "EXT_"];
const RESERVED_KEYS = [
    "FIREBASE_CONFIG",
    "CLOUD_RUNTIME_CONFIG",
    "EVENTARC_CLOUD_EVENT_SOURCE",
    "ENTRY_POINT",
    "GCP_PROJECT",
    "GCLOUD_PROJECT",
    "GOOGLE_CLOUD_PROJECT",
    "FUNCTION_TRIGGER_TYPE",
    "FUNCTION_NAME",
    "FUNCTION_MEMORY_MB",
    "FUNCTION_TIMEOUT_SEC",
    "FUNCTION_IDENTITY",
    "FUNCTION_REGION",
    "FUNCTION_TARGET",
    "FUNCTION_SIGNATURE_TYPE",
    "K_SERVICE",
    "K_REVISION",
    "PORT",
    "K_CONFIGURATION",
];
const LINE_RE = new RegExp("^" +
    "\\s*" +
    "(?:export)?" +
    "\\s*" +
    "([\\w./]+)" +
    "\\s*=[\\f\\t\\v]*" +
    "(" +
    "\\s*'(?:\\\\'|[^'])*'|" +
    '\\s*"(?:\\\\"|[^"])*"|' +
    "[^#\\r\\n]*" +
    ")?" +
    "\\s*" +
    "(?:#[^\\n]*)?" +
    "$", "gms");
const ESCAPE_SEQUENCES_TO_CHARACTERS = {
    "\\n": "\n",
    "\\r": "\r",
    "\\t": "\t",
    "\\v": "\v",
    "\\\\": "\\",
    "\\'": "'",
    '\\"': '"',
};
const ALL_ESCAPE_SEQUENCES_RE = /\\[nrtv\\'"]/g;
const CHARACTERS_TO_ESCAPE_SEQUENCES = {
    "\n": "\\n",
    "\r": "\\r",
    "\t": "\\t",
    "\v": "\\v",
    "\\": "\\\\",
    "'": "\\'",
    '"': '\\"',
};
const ALL_ESCAPABLE_CHARACTERS_RE = /[\n\r\t\v\\'"]/g;
function parse(data) {
    const envs = {};
    const errors = [];
    data = data.replace(/\r\n?/, "\n");
    let match;
    while ((match = LINE_RE.exec(data))) {
        let [, k, v] = match;
        v = (v || "").trim();
        let quotesMatch;
        if ((quotesMatch = /^(["'])(.*)\1$/ms.exec(v)) != null) {
            v = quotesMatch[2];
            if (quotesMatch[1] === '"') {
                v = v.replace(ALL_ESCAPE_SEQUENCES_RE, (match) => ESCAPE_SEQUENCES_TO_CHARACTERS[match]);
            }
        }
        envs[k] = v;
    }
    const nonmatches = data.replace(LINE_RE, "");
    for (let line of nonmatches.split(/[\r\n]+/)) {
        line = line.trim();
        if (line.startsWith("#")) {
            continue;
        }
        if (line.length)
            errors.push(line);
    }
    return { envs, errors };
}
class KeyValidationError extends Error {
    constructor(key, message) {
        super(`Failed to validate key ${key}: ${message}`);
        this.key = key;
        this.message = message;
    }
}
exports.KeyValidationError = KeyValidationError;
function validateKey(key) {
    if (RESERVED_KEYS.includes(key)) {
        throw new KeyValidationError(key, `Key ${key} is reserved for internal use.`);
    }
    if (!/^[A-Z_][A-Z0-9_]*$/.test(key)) {
        throw new KeyValidationError(key, `Key ${key} must start with an uppercase ASCII letter or underscore` +
            ", and then consist of uppercase ASCII letters, digits, and underscores.");
    }
    if (RESERVED_PREFIXES.some((prefix) => key.startsWith(prefix))) {
        throw new KeyValidationError(key, `Key ${key} starts with a reserved prefix (${RESERVED_PREFIXES.join(" ")})`);
    }
}
function parseStrict(data) {
    const { envs, errors } = parse(data);
    if (errors.length) {
        throw new error_1.FirebaseError(`Invalid dotenv file, error on lines: ${errors.join(",")}`);
    }
    const validationErrors = [];
    for (const key of Object.keys(envs)) {
        try {
            validateKey(key);
        }
        catch (err) {
            logger_1.logger.debug(`Failed to validate key ${key}: ${err}`);
            if (err instanceof KeyValidationError) {
                validationErrors.push(err);
            }
            else {
                throw err;
            }
        }
    }
    if (validationErrors.length > 0) {
        throw new error_1.FirebaseError("Validation failed", { children: validationErrors });
    }
    return envs;
}
function findEnvfiles(configDir, projectId, projectAlias, isEmulator) {
    const files = [".env"];
    files.push(`.env.${projectId}`);
    if (projectAlias) {
        files.push(`.env.${projectAlias}`);
    }
    if (isEmulator) {
        files.push(FUNCTIONS_EMULATOR_DOTENV);
    }
    return files
        .map((f) => path.join(configDir, f))
        .filter(fs.existsSync)
        .map((p) => path.basename(p));
}
function hasUserEnvs(opts) {
    const configDir = opts.configDir || opts.functionsSource;
    return findEnvfiles(configDir, opts.projectId, opts.projectAlias, opts.isEmulator).length > 0;
}
function writeUserEnvs(toWrite, envOpts) {
    if (Object.keys(toWrite).length === 0) {
        return;
    }
    const { projectId, projectAlias, isEmulator } = envOpts;
    const configDir = envOpts.configDir || envOpts.functionsSource;
    const allEnvFiles = findEnvfiles(configDir, projectId, projectAlias, isEmulator);
    const targetEnvFile = envOpts.isEmulator
        ? FUNCTIONS_EMULATOR_DOTENV
        : `.env.${envOpts.projectId}`;
    const targetEnvFileExists = allEnvFiles.includes(targetEnvFile);
    if (!targetEnvFileExists) {
        fs.writeFileSync(path.join(configDir, targetEnvFile), "", { flag: "wx" });
        (0, utils_1.logBullet)(clc.yellow(clc.bold("functions: ")) +
            `Created new local file ${targetEnvFile} to store param values. We suggest explicitly adding or excluding this file from version control.`);
    }
    const fullEnvs = loadUserEnvs(envOpts);
    const prodEnvs = isEmulator
        ? loadUserEnvs({ ...envOpts, isEmulator: false })
        : loadUserEnvs(envOpts);
    checkForDuplicateKeys(isEmulator || false, Object.keys(toWrite), fullEnvs, prodEnvs);
    for (const k of Object.keys(toWrite)) {
        validateKey(k);
    }
    (0, utils_1.logBullet)(clc.cyan(clc.bold("functions: ")) + `Writing new parameter values to disk: ${targetEnvFile}`);
    let lines = "";
    for (const k of Object.keys(toWrite)) {
        lines += formatUserEnvForWrite(k, toWrite[k]);
    }
    fs.appendFileSync(path.join(configDir, targetEnvFile), lines);
}
function checkForDuplicateKeys(isEmulator, keys, fullEnv, envsWithoutLocal) {
    for (const key of keys) {
        const definedInEnv = fullEnv.hasOwnProperty(key);
        if (definedInEnv) {
            if (envsWithoutLocal && isEmulator && envsWithoutLocal.hasOwnProperty(key)) {
                (0, utils_1.logWarning)(clc.cyan(clc.yellow("functions: ")) +
                    `Writing parameter ${key} to emulator-specific config .env.local. This will overwrite your existing definition only when emulating.`);
                continue;
            }
            throw new error_1.FirebaseError(`Attempted to write param-defined key ${key} to .env files, but it was already defined.`);
        }
    }
}
function formatUserEnvForWrite(key, value) {
    const escapedValue = value.replace(ALL_ESCAPABLE_CHARACTERS_RE, (match) => CHARACTERS_TO_ESCAPE_SEQUENCES[match]);
    if (escapedValue !== value) {
        return `${key}="${escapedValue}"\n`;
    }
    return `${key}=${escapedValue}\n`;
}
function loadUserEnvs(opts) {
    const configDir = opts.configDir || opts.functionsSource;
    const envFiles = findEnvfiles(configDir, opts.projectId, opts.projectAlias, opts.isEmulator);
    if (envFiles.length === 0) {
        return {};
    }
    if (opts.projectAlias) {
        if (envFiles.includes(`.env.${opts.projectId}`) &&
            envFiles.includes(`.env.${opts.projectAlias}`)) {
            throw new error_1.FirebaseError(`Can't have both dotenv files with projectId (env.${opts.projectId}) ` +
                `and projectAlias (.env.${opts.projectAlias}) as extensions.`);
        }
    }
    let envs = {};
    for (const f of envFiles) {
        try {
            const data = fs.readFileSync(path.join(configDir, f), "utf8");
            envs = { ...envs, ...parseStrict(data) };
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to load environment variables from ${f}.`, {
                exit: 2,
                children: err.children?.length > 0 ? err.children : [err],
            });
        }
    }
    (0, utils_1.logBullet)(clc.cyan(clc.bold("functions: ")) + `Loaded environment variables from ${envFiles.join(", ")}.`);
    return envs;
}
function loadFirebaseEnvs(firebaseConfig, projectId) {
    return {
        FIREBASE_CONFIG: JSON.stringify(firebaseConfig),
        GCLOUD_PROJECT: projectId,
    };
}
function writeResolvedParams(resolvedEnvs, userEnvs, userEnvOpt) {
    const toWrite = {};
    for (const paramName of Object.keys(resolvedEnvs)) {
        const paramValue = resolvedEnvs[paramName];
        if (!paramValue.internal && !Object.prototype.hasOwnProperty.call(userEnvs, paramName)) {
            toWrite[paramName] = paramValue.toString();
        }
    }
    writeUserEnvs(toWrite, userEnvOpt);
}
