"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Delegate = exports.DART_ENTRY_POINT = void 0;
exports.tryCreateDelegate = tryCreateDelegate;
const fs = require("fs");
const path = require("path");
const util_1 = require("util");
const spawn = require("cross-spawn");
const discovery = require("../discovery");
const supported = require("../supported");
const logger_1 = require("../../../../logger");
const error_1 = require("../../../../error");
const utils_1 = require("../../../../utils");
const registry_1 = require("../../../../emulator/registry");
const types_1 = require("../../../../emulator/types");
const experiments = require("../../../../experiments");
async function tryCreateDelegate(context) {
    const pubspecYamlPath = path.join(context.sourceDir, "pubspec.yaml");
    if (!(await (0, util_1.promisify)(fs.exists)(pubspecYamlPath))) {
        logger_1.logger.debug("Customer code is not Dart code.");
        return;
    }
    experiments.assertEnabled("dartfunctions", "use Dart functions");
    const runtime = context.runtime ?? supported.latest("dart");
    if (!supported.isRuntime(runtime)) {
        throw new error_1.FirebaseError(`Runtime ${runtime} is not a valid Dart runtime`);
    }
    if (!supported.runtimeIsLanguage(runtime, "dart")) {
        throw new error_1.FirebaseError(`Internal error. Trying to construct a dart runtime delegate for runtime ${runtime}`, { exit: 1 });
    }
    return Promise.resolve(new Delegate(context.projectId, context.sourceDir, runtime));
}
const MIN_DART_SDK_VERSION = "3.9.0";
exports.DART_ENTRY_POINT = "bin/server.dart";
class Delegate {
    constructor(projectId, sourceDir, runtime) {
        this.projectId = projectId;
        this.sourceDir = sourceDir;
        this.runtime = runtime;
        this.language = "dart";
        this.bin = "dart";
        this.entryPoint = exports.DART_ENTRY_POINT;
        this.buildRunnerProcess = null;
    }
    async validate() {
        const result = spawn.sync(this.bin, ["--version"], {
            encoding: "utf8",
            timeout: 10000,
        });
        if (result.error) {
            throw new error_1.FirebaseError(`Could not find a Dart SDK. Make sure the '${this.bin}' command is available on your PATH.`);
        }
        const versionOutput = (result.stdout || result.stderr || "").toString();
        const match = /Dart SDK version:\s*(\d+\.\d+\.\d+)/.exec(versionOutput);
        if (match) {
            const installedVersion = match[1];
            if (installedVersion.localeCompare(MIN_DART_SDK_VERSION, undefined, { numeric: true }) < 0) {
                throw new error_1.FirebaseError(`Dart SDK version ${installedVersion} is not supported. ` +
                    `Firebase Functions for Dart requires Dart ${MIN_DART_SDK_VERSION} or later. ` +
                    `Please upgrade your Dart SDK.`);
            }
        }
        else {
            logger_1.logger.debug(`Could not parse Dart SDK version from: ${versionOutput}`);
        }
        const pubspecYamlPath = path.join(this.sourceDir, "pubspec.yaml");
        try {
            await fs.promises.access(pubspecYamlPath, fs.constants.R_OK);
        }
        catch (err) {
            throw new error_1.FirebaseError(`Failed to read pubspec.yaml at ${pubspecYamlPath}: ${err.message}`);
        }
        const entryPointPath = path.join(this.sourceDir, this.entryPoint);
        try {
            await fs.promises.access(entryPointPath, fs.constants.R_OK);
        }
        catch (err) {
            throw new error_1.FirebaseError(`Could not find entry point at ${entryPointPath}. ` +
                `Firebase Functions for Dart expects your main function in ${this.entryPoint}.`);
        }
        const packageConfigPath = path.join(this.sourceDir, ".dart_tool", "package_config.json");
        try {
            await fs.promises.access(packageConfigPath, fs.constants.R_OK);
        }
        catch {
            (0, utils_1.logLabeledBullet)("functions", "running dart pub get...");
            const pubGetProcess = spawn(this.bin, ["pub", "get"], {
                cwd: this.sourceDir,
                stdio: ["ignore", "pipe", "pipe"],
            });
            pubGetProcess.stdout?.on("data", (chunk) => {
                logger_1.logger.debug(`[dart pub get] ${chunk.toString("utf8").trim()}`);
            });
            pubGetProcess.stderr?.on("data", (chunk) => {
                logger_1.logger.debug(`[dart pub get] ${chunk.toString("utf8").trim()}`);
            });
            await new Promise((resolve, reject) => {
                pubGetProcess.on("exit", (code) => {
                    if (code === 0 || code === null) {
                        resolve();
                    }
                    else {
                        reject(new error_1.FirebaseError(`dart pub get failed with exit code ${code}. ` +
                            `Make sure your pubspec.yaml is valid and dependencies are available.`));
                    }
                });
                pubGetProcess.on("error", reject);
            });
        }
    }
    async build() {
        if (Delegate.watchModeActive) {
            return;
        }
        (0, utils_1.logLabeledBullet)("functions", "running build_runner...");
        const buildRunnerProcess = spawn(this.bin, ["run", "build_runner", "build", "--delete-conflicting-outputs"], {
            cwd: this.sourceDir,
            stdio: ["ignore", "pipe", "pipe"],
        });
        buildRunnerProcess.stdout?.on("data", (chunk) => {
            logger_1.logger.debug(`[build_runner] ${chunk.toString("utf8").trim()}`);
        });
        buildRunnerProcess.stderr?.on("data", (chunk) => {
            logger_1.logger.debug(`[build_runner] ${chunk.toString("utf8").trim()}`);
        });
        await new Promise((resolve, reject) => {
            buildRunnerProcess.on("exit", (code) => {
                if (code === 0 || code === null) {
                    resolve();
                }
                else {
                    reject(new error_1.FirebaseError(`build_runner failed with exit code ${code}. ` +
                        `Make sure your Dart project is properly configured.`));
                }
            });
            buildRunnerProcess.on("error", reject);
        });
        if (registry_1.EmulatorRegistry.isRunning(types_1.Emulators.FUNCTIONS)) {
            logger_1.logger.debug("Skipping Dart compilation in emulator mode.");
            return;
        }
        const binDir = path.join(this.sourceDir, "bin");
        await fs.promises.mkdir(binDir, { recursive: true });
        (0, utils_1.logLabeledBullet)("functions", "compiling Dart to linux-x64 executable...");
        const compileProcess = spawn(this.bin, [
            "compile",
            "exe",
            this.entryPoint,
            "-o",
            "bin/server",
            "--target-os=linux",
            "--target-arch=x64",
        ], {
            cwd: this.sourceDir,
            stdio: ["ignore", "pipe", "pipe"],
        });
        compileProcess.stdout?.on("data", (chunk) => {
            logger_1.logger.debug(`[dart compile] ${chunk.toString("utf8").trim()}`);
        });
        compileProcess.stderr?.on("data", (chunk) => {
            logger_1.logger.debug(`[dart compile] ${chunk.toString("utf8").trim()}`);
        });
        await new Promise((resolve, reject) => {
            compileProcess.on("exit", (code) => {
                if (code === 0 || code === null) {
                    resolve();
                }
                else {
                    reject(new error_1.FirebaseError(`Dart compilation failed with exit code ${code}. ` +
                        `Make sure your Dart project compiles successfully with: ` +
                        `dart compile exe ${this.entryPoint} --target-os=linux --target-arch=x64`));
                }
            });
            compileProcess.on("error", reject);
        });
        (0, utils_1.logLabeledBullet)("functions", "Dart compilation complete.");
    }
    async watch(onRebuild) {
        Delegate.watchModeActive = true;
        logger_1.logger.debug("Starting build_runner watch for Dart functions...");
        const buildRunnerProcess = spawn(this.bin, ["run", "build_runner", "watch", "--delete-conflicting-outputs"], {
            cwd: this.sourceDir,
            stdio: ["ignore", "pipe", "pipe"],
        });
        this.buildRunnerProcess = buildRunnerProcess;
        let initialBuildComplete = false;
        let resolveInitialBuild;
        let rejectInitialBuild;
        const initialBuildPromise = new Promise((resolve, reject) => {
            resolveInitialBuild = resolve;
            rejectInitialBuild = reject;
        });
        const buildCompletePattern = /Succeeded after|Built with build_runner/;
        buildRunnerProcess.stdout?.on("data", (chunk) => {
            const output = chunk.toString("utf8").trim();
            if (output) {
                logger_1.logger.debug(`[build_runner] ${output}`);
                if (buildCompletePattern.test(output)) {
                    if (!initialBuildComplete) {
                        initialBuildComplete = true;
                        logger_1.logger.debug("build_runner initial build completed");
                        resolveInitialBuild();
                    }
                    else if (onRebuild) {
                        onRebuild();
                    }
                }
            }
        });
        buildRunnerProcess.stderr?.on("data", (chunk) => {
            const output = chunk.toString("utf8").trim();
            if (output) {
                logger_1.logger.debug(`[build_runner] ${output}`);
            }
        });
        buildRunnerProcess.on("exit", (code) => {
            if (code !== 0 && code !== null) {
                logger_1.logger.debug(`build_runner exited with code ${code}. Initial build failed.`);
                if (!initialBuildComplete) {
                    rejectInitialBuild(new error_1.FirebaseError(`build_runner exited with code ${code}. Your Dart functions may not be deployed or emulated correctly.`));
                }
            }
            this.buildRunnerProcess = null;
        });
        buildRunnerProcess.on("error", (err) => {
            logger_1.logger.debug(`Failed to start build_runner: ${err.message}. Your Dart functions may not be deployed or emulated correctly.`);
            if (!initialBuildComplete) {
                rejectInitialBuild(err);
            }
        });
        await initialBuildPromise;
        return async () => {
            if (this.buildRunnerProcess && !this.buildRunnerProcess.killed) {
                this.buildRunnerProcess.kill("SIGTERM");
                this.buildRunnerProcess = null;
            }
        };
    }
    async discoverBuild(_configValues, envs) {
        const yamlDir = this.sourceDir;
        const yamlPath = path.join(yamlDir, "functions.yaml");
        let discovered = await discovery.detectFromYaml(yamlDir, this.projectId, this.runtime);
        if (!discovered) {
            logger_1.logger.debug("functions.yaml not found, running build_runner to generate it...");
            const buildRunnerProcess = spawn(this.bin, ["run", "build_runner", "build"], {
                cwd: this.sourceDir,
                stdio: ["ignore", "pipe", "pipe"],
            });
            buildRunnerProcess.stdout?.on("data", (chunk) => {
                logger_1.logger.debug(`[build_runner] ${chunk.toString("utf8")}`);
            });
            buildRunnerProcess.stderr?.on("data", (chunk) => {
                logger_1.logger.debug(`[build_runner] ${chunk.toString("utf8")}`);
            });
            await new Promise((resolve, reject) => {
                buildRunnerProcess.on("exit", (code) => {
                    if (code === 0 || code === null) {
                        resolve();
                    }
                    else {
                        reject(new error_1.FirebaseError(`build_runner failed with exit code ${code}. Make sure your Dart project is properly configured.`));
                    }
                });
                buildRunnerProcess.on("error", reject);
            });
            discovered = await discovery.detectFromYaml(yamlDir, this.projectId, this.runtime);
            if (!discovered) {
                throw new error_1.FirebaseError(`Could not find functions.yaml at ${yamlPath} after running build_runner. ` +
                    `Make sure your Dart project is properly configured with firebase_functions.`);
            }
        }
        const isEmulator = envs.FUNCTIONS_EMULATOR === "true";
        if (!isEmulator) {
            for (const ep of Object.values(discovered.endpoints)) {
                if (ep.platform === "gcfv2") {
                    ep.platform = "run";
                }
            }
        }
        return discovered;
    }
}
exports.Delegate = Delegate;
Delegate.watchModeActive = false;
