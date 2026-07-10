"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getRepoCache = exports.DEFAULT_CLEANUP_DAYS = exports.OPT_OUT_LABEL_KEY = exports.CLEANUP_POLICY_ID = exports.GCF_REPO_ID = void 0;
exports.makeRepoPath = makeRepoPath;
exports.getRepo = getRepo;
exports.findExistingPolicy = findExistingPolicy;
exports.daysToSeconds = daysToSeconds;
exports.parseDaysFromPolicy = parseDaysFromPolicy;
exports.generateCleanupPolicy = generateCleanupPolicy;
exports.updateRepository = updateRepository;
exports.optOutRepository = optOutRepository;
exports.setCleanupPolicy = setCleanupPolicy;
exports.hasSameCleanupPolicy = hasSameCleanupPolicy;
exports.hasCleanupOptOut = hasCleanupOptOut;
exports.checkCleanupPolicy = checkCleanupPolicy;
exports.setCleanupPolicies = setCleanupPolicies;
const artifactregistry = require("../gcp/artifactregistry");
const logger_1 = require("../logger");
const error_1 = require("../error");
exports.GCF_REPO_ID = "gcf-artifacts";
exports.CLEANUP_POLICY_ID = "firebase-functions-cleanup";
exports.OPT_OUT_LABEL_KEY = "firebase-functions-cleanup-opted-out";
exports.DEFAULT_CLEANUP_DAYS = 1;
const SECONDS_IN_DAY = 24 * 60 * 60;
function makeRepoPath(projectId, location, repoName = exports.GCF_REPO_ID) {
    return `projects/${projectId}/locations/${location}/repositories/${repoName}`;
}
exports.getRepoCache = new Map();
async function getRepo(projectId, location, forceRefresh = false, repoName = exports.GCF_REPO_ID) {
    const repoPath = makeRepoPath(projectId, location, repoName);
    if (!forceRefresh && exports.getRepoCache.has(repoPath)) {
        return exports.getRepoCache.get(repoPath);
    }
    const repo = await artifactregistry.getRepository(repoPath);
    exports.getRepoCache.set(repoPath, repo);
    return repo;
}
function findExistingPolicy(repository) {
    return repository?.cleanupPolicies?.[exports.CLEANUP_POLICY_ID];
}
function daysToSeconds(days) {
    const seconds = days * SECONDS_IN_DAY;
    return `${seconds}s`;
}
function parseDaysFromPolicy(olderThan) {
    const match = olderThan.match(/^(\d+)s$/);
    if (match && match[1]) {
        const seconds = parseInt(match[1], 10);
        return Math.floor(seconds / SECONDS_IN_DAY);
    }
    return;
}
function generateCleanupPolicy(daysToKeep) {
    return {
        [exports.CLEANUP_POLICY_ID]: {
            id: exports.CLEANUP_POLICY_ID,
            condition: {
                tagState: "ANY",
                olderThan: daysToSeconds(daysToKeep),
            },
            action: "DELETE",
        },
    };
}
async function updateRepository(repo) {
    try {
        await artifactregistry.updateRepository(repo);
    }
    catch (err) {
        if (err.status === 403) {
            throw new error_1.FirebaseError(`You don't have permission to update this repository.\n` +
                `To update repository settings, ask your administrator to grant you the ` +
                `Artifact Registry Administrator (roles/artifactregistry.admin) IAM role on the repository project.`, { original: err, exit: 1 });
        }
        else {
            throw new error_1.FirebaseError("Failed to update artifact registry repository", {
                original: err,
            });
        }
    }
}
async function optOutRepository(repository) {
    const policies = {
        ...repository.cleanupPolicies,
    };
    if (exports.CLEANUP_POLICY_ID in policies) {
        delete policies[exports.CLEANUP_POLICY_ID];
    }
    const update = {
        name: repository.name,
        labels: { ...repository.labels, [exports.OPT_OUT_LABEL_KEY]: "true" },
        cleanupPolicies: policies,
    };
    await exports.updateRepository(update);
}
async function setCleanupPolicy(repository, daysToKeep) {
    const labels = { ...repository.labels };
    delete labels[exports.OPT_OUT_LABEL_KEY];
    const update = {
        name: repository.name,
        cleanupPolicies: {
            ...repository.cleanupPolicies,
            ...generateCleanupPolicy(daysToKeep),
        },
        cleanupPolicyDryRun: false,
        labels,
    };
    await exports.updateRepository(update);
}
function hasSameCleanupPolicy(repository, daysToKeep) {
    const existingPolicy = findExistingPolicy(repository);
    if (!existingPolicy) {
        return false;
    }
    if (existingPolicy.condition?.tagState !== "ANY" || !existingPolicy.condition?.olderThan) {
        return false;
    }
    const existingSeconds = parseDaysFromPolicy(existingPolicy.condition.olderThan);
    return existingSeconds === daysToKeep;
}
function hasCleanupOptOut(repo) {
    return !!(repo.labels && repo.labels[exports.OPT_OUT_LABEL_KEY] === "true");
}
async function checkCleanupPolicy(projectId, locations) {
    if (locations.length === 0) {
        return { locationsToSetup: [], locationsWithErrors: [] };
    }
    const checkRepos = await Promise.allSettled(locations.map(async (location) => {
        try {
            const repository = await exports.getRepo(projectId, location);
            const hasPolicy = !!findExistingPolicy(repository);
            const hasOptOut = hasCleanupOptOut(repository);
            const hasOtherPolicies = repository.cleanupPolicies &&
                Object.keys(repository.cleanupPolicies).some((key) => key !== exports.CLEANUP_POLICY_ID);
            return {
                location,
                repository,
                hasPolicy,
                hasOptOut,
                hasOtherPolicies,
            };
        }
        catch (err) {
            logger_1.logger.debug(`Failed to check artifact cleanup policy for region ${location}:`, err);
            throw err;
        }
    }));
    const locationsToSetup = [];
    const locationsWithErrors = [];
    for (let i = 0; i < checkRepos.length; i++) {
        const result = checkRepos[i];
        if (result.status === "fulfilled") {
            if (!(result.value.hasPolicy || result.value.hasOptOut || result.value.hasOtherPolicies)) {
                locationsToSetup.push(result.value.location);
            }
        }
        else {
            locationsWithErrors.push(locations[i]);
        }
    }
    return { locationsToSetup, locationsWithErrors };
}
async function setCleanupPolicies(projectId, locations, daysToKeep) {
    if (locations.length === 0)
        return { locationsWithPolicy: [], locationsWithErrors: [] };
    const locationsWithPolicy = [];
    const locationsWithErrors = [];
    const setupRepos = await Promise.allSettled(locations.map(async (location) => {
        try {
            logger_1.logger.debug(`Setting up artifact cleanup policy for region ${location}`);
            const repo = await exports.getRepo(projectId, location);
            await exports.setCleanupPolicy(repo, daysToKeep);
            return location;
        }
        catch (err) {
            throw new error_1.FirebaseError("Failed to set up artifact cleanup policy", {
                original: err,
            });
        }
    }));
    for (let i = 0; i < locations.length; i++) {
        const location = locations[i];
        const result = setupRepos[i];
        if (result.status === "rejected") {
            logger_1.logger.debug(`Failed to set up artifact cleanup policy for region ${location}:`, result.reason);
            locationsWithErrors.push(location);
        }
        else {
            locationsWithPolicy.push(location);
        }
    }
    return {
        locationsWithPolicy,
        locationsWithErrors,
    };
}
