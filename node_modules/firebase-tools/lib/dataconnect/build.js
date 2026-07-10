"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.build = build;
exports.handleBuildErrors = handleBuildErrors;
const dataconnectEmulator_1 = require("../emulator/dataconnectEmulator");
const error_1 = require("../error");
const prompt_1 = require("../prompt");
const utils = require("../utils");
const graphqlError_1 = require("./graphqlError");
const auth_1 = require("../auth");
async function build(options, configDir, deployStats) {
    const account = (0, auth_1.getProjectDefaultAccount)(options.projectRoot);
    const args = { configDir, account };
    if (options.projectId) {
        args.projectId = options.projectId;
    }
    const buildResult = await dataconnectEmulator_1.DataConnectEmulator.build(args);
    if (buildResult?.errors?.length) {
        buildResult.errors.forEach((e) => {
            if (e.extensions?.warningLevel) {
                let key = e.extensions.warningLevel.toLowerCase();
                const msgSp = e.message.split(": ");
                if (msgSp.length >= 2) {
                    key += `_${msgSp[0].toLowerCase()}`;
                }
                deployStats.numBuildWarnings.set(key, (deployStats.numBuildWarnings.get(key) ?? 0) + 1);
            }
            else {
                deployStats.numBuildErrors += 1;
            }
        });
        await handleBuildErrors(buildResult.errors, options.nonInteractive, options.force, options.dryRun);
    }
    return buildResult?.metadata ?? {};
}
async function handleBuildErrors(errors, nonInteractive, force, dryRun) {
    const fatalDeploys = errors.filter((w) => w.extensions?.warningLevel === "ALWAYS_REQUIRED");
    if (fatalDeploys.length) {
        utils.logLabeledError("dataconnect", `There are requirements that are always required and cannot be bypassed:\n` +
            (0, graphqlError_1.prettifyTable)(fatalDeploys));
        throw new error_1.FirebaseError("Failed due to unbypassable requirements.");
    }
    if (errors.filter((w) => !w.extensions?.warningLevel).length) {
        throw new error_1.FirebaseError(`There are errors in your schema and connector files:\n${errors.map(graphqlError_1.prettify).join("\n")}`);
    }
    const requiredForces = errors.filter((w) => w.extensions?.warningLevel === "REQUIRE_FORCE");
    if (requiredForces.length && !force) {
        utils.logLabeledError("dataconnect", `There are changes in your schema or connectors that will result in broken behavior:\n` +
            (0, graphqlError_1.prettifyTable)(requiredForces));
        throw new error_1.FirebaseError("Rerun this command with --force to proceed with these changes.");
    }
    const interactiveAcks = errors.filter((w) => w.extensions?.warningLevel === "INTERACTIVE_ACK");
    const requiredAcks = errors.filter((w) => w.extensions?.warningLevel === "REQUIRE_ACK");
    const choices = [
        { name: "Acknowledge all changes and proceed", value: "proceed" },
        { name: "Reject changes and abort", value: "abort" },
    ];
    if (requiredAcks.length) {
        utils.logLabeledWarning("dataconnect", `There are changes in your schema or connectors that may break your existing applications or introduce operations that are insecure. These changes require explicit acknowledgement to proceed. You may either reject the changes and update your sources with the suggested workaround(s), if any, or acknowledge these changes and proceed with the deployment:\n` +
            (0, graphqlError_1.prettifyTable)(requiredAcks));
        if (nonInteractive && !force) {
            throw new error_1.FirebaseError("Explicit acknowledgement required for breaking schema or connector changes and new insecure operations. Rerun this command with --force to proceed with these changes.");
        }
        else if (!nonInteractive && !force && !dryRun) {
            const result = await (0, prompt_1.select)({
                message: "Would you like to proceed with these changes?",
                choices,
                default: "abort",
            });
            if (result === "abort") {
                throw new error_1.FirebaseError("Aborted.");
            }
        }
    }
    if (interactiveAcks.length) {
        utils.logLabeledWarning("dataconnect", `There are existing insecure operations or changes in your schema or connectors that may cause unexpected behavior in your existing applications:\n` +
            (0, graphqlError_1.prettifyTable)(interactiveAcks));
        if (!nonInteractive && !force && !dryRun) {
            const result = await (0, prompt_1.select)({
                message: "Would you like to proceed with these changes?",
                choices,
                default: "proceed",
            });
            if (result === "abort") {
                throw new error_1.FirebaseError("Aborted.");
            }
        }
    }
}
