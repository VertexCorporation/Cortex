"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const error_1 = require("../error");
const projectUtils_1 = require("../projectUtils");
const prompt_1 = require("../prompt");
const requirePermissions_1 = require("../requirePermissions");
const requireAuth_1 = require("../requireAuth");
const utils_1 = require("../utils");
const artifactregistry = require("../gcp/artifactregistry");
const artifacts = require("../functions/artifacts");
exports.command = new command_1.Command("functions:artifacts:setpolicy")
    .description("set up a cleanup policy for Cloud Run functions container images in Artifact Registry " +
    "to automatically delete old function images")
    .option("--location <location>", "specify location to set up the cleanup policy. " +
    "If omitted, uses the default functions location", "us-central1")
    .option("--days <days>", `number of days to keep container images before deletion. Default is ${artifacts.DEFAULT_CLEANUP_DAYS} day`)
    .option("--none", "opt-out from cleanup policy. This will prevent suggestions to set up a cleanup policy during initialization and deployment")
    .withForce("automatically create or modify cleanup policy")
    .before(requireAuth_1.requireAuth)
    .before(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    await artifactregistry.ensureApiEnabled(projectId);
})
    .before(requirePermissions_1.requirePermissions, [
    "artifactregistry.repositories.update",
    "artifactregistry.versions.delete",
])
    .action(async (options) => {
    if (options.days && options.none) {
        throw new error_1.FirebaseError("Cannot specify both --days and --none options.");
    }
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const location = options.location || "us-central1";
    let daysToKeep = parseInt(options.days || artifacts.DEFAULT_CLEANUP_DAYS, 10);
    const repoPath = artifacts.makeRepoPath(projectId, location);
    let repository;
    try {
        repository = await artifactregistry.getRepository(repoPath);
    }
    catch (err) {
        if (err.status === 404) {
            (0, utils_1.logBullet)(`Repository '${repoPath}' does not exist in Artifact Registry.`);
            (0, utils_1.logBullet)(`Please deploy your functions first using: ` +
                `${clc.bold(`firebase deploy --only functions`)}`);
            return;
        }
        throw err;
    }
    if (options.none) {
        const existingPolicy = artifacts.findExistingPolicy(repository);
        if (artifacts.hasCleanupOptOut(repository) && !existingPolicy) {
            (0, utils_1.logBullet)(`Repository '${repoPath}' is already opted out from cleanup policies.`);
            (0, utils_1.logBullet)(`No changes needed.`);
            return;
        }
        (0, utils_1.logBullet)(`You are about to opt-out from cleanup policy for repository '${repoPath}'.`);
        (0, utils_1.logBullet)(`This will prevent suggestions to set up cleanup policy during initialization and deployment.`);
        if (existingPolicy) {
            (0, utils_1.logBullet)(`Note: This will remove the existing cleanup policy from the repository.`);
        }
        const confirmOptOut = await (0, prompt_1.confirm)({
            message: "Do you want to continue?",
            default: true,
            force: options.force,
            nonInteractive: options.nonInteractive,
        });
        if (!confirmOptOut) {
            throw new error_1.FirebaseError("Command aborted.", { exit: 1 });
        }
        try {
            await artifacts.optOutRepository(repository);
            (0, utils_1.logSuccess)(`Successfully opted out from cleanup policy for ${clc.bold(repoPath)}`);
            return;
        }
        catch (err) {
            throw new error_1.FirebaseError("Failed to opt-out from artifact registry cleanup policy", {
                original: err,
            });
        }
    }
    if (isNaN(daysToKeep) || daysToKeep < 0) {
        throw new error_1.FirebaseError("Days must be a non-negative number");
    }
    if (daysToKeep === 0) {
        daysToKeep = 0.003472;
    }
    if (artifacts.hasSameCleanupPolicy(repository, daysToKeep)) {
        (0, utils_1.logBullet)(`A cleanup policy already exists that deletes images older than ${clc.bold(daysToKeep)} days.`);
        (0, utils_1.logBullet)(`No changes needed.`);
        return;
    }
    (0, utils_1.logBullet)(`You are about to set up a cleanup policy for Cloud Run functions container images in location ${clc.bold(location)}`);
    (0, utils_1.logBullet)(`This policy will automatically delete container images that are older than ${clc.bold(daysToKeep)} days`);
    (0, utils_1.logBullet)("This helps reduce storage costs by removing old container images that are no longer needed");
    const existingPolicy = artifacts.findExistingPolicy(repository);
    let isUpdate = false;
    if (existingPolicy && existingPolicy.condition?.olderThan) {
        const existingDays = artifacts.parseDaysFromPolicy(existingPolicy.condition.olderThan);
        if (existingDays) {
            isUpdate = true;
            (0, utils_1.logBullet)(`Note: This will update an existing policy that currently deletes images older than ${clc.bold(existingDays)} days`);
        }
    }
    if (artifacts.hasCleanupOptOut(repository)) {
        (0, utils_1.logBullet)(`Note: This repository was previously opted out from cleanup policy. This action will remove the opt-out status.`);
    }
    const confirmSetup = await (0, prompt_1.confirm)({
        message: "Do you want to continue?",
        default: true,
        force: options.force,
        nonInteractive: options.nonInteractive,
    });
    if (!confirmSetup) {
        throw new error_1.FirebaseError("Command aborted.", { exit: 1 });
    }
    try {
        await artifacts.setCleanupPolicy(repository, daysToKeep);
        const successMessage = isUpdate
            ? `Successfully updated cleanup policy to delete images older than ${clc.bold(daysToKeep)} days`
            : `Successfully set up cleanup policy that deletes images older than ${clc.bold(daysToKeep)} days`;
        (0, utils_1.logSuccess)(successMessage);
        (0, utils_1.logBullet)(`Cleanup policy has been set for ${clc.bold(repoPath)}`);
    }
    catch (err) {
        throw new error_1.FirebaseError("Failed to set up artifact registry cleanup policy", {
            original: err,
        });
    }
});
