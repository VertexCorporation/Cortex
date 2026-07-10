"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const checkMinRequiredVersion_1 = require("../checkMinRequiredVersion");
const command_1 = require("../command");
const extensionsApi = require("../extensions/extensionsApi");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const localHelper_1 = require("../extensions/localHelper");
const logger_1 = require("../logger");
const requirePermissions_1 = require("../requirePermissions");
const utils = require("../utils");
const marked_1 = require("marked");
const marked_terminal_1 = require("marked-terminal");
const FUNCTION_TYPE_REGEX = /\..+\.function/;
exports.command = new command_1.Command("ext:info <extensionName>")
    .description("display information about an extension by name (extensionName@x.y.z for a specific version)")
    .option("--markdown", "output info in Markdown suitable for constructing a README file")
    .before(checkMinRequiredVersion_1.checkMinRequiredVersion, "extMinVersion")
    .action(async (extensionName, options) => {
    let spec;
    let version;
    if ((0, localHelper_1.isLocalExtension)(extensionName)) {
        if (!options.markdown) {
            utils.logLabeledBullet(extensionsHelper_1.logPrefix, `reading extension from directory: ${extensionName}`);
        }
        spec = await (0, localHelper_1.getLocalExtensionSpec)(extensionName);
    }
    else {
        await (0, requirePermissions_1.requirePermissions)(options, ["firebaseextensions.sources.get"]);
        await (0, extensionsHelper_1.ensureExtensionsApiEnabled)(options);
        const hasPublisherId = extensionName.split("/").length >= 2;
        if (hasPublisherId) {
            const nameAndVersion = extensionName.split("/")[1];
            if (nameAndVersion.split("@").length < 2) {
                extensionName = extensionName + "@latest";
            }
        }
        else {
            const [name, version] = extensionName.split("@");
            extensionName = `firebase/${name}@${version || "latest"}`;
        }
        version = await extensionsApi.getExtensionVersion(extensionName);
        spec = version.spec;
    }
    if (!options.markdown) {
        utils.logLabeledBullet(extensionsHelper_1.logPrefix, `information about ${extensionName}:\n`);
    }
    const lines = [];
    if (options.markdown) {
        lines.push(`# ${spec.displayName}`);
    }
    else {
        lines.push(`**Name**: ${spec.displayName}`);
    }
    const authorName = spec.author?.authorName;
    const url = spec.author?.url;
    const urlMarkdown = url ? `(**[${url}](${url})**)` : "";
    lines.push(`**Author**: ${authorName} ${urlMarkdown}`);
    if (version?.sourceDownloadUri) {
        lines.push(`**Download URL**: ${version.sourceDownloadUri}`);
    }
    if (spec.description) {
        lines.push(`**Description**: ${spec.description}`);
    }
    if (spec.preinstallContent) {
        lines.push("", `**Details**: ${spec.preinstallContent}`);
    }
    if (spec.params && Array.isArray(spec.params) && spec.params.length > 0) {
        lines.push("", "**Configuration Parameters:**");
        for (const param of spec.params) {
            lines.push(`* ${param.label}` + (param.description ? `: ${param.description}` : ""));
        }
    }
    const functions = [];
    const otherResources = [];
    for (const resource of spec.resources) {
        if (FUNCTION_TYPE_REGEX.test(resource.type)) {
            functions.push(resource);
        }
        else {
            otherResources.push(resource);
        }
    }
    if (functions.length > 0) {
        lines.push("", "**Cloud Functions:**");
        for (const func of functions) {
            lines.push(`* **${func.name}:** ${func.description}`);
        }
    }
    if (otherResources.length > 0) {
        lines.push("", "**Other Resources**:");
        for (const resource of otherResources) {
            lines.push(`* ${resource.name} (${resource.type})`);
        }
    }
    if (spec.apis) {
        lines.push("", "**APIs Used**:");
        for (const api of spec.apis) {
            lines.push(`* ${api.apiName}` + (api.reason ? ` (Reason: ${api.reason})` : ""));
        }
    }
    if (spec.roles) {
        lines.push("", "**Access Required**:");
        lines.push("", "This extension will operate with the following project IAM roles:");
        for (const role of spec.roles) {
            lines.push(`* ${role.role}` + (role.reason ? ` (Reason: ${role.reason})` : ""));
        }
    }
    if (options.markdown) {
        logger_1.logger.info(lines.join("\n\n"));
    }
    else {
        marked_1.marked.use((0, marked_terminal_1.markedTerminal)());
        logger_1.logger.info(await (0, marked_1.marked)(lines.join("\n")));
        utils.logLabeledBullet(extensionsHelper_1.logPrefix, `to install this extension, run ` +
            clc.bold(`firebase ext:install ${extensionName} --project=YOUR_PROJECT`));
        utils.logLabeledBullet(extensionsHelper_1.logPrefix, `to install an autogenerated SDK for this extension into your functions codebase, run ` +
            clc.bold(`firebase ext:sdk:install ${extensionName} --project=YOUR_PROJECT`));
    }
});
