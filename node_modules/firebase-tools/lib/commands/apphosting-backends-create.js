"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const error_1 = require("../error");
const projectUtils_1 = require("../projectUtils");
const requireAuth_1 = require("../requireAuth");
const backend_1 = require("../apphosting/backend");
const apphosting_1 = require("../gcp/apphosting");
const experiments = require("../experiments");
const firedata_1 = require("../gcp/firedata");
const requireTosAcceptance_1 = require("../requireTosAcceptance");
exports.command = new command_1.Command("apphosting:backends:create")
    .description("create a Firebase App Hosting backend")
    .option("-a, --app <webAppId>", "specify an existing Firebase web app's ID to associate your App Hosting backend with")
    .option("--backend <backend>", "specify the name of the new backend. Required with --non-interactive.")
    .option("-s, --service-account <serviceAccount>", "specify the service account used to run the server", "")
    .option("--primary-region <primaryRegion>", "specify the primary region for the backend. Required with --non-interactive.")
    .option("--root-dir <rootDir>", "specify the root directory for the backend.");
const abiuEnabled = experiments.isEnabled("abiu");
if (abiuEnabled) {
    exports.command.option("--runtime [runtime]", "specify the runtime for the backend (e.g., nodejs, nodejs22)");
}
exports.command
    .before(requireAuth_1.requireAuth)
    .before(apphosting_1.ensureApiEnabled)
    .before((0, requireTosAcceptance_1.requireTosAcceptance)(firedata_1.APPHOSTING_TOS_ID))
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    if (options.nonInteractive && (options.backend == null || options.primaryRegion == null)) {
        throw new error_1.FirebaseError(`--non-interactive option requires --backend and --primary-region`);
    }
    const abiuAllowed = experiments.isEnabled("abiu");
    if (!abiuAllowed && options.runtime) {
        throw new error_1.FirebaseError("The --runtime flag is only available when the 'abiu' experiment is enabled. To enable it, run 'firebase experiments:enable abiu'.");
    }
    const runtime = abiuAllowed && typeof options.runtime === "string" ? options.runtime : undefined;
    return (0, backend_1.doSetup)(projectId, options.nonInteractive, options.app, options.backend, options.serviceAccount, options.primaryRegion, options.rootDir, runtime);
});
