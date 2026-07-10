"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const error_1 = require("../error");
const requireAuth_1 = require("../requireAuth");
const secretManager = require("../gcp/secretManager");
const requirePermissions_1 = require("../requirePermissions");
const apphosting = require("../gcp/apphosting");
const secrets = require("../apphosting/secrets");
const backend_1 = require("../apphosting/backend");
exports.command = new command_1.Command("apphosting:secrets:grantaccess <secretNames>")
    .description("Grant service accounts, users, or groups permissions to the provided secret(s). Can pass one or more secrets, separated by a comma")
    .option("-l, --location <location>", "backend location", "-")
    .option("-b, --backend <backend>", "backend name")
    .option("-e, --emails <emails>", "comma delimited list of user or group emails")
    .before(requireAuth_1.requireAuth)
    .before(secretManager.ensureApi)
    .before(apphosting.ensureApiEnabled)
    .before(requirePermissions_1.requirePermissions, [
    "secretmanager.secrets.create",
    "secretmanager.secrets.get",
    "secretmanager.secrets.update",
    "secretmanager.versions.add",
    "secretmanager.secrets.getIamPolicy",
    "secretmanager.secrets.setIamPolicy",
])
    .action(async (secretNames, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    if (!options.backend && !options.emails) {
        throw new error_1.FirebaseError("Missing required flag --backend or --emails. See firebase apphosting:secrets:grantaccess --help for more info");
    }
    if (options.backend && options.emails) {
        throw new error_1.FirebaseError("Cannot specify both --backend and --emails. See firebase apphosting:secrets:grantaccess --help for more info");
    }
    const secretList = secretNames.split(",");
    for (const secretName of secretList) {
        const exists = await secretManager.secretExists(projectId, secretName);
        if (!exists) {
            throw new error_1.FirebaseError(`Cannot find secret ${secretName}`);
        }
    }
    if (options.emails) {
        return await secrets.grantEmailsSecretAccess(projectId, secretList, String(options.emails).split(","));
    }
    const backendId = options.backend;
    const location = options.location;
    let backend;
    if (location === "" || location === "-") {
        backend = await (0, backend_1.getBackendForAmbiguousLocation)(projectId, backendId, "Please select the location of your backend:");
    }
    else {
        backend = await apphosting.getBackend(projectId, location, backendId);
    }
    const accounts = secrets.toMulti(await secrets.serviceAccountsForBackend(projectNumber, backend));
    await Promise.allSettled(secretList.map((secretName) => secrets.grantSecretAccess(projectId, projectNumber, secretName, accounts)));
});
