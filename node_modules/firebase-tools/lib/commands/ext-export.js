"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const checkMinRequiredVersion_1 = require("../checkMinRequiredVersion");
const command_1 = require("../command");
const planner = require("../deploy/extensions/planner");
const etags_1 = require("../extensions/etags");
const export_1 = require("../extensions/export");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const manifest = require("../extensions/manifest");
const paramHelper_1 = require("../extensions/paramHelper");
const functional_1 = require("../functional");
const getProjectNumber_1 = require("../getProjectNumber");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const prompt_1 = require("../prompt");
const requirePermissions_1 = require("../requirePermissions");
exports.command = new command_1.Command("ext:export")
    .description("export all Extension instances installed on a project to a local Firebase directory")
    .before(requirePermissions_1.requirePermissions, ["firebaseextensions.instances.list"])
    .before(extensionsHelper_1.ensureExtensionsApiEnabled)
    .before(checkMinRequiredVersion_1.checkMinRequiredVersion, "extMinVersion")
    .withForce()
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const projectNumber = await (0, getProjectNumber_1.getProjectNumber)(options);
    const have = await Promise.all(await planner.have(projectId));
    if (have.length === 0) {
        logger_1.logger.info(`No extension instances installed on ${projectId}, so there is nothing to export.`);
        return;
    }
    const [withRef, withoutRef] = (0, functional_1.partition)(have, (s) => !!s.ref);
    const withRefSubbed = await Promise.all(withRef.map(async (i) => {
        const subbed = await (0, export_1.setSecretParamsToLatest)(i);
        return (0, export_1.parameterizeProject)(projectId, projectNumber, subbed);
    }));
    (0, export_1.displayExportInfo)(withRefSubbed, withoutRef);
    if (!options.nonInteractive &&
        !options.force &&
        !(await (0, prompt_1.confirm)({
            message: "Do you wish to add these Extension instances to firebase.json?",
            default: true,
        }))) {
        logger_1.logger.info("Exiting. No changes made.");
        return;
    }
    const manifestSpecs = withRefSubbed.map((spec) => {
        const paramCopy = { ...spec.params, ...spec.systemParams };
        if (spec.eventarcChannel) {
            paramCopy.EVENTARC_CHANNEL = spec.eventarcChannel;
        }
        if (spec.allowedEventTypes) {
            paramCopy.ALLOWED_EVENT_TYPES = spec.allowedEventTypes.join(",");
        }
        return {
            instanceId: spec.instanceId,
            ref: spec.ref,
            params: (0, paramHelper_1.buildBindingOptionsWithBaseValue)(paramCopy),
        };
    });
    const existingConfig = manifest.loadConfig(options);
    await manifest.writeToManifest(manifestSpecs, existingConfig, {
        nonInteractive: options.nonInteractive,
        force: options.force,
    }, true);
    (0, etags_1.saveEtags)(options.rc, projectId, have);
});
