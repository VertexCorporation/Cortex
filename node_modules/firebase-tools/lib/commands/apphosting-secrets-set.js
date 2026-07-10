"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const requireAuth_1 = require("../requireAuth");
const gcsm = require("../gcp/secretManager");
const apphosting = require("../gcp/apphosting");
const requirePermissions_1 = require("../requirePermissions");
const secrets_1 = require("../apphosting/secrets");
exports.command = new command_1.Command("apphosting:secrets:set <secretName>")
    .description("create or update a secret for use in Firebase App Hosting")
    .option("-l, --location <location>", "optional location to retrict secret replication")
    .withForce("Automatically create a secret, grant permissions, and add to YAML.")
    .before(requireAuth_1.requireAuth)
    .before(gcsm.ensureApi)
    .before(apphosting.ensureApiEnabled)
    .before(requirePermissions_1.requirePermissions, [
    "secretmanager.secrets.create",
    "secretmanager.secrets.get",
    "secretmanager.secrets.update",
    "secretmanager.versions.add",
    "secretmanager.secrets.getIamPolicy",
    "secretmanager.secrets.setIamPolicy",
])
    .option("--data-file <dataFile>", 'File path from which to read secret data. Set to "-" to read the secret data from stdin.')
    .action(async (secretName, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const projectNumber = await (0, projectUtils_1.needProjectNumber)(options);
    return (0, secrets_1.apphostingSecretsSetAction)(secretName, projectId, projectNumber, options.location, options.dataFile, options.nonInteractive);
});
