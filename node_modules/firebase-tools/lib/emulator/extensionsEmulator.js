"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExtensionsEmulator = void 0;
const clc = require("colorette");
const spawn = require("cross-spawn");
const fs = require("fs-extra");
const os = require("os");
const path = require("path");
const Table = require("cli-table3");
const planner = require("../deploy/extensions/planner");
const ensureApiEnabled_1 = require("../ensureApiEnabled");
const error_1 = require("../error");
const optionsHelper_1 = require("../extensions/emulator/optionsHelper");
const refs_1 = require("../extensions/refs");
const constants_1 = require("./constants");
const download_1 = require("./download");
const emulatorLogger_1 = require("./emulatorLogger");
const validation_1 = require("./extensions/validation");
const registry_1 = require("./registry");
const types_1 = require("./types");
const common_1 = require("../extensions/runtimes/common");
const paramHelper_1 = require("../extensions/paramHelper");
class ExtensionsEmulator {
    constructor(args) {
        this.want = [];
        this.wantDynamic = {};
        this.backends = [];
        this.staticBackends = [];
        this.dynamicBackends = {};
        this.logger = emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.EXTENSIONS);
        this.pendingDownloads = new Map();
        this.args = args;
    }
    start() {
        this.logger.logLabeled("DEBUG", "Extensions", "Started Extensions emulator, this is a noop.");
        return Promise.resolve();
    }
    stop() {
        this.logger.logLabeled("DEBUG", "Extensions", "Stopping Extensions emulator, this is a noop.");
        return Promise.resolve();
    }
    connect() {
        this.logger.logLabeled("DEBUG", "Extensions", "Connecting Extensions emulator, this is a noop.");
        return Promise.resolve();
    }
    getInfo() {
        const functionsEmulator = registry_1.EmulatorRegistry.get(types_1.Emulators.FUNCTIONS);
        if (!functionsEmulator) {
            throw new error_1.FirebaseError("Extensions Emulator is running but Functions emulator is not. This should never happen.");
        }
        return { ...functionsEmulator.getInfo(), name: this.getName() };
    }
    getName() {
        return types_1.Emulators.EXTENSIONS;
    }
    async readManifest() {
        this.want = await planner.want({
            projectId: this.args.projectId,
            projectNumber: this.args.projectNumber,
            aliases: this.args.aliases ?? [],
            projectDir: this.args.projectDir,
            extensions: this.args.extensions,
            emulatorMode: true,
        });
    }
    async ensureSourceCode(instance) {
        if (instance.localPath) {
            if (!this.hasValidSource({ path: instance.localPath, extTarget: instance.localPath })) {
                throw new error_1.FirebaseError(`Tried to emulate local extension at ${instance.localPath}, but it was missing required files.`);
            }
            return path.resolve(instance.localPath);
        }
        else if (instance.ref) {
            const ref = (0, refs_1.toExtensionVersionRef)(instance.ref);
            const cacheDir = process.env.FIREBASE_EXTENSIONS_CACHE_PATH ||
                path.join(os.homedir(), ".cache", "firebase", "extensions");
            const sourceCodePath = path.join(cacheDir, ref);
            if (this.pendingDownloads.get(ref)) {
                await this.pendingDownloads.get(ref);
            }
            if (!this.hasValidSource({ path: sourceCodePath, extTarget: ref })) {
                const promise = this.downloadSource(instance, ref, sourceCodePath);
                this.pendingDownloads.set(ref, promise);
                await promise;
            }
            return sourceCodePath;
        }
        else {
            throw new error_1.FirebaseError("Tried to emulate an extension instance without a ref or localPath. This should never happen.");
        }
    }
    async downloadSource(instance, ref, sourceCodePath) {
        const extensionVersion = await planner.getExtensionVersion(instance);
        await (0, download_1.downloadExtensionVersion)(ref, extensionVersion.sourceDownloadUri, sourceCodePath);
        this.installAndBuildSourceCode(sourceCodePath);
    }
    hasValidSource(args) {
        const requiredFiles = ["./extension.yaml", "./functions/package.json"];
        if (!fs.existsSync(args.path)) {
            return false;
        }
        for (const requiredFile of requiredFiles) {
            const f = path.join(args.path, requiredFile);
            if (!fs.existsSync(f)) {
                this.logger.logLabeled("BULLET", "extensions", `Detected invalid source code for ${args.extTarget}, expected to find ${f}`);
                return false;
            }
        }
        this.logger.logLabeled("DEBUG", "extensions", `Source code valid for ${args.extTarget}`);
        return true;
    }
    installAndBuildSourceCode(sourceCodePath) {
        this.logger.logLabeled("DEBUG", "Extensions", `Running "npm install" for ${sourceCodePath}`);
        const functionsDirectory = path.resolve(sourceCodePath, "functions");
        const npmInstall = spawn.sync("npm", ["install"], {
            encoding: "utf8",
            cwd: functionsDirectory,
        });
        if (npmInstall.error) {
            throw npmInstall.error;
        }
        this.logger.logLabeled("DEBUG", "Extensions", `Finished "npm install" for ${sourceCodePath}`);
        this.logger.logLabeled("DEBUG", "Extensions", `Running "npm run gcp-build" for ${sourceCodePath}`);
        const npmRunGCPBuild = spawn.sync("npm", ["run", "gcp-build"], {
            encoding: "utf8",
            cwd: functionsDirectory,
        });
        if (npmRunGCPBuild.error) {
            throw npmRunGCPBuild.error;
        }
        this.logger.logLabeled("DEBUG", "Extensions", `Finished "npm run gcp-build" for ${sourceCodePath}`);
    }
    async getExtensionBackends() {
        this.backends = await this.getStaticExtensionBackends();
        for (const backends of Object.values(this.dynamicBackends)) {
            this.backends.push(...backends);
        }
        return this.backends;
    }
    async getStaticExtensionBackends() {
        await this.readManifest();
        await this.checkAndWarnAPIs(this.want);
        this.staticBackends = await Promise.all(this.want.map((i) => {
            return this.toEmulatableBackend(i);
        }));
        return this.staticBackends;
    }
    getDynamicExtensionBackends() {
        const dynamicBackends = [];
        for (const backends of Object.values(this.dynamicBackends)) {
            dynamicBackends.push(...backends);
        }
        return dynamicBackends;
    }
    async addDynamicExtensions(codebase, build) {
        const extensions = (0, common_1.extractExtensionsFromBuilds)({ build });
        this.wantDynamic[codebase] = await planner.wantDynamic({
            projectId: this.args.projectId,
            projectNumber: this.args.projectNumber,
            extensions,
            emulatorMode: true,
        });
        await this.checkAndWarnAPIs(this.wantDynamic[codebase]);
        this.dynamicBackends[codebase] = await Promise.all(this.wantDynamic[codebase].map((i) => {
            return this.toEmulatableBackend(i);
        }));
        await this.getExtensionBackends();
    }
    async toEmulatableBackend(instance) {
        const extensionDir = await this.ensureSourceCode(instance);
        const functionsDir = path.join(extensionDir, "functions");
        const params = (0, paramHelper_1.populateDefaultParams)(instance.params, await planner.getExtensionSpec(instance));
        const env = Object.assign(this.autoPopulatedParams(instance), params);
        const { extensionTriggers, runtime, nonSecretEnv, secretEnvVariables } = await (0, optionsHelper_1.getExtensionFunctionInfo)(instance, env);
        const emulatableBackend = {
            functionsDir,
            runtime,
            bin: process.execPath,
            env: nonSecretEnv,
            codebase: instance.instanceId,
            secretEnv: secretEnvVariables,
            predefinedTriggers: extensionTriggers,
            extensionInstanceId: instance.instanceId,
        };
        if (instance.ref) {
            emulatableBackend.extension = await planner.getExtension(instance);
            emulatableBackend.extensionVersion = await planner.getExtensionVersion(instance);
        }
        else if (instance.localPath) {
            emulatableBackend.extensionSpec = await planner.getExtensionSpec(instance);
        }
        return emulatableBackend;
    }
    autoPopulatedParams(instance) {
        const projectId = this.args.projectId;
        return {
            PROJECT_ID: projectId ?? "",
            EXT_INSTANCE_ID: instance.instanceId,
            DATABASE_INSTANCE: projectId ?? "",
            DATABASE_URL: `https://${projectId}.firebaseio.com`,
            STORAGE_BUCKET: `${projectId}.appspot.com`,
            ALLOWED_EVENT_TYPES: instance.allowedEventTypes ? instance.allowedEventTypes.join(",") : "",
            EVENTARC_CHANNEL: instance.eventarcChannel ?? "",
            EVENTARC_CLOUD_EVENT_SOURCE: `projects/${projectId}/instances/${instance.instanceId}`,
        };
    }
    async checkAndWarnAPIs(instances) {
        const apisToWarn = await (0, validation_1.getUnemulatedAPIs)(this.args.projectId, instances);
        if (apisToWarn.length) {
            const table = new Table({
                head: [
                    "API Name",
                    "Instances using this API",
                    `Enabled on ${this.args.projectId}`,
                    `Enable this API`,
                ],
                style: { head: ["yellow"] },
            });
            for (const apiToWarn of apisToWarn) {
                const enablementUri = (0, ensureApiEnabled_1.enableApiURI)(this.args.projectId, apiToWarn.apiName);
                table.push([
                    apiToWarn.apiName,
                    apiToWarn.instanceIds.join(", "),
                    apiToWarn.enabled ? "Yes" : "No",
                    apiToWarn.enabled ? "" : clc.bold(clc.underline(enablementUri)),
                ]);
            }
            if (constants_1.Constants.isDemoProject(this.args.projectId)) {
                this.logger.logLabeled("WARN", "Extensions", "The following Extensions make calls to Google Cloud APIs that do not have Emulators. " +
                    `${clc.bold(this.args.projectId)} is a demo project, so these Extensions may not work as expected.\n` +
                    table.toString());
            }
            else {
                this.logger.logLabeled("WARN", "Extensions", "The following Extensions make calls to Google Cloud APIs that do not have Emulators. " +
                    `These calls will go to production Google Cloud APIs which may have real effects on ${clc.bold(this.args.projectId)}.\n` +
                    table.toString());
            }
        }
    }
    filterUnemulatedTriggers(backends) {
        let foundUnemulatedTrigger = false;
        const filteredBackends = backends.filter((backend) => {
            const unemulatedServices = (0, validation_1.checkForUnemulatedTriggerTypes)(backend, this.args.options);
            if (unemulatedServices.length) {
                foundUnemulatedTrigger = true;
                const msg = ` ignored becuase it includes ${unemulatedServices.join(", ")} triggered functions, and the ${unemulatedServices.join(", ")} emulator does not exist or is not running.`;
                this.logger.logLabeled("WARN", `extensions[${backend.extensionInstanceId}]`, msg);
            }
            return unemulatedServices.length === 0;
        });
        if (foundUnemulatedTrigger) {
            const msg = "No Cloud Functions for these instances will be emulated, because partially emulating an Extension can lead to unexpected behavior. ";
            this.logger.log("WARN", msg);
        }
        return filteredBackends;
    }
    extensionDetailsUILink(backend) {
        if (!registry_1.EmulatorRegistry.isRunning(types_1.Emulators.UI) || !backend.extensionInstanceId) {
            return "";
        }
        const uiUrl = registry_1.EmulatorRegistry.url(types_1.Emulators.UI);
        uiUrl.pathname = `/${types_1.Emulators.EXTENSIONS}/${backend.extensionInstanceId}`;
        return clc.underline(clc.bold(uiUrl.toString()));
    }
    extensionsInfoTable() {
        const filtedBackends = this.filterUnemulatedTriggers(this.backends);
        const uiRunning = registry_1.EmulatorRegistry.isRunning(types_1.Emulators.UI);
        const tableHead = ["Extension Instance Name", "Extension Ref"];
        if (uiRunning) {
            tableHead.push("View in Emulator UI");
        }
        const table = new Table({ head: tableHead, style: { head: ["yellow"] } });
        for (const b of filtedBackends) {
            if (b.extensionInstanceId) {
                const tableEntry = [b.extensionInstanceId, b.extensionVersion?.ref || "Local Extension"];
                if (uiRunning)
                    tableEntry.push(this.extensionDetailsUILink(b));
                table.push(tableEntry);
            }
        }
        return table.toString();
    }
}
exports.ExtensionsEmulator = ExtensionsEmulator;
