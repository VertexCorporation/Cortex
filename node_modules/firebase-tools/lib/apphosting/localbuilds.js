"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.runUniversalMaker = runUniversalMaker;
exports.localBuild = localBuild;
exports.validateLocalBuildNodeVersion = validateLocalBuildNodeVersion;
const childProcess = require("child_process");
const fs = require("fs-extra");
const path = require("path");
const semver = require("semver");
const index_1 = require("./secrets/index");
const prompt_1 = require("../prompt");
const error_1 = require("../error");
const logger_1 = require("../logger");
const utils_1 = require("../utils");
const universalMakerDownload_1 = require("./universalMakerDownload");
async function runUniversalMaker(projectRoot, addedEnv) {
    const universalMakerBinary = await (0, universalMakerDownload_1.getOrDownloadUniversalMaker)();
    executeUniversalMakerBinary(universalMakerBinary, projectRoot, addedEnv);
    return processUniversalMakerOutput(projectRoot);
}
function executeUniversalMakerBinary(universalMakerBinary, projectRoot, addedEnv) {
    try {
        const targetAppHosting = path.join(projectRoot, ".apphosting");
        fs.removeSync(targetAppHosting);
        fs.ensureDirSync(targetAppHosting);
        const res = childProcess.spawnSync(universalMakerBinary, ["-application_dir", projectRoot, "-output_dir", projectRoot, "-output_format", "json"], {
            cwd: projectRoot,
            env: {
                ...process.env,
                ...addedEnv,
                X_GOOGLE_TARGET_PLATFORM: "fah",
                FIREBASE_OUTPUT_BUNDLE_DIR: targetAppHosting,
            },
            stdio: "pipe",
        });
        const failed = !!res.error || res.status !== 0;
        const log = (msg) => (failed ? logger_1.logger.info(msg) : logger_1.logger.debug(msg));
        if (res.stdout) {
            log("[Universal Maker stdout]:\n" + res.stdout.toString());
        }
        if (res.stderr) {
            log("[Universal Maker stderr]:\n" + res.stderr.toString());
        }
        if (res.error) {
            throw res.error;
        }
        if (res.status !== 0) {
            throw new error_1.FirebaseError(`Universal Maker failed with exit code ${res.status ?? "unknown"}.`);
        }
    }
    catch (e) {
        if (e && typeof e === "object" && "code" in e && e.code === "EACCES") {
            throw new error_1.FirebaseError(`Failed to execute the Universal Maker binary at ${universalMakerBinary} due to permission constraints. Please assure you have set execution permissions (e.g., chmod +x) on the file.`);
        }
        throw e;
    }
}
function parseBundleYaml(projectRoot, defaultRunCommand) {
    const bundleYamlPath = path.join(projectRoot, ".apphosting", "bundle.yaml");
    if (!fs.existsSync(bundleYamlPath)) {
        throw new error_1.FirebaseError("Failed to resolve build artifacts. Ensure Universal Maker produced a valid bundle.yaml with outputFiles.");
    }
    const bundleRaw = fs.readFileSync(bundleYamlPath, "utf-8");
    const bundleData = (0, utils_1.wrappedSafeLoad)(bundleRaw);
    const runCommand = bundleData?.runConfig?.runCommand ?? defaultRunCommand;
    const outputFiles = bundleData?.outputFiles?.serverApp?.include ?? [];
    return { runCommand, outputFiles };
}
function processUniversalMakerOutput(projectRoot) {
    const outputFilePath = path.join(projectRoot, "build_output.json");
    if (!fs.existsSync(outputFilePath)) {
        throw new error_1.FirebaseError(`Universal Maker did not produce the expected output file at ${outputFilePath}`);
    }
    const outputRaw = fs.readFileSync(outputFilePath, "utf-8");
    fs.unlinkSync(outputFilePath);
    let umOutput;
    try {
        umOutput = JSON.parse(outputRaw);
    }
    catch (e) {
        throw new error_1.FirebaseError(`Failed to parse build_output.json: ${(0, error_1.getErrMsg)(e)}`);
    }
    const defaultRunCommand = `${umOutput.command} ${umOutput.args.join(" ")}`;
    const { runCommand: finalRunCommand, outputFiles: finalOutputFiles } = parseBundleYaml(projectRoot, defaultRunCommand);
    return {
        runConfig: {
            runCommand: finalRunCommand,
            environmentVariables: Object.entries(umOutput.envVars || {})
                .filter(([k]) => k !== "FIREBASE_OUTPUT_BUNDLE_DIR")
                .map(([k, v]) => ({
                variable: k,
                value: String(v),
                availability: ["RUNTIME"],
            })),
        },
        outputFiles: {
            serverApp: {
                include: finalOutputFiles,
            },
        },
    };
}
async function localBuild(projectId, projectRoot, env = {}, options) {
    const hasBuildAvailableSecrets = Object.values(env).some((v) => v.secret && (!v.availability || v.availability.includes("BUILD")));
    if (hasBuildAvailableSecrets && !options?.allowLocalBuildSecrets) {
        if (options?.nonInteractive) {
            throw new error_1.FirebaseError("Using build-available secrets during a local build in non-interactive mode requires the --allow-local-build-secrets flag.");
        }
        if (!(await (0, prompt_1.confirm)({
            message: "Your build includes secrets that are available to the build environment. Using secrets in local builds may leave sensitive values in local artifacts/temporary files. Do you want to continue?",
            default: false,
        }))) {
            throw new error_1.FirebaseError("Cancelled local build due to BUILD-available secrets.");
        }
    }
    const addedEnv = await toProcessEnv(projectId, env);
    const apphostingBuildOutput = await runUniversalMaker(projectRoot, addedEnv);
    const discoveredEnv = apphostingBuildOutput.runConfig.environmentVariables?.map(({ variable, value, availability }) => ({
        variable,
        value,
        availability: availability,
    }));
    return {
        outputFiles: apphostingBuildOutput.outputFiles?.serverApp.include ?? [],
        buildConfig: {
            runCommand: apphostingBuildOutput.runConfig.runCommand,
            env: discoveredEnv ?? [],
        },
    };
}
async function toProcessEnv(projectId, env) {
    const buildVars = Object.entries(env).filter(([, value]) => {
        return !value.availability || value.availability.includes("BUILD");
    });
    const resolvedEntries = await Promise.all(buildVars.map(async ([key, value]) => {
        const resolvedValue = value.secret
            ? await (0, index_1.loadSecret)(projectId, value.secret)
            : value.value || "";
        return [key, resolvedValue];
    }));
    return Object.fromEntries(resolvedEntries);
}
function validateLocalBuildNodeVersion(backend, projectRoot) {
    const runtimeValue = backend.runtime?.value ?? "";
    const isLegacyRuntime = runtimeValue === "" || runtimeValue === "nodejs";
    const abiuEnabled = !isLegacyRuntime && !backend.automaticBaseImageUpdatesDisabled;
    if (!abiuEnabled) {
        throw new error_1.FirebaseError(`Local builds are only supported for backends with ABIU (Automatic Base Image Updates) enabled. ` +
            `Your backend is currently configured with a non-ABIU runtime ("${runtimeValue || "unspecified"}"). ` +
            `Please update your backend to a versioned runtime (e.g., nodejs22) to enable local builds.`, { exit: 1 });
    }
    const targetMajorMatch = runtimeValue.match(/^nodejs(\d+)$/);
    if (!targetMajorMatch) {
        (0, utils_1.logLabeledWarning)("apphosting", `Unable to extract Node.js major version from the backend runtime ("${runtimeValue}"). ` +
            `Skipping local Node.js version compatibility checks.`);
        return;
    }
    const targetMajor = parseInt(targetMajorMatch[1], 10);
    let localNodeVersion;
    try {
        localNodeVersion = childProcess.execSync("node -v", { encoding: "utf8" }).trim();
    }
    catch {
        (0, utils_1.logLabeledWarning)("apphosting", `Unable to detect your local Node.js version (is 'node' installed and in your PATH?). ` +
            `Skipping local Node.js version compatibility checks.`);
        return;
    }
    const packageJsonPath = path.join(projectRoot, "package.json");
    const packageJson = fs.readJsonSync(packageJsonPath, { throws: false });
    const enginesNode = packageJson?.engines?.node;
    if (enginesNode) {
        (0, utils_1.logLabeledWarning)("apphosting", `Your package.json specifies Node.js engine "${enginesNode}". ` +
            `Please note that local builds do NOT use the "engines" field to resolve or download Node.js. ` +
            `Instead, your local build uses your host machine's active Node.js version (${localNodeVersion}) to compile the app, ` +
            `and your deployed app will run on the backend's configured ABIU runtime (${runtimeValue}).`);
        const targetRange = `^${targetMajor}.0.0`;
        if (semver.validRange(enginesNode) && !semver.intersects(targetRange, enginesNode)) {
            (0, utils_1.logLabeledWarning)("apphosting", `The Node.js version range specified in your package.json engines ("${enginesNode}") ` +
                `does not satisfy your backend's target ABIU runtime version (Node.js ${targetMajor}). ` +
                `Please update your package.json engines to align with your backend configuration.`);
        }
    }
    const localMajorMatch = localNodeVersion.match(/^v?(\d+)/);
    const localMajor = localMajorMatch ? parseInt(localMajorMatch[1], 10) : null;
    if (localMajor !== null && localMajor !== targetMajor) {
        (0, utils_1.logLabeledWarning)("apphosting", `Local Node.js version (${localNodeVersion}) does not match your backend's target Node.js version (Node.js ${targetMajor}). ` +
            `This mismatch may cause runtime issues. ` +
            `Please switch your local environment to Node.js ${targetMajor} to ensure build-to-run parity.`);
    }
}
