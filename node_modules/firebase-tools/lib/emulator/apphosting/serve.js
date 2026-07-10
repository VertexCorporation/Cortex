"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.start = start;
exports.getEmulatorEnvs = getEmulatorEnvs;
const net_1 = require("net");
const portUtils_1 = require("../portUtils");
const developmentServer_1 = require("./developmentServer");
const constants_1 = require("../constants");
const spawn_1 = require("../../init/spawn");
const developmentServer_2 = require("./developmentServer");
const types_1 = require("../types");
const config_1 = require("./config");
const projectPath_1 = require("../../projectPath");
const registry_1 = require("../registry");
const env_1 = require("../env");
const error_1 = require("../../error");
const index_1 = require("../../apphosting/secrets/index");
const utils_1 = require("../../utils");
const apphosting = require("../../gcp/apphosting");
const constants_2 = require("../constants");
const fetchWebSetup_1 = require("../../fetchWebSetup");
const child_process_1 = require("child_process");
const semver_1 = require("semver");
const utils_2 = require("../../apphosting/utils");
const apps_1 = require("../../management/apps");
async function start(options) {
    const hostname = constants_1.DEFAULT_HOST;
    let port = options?.port ?? constants_1.DEFAULT_PORTS.apphosting;
    while (!(await availablePort(hostname, port))) {
        port += 1;
    }
    const backendRoot = (0, projectPath_1.resolveProjectPath)({}, options?.rootDirectory ?? "./");
    let startCommand;
    if (options?.startCommand) {
        startCommand = options?.startCommand;
        if (startCommand.includes("--port") || startCommand.includes(" -p ")) {
            throw new error_1.FirebaseError("Specifying a port in the start command is not supported by the apphosting emulator");
        }
        if (startCommand.includes("ng serve")) {
            startCommand += ` --port ${port}`;
        }
        developmentServer_2.logger.logLabeled("BULLET", types_1.Emulators.APPHOSTING, `running custom start command: '${startCommand}'`);
    }
    else {
        startCommand = await (0, developmentServer_1.detectPackageManagerStartCommand)(backendRoot);
        developmentServer_2.logger.logLabeled("BULLET", types_1.Emulators.APPHOSTING, `starting app with: '${startCommand}'`);
    }
    const packageManager = await (0, developmentServer_1.detectPackageManager)(backendRoot).catch(() => undefined);
    let autoinitEnvVars = {};
    if (packageManager === "pnpm") {
        (0, utils_1.logLabeledWarning)("apphosting", "Firebase JS SDK autoinit does not currently support PNPM.");
    }
    else {
        const webappConfig = await getBackendAppConfig(options?.projectId, options?.backendId);
        autoinitEnvVars = (0, utils_2.getAutoinitEnvVars)(webappConfig);
    }
    const apphostingLocalConfig = await (0, config_1.getLocalAppHostingConfiguration)(backendRoot);
    const resolveEnv = Object.entries(apphostingLocalConfig.env).map(async ([key, value]) => [
        key,
        value.value ? value.value : await (0, index_1.loadSecret)(options?.projectId, value.secret),
    ]);
    const environmentVariablesToInject = {
        NODE_ENV: process.env.NODE_ENV,
        ...autoinitEnvVars,
        ...getEmulatorEnvs(),
        ...Object.fromEntries(await Promise.all(resolveEnv)),
        FIREBASE_APP_HOSTING: "1",
        X_GOOGLE_TARGET_PLATFORM: "fah",
        GCLOUD_PROJECT: options?.projectId,
        PROJECT_ID: options?.projectId,
        PORT: port.toString(),
    };
    if (packageManager !== "pnpm") {
        await tripFirebasePostinstall(backendRoot, environmentVariablesToInject);
    }
    (0, spawn_1.spawnWithCommandString)(startCommand, backendRoot, environmentVariablesToInject)
        .catch((err) => {
        developmentServer_2.logger.logLabeled("ERROR", types_1.Emulators.APPHOSTING, `failed to start Dev Server: ${err}`);
    })
        .then(() => developmentServer_2.logger.logLabeled("BULLET", types_1.Emulators.APPHOSTING, `Dev Server stopped`));
    return { hostname, port };
}
function availablePort(host, port) {
    return (0, portUtils_1.checkListenable)({
        address: host,
        port,
        family: (0, net_1.isIPv4)(host) ? "IPv4" : "IPv6",
    });
}
function getEmulatorEnvs() {
    const envs = {};
    const emulatorInfos = registry_1.EmulatorRegistry.listRunningWithInfo().filter((emulator) => emulator.name !== types_1.Emulators.APPHOSTING);
    (0, env_1.setEnvVarsForEmulators)(envs, emulatorInfos);
    return envs;
}
async function tripFirebasePostinstall(rootDirectory, env) {
    const npmLs = (0, child_process_1.spawnSync)("npm", ["ls", "@firebase/util", "--json", "--long"], {
        cwd: rootDirectory,
        shell: process.platform === "win32",
    });
    if (!npmLs.stdout) {
        return;
    }
    const npmLsResults = JSON.parse(npmLs.stdout.toString().trim());
    const dependenciesToSearch = Object.values(npmLsResults.dependencies || {});
    const firebaseUtilPaths = [];
    for (const dependency of dependenciesToSearch) {
        if (dependency.name === "@firebase/util" &&
            (0, semver_1.gte)(dependency.version, "1.11.0") &&
            firebaseUtilPaths.indexOf(dependency.path) === -1) {
            firebaseUtilPaths.push(dependency.path);
        }
        if (dependency.dependencies) {
            dependenciesToSearch.push(...Object.values(dependency.dependencies));
        }
    }
    await Promise.all(firebaseUtilPaths.map((path) => new Promise((resolve) => {
        (0, child_process_1.spawnSync)("npm", ["run", "postinstall"], {
            cwd: path,
            env,
            stdio: "ignore",
            shell: process.platform === "win32",
        });
        resolve();
    })));
}
async function getBackendAppConfig(projectId, backendId) {
    if (!projectId) {
        return undefined;
    }
    if (constants_2.Constants.isDemoProject(projectId)) {
        return (0, fetchWebSetup_1.constructDefaultWebSetup)(projectId);
    }
    if (!backendId) {
        return undefined;
    }
    const backendsList = await apphosting.listBackends(projectId, "-").catch(() => undefined);
    const backend = backendsList?.backends.find((b) => apphosting.parseBackendName(b.name).id === backendId);
    if (!backend) {
        (0, utils_1.logLabeledWarning)("apphosting", `Unable to lookup details for backend ${backendId}. Firebase SDK autoinit will not be available.`);
        return undefined;
    }
    if (!backend.appId) {
        return undefined;
    }
    return (await (0, apps_1.getAppConfig)(backend.appId, apps_1.AppPlatform.WEB));
}
