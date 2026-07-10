"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Delegate = void 0;
exports.tryCreateDelegate = tryCreateDelegate;
const os = require("os");
const fs = require("fs");
const path = require("path");
const portfinder = require("portfinder");
const semver = require("semver");
const spawn = require("cross-spawn");
const node_fetch_1 = require("node-fetch");
const error_1 = require("../../../../error");
const parseRuntimeAndValidateSDK_1 = require("./parseRuntimeAndValidateSDK");
const logger_1 = require("../../../../logger");
const utils_1 = require("../../../../utils");
const discovery = require("../discovery");
const supported = require("../supported");
const validate = require("./validate");
const versioning = require("./versioning");
const fsutils_1 = require("../../../../fsutils");
const MIN_FUNCTIONS_SDK_VERSION = "3.20.0";
const MIN_FUNCTIONS_SDK_VERSION_FOR_EXTENSIONS_FEATURES = "5.1.0";
async function tryCreateDelegate(context) {
    const packageJsonPath = path.join(context.sourceDir, "package.json");
    try {
        await fs.promises.access(packageJsonPath);
    }
    catch {
        logger_1.logger.debug("Customer code is not Node");
        return undefined;
    }
    const runtime = (0, parseRuntimeAndValidateSDK_1.getRuntimeChoice)(context.sourceDir, context.runtime);
    if (!supported.runtimeIsLanguage(runtime, "nodejs")) {
        logger_1.logger.debug("Customer has a package.json but did not get a nodejs runtime. This should not happen");
        throw new error_1.FirebaseError(`Unexpected runtime ${runtime}`);
    }
    return new Delegate(context.projectId, context.projectDir, context.sourceDir, runtime);
}
class Delegate {
    constructor(projectId, projectDir, sourceDir, runtime) {
        this.projectId = projectId;
        this.projectDir = projectDir;
        this.sourceDir = sourceDir;
        this.runtime = runtime;
        this.language = "nodejs";
        this._sdkVersion = undefined;
        this._bin = "";
    }
    get sdkVersion() {
        if (this._sdkVersion === undefined) {
            this._sdkVersion = versioning.getFunctionsSDKVersion(this.sourceDir) || "";
        }
        return this._sdkVersion;
    }
    get bin() {
        if (this._bin === "") {
            this._bin = this.getNodeBinary();
        }
        return this._bin;
    }
    getNodeBinary() {
        const requestedVersion = semver.coerce(this.runtime);
        if (!requestedVersion) {
            throw new error_1.FirebaseError(`Could not determine version of the requested runtime: ${this.runtime}`);
        }
        const hostVersion = process.versions.node;
        const localNodePath = path.join(this.sourceDir, "node_modules/node");
        const localNodeVersion = versioning.findModuleVersion("node", localNodePath);
        if (localNodeVersion) {
            if (semver.major(requestedVersion) === semver.major(localNodeVersion)) {
                (0, utils_1.logLabeledSuccess)("functions", `Using node@${semver.major(localNodeVersion)} from local cache.`);
                return localNodePath;
            }
        }
        if (semver.major(requestedVersion) === semver.major(hostVersion)) {
            (0, utils_1.logLabeledSuccess)("functions", `Using node@${semver.major(hostVersion)} from host.`);
            return process.execPath;
        }
        if (!process.env.FIREPIT_VERSION) {
            (0, utils_1.logLabeledWarning)("functions", `Your requested "node" version "${semver.major(requestedVersion)}" doesn't match your global version "${semver.major(hostVersion)}". Using node@${semver.major(hostVersion)} from host.`);
            return process.execPath;
        }
        (0, utils_1.logLabeledWarning)("functions", `You've requested "node" version "${semver.major(requestedVersion)}", but the standalone Firebase CLI comes with bundled Node "${semver.major(hostVersion)}".`);
        (0, utils_1.logLabeledSuccess)("functions", `To use a different Node.js version, consider removing the standalone Firebase CLI and switching to "firebase-tools" on npm.`);
        return process.execPath;
    }
    validate() {
        versioning.checkFunctionsSDKVersion(this.sdkVersion);
        const relativeDir = path.relative(this.projectDir, this.sourceDir);
        validate.packageJsonIsValid(relativeDir, this.sourceDir, this.projectDir);
        return Promise.resolve();
    }
    async build() {
    }
    watch() {
        return Promise.resolve(() => Promise.resolve());
    }
    findFunctionsBinary() {
        const sourceNodeModulesPath = path.join(this.sourceDir, "node_modules");
        const projectNodeModulesPath = path.join(this.projectDir, "node_modules");
        const sdkPath = require.resolve("firebase-functions", { paths: [this.sourceDir] });
        const sdkNodeModulesPath = sdkPath.substring(0, sdkPath.lastIndexOf("node_modules") + 12);
        const ignorePnpmModulesPath = sdkNodeModulesPath.replace(/\/\.pnpm\/.*/, "");
        for (const nodeModulesPath of [
            sourceNodeModulesPath,
            projectNodeModulesPath,
            sdkNodeModulesPath,
            ignorePnpmModulesPath,
        ]) {
            const binPath = path.join(nodeModulesPath, ".bin", "firebase-functions");
            if ((0, fsutils_1.fileExistsSync)(binPath)) {
                logger_1.logger.debug(`Found firebase-functions binary at '${binPath}'`);
                return binPath;
            }
        }
        throw new error_1.FirebaseError("Failed to find location of Firebase Functions SDK. " +
            "Please file a bug on Github (https://github.com/firebase/firebase-tools/).");
    }
    spawnFunctionsProcess(config, envs) {
        const env = {
            ...envs,
            FUNCTIONS_CONTROL_API: "true",
            HOME: process.env.HOME,
            PATH: process.env.PATH,
            NODE_ENV: process.env.NODE_ENV,
            __FIREBASE_FRAMEWORKS_ENTRY__: process.env.__FIREBASE_FRAMEWORKS_ENTRY__,
        };
        if (Object.keys(config || {}).length) {
            env.CLOUD_RUNTIME_CONFIG = JSON.stringify(config);
        }
        const binPath = this.findFunctionsBinary();
        const childProcess = spawn(binPath, [this.sourceDir], {
            env,
            cwd: this.sourceDir,
            stdio: ["ignore", "pipe", "pipe"],
        });
        childProcess.stdout?.on("data", (chunk) => {
            logger_1.logger.info(chunk.toString("utf8"));
        });
        childProcess.stderr?.on("data", (chunk) => {
            logger_1.logger.error(chunk.toString("utf8"));
        });
        return childProcess;
    }
    execAdmin(config, envs, manifestPath) {
        return this.spawnFunctionsProcess(config, {
            ...envs,
            FUNCTIONS_MANIFEST_OUTPUT_PATH: manifestPath,
        });
    }
    serveAdmin(config, envs, port) {
        const childProcess = this.spawnFunctionsProcess(config, { ...envs, PORT: port });
        return Promise.resolve(async () => {
            const p = new Promise((resolve, reject) => {
                childProcess.once("exit", resolve);
                childProcess.once("error", reject);
            });
            try {
                await (0, node_fetch_1.default)(`http://localhost:${port}/__/quitquitquit`);
            }
            catch (e) {
                logger_1.logger.debug("Failed to call quitquitquit. This often means the server failed to start", e);
            }
            setTimeout(() => {
                if (!childProcess.killed) {
                    childProcess.kill("SIGKILL");
                }
            }, 10000);
            return p;
        });
    }
    async discoverBuild(config, env) {
        if (semver.valid(this.sdkVersion)) {
            if (semver.lt(this.sdkVersion, MIN_FUNCTIONS_SDK_VERSION)) {
                throw new error_1.FirebaseError(`You are using an old version of firebase-functions SDK (${this.sdkVersion}). ` +
                    `Please update firebase-functions SDK to >=${MIN_FUNCTIONS_SDK_VERSION}`);
            }
            if (semver.lt(this.sdkVersion, MIN_FUNCTIONS_SDK_VERSION_FOR_EXTENSIONS_FEATURES)) {
                (0, utils_1.logLabeledBullet)("functions", `You are using a version of firebase-functions SDK (${this.sdkVersion}) that does not have support for the newest Firebase Extensions features. ` +
                    `Please update firebase-functions SDK to >=${MIN_FUNCTIONS_SDK_VERSION_FOR_EXTENSIONS_FEATURES} to use them correctly`);
            }
        }
        else {
            logger_1.logger.debug(`Could not parse firebase-functions version '${this.sdkVersion}' into semver.`);
        }
        let discovered = await discovery.detectFromYaml(this.sourceDir, this.projectId, this.runtime);
        if (!discovered) {
            const discoveryPath = process.env.FIREBASE_FUNCTIONS_DISCOVERY_OUTPUT_PATH;
            if (!discoveryPath) {
                const basePort = 8000 + (0, utils_1.randomInt)(0, 1000);
                const port = await portfinder.getPortPromise({ port: basePort });
                const kill = await this.serveAdmin(config, env, port.toString());
                try {
                    discovered = await discovery.detectFromPort(port, this.projectId, this.runtime);
                }
                finally {
                    await kill();
                }
            }
            else if (discoveryPath === "true") {
                const tempDir = await fs.promises.mkdtemp(path.join(os.tmpdir(), "firebase-discovery-"));
                const manifestPath = path.join(tempDir, "functions.yaml");
                logger_1.logger.debug(`Writing functions discovery manifest to temporary file ${manifestPath}`);
                const childProcess = this.execAdmin(config, env, manifestPath);
                discovered = await discovery.detectFromOutputPath(childProcess, manifestPath, this.projectId, this.runtime);
            }
            else {
                const manifestPath = path.join(discoveryPath, "functions.yaml");
                logger_1.logger.debug(`Writing functions discovery manifest to ${manifestPath}`);
                const childProcess = this.execAdmin(config, env, manifestPath);
                discovered = await discovery.detectFromOutputPath(childProcess, manifestPath, this.projectId, this.runtime);
            }
        }
        return discovered;
    }
}
exports.Delegate = Delegate;
