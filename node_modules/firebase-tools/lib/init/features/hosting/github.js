"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.initGitHub = initGitHub;
const colorette_1 = require("colorette");
const fs = require("fs");
const yaml = require("yaml");
const ora = require("ora");
const path = require("path");
const libsodium = require("libsodium-wrappers");
const auth_1 = require("../../../auth");
const fsutils_1 = require("../../../fsutils");
const iam_1 = require("../../../gcp/iam");
const resourceManager_1 = require("../../../gcp/resourceManager");
const logger_1 = require("../../../logger");
const prompt_1 = require("../../../prompt");
const utils_1 = require("../../../utils");
const api_1 = require("../../../api");
const apiv2_1 = require("../../../apiv2");
const error_1 = require("../../../error");
let GIT_DIR;
let GITHUB_DIR;
let WORKFLOW_DIR;
let YML_FULL_PATH_PULL_REQUEST;
let YML_FULL_PATH_MERGE;
const YML_PULL_REQUEST_FILENAME = "firebase-hosting-pull-request.yml";
const YML_MERGE_FILENAME = "firebase-hosting-merge.yml";
const CHECKOUT_GITHUB_ACTION_NAME = "actions/checkout@v4";
const HOSTING_GITHUB_ACTION_NAME = "FirebaseExtended/action-hosting-deploy@v0";
const SERVICE_ACCOUNT_MAX_KEY_NUMBER = 10;
const githubApiClient = new apiv2_1.Client({ urlPrefix: (0, api_1.githubApiOrigin)(), auth: false });
async function initGitHub(setup) {
    if (!setup.projectId) {
        return (0, utils_1.reject)("Could not determine Project ID, can't set up GitHub workflow.", { exit: 1 });
    }
    if (!setup.config.hosting && !setup.featureInfo?.hosting) {
        return (0, utils_1.reject)(`Didn't find a Hosting config in firebase.json. Run ${(0, colorette_1.bold)("firebase init hosting")} instead.`);
    }
    logger_1.logger.info();
    const gitRoot = getGitFolderPath();
    GIT_DIR = path.join(gitRoot, ".git");
    GITHUB_DIR = path.join(gitRoot, ".github");
    WORKFLOW_DIR = `${GITHUB_DIR}/workflows`;
    YML_FULL_PATH_PULL_REQUEST = `${WORKFLOW_DIR}/${YML_PULL_REQUEST_FILENAME}`;
    YML_FULL_PATH_MERGE = `${WORKFLOW_DIR}/${YML_MERGE_FILENAME}`;
    (0, utils_1.logBullet)("Authorizing with GitHub to upload your service account to a GitHub repository's secrets store.");
    const ghAccessToken = await signInWithGitHub();
    const userDetails = await getGitHubUserDetails(ghAccessToken);
    const ghUserName = userDetails.login;
    logger_1.logger.info();
    (0, utils_1.logSuccess)(`Success! Logged into GitHub as ${(0, colorette_1.bold)(ghUserName)}`);
    logger_1.logger.info();
    const { repo, key, keyId } = await promptForRepo(setup, ghAccessToken);
    const { default_branch: defaultBranch, id: repoId } = await getRepoDetails(repo, ghAccessToken);
    const githubSecretName = `FIREBASE_SERVICE_ACCOUNT_${setup.projectId
        .replace(/-/g, "_")
        .toUpperCase()}`;
    const serviceAccountName = `github-action-${repoId}`;
    const serviceAccountJSON = await createServiceAccountAndKeyWithRetry(setup, repo, serviceAccountName);
    logger_1.logger.info();
    (0, utils_1.logSuccess)(`Created service account ${(0, colorette_1.bold)(serviceAccountName)} with Firebase Hosting admin permissions.`);
    const spinnerSecrets = ora(`Uploading service account secrets to repository: ${repo}`);
    spinnerSecrets.start();
    const encryptedServiceAccountJSON = encryptServiceAccountJSON(serviceAccountJSON, key);
    await uploadSecretToGitHub(repo, ghAccessToken, await encryptedServiceAccountJSON, keyId, githubSecretName);
    spinnerSecrets.stop();
    (0, utils_1.logSuccess)(`Uploaded service account JSON to GitHub as secret ${(0, colorette_1.bold)(githubSecretName)}.`);
    (0, utils_1.logBullet)(`You can manage your secrets at https://github.com/${repo}/settings/secrets.`);
    logger_1.logger.info();
    if (!Array.isArray(setup.config.hosting) && setup.config.hosting?.predeploy) {
        (0, utils_1.logBullet)(`You have a predeploy script configured in firebase.json.`);
    }
    const { script } = await promptForBuildScript(setup?.hosting?.useWebFrameworks);
    const ymlDeployDoc = loadYMLDeploy();
    let shouldWriteYMLHostingFile = true;
    let shouldWriteYMLDeployFile = false;
    if (fs.existsSync(YML_FULL_PATH_PULL_REQUEST)) {
        const overwrite = await (0, prompt_1.confirm)({
            message: `GitHub workflow file for PR previews exists. Overwrite? ${YML_PULL_REQUEST_FILENAME}`,
        });
        shouldWriteYMLHostingFile = overwrite;
    }
    if (shouldWriteYMLHostingFile) {
        writeChannelActionYMLFile(YML_FULL_PATH_PULL_REQUEST, githubSecretName, setup.projectId, script, setup?.hosting?.useWebFrameworks, setup?.hosting?.source);
        logger_1.logger.info();
        (0, utils_1.logSuccess)(`Created workflow file ${(0, colorette_1.bold)(YML_FULL_PATH_PULL_REQUEST)}`);
    }
    const { setupDeploys, branch } = await promptToSetupDeploys(ymlDeployDoc.branch || defaultBranch);
    if (setupDeploys) {
        if (ymlDeployDoc.exists) {
            if (ymlDeployDoc.branch !== branch) {
                shouldWriteYMLDeployFile = true;
            }
            else {
                shouldWriteYMLDeployFile = await (0, prompt_1.confirm)({
                    message: `The GitHub workflow file for deploying to the live channel already exists. Overwrite? ${YML_MERGE_FILENAME}`,
                });
            }
        }
        else {
            shouldWriteYMLDeployFile = true;
        }
        if (shouldWriteYMLDeployFile) {
            writeDeployToProdActionYMLFile(YML_FULL_PATH_MERGE, branch, githubSecretName, setup.projectId, script, setup?.hosting?.useWebFrameworks, setup?.hosting?.source);
            logger_1.logger.info();
            (0, utils_1.logSuccess)(`Created workflow file ${(0, colorette_1.bold)(YML_FULL_PATH_MERGE)}`);
        }
    }
    logger_1.logger.info();
    (0, utils_1.logLabeledBullet)("Action required", `Visit this URL to revoke authorization for the Firebase CLI GitHub OAuth App:`);
    logger_1.logger.info((0, colorette_1.bold)((0, colorette_1.underline)(`https://github.com/settings/connections/applications/${(0, api_1.githubClientId)()}`)));
    (0, utils_1.logLabeledBullet)("Action required", `Push any new workflow file(s) to your repo`);
}
function getGitFolderPath() {
    const commandDir = process.cwd();
    let projectRootDir = commandDir;
    while (!fs.existsSync(path.resolve(projectRootDir, ".git"))) {
        const parentDir = path.dirname(projectRootDir);
        if (parentDir === projectRootDir) {
            (0, utils_1.logBullet)(`Didn't detect a .git folder. Assuming ${commandDir} is the project root.`);
            return commandDir;
        }
        projectRootDir = parentDir;
    }
    (0, utils_1.logBullet)(`Detected a .git folder at ${projectRootDir}`);
    return projectRootDir;
}
function defaultGithubRepo() {
    const gitConfigPath = path.join(GIT_DIR, "config");
    if (fs.existsSync(gitConfigPath)) {
        const gitConfig = fs.readFileSync(gitConfigPath, "utf8");
        const match = /github\.com:(.+)\.git/.exec(gitConfig);
        if (match) {
            return match[1];
        }
    }
    return undefined;
}
function loadYMLDeploy() {
    if (fs.existsSync(YML_FULL_PATH_MERGE)) {
        const { on } = loadYML(YML_FULL_PATH_MERGE);
        const branch = on.push.branches[0];
        return { exists: true, branch };
    }
    else {
        return { exists: false };
    }
}
function loadYML(ymlPath) {
    return yaml.parse(fs.readFileSync(ymlPath, "utf8"));
}
function mkdirNotExists(dir) {
    if (!(0, fsutils_1.dirExistsSync)(dir)) {
        fs.mkdirSync(dir);
    }
}
function writeChannelActionYMLFile(ymlPath, secretName, projectId, script, useWebFrameworks, hostingSource) {
    const workflowConfig = {
        name: "Deploy to Firebase Hosting on PR",
        on: "pull_request",
        permissions: {
            checks: "write",
            contents: "read",
            "pull-requests": "write",
        },
        jobs: {
            ["build_and_preview"]: {
                if: "${{ github.event.pull_request.head.repo.full_name == github.repository }}",
                "runs-on": "ubuntu-latest",
                steps: [{ uses: CHECKOUT_GITHUB_ACTION_NAME }],
            },
        },
    };
    const buildAndPreviewParams = {
        uses: HOSTING_GITHUB_ACTION_NAME,
        with: {
            repoToken: "${{ secrets.GITHUB_TOKEN }}",
            firebaseServiceAccount: `\${{ secrets.${secretName} }}`,
            projectId: projectId,
        },
    };
    if (useWebFrameworks) {
        workflowConfig.jobs.build_and_preview.steps.push({ run: "npm ci" });
        buildAndPreviewParams.env = {
            FIREBASE_CLI_EXPERIMENTS: "webframeworks",
        };
        if (hostingSource && hostingSource !== ".") {
            workflowConfig.jobs.build_and_preview.defaults = {
                run: { "working-directory": hostingSource },
            };
        }
    }
    if (script) {
        workflowConfig.jobs.build_and_preview.steps.push({
            run: script,
        });
    }
    workflowConfig.jobs.build_and_preview.steps.push(buildAndPreviewParams);
    const ymlContents = `# This file was auto-generated by the Firebase CLI
# https://github.com/firebase/firebase-tools

${yaml.stringify(workflowConfig)}`;
    mkdirNotExists(GITHUB_DIR);
    mkdirNotExists(WORKFLOW_DIR);
    fs.writeFileSync(ymlPath, ymlContents, "utf8");
}
function writeDeployToProdActionYMLFile(ymlPath, branch, secretName, projectId, script, useWebFrameworks, hostingSource) {
    const workflowConfig = {
        name: "Deploy to Firebase Hosting on merge",
        on: { push: { branches: [branch || "master"] } },
        jobs: {
            ["build_and_deploy"]: {
                "runs-on": "ubuntu-latest",
                steps: [{ uses: CHECKOUT_GITHUB_ACTION_NAME }],
            },
        },
    };
    const buildAndDeployParams = {
        uses: HOSTING_GITHUB_ACTION_NAME,
        with: {
            repoToken: "${{ secrets.GITHUB_TOKEN }}",
            firebaseServiceAccount: `\${{ secrets.${secretName} }}`,
            channelId: "live",
            projectId: projectId,
        },
    };
    if (useWebFrameworks) {
        workflowConfig.jobs.build_and_deploy.steps.push({ run: "npm ci" });
        buildAndDeployParams.env = {
            FIREBASE_CLI_EXPERIMENTS: "webframeworks",
        };
        if (hostingSource && hostingSource !== ".") {
            workflowConfig.jobs.build_and_deploy.defaults = {
                run: { "working-directory": hostingSource },
            };
        }
    }
    if (script) {
        workflowConfig.jobs.build_and_deploy.steps.push({ run: script });
    }
    workflowConfig.jobs.build_and_deploy.steps.push(buildAndDeployParams);
    const ymlContents = `# This file was auto-generated by the Firebase CLI
# https://github.com/firebase/firebase-tools

${yaml.stringify(workflowConfig)}`;
    mkdirNotExists(GITHUB_DIR);
    mkdirNotExists(WORKFLOW_DIR);
    fs.writeFileSync(ymlPath, ymlContents, "utf8");
}
async function uploadSecretToGitHub(repo, ghAccessToken, encryptedServiceAccountJSON, keyId, secretName) {
    const data = {
        ["encrypted_value"]: encryptedServiceAccountJSON,
        ["key_id"]: keyId,
    };
    const headers = { Authorization: `token ${ghAccessToken}`, "User-Agent": "Firebase CLI" };
    return await githubApiClient.put(`/repos/${repo}/actions/secrets/${secretName}`, data, { headers });
}
async function promptForRepo(options, ghAccessToken) {
    let key = "";
    let keyId = "";
    const repo = options.repo ||
        (await (0, prompt_1.input)({
            default: defaultGithubRepo(),
            message: "For which GitHub repository would you like to set up a GitHub workflow? (format: user/repository)",
            validate: async (repo) => {
                try {
                    const { body } = await githubApiClient.get(`/repos/${repo}/actions/secrets/public-key`, {
                        headers: { Authorization: `token ${ghAccessToken}`, "User-Agent": "Firebase CLI" },
                        queryParams: { type: "owner" },
                    });
                    key = body.key;
                    keyId = body.key_id;
                }
                catch (e) {
                    if ([403, 404].includes(e.status)) {
                        logger_1.logger.info();
                        logger_1.logger.info();
                        (0, utils_1.logWarning)("The provided authorization cannot be used with this repository. If this repository is in an organization, did you remember to grant access?", "error");
                        logger_1.logger.info();
                        (0, utils_1.logLabeledBullet)("Action required", `Visit this URL to ensure access has been granted to the appropriate organization(s) for the Firebase CLI GitHub OAuth App:`);
                        logger_1.logger.info((0, colorette_1.bold)((0, colorette_1.underline)(`https://github.com/settings/connections/applications/${(0, api_1.githubClientId)()}`)));
                        logger_1.logger.info();
                    }
                    return false;
                }
                return true;
            },
        }));
    options.repo = repo;
    return { repo, key, keyId };
}
async function promptForBuildScript(useWebFrameworks) {
    const shouldSetupScript = await (0, prompt_1.confirm)({
        message: "Set up the workflow to run a build script before every deploy?",
    });
    if (!shouldSetupScript) {
        return { script: undefined };
    }
    const script = await (0, prompt_1.input)({
        default: useWebFrameworks ? undefined : "npm ci && npm run build",
        message: "What script should be run before every deploy?",
    });
    return { script };
}
async function promptToSetupDeploys(defaultBranch) {
    const setupDeploys = await (0, prompt_1.confirm)({
        default: true,
        message: "Set up automatic deployment to your site's live channel when a PR is merged?",
    });
    if (!setupDeploys) {
        return { setupDeploys };
    }
    const branch = await (0, prompt_1.input)({
        default: defaultBranch,
        message: "What is the name of the GitHub branch associated with your site's live channel?",
    });
    return { branch, setupDeploys };
}
async function getGitHubUserDetails(ghAccessToken) {
    const { body: ghUserDetails } = await githubApiClient.get("/user", {
        headers: { Authorization: `token ${ghAccessToken}`, "User-Agent": "Firebase CLI" },
    });
    return ghUserDetails;
}
async function getRepoDetails(repo, ghAccessToken) {
    const { body } = await githubApiClient.get(`/repos/${repo}`, {
        headers: { Authorization: `token ${ghAccessToken}`, "User-Agent": "Firebase CLI" },
    });
    return body;
}
async function signInWithGitHub() {
    return await (0, auth_1.loginGithub)();
}
async function createServiceAccountAndKeyWithRetry(options, repo, accountId) {
    const spinnerServiceAccount = ora("Retrieving a service account.");
    spinnerServiceAccount.start();
    try {
        const serviceAccountJSON = await createServiceAccountAndKey(options, repo, accountId);
        spinnerServiceAccount.stop();
        return serviceAccountJSON;
    }
    catch (e) {
        spinnerServiceAccount.stop();
        if (!e.message.includes("429")) {
            const serviceAccountKeys = await (0, iam_1.listServiceAccountKeys)(options.projectId, accountId);
            if (serviceAccountKeys.length >= SERVICE_ACCOUNT_MAX_KEY_NUMBER) {
                throw new error_1.FirebaseError(`You cannot add another key because the service account ${(0, colorette_1.bold)(accountId)} already contains the max number of keys: ${SERVICE_ACCOUNT_MAX_KEY_NUMBER}.`, {
                    original: e,
                    exit: 1,
                });
            }
            throw e;
        }
        spinnerServiceAccount.start();
        await (0, iam_1.deleteServiceAccount)(options.projectId, `${accountId}@${options.projectId}.iam.gserviceaccount.com`);
        const serviceAccountJSON = await createServiceAccountAndKey(options, repo, accountId);
        spinnerServiceAccount.stop();
        return serviceAccountJSON;
    }
}
async function createServiceAccountAndKey(options, repo, accountId) {
    try {
        await (0, iam_1.createServiceAccount)(options.projectId, accountId, `A service account with permission to deploy to Firebase Hosting and Cloud Functions for the GitHub repository ${repo}`, `GitHub Actions (${repo})`);
    }
    catch (e) {
        if (!e.message.includes("409")) {
            throw e;
        }
    }
    const requiredRoles = [
        resourceManager_1.firebaseRoles.authAdmin,
        resourceManager_1.firebaseRoles.serviceUsageConsumer,
        resourceManager_1.firebaseRoles.apiKeysViewer,
        resourceManager_1.firebaseRoles.hostingAdmin,
        resourceManager_1.firebaseRoles.runViewer,
        resourceManager_1.firebaseRoles.functionsDeveloper,
    ];
    await (0, resourceManager_1.addServiceAccountToRoles)(options.projectId, accountId, requiredRoles);
    const serviceAccountKey = await (0, iam_1.createServiceAccountKey)(options.projectId, accountId);
    const buf = Buffer.from(serviceAccountKey.privateKeyData, "base64");
    const serviceAccountJSON = buf.toString();
    return serviceAccountJSON;
}
async function encryptServiceAccountJSON(serviceAccountJSON, key) {
    const messageBytes = Buffer.from(serviceAccountJSON);
    const keyBytes = Buffer.from(key, "base64");
    await libsodium.ready;
    const encryptedBytes = libsodium.crypto_box_seal(messageBytes, keyBytes);
    return Buffer.from(encryptedBytes).toString("base64");
}
