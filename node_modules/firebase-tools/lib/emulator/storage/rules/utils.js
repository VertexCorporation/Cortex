"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getFirebaseRulesValidator = getFirebaseRulesValidator;
exports.getAdminOnlyFirebaseRulesValidator = getAdminOnlyFirebaseRulesValidator;
exports.getAdminCredentialValidator = getAdminCredentialValidator;
exports.isPermitted = isPermitted;
const emulatorLogger_1 = require("../../emulatorLogger");
const types_1 = require("../../types");
function getFirebaseRulesValidator(rulesetProvider) {
    return {
        validate: async (path, bucketId, method, variableOverrides, projectId, authorization, delimiter) => {
            return await isPermitted({
                ruleset: rulesetProvider(bucketId),
                file: variableOverrides,
                path,
                method,
                projectId,
                authorization,
                delimiter,
            });
        },
    };
}
function getAdminOnlyFirebaseRulesValidator() {
    return {
        validate: (_path, _bucketId, _method, _variableOverrides, _authorization, delimiter) => {
            return Promise.resolve(true);
        },
    };
}
function getAdminCredentialValidator() {
    return { validate: isValidAdminCredentials };
}
async function isPermitted(opts) {
    if (!opts.ruleset) {
        emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.STORAGE).log("WARN", `Can not process SDK request with no loaded ruleset`);
        return false;
    }
    if (isValidAdminCredentials(opts.authorization)) {
        return true;
    }
    const { permitted, issues } = await opts.ruleset.verify({
        method: opts.method,
        path: opts.path,
        file: opts.file,
        projectId: opts.projectId,
        token: opts.authorization ? opts.authorization.split(" ")[1] : undefined,
        delimiter: opts.delimiter,
    });
    if (issues.exist()) {
        issues.all.forEach((warningOrError) => {
            emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.STORAGE).log("WARN", warningOrError);
        });
    }
    return !!permitted;
}
function isValidAdminCredentials(authorization) {
    return ["Bearer owner", "Firebase owner"].includes(authorization ?? "");
}
