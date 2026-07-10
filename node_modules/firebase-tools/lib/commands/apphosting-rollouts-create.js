"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const apphosting = require("../gcp/apphosting");
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const requireAuth_1 = require("../requireAuth");
const error_1 = require("../error");
const rollout_1 = require("../apphosting/rollout");
exports.command = new command_1.Command("apphosting:rollouts:create <backendId>")
    .description("create a rollout using a build for an App Hosting backend")
    .option("-b, --git-branch <gitBranch>", "repository branch to deploy (mutually exclusive with -g)")
    .option("-g, --git-commit <gitCommit>", "git commit to deploy (mutually exclusive with -b)")
    .withForce("Skip confirmation before creating rollout")
    .before(requireAuth_1.requireAuth)
    .before(apphosting.ensureApiEnabled)
    .action(async (backendId, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const branch = options.gitBranch;
    const commit = options.gitCommit;
    if (branch && commit) {
        throw new error_1.FirebaseError("Cannot specify both a branch and commit to deploy. Please specify either --git-branch or --git-commit.");
    }
    await (0, rollout_1.createRollout)(backendId, projectId, branch, commit, options.force);
});
