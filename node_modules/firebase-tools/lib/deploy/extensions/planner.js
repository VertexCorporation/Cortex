"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getExtensionVersion = getExtensionVersion;
exports.getExtension = getExtension;
exports.getExtensionSpec = getExtensionSpec;
exports.haveDynamic = haveDynamic;
exports.have = have;
exports.wantDynamic = wantDynamic;
exports.want = want;
exports.resolveVersion = resolveVersion;
const semver = require("semver");
const extensionsApi = require("../../extensions/extensionsApi");
const refs = require("../../extensions/refs");
const error_1 = require("../../error");
const extensionsHelper_1 = require("../../extensions/extensionsHelper");
const logger_1 = require("../../logger");
const manifest_1 = require("../../extensions/manifest");
const paramHelper_1 = require("../../extensions/paramHelper");
const specHelper_1 = require("../../extensions/emulator/specHelper");
const functional_1 = require("../../functional");
const askUserForEventsConfig_1 = require("../../extensions/askUserForEventsConfig");
async function getExtensionVersion(i) {
    if (!i.extensionVersion) {
        if (!i.ref) {
            throw new error_1.FirebaseError(`Can't get ExtensionVersion for ${i.instanceId} because it has no ref`);
        }
        i.extensionVersion = await extensionsApi.getExtensionVersion(refs.toExtensionVersionRef(i.ref));
    }
    return i.extensionVersion;
}
async function getExtension(i) {
    if (!i.ref) {
        throw new error_1.FirebaseError(`Can't get Extension for ${i.instanceId} because it has no ref`);
    }
    if (!i.extension) {
        i.extension = await extensionsApi.getExtension(refs.toExtensionRef(i.ref));
    }
    return i.extension;
}
async function getExtensionSpec(i) {
    if (!i.extensionSpec) {
        if (i.ref) {
            const extensionVersion = await getExtensionVersion(i);
            i.extensionSpec = extensionVersion.spec;
        }
        else if (i.localPath) {
            i.extensionSpec = await (0, specHelper_1.readExtensionYaml)(i.localPath);
            i.extensionSpec.postinstallContent = await (0, specHelper_1.readPostinstall)(i.localPath);
        }
        else {
            throw new error_1.FirebaseError("InstanceSpec had no ref or localPath, unable to get extensionSpec");
        }
    }
    if (!i.extensionSpec) {
        throw new error_1.FirebaseError("Internal error getting extension");
    }
    return i.extensionSpec;
}
async function haveDynamic(projectId) {
    return (await extensionsApi.listInstances(projectId))
        .filter((i) => i.labels?.createdBy === "SDK")
        .map((i) => {
        const instanceId = i.name.split("/").pop();
        if (!instanceId) {
            throw new error_1.FirebaseError(`Internal error getting instanceId from ${i.name}`);
        }
        const dep = {
            instanceId,
            params: i.config.params,
            systemParams: i.config.systemParams ?? {},
            allowedEventTypes: i.config.allowedEventTypes,
            eventarcChannel: i.config.eventarcChannel,
            etag: i.etag,
            labels: i.labels,
        };
        if (i.config.extensionRef) {
            const ref = refs.parse(i.config.extensionRef);
            dep.ref = ref;
            dep.ref.version = i.config.extensionVersion;
        }
        return dep;
    });
}
async function have(projectId) {
    return (await extensionsApi.listInstances(projectId))
        .filter((i) => !(i.labels?.createdBy === "SDK"))
        .map((i) => {
        const instanceId = i.name.split("/").pop();
        if (!instanceId) {
            throw new error_1.FirebaseError(`Internal error getting instanceId from ${i.name}`);
        }
        const dep = {
            instanceId,
            params: i.config.params,
            systemParams: i.config.systemParams ?? {},
            allowedEventTypes: i.config.allowedEventTypes,
            eventarcChannel: i.config.eventarcChannel,
            etag: i.etag,
        };
        if (i.labels) {
            dep.labels = i.labels;
        }
        if (i.config.extensionRef) {
            const ref = refs.parse(i.config.extensionRef);
            dep.ref = ref;
            dep.ref.version = i.config.extensionVersion;
        }
        return dep;
    });
}
async function wantDynamic(args) {
    const instanceSpecs = [];
    const errors = [];
    if (!args.extensions) {
        return [];
    }
    for (const [instanceId, ext] of Object.entries(args.extensions)) {
        const autoPopulatedParams = await (0, extensionsHelper_1.getFirebaseProjectParams)(args.projectId, args.emulatorMode);
        const subbedParams = (0, extensionsHelper_1.substituteParams)(ext.params, autoPopulatedParams);
        const eventarcChannel = ext.params["_EVENT_ARC_REGION"]
            ? (0, askUserForEventsConfig_1.getEventArcChannel)(args.projectId, ext.params["_EVENT_ARC_REGION"])
            : undefined;
        delete subbedParams["_EVENT_ARC_REGION"];
        const subbedSecretParams = await (0, extensionsHelper_1.substituteSecretParams)(args.projectNumber, subbedParams);
        const [systemParams, params] = (0, functional_1.partitionRecord)(subbedSecretParams, paramHelper_1.isSystemParam);
        const allowedEventTypes = ext.events.length ? ext.events : undefined;
        if (allowedEventTypes && !eventarcChannel) {
            errors.push(new error_1.FirebaseError("EventArcRegion must be specified if event handlers are defined"));
        }
        if (ext.localPath) {
            instanceSpecs.push({
                instanceId,
                localPath: ext.localPath,
                params,
                systemParams,
                allowedEventTypes,
                eventarcChannel,
                labels: ext.labels,
            });
        }
        else if (ext.ref) {
            instanceSpecs.push({
                instanceId,
                ref: refs.parse(ext.ref),
                params,
                systemParams,
                allowedEventTypes,
                eventarcChannel,
                labels: ext.labels,
            });
        }
    }
    if (errors.length) {
        const messages = errors.map((err) => `- ${err.message}`).join("\n");
        throw new error_1.FirebaseError(`Errors while reading 'extensions' in app code\n${messages}`);
    }
    return instanceSpecs;
}
async function want(args) {
    const instanceSpecs = [];
    const errors = [];
    if (!args.extensions) {
        return [];
    }
    for (const e of Object.entries(args.extensions)) {
        try {
            const instanceId = e[0];
            const rawParams = (0, manifest_1.readInstanceParam)({
                projectDir: args.projectDir,
                instanceId,
                projectId: args.projectId,
                projectNumber: args.projectNumber,
                aliases: args.aliases,
                checkLocal: args.emulatorMode,
            });
            const autoPopulatedParams = await (0, extensionsHelper_1.getFirebaseProjectParams)(args.projectId, args.emulatorMode);
            const subbedParams = (0, extensionsHelper_1.substituteParams)(rawParams, autoPopulatedParams);
            const [systemParams, params] = (0, functional_1.partitionRecord)(subbedParams, paramHelper_1.isSystemParam);
            const allowedEventTypes = params.ALLOWED_EVENT_TYPES !== undefined
                ? params.ALLOWED_EVENT_TYPES.split(",").filter((e) => e !== "")
                : undefined;
            const eventarcChannel = params.EVENTARC_CHANNEL;
            delete params["EVENTARC_CHANNEL"];
            delete params["ALLOWED_EVENT_TYPES"];
            if ((0, extensionsHelper_1.isLocalPath)(e[1])) {
                instanceSpecs.push({
                    instanceId,
                    localPath: e[1],
                    params,
                    systemParams,
                    allowedEventTypes: allowedEventTypes,
                    eventarcChannel: eventarcChannel,
                });
            }
            else {
                const ref = refs.parse(e[1]);
                ref.version = await resolveVersion(ref);
                instanceSpecs.push({
                    instanceId,
                    ref,
                    params,
                    systemParams,
                    allowedEventTypes: allowedEventTypes,
                    eventarcChannel: eventarcChannel,
                });
            }
        }
        catch (err) {
            logger_1.logger.debug(`Got error reading extensions entry ${e[0]} (${e[1]}): ${(0, error_1.getErrMsg)(err)}`);
            errors.push(err);
        }
    }
    if (errors.length) {
        const messages = errors.map((err) => `- ${err.message}`).join("\n");
        throw new error_1.FirebaseError(`Errors while reading 'extensions' in 'firebase.json'\n${messages}`);
    }
    return instanceSpecs;
}
async function resolveVersion(ref, extension) {
    const extensionRef = refs.toExtensionRef(ref);
    if (!ref.version && extension?.latestApprovedVersion) {
        return extension.latestApprovedVersion;
    }
    if (ref.version === "latest-approved") {
        if (!extension?.latestApprovedVersion) {
            throw new error_1.FirebaseError(`${extensionRef} has not been published to Extensions Hub (https://extensions.dev). To install it, you must specify the version you want to install.`);
        }
        return extension.latestApprovedVersion;
    }
    if (!ref.version || ref.version === "latest") {
        if (!extension?.latestVersion) {
            throw new error_1.FirebaseError(`${extensionRef} has no stable non-deprecated versions. If you wish to install a prerelease version, you must specify the version you want to install.`);
        }
        return extension.latestVersion;
    }
    const versions = await extensionsApi.listExtensionVersions(extensionRef, undefined, true);
    if (versions.length === 0) {
        throw new error_1.FirebaseError(`No versions found for ${extensionRef}`);
    }
    const maxSatisfying = semver.maxSatisfying(versions.map((ev) => ev.spec.version), ref.version);
    if (!maxSatisfying) {
        throw new error_1.FirebaseError(`No version of ${extensionRef} matches requested version ${ref.version}`);
    }
    return maxSatisfying;
}
