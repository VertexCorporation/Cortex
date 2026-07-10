"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.toMulti = toMulti;
exports.serviceAccountsForBackend = serviceAccountsForBackend;
exports.grantSecretAccess = grantSecretAccess;
exports.grantEmailsSecretAccess = grantEmailsSecretAccess;
exports.revokeSecretAccess = revokeSecretAccess;
exports.revokeEmailsSecretAccess = revokeEmailsSecretAccess;
exports.upsertSecret = upsertSecret;
exports.loadSecret = loadSecret;
exports.fetchSecrets = fetchSecrets;
exports.getSecretNameParts = getSecretNameParts;
exports.apphostingSecretsSetAction = apphostingSecretsSetAction;
const clc = require("colorette");
const error_1 = require("../../error");
const gcsm = require("../../gcp/secretManager");
const gcb = require("../../gcp/cloudbuild");
const gce = require("../../gcp/computeEngine");
const apphosting = require("../../gcp/apphosting");
const secretManager_1 = require("../../gcp/secretManager");
const secretManager_2 = require("../../gcp/secretManager");
const utils = require("../../utils");
const prompt = require("../../prompt");
const dialogs = require("../../apphosting/secrets/dialogs");
const config = require("../../apphosting/config");
const projects_1 = require("../../management/projects");
function toMulti(accounts) {
    const m = {
        buildServiceAccounts: [accounts.buildServiceAccount],
        runServiceAccounts: [],
    };
    if (accounts.buildServiceAccount !== accounts.runServiceAccount) {
        m.runServiceAccounts.push(accounts.runServiceAccount);
    }
    return m;
}
async function serviceAccountsForBackend(projectNumber, backend) {
    if (backend.serviceAccount) {
        return {
            buildServiceAccount: backend.serviceAccount,
            runServiceAccount: backend.serviceAccount,
        };
    }
    return {
        buildServiceAccount: gcb.getDefaultServiceAccount(projectNumber),
        runServiceAccount: await gce.getDefaultServiceAccount(projectNumber),
    };
}
async function grantSecretAccess(projectId, projectNumber, secretName, accounts) {
    const p4saEmail = apphosting.serviceAgentEmail(projectNumber);
    const newBindings = [
        {
            role: "roles/secretmanager.secretAccessor",
            members: [...accounts.buildServiceAccounts, ...accounts.runServiceAccounts].map((sa) => `serviceAccount:${sa}`),
        },
        {
            role: "roles/secretmanager.viewer",
            members: accounts.buildServiceAccounts.map((sa) => `serviceAccount:${sa}`),
        },
        {
            role: "roles/secretmanager.secretVersionManager",
            members: [`serviceAccount:${p4saEmail}`],
        },
    ];
    let existingBindings;
    try {
        existingBindings = (await gcsm.getIamPolicy({ projectId, name: secretName })).bindings || [];
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to get IAM bindings on secret: ${secretName}. Ensure you have the permissions to do so and try again.`, { original: (0, error_1.getError)(err) });
    }
    const updatedBindings = existingBindings.concat(newBindings);
    try {
        await gcsm.setIamPolicy({ projectId, name: secretName }, updatedBindings);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to set IAM bindings ${JSON.stringify(newBindings)} on secret: ${secretName}. Ensure you have the permissions to do so and try again. ` +
            "For more information visit https://cloud.google.com/secret-manager/docs/manage-access-to-secrets#required-roles", { original: (0, error_1.getError)(err) });
    }
    utils.logSuccess(`Successfully set IAM bindings on secret ${secretName}.\n`);
}
async function grantEmailsSecretAccess(projectId, secretNames, emails) {
    const typeGuesses = Object.fromEntries(emails.map((email) => [email, "user"]));
    for (const secretName of secretNames) {
        let existingBindings;
        try {
            existingBindings = (await gcsm.getIamPolicy({ projectId, name: secretName })).bindings || [];
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to get IAM bindings on secret: ${secretName}. Ensure you have the permissions to do so and try again. ` +
                "For more information visit https://cloud.google.com/secret-manager/docs/manage-access-to-secrets#required-roles", { original: (0, error_1.getError)(err) });
        }
        do {
            try {
                const newBindings = [
                    {
                        role: "roles/secretmanager.secretAccessor",
                        members: Object.entries(typeGuesses).map(([email, type]) => `${type}:${email}`),
                    },
                ];
                const updatedBindings = existingBindings.concat(newBindings);
                await gcsm.setIamPolicy({ projectId, name: secretName }, updatedBindings);
                break;
            }
            catch (err) {
                if (!(err instanceof error_1.FirebaseError)) {
                    throw new error_1.FirebaseError(`Unexpected error updating IAM bindings on secret: ${secretName}`, {
                        original: (0, error_1.getError)(err),
                    });
                }
                const match = /Principal (.*) is of type "([^"]+)"/.exec(err.message);
                if (!match) {
                    throw new error_1.FirebaseError(`Failed to set IAM bindings on secret: ${secretName}. Ensure you have the permissions to do so and try again.`, { original: (0, error_1.getError)(err) });
                }
                typeGuesses[match[1]] = match[2];
                continue;
            }
        } while (true);
        utils.logSuccess(`Successfully set IAM bindings on secret ${secretName}.\n`);
    }
}
async function revokeSecretAccess(projectId, secretName, accounts) {
    const bindingsToRevoke = [
        {
            role: "roles/secretmanager.secretAccessor",
            members: [...accounts.buildServiceAccounts, ...accounts.runServiceAccounts].map((sa) => `serviceAccount:${sa}`),
        },
        {
            role: "roles/secretmanager.viewer",
            members: accounts.buildServiceAccounts.map((sa) => `serviceAccount:${sa}`),
        },
    ];
    await revokeSecretBindings(projectId, secretName, bindingsToRevoke);
}
async function revokeEmailsSecretAccess(projectId, secretNames, emails) {
    const bindingsToRevoke = [
        {
            role: "roles/secretmanager.secretAccessor",
            members: emails.flatMap((email) => [`user:${email}`, `group:${email}`]),
        },
    ];
    for (const secretName of secretNames) {
        await revokeSecretBindings(projectId, secretName, bindingsToRevoke);
    }
}
async function revokeSecretBindings(projectId, secretName, bindingsToRevoke) {
    let existingBindings;
    try {
        existingBindings = (await gcsm.getIamPolicy({ projectId, name: secretName })).bindings || [];
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to get IAM bindings on secret: ${secretName}. Ensure you have the permissions to do so and try again.`, { original: (0, error_1.getError)(err) });
    }
    const removalsByRole = new Map();
    for (const binding of bindingsToRevoke) {
        let members = removalsByRole.get(binding.role);
        if (!members) {
            members = new Set();
            removalsByRole.set(binding.role, members);
        }
        for (const member of binding.members) {
            members.add(member);
        }
    }
    let updated = false;
    const bindings = [];
    for (const binding of existingBindings) {
        const removals = removalsByRole.get(binding.role);
        if (!removals || binding.condition) {
            bindings.push(binding);
            continue;
        }
        const members = binding.members.filter((member) => !removals.has(member));
        if (members.length !== binding.members.length) {
            updated = true;
        }
        if (members.length) {
            bindings.push({ ...binding, members });
        }
        else {
            updated = true;
        }
    }
    if (!updated) {
        utils.logSuccess(`No matching IAM bindings found on secret ${secretName}.\n`);
        return;
    }
    try {
        await gcsm.setIamPolicy({ projectId, name: secretName }, bindings);
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to revoke IAM bindings ${JSON.stringify(bindingsToRevoke)} on secret: ${secretName}. Ensure you have the permissions to do so and try again. ` +
            "For more information visit https://cloud.google.com/secret-manager/docs/manage-access-to-secrets#required-roles", { original: (0, error_1.getError)(err) });
    }
    utils.logSuccess(`Successfully revoked IAM bindings on secret ${secretName}.\n`);
}
async function upsertSecret(project, secret, location) {
    let existing;
    try {
        existing = await gcsm.getSecret(project, secret);
    }
    catch (err) {
        if ((0, error_1.getErrStatus)(err) !== 404) {
            throw new error_1.FirebaseError("Unexpected error loading secret", { original: (0, error_1.getError)(err) });
        }
        await gcsm.createSecret(project, secret, gcsm.labels("apphosting"), location);
        return true;
    }
    const replication = existing.replication?.userManaged;
    if (location &&
        (replication?.replicas?.length !== 1 || replication?.replicas?.[0]?.location !== location)) {
        utils.logLabeledError("apphosting", "Secret replication policies cannot be changed after creation");
        return null;
    }
    if ((0, secretManager_2.isFunctionsManaged)(existing)) {
        utils.logLabeledWarning("apphosting", `Cloud Functions for Firebase currently manages versions of ${secret}. Continuing will disable ` +
            "automatic deletion of old versions.");
        const stopTracking = await prompt.confirm({
            message: "Do you wish to continue?",
            default: false,
        });
        if (!stopTracking) {
            return null;
        }
        delete existing.labels[secretManager_1.FIREBASE_MANAGED];
        await gcsm.patchSecret(project, secret, existing.labels);
    }
    return false;
}
const secretResourceRegex = /^projects\/([^/]+)\/secrets\/([^/]+)(?:\/versions\/((?:latest)|\d+))?$/;
const secretShorthandRegex = /^([^/@]+)(?:@((?:latest)|\d+))?$/;
async function loadSecret(project, name) {
    let projectId;
    let secretId;
    let version;
    const match = secretResourceRegex.exec(name);
    if (match) {
        projectId = match[1];
        secretId = match[2];
        version = match[3] || "latest";
    }
    else {
        const match = secretShorthandRegex.exec(name);
        if (!match) {
            throw new error_1.FirebaseError(`Invalid secret name: ${name}`);
        }
        if (!project) {
            throw new error_1.FirebaseError(`Cannot load secret ${match[1]} without a project. ` +
                `Please use ${clc.bold("firebase use")} or pass the --project flag.`);
        }
        projectId = project;
        secretId = match[1];
        version = match[2] || "latest";
    }
    try {
        return await gcsm.accessSecretVersion(projectId, secretId, version);
    }
    catch (err) {
        if (err instanceof error_1.FirebaseError) {
            const original = err.original;
            if (typeof original === "object" && original !== null) {
                if (original.code === 403 ||
                    original.context?.response?.statusCode === 403) {
                    utils.logLabeledError("apphosting", `Permission denied to access secret ${secretId}. Use ` +
                        `${clc.bold("firebase apphosting:secrets:grantaccess")} to get permissions.`);
                }
            }
        }
        throw err;
    }
}
async function fetchSecrets(projectId, secrets) {
    let secretsKeyValuePairs;
    try {
        const secretPromises = secrets.map(async (secretConfig) => {
            const [name, version] = getSecretNameParts(secretConfig.secret);
            const value = await gcsm.accessSecretVersion(projectId, name, version);
            return [secretConfig.variable, value];
        });
        const secretEntries = await Promise.all(secretPromises);
        secretsKeyValuePairs = new Map(secretEntries);
    }
    catch (e) {
        throw new error_1.FirebaseError(`Error exporting secrets`, {
            original: e,
        });
    }
    return secretsKeyValuePairs;
}
function getSecretNameParts(secret) {
    let [name, version] = secret.split("@");
    if (!version) {
        version = "latest";
    }
    return [name, version];
}
async function apphostingSecretsSetAction(secretName, projectId, projectNumber, location, dataFile, nonInteractive) {
    if (!projectNumber) {
        projectNumber = (await (0, projects_1.getProject)(projectId)).projectNumber;
    }
    const created = await upsertSecret(projectId, secretName, location);
    if (created === null) {
        return;
    }
    else if (created) {
        utils.logSuccess(`Created new secret projects/${projectId}/secrets/${secretName}`);
    }
    const secretValue = await utils.readSecretValue(`Enter a value for ${secretName}`, dataFile);
    const version = await gcsm.addVersion(projectId, secretName, secretValue);
    utils.logSuccess(`Created new secret version ${gcsm.toSecretVersionResourceName(version)}`);
    utils.logBullet(`You can access the contents of the secret's latest value with ${clc.bold(`firebase apphosting:secrets:access ${secretName}\n`)}`);
    if (!created) {
        return;
    }
    const type = await prompt.select({
        message: "Is this secret for production or only local testing?",
        choices: [
            { name: "Production", value: "production" },
            { name: "Local testing only", value: "local" },
        ],
        nonInteractive: !!nonInteractive,
        default: "production",
    });
    if (type === "local") {
        const emailList = await prompt.input({
            message: "Please enter a comma separated list of user or groups who should have access to this secret:",
        });
        if (emailList.length) {
            await grantEmailsSecretAccess(projectId, [secretName], emailList.split(","));
        }
        else {
            utils.logBullet("To grant access in the future run " +
                clc.bold(`firebase apphosting:secrets:grantaccess ${secretName} --emails [email list]`));
        }
        await config.maybeAddSecretToYaml(secretName, config.APPHOSTING_EMULATORS_YAML_FILE);
        return;
    }
    const accounts = await dialogs.selectBackendServiceAccounts(projectNumber, projectId, !!nonInteractive);
    if (!accounts.buildServiceAccounts.length && !accounts.runServiceAccounts.length) {
        utils.logWarning(`To use this secret in your backend, you must grant access. You can do so in the future with ${clc.bold("firebase apphosting:secrets:grantaccess")}`);
    }
    else {
        await grantSecretAccess(projectId, projectNumber, secretName, accounts);
    }
    await config.maybeAddSecretToYaml(secretName, config.APPHOSTING_BASE_YAML_FILE);
    utils.logBullet("To grant additional users access to this secret run " +
        clc.bold(`firebase apphosting:secrets:grantaccess ${secretName} --email [email list]`) +
        ".\nTo grant additional backends access to this secret run " +
        clc.bold(`firebase apphosting:secrets:grantaccess ${secretName} --backend [backend ID]`));
}
