"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const checkMinRequiredVersion_1 = require("../checkMinRequiredVersion");
const command_1 = require("../command");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const requirePermissions_1 = require("../requirePermissions");
const utils_1 = require("../utils");
const manifest = require("../extensions/manifest");
exports.command = new command_1.Command("ext:uninstall <extensionInstanceId>")
    .description("uninstall an extension that is installed in your Firebase project by instance ID")
    .option("--local", "deprecated")
    .withForce()
    .before(requirePermissions_1.requirePermissions, ["firebaseextensions.instances.delete"])
    .before(extensionsHelper_1.ensureExtensionsApiEnabled)
    .before(checkMinRequiredVersion_1.checkMinRequiredVersion, "extMinVersion")
    .before(extensionsHelper_1.diagnoseAndFixProject)
    .action((instanceId, options) => {
    if (options.local) {
        (0, utils_1.logLabeledWarning)(extensionsHelper_1.logPrefix, "As of firebase-tools@11.0.0, the `--local` flag is no longer required, as it is the default behavior.");
    }
    const config = manifest.loadConfig(options);
    manifest.removeFromManifest(instanceId, config);
});
