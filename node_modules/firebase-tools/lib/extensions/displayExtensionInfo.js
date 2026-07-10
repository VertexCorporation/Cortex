"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.displayExtensionVersionInfo = displayExtensionVersionInfo;
exports.displayExternalServices = displayExternalServices;
exports.displayEvents = displayEvents;
exports.displayResources = displayResources;
exports.retrieveRoleInfo = retrieveRoleInfo;
const clc = require("colorette");
const semver = require("semver");
const path = require("path");
const refs = require("../extensions/refs");
const logger_1 = require("../logger");
const types_1 = require("./types");
const iam = require("../gcp/iam");
const secretsUtils_1 = require("./secretsUtils");
const TASKS_ROLE = "cloudtasks.enqueuer";
const TASKS_API = "cloudtasks.googleapis.com";
async function displayExtensionVersionInfo(args) {
    const { spec, extensionVersion, latestApprovedVersion, latestVersion } = args;
    const lines = [];
    const extensionRef = extensionVersion
        ? refs.toExtensionRef(refs.parse(extensionVersion?.ref))
        : "";
    lines.push(`${clc.bold("Extension:")} ${spec.displayName ?? "Unnamed extension"} ${extensionRef ? `(${extensionRef})` : ""}`);
    if (spec.description) {
        lines.push(`${clc.bold("Description:")} ${spec.description}`);
    }
    let versionNote = "";
    const latestRelevantVersion = latestApprovedVersion || latestVersion;
    if (latestRelevantVersion && semver.eq(spec.version, latestRelevantVersion)) {
        versionNote = `- ${clc.green("Latest")}`;
    }
    if (extensionVersion?.state === "DEPRECATED") {
        versionNote = `- ${clc.red("Deprecated")}`;
    }
    lines.push(`${clc.bold("Version:")} ${spec.version} ${versionNote}`);
    if (extensionVersion) {
        let reviewStatus;
        switch (extensionVersion.listing?.state) {
            case "APPROVED":
                reviewStatus = clc.bold(clc.green("Accepted"));
                break;
            case "REJECTED":
                reviewStatus = clc.bold(clc.red("Rejected"));
                break;
            default:
                reviewStatus = clc.bold(clc.yellow("Unreviewed"));
        }
        lines.push(`${clc.bold("Review status:")} ${reviewStatus}`);
        if (latestApprovedVersion) {
            lines.push(`${clc.bold("View in Extensions Hub:")} https://extensions.dev/extensions/${extensionRef}`);
        }
        if (extensionVersion.buildSourceUri) {
            const buildSourceUri = new URL(extensionVersion.buildSourceUri);
            buildSourceUri.pathname = path.join(buildSourceUri.pathname, extensionVersion.extensionRoot ?? "");
            lines.push(`${clc.bold("Source in GitHub:")} ${buildSourceUri.toString()}`);
        }
        else {
            lines.push(`${clc.bold("Source download URI:")} ${extensionVersion.sourceDownloadUri ?? "-"}`);
        }
    }
    lines.push(`${clc.bold("License:")} ${spec.license ?? "-"}`);
    lines.push(displayResources(spec));
    if (spec.events?.length) {
        lines.push(displayEvents(spec));
    }
    if (spec.externalServices?.length) {
        lines.push(displayExternalServices(spec));
    }
    const apis = impliedApis(spec);
    if (apis.length) {
        lines.push(displayApis(apis));
    }
    const roles = impliedRoles(spec);
    if (roles.length) {
        lines.push(await displayRoles(roles));
    }
    logger_1.logger.info(`\n${lines.join("\n")}`);
    return lines;
}
function displayExternalServices(spec) {
    const lines = spec.externalServices?.map((service) => {
        return `  - ${clc.cyan(`${service.name} (${service.pricingUri})`)}`;
    }) ?? [];
    return clc.bold("External services used:\n") + lines.join("\n");
}
function displayEvents(spec) {
    const lines = spec.events?.map((event) => {
        return `  - ${clc.magenta(event.type)}${event.description ? `: ${event.description}` : ""}`;
    }) ?? [];
    return clc.bold("Events emitted:\n") + lines.join("\n");
}
function displayResources(spec) {
    const lines = spec.resources.map((resource) => {
        let type = resource.type;
        switch (resource.type) {
            case "firebaseextensions.v1beta.function":
                type = "Cloud Function (1st gen)";
                break;
            case "firebaseextensions.v1beta.v2function":
                type = "Cloud Function (2nd gen)";
                break;
            default:
        }
        return `  - ${clc.blueBright(`${resource.name} (${type})`)}${resource.description ? `: ${resource.description}` : ""}`;
    });
    lines.push(...new Set(spec.lifecycleEvents?.map((event) => {
        return `  - ${clc.blueBright(`${event.taskQueueTriggerFunction} (Cloud Task queue)`)}`;
    })));
    lines.push(...spec.params
        .filter((param) => {
        return param.type === "SECRET";
    })
        .map((param) => {
        return `  - ${clc.blueBright(`${param.param} (Cloud Secret Manager secret)`)}`;
    }));
    return clc.bold("Resources created:\n") + (lines.length ? lines.join("\n") : " - None");
}
async function retrieveRoleInfo(role) {
    const res = await iam.getRole(role);
    return `  - ${clc.yellow(res.title || res.name)}${res.description ? `: ${res.description}` : ""}`;
}
async function displayRoles(roles) {
    const lines = await Promise.all(roles.map((role) => {
        return retrieveRoleInfo(role.role);
    }));
    return clc.bold("Roles granted:\n") + lines.join("\n");
}
function displayApis(apis) {
    const lines = apis.map((api) => {
        return `  - ${clc.cyan(api.apiName)}: ${api.reason}`;
    });
    return clc.bold("APIs used:\n") + lines.join("\n");
}
function usesTasks(spec) {
    return spec.resources.some((r) => r.type === types_1.FUNCTIONS_RESOURCE_TYPE && r.properties?.taskQueueTrigger !== undefined);
}
function impliedRoles(spec) {
    const roles = [];
    if ((0, secretsUtils_1.usesSecrets)(spec) && !spec.roles?.some((r) => r.role === secretsUtils_1.SECRET_ROLE)) {
        roles.push({
            role: secretsUtils_1.SECRET_ROLE,
            reason: "Allows the extension to read secret values from Cloud Secret Manager.",
        });
    }
    if (usesTasks(spec) && !spec.roles?.some((r) => r.role === TASKS_ROLE)) {
        roles.push({
            role: TASKS_ROLE,
            reason: "Allows the extension to enqueue Cloud Tasks.",
        });
    }
    return roles.concat(spec.roles ?? []);
}
function impliedApis(spec) {
    const apis = [];
    if (usesTasks(spec) && !spec.apis?.some((a) => a.apiName === TASKS_API)) {
        apis.push({
            apiName: TASKS_API,
            reason: "Allows the extension to enqueue Cloud Tasks.",
        });
    }
    return apis.concat(spec.apis ?? []);
}
