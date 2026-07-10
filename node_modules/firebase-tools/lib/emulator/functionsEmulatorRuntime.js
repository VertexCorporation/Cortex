"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const express = require("express");
const path = require("path");
const bodyParser = require("body-parser");
const url_1 = require("url");
const _ = require("lodash");
const types_1 = require("./types");
const error_1 = require("../error");
const constants_1 = require("./constants");
const functionsEmulatorShared_1 = require("./functionsEmulatorShared");
const functionsEmulatorUtils_1 = require("./functionsEmulatorUtils");
const types_2 = require("./events/types");
let functionModule;
let FUNCTION_TARGET_NAME;
let FUNCTION_SIGNATURE;
let FUNCTION_DEBUG_MODE;
let developerPkgJSON;
const dynamicImport = new Function("modulePath", "return import(modulePath)");
function noOp() {
    return false;
}
function requireAsync(moduleName, opts) {
    return new Promise((res, rej) => {
        try {
            res(require(require.resolve(moduleName, opts)));
        }
        catch (e) {
            rej(e);
        }
    });
}
function requireResolveAsync(moduleName, opts) {
    return new Promise((res, rej) => {
        try {
            res(require.resolve(moduleName, opts));
        }
        catch (e) {
            rej(e);
        }
    });
}
class Proxied {
    static getOriginal(target, key) {
        const value = target[key];
        if (!Proxied.isExists(value)) {
            return undefined;
        }
        else if (Proxied.isConstructor(value) || typeof value !== "function") {
            return value;
        }
        else {
            return value.bind(target);
        }
    }
    static applyOriginal(target, thisArg, argArray) {
        return target.apply(thisArg, argArray);
    }
    static isConstructor(obj) {
        return !!obj.prototype && !!obj.prototype.constructor.name;
    }
    static isExists(obj) {
        return obj !== undefined;
    }
    constructor(original) {
        this.original = original;
        this.rewrites = {};
        this.proxy = new Proxy(this.original, {
            get: (target, key) => {
                key = key.toString();
                if (this.rewrites[key]) {
                    return this.rewrites[key](target, key);
                }
                if (this.anyValue) {
                    return this.anyValue(target, key);
                }
                return Proxied.getOriginal(target, key);
            },
            apply: (target, thisArg, argArray) => {
                if (this.appliedValue) {
                    return this.appliedValue.apply(thisArg);
                }
                else {
                    return Proxied.applyOriginal(target, thisArg, argArray);
                }
            },
        });
    }
    when(key, value) {
        this.rewrites[key] = value;
        return this;
    }
    any(value) {
        this.anyValue = value;
        return this;
    }
    applied(value) {
        this.appliedValue = value;
        return this;
    }
    finalize() {
        return this.proxy;
    }
}
async function resolveDeveloperNodeModule(name) {
    const pkg = requirePackageJson();
    if (!pkg) {
        new types_1.EmulatorLog("SYSTEM", "missing-package-json", "").log();
        throw new Error("Could not find package.json");
    }
    const dependencies = pkg.dependencies;
    const devDependencies = pkg.devDependencies;
    const isInPackageJSON = dependencies[name] || devDependencies[name];
    if (!isInPackageJSON) {
        return { declared: false, installed: false };
    }
    const resolveResult = await requireResolveAsync(name, { paths: [process.cwd()] }).catch(noOp);
    if (!resolveResult) {
        return { declared: true, installed: false };
    }
    const modPackageJSON = require(path.join((0, functionsEmulatorShared_1.findModuleRoot)(name, resolveResult), "package.json"));
    const moduleResolution = {
        declared: true,
        installed: true,
        version: modPackageJSON.version,
        resolution: resolveResult,
    };
    logDebug(`Resolved module ${name}`, moduleResolution);
    return moduleResolution;
}
async function assertResolveDeveloperNodeModule(name) {
    const resolution = await resolveDeveloperNodeModule(name);
    if (!(resolution.installed && resolution.declared && resolution.resolution && resolution.version)) {
        throw new Error(`Assertion failure: could not fully resolve ${name}: ${JSON.stringify(resolution)}`);
    }
    return resolution;
}
async function verifyDeveloperNodeModules() {
    const modBundles = [
        { name: "firebase-admin", isDev: false, minVersion: "8.9.0" },
        { name: "firebase-functions", isDev: false, minVersion: "3.16.0" },
    ];
    for (const modBundle of modBundles) {
        const resolution = await resolveDeveloperNodeModule(modBundle.name);
        if (!resolution.declared) {
            new types_1.EmulatorLog("SYSTEM", "missing-module", "", modBundle).log();
            return false;
        }
        if (!resolution.installed) {
            new types_1.EmulatorLog("SYSTEM", "uninstalled-module", "", modBundle).log();
            return false;
        }
        if ((0, functionsEmulatorUtils_1.compareVersionStrings)(resolution.version, modBundle.minVersion) < 0) {
            new types_1.EmulatorLog("SYSTEM", "out-of-date-module", "", modBundle).log();
            return false;
        }
    }
    return true;
}
function requirePackageJson() {
    if (developerPkgJSON) {
        return developerPkgJSON;
    }
    try {
        const pkg = require(`${process.cwd()}/package.json`);
        developerPkgJSON = {
            engines: pkg.engines || {},
            dependencies: pkg.dependencies || {},
            devDependencies: pkg.devDependencies || {},
        };
        return developerPkgJSON;
    }
    catch (err) {
        return;
    }
}
function initializeNetworkFiltering() {
    const networkingModules = [
        { name: "http", module: require("http"), path: ["request"] },
        { name: "http", module: require("http"), path: ["get"] },
        { name: "https", module: require("https"), path: ["request"] },
        { name: "https", module: require("https"), path: ["get"] },
        { name: "net", module: require("net"), path: ["connect"] },
    ];
    const history = {};
    const results = networkingModules.map((bundle) => {
        let obj = bundle.module;
        for (const field of bundle.path.slice(0, -1)) {
            obj = obj[field];
        }
        const method = bundle.path.slice(-1)[0];
        const original = obj[method].bind(bundle.module);
        obj[method] = function (...args) {
            const hrefs = args
                .map((arg) => {
                if (typeof arg === "string") {
                    try {
                        new url_1.URL(arg);
                        return arg;
                    }
                    catch (err) {
                        return;
                    }
                }
                else if (typeof arg === "object") {
                    return arg.href;
                }
                else {
                    return;
                }
            })
                .filter((v) => v);
            const href = (hrefs.length && hrefs[0]) || "";
            if (href && !history[href] && !(0, functionsEmulatorUtils_1.isLocalHost)(href)) {
                history[href] = true;
                if (href.indexOf("googleapis.com") !== -1) {
                    new types_1.EmulatorLog("SYSTEM", "googleapis-network-access", "", {
                        href,
                        module: bundle.name,
                    }).log();
                }
                else {
                    new types_1.EmulatorLog("SYSTEM", "unidentified-network-access", "", {
                        href,
                        module: bundle.name,
                    }).log();
                }
            }
            try {
                return original(...args);
            }
            catch (e) {
                const newed = new original(...args);
                return newed;
            }
        };
        return { name: bundle.name, status: "mocked" };
    });
    logDebug("Outgoing network have been stubbed.", results);
}
async function initializeFirebaseFunctionsStubs() {
    const firebaseFunctionsResolution = await assertResolveDeveloperNodeModule("firebase-functions");
    if ((0, functionsEmulatorUtils_1.compareVersionStrings)(firebaseFunctionsResolution.version, "7.0.0") >= 0) {
        logDebug("Detected firebase-functions v7+, skipping legacy stubs.");
        return;
    }
    const firebaseFunctionsRoot = (0, functionsEmulatorShared_1.findModuleRoot)("firebase-functions", firebaseFunctionsResolution.resolution);
    const httpsProviderResolution = path.join(firebaseFunctionsRoot, "lib/providers/https");
    const httpsProviderV1Resolution = path.join(firebaseFunctionsRoot, "lib/v1/providers/https");
    let httpsProvider;
    try {
        httpsProvider = require(httpsProviderV1Resolution);
    }
    catch (e) {
        httpsProvider = require(httpsProviderResolution);
    }
    const onRequestInnerMethodName = "_onRequestWithOptions";
    const onRequestMethodOriginal = httpsProvider[onRequestInnerMethodName];
    httpsProvider[onRequestInnerMethodName] = (handler, opts) => {
        const cf = onRequestMethodOriginal(handler, opts);
        cf.__emulator_func = handler;
        return cf;
    };
    httpsProvider.onRequest = (handler) => {
        return httpsProvider[onRequestInnerMethodName](handler, {});
    };
}
function getDefaultConfig() {
    return JSON.parse(process.env.FIREBASE_CONFIG || "{}");
}
async function initializeFirebaseAdminStubs() {
    const adminResolution = await assertResolveDeveloperNodeModule("firebase-admin");
    const localAdminModule = require(adminResolution.resolution);
    const functionsResolution = await assertResolveDeveloperNodeModule("firebase-functions");
    const localFunctionsModule = require(functionsResolution.resolution);
    const defaultConfig = getDefaultConfig();
    const adminModuleProxy = new Proxied(localAdminModule);
    const proxiedAdminModule = adminModuleProxy
        .when("initializeApp", (adminModuleTarget) => (opts, appName) => {
        if (appName) {
            new types_1.EmulatorLog("SYSTEM", "non-default-admin-app-used", "", { appName, opts }).log();
            return adminModuleTarget.initializeApp(opts, appName);
        }
        const defaultAppOptions = opts ? opts : defaultConfig;
        new types_1.EmulatorLog("SYSTEM", "default-admin-app-used", `config=${defaultAppOptions}`, {
            opts: defaultAppOptions,
        }).log();
        const defaultApp = makeProxiedFirebaseApp(adminModuleTarget.initializeApp(defaultAppOptions));
        logDebug("initializeApp(DEFAULT)", defaultAppOptions);
        localFunctionsModule.app.setEmulatedAdminApp(defaultApp);
        if (process.env[constants_1.Constants.FIREBASE_AUTH_EMULATOR_HOST]) {
            if ((0, functionsEmulatorUtils_1.compareVersionStrings)(adminResolution.version, "9.3.0") < 0) {
                new types_1.EmulatorLog("WARN_ONCE", "runtime-status", "The Firebase Authentication emulator is running, but your 'firebase-admin' dependency is below version 9.3.0, so calls to Firebase Authentication will affect production.").log();
            }
            else if ((0, functionsEmulatorUtils_1.compareVersionStrings)(adminResolution.version, "9.4.2") <= 0) {
                const auth = defaultApp.auth();
                if (typeof auth.setJwtVerificationEnabled === "function") {
                    logDebug("auth.setJwtVerificationEnabled(false)", {});
                    auth.setJwtVerificationEnabled(false);
                }
                else {
                    logDebug("auth.setJwtVerificationEnabled not available", {});
                }
            }
        }
        return defaultApp;
    })
        .when("firestore", (target) => {
        warnAboutFirestoreProd();
        return Proxied.getOriginal(target, "firestore");
    })
        .when("database", (target) => {
        warnAboutDatabaseProd();
        return Proxied.getOriginal(target, "database");
    })
        .when("auth", (target) => {
        warnAboutAuthProd();
        return Proxied.getOriginal(target, "auth");
    })
        .when("storage", (target) => {
        warnAboutStorageProd();
        return Proxied.getOriginal(target, "storage");
    })
        .finalize();
    const v = require.cache[adminResolution.resolution];
    require.cache[adminResolution.resolution] = Object.assign(v, {
        exports: proxiedAdminModule,
        path: path.dirname(adminResolution.resolution),
    });
    logDebug("firebase-admin has been stubbed.", {
        adminResolution,
    });
}
function makeProxiedFirebaseApp(original) {
    const appProxy = new Proxied(original);
    return appProxy
        .when("firestore", (target) => {
        warnAboutFirestoreProd();
        return Proxied.getOriginal(target, "firestore");
    })
        .when("database", (target) => {
        warnAboutDatabaseProd();
        return Proxied.getOriginal(target, "database");
    })
        .when("auth", (target) => {
        warnAboutAuthProd();
        return Proxied.getOriginal(target, "auth");
    })
        .when("storage", (target) => {
        warnAboutStorageProd();
        return Proxied.getOriginal(target, "storage");
    })
        .finalize();
}
function warnAboutFirestoreProd() {
    if (process.env[constants_1.Constants.FIRESTORE_EMULATOR_HOST]) {
        return;
    }
    new types_1.EmulatorLog("WARN_ONCE", "runtime-status", "The Cloud Firestore emulator is not running, so calls to Firestore will affect production.").log();
}
function warnAboutDatabaseProd() {
    if (process.env[constants_1.Constants.FIREBASE_DATABASE_EMULATOR_HOST]) {
        return;
    }
    new types_1.EmulatorLog("WARN_ONCE", "runtime-status", "The Realtime Database emulator is not running, so calls to Realtime Database will affect production.").log();
}
function warnAboutAuthProd() {
    if (process.env[constants_1.Constants.FIREBASE_AUTH_EMULATOR_HOST]) {
        return;
    }
    new types_1.EmulatorLog("WARN_ONCE", "runtime-status", "The Firebase Authentication emulator is not running, so calls to Firebase Authentication will affect production.").log();
}
function warnAboutStorageProd() {
    if (process.env[constants_1.Constants.FIREBASE_STORAGE_EMULATOR_HOST]) {
        return;
    }
    new types_1.EmulatorLog("WARN_ONCE", "runtime-status", "The Firebase Storage emulator is not running, so calls to Firebase Storage will affect production.").log();
}
function rawBodySaver(req, res, buf) {
    req.rawBody = buf;
}
async function processBackground(trigger, reqBody, signature) {
    if (signature === "cloudevent") {
        return runCloudEvent(trigger, reqBody);
    }
    const data = reqBody.data;
    delete reqBody.data;
    const context = reqBody.context ? reqBody.context : reqBody;
    if (!reqBody.eventType || !reqBody.eventType.startsWith("google.storage")) {
        if (context.resource && context.resource.name) {
            logDebug("ProcessBackground: lifting resource.name from resource", context.resource);
            context.resource = context.resource.name;
        }
    }
    await runBackground(trigger, { data, context });
}
async function runFunction(func) {
    let caughtErr;
    try {
        await func();
    }
    catch (err) {
        caughtErr = err;
    }
    if (caughtErr) {
        throw caughtErr;
    }
}
async function runBackground(trigger, reqBody) {
    logDebug("RunBackground", reqBody);
    await runFunction(() => {
        return trigger(reqBody.data, reqBody.context);
    });
}
async function runCloudEvent(trigger, event) {
    logDebug("RunCloudEvent", event);
    await runFunction(() => {
        return trigger(event);
    });
}
async function runHTTPS(trigger, args) {
    if (args.length < 2) {
        throw new Error("Function must be passed 2 args.");
    }
    await runFunction(() => {
        return trigger(args[0], args[1]);
    });
}
async function moduleResolutionDetective(error) {
    const clues = {
        tsconfigJSON: await requireAsync("./tsconfig.json", { paths: [process.cwd()] }).catch(noOp),
        packageJSON: await requireAsync("./package.json", { paths: [process.cwd()] }).catch(noOp),
    };
    const isPotentially = {
        typescript: false,
        uncompiled: false,
        wrong_directory: false,
    };
    isPotentially.typescript = !!clues.tsconfigJSON;
    isPotentially.wrong_directory = !clues.packageJSON;
    isPotentially.uncompiled = !!_.get(clues.packageJSON, "scripts.build", false);
    new types_1.EmulatorLog("SYSTEM", "function-code-resolution-failed", "", {
        isPotentially,
        error: error.stack,
    }).log();
}
function logDebug(msg, data) {
    new types_1.EmulatorLog("DEBUG", "runtime-status", `[${process.pid}] ${msg}`, data).log();
}
async function initializeRuntime() {
    FUNCTION_DEBUG_MODE = process.env.FUNCTION_DEBUG_MODE || "";
    if (!FUNCTION_DEBUG_MODE) {
        FUNCTION_TARGET_NAME = process.env.FUNCTION_TARGET || "";
        if (!FUNCTION_TARGET_NAME) {
            new types_1.EmulatorLog("FATAL", "runtime-status", `Environment variable FUNCTION_TARGET cannot be empty. This shouldn't happen.`).log();
            await flushAndExit(1);
        }
        FUNCTION_SIGNATURE = process.env.FUNCTION_SIGNATURE_TYPE || "";
        if (!FUNCTION_SIGNATURE) {
            new types_1.EmulatorLog("FATAL", "runtime-status", `Environment variable FUNCTION_SIGNATURE_TYPE cannot be empty. This shouldn't happen.`).log();
            await flushAndExit(1);
        }
    }
    const verified = await verifyDeveloperNodeModules();
    if (!verified) {
        new types_1.EmulatorLog("INFO", "runtime-status", `Your functions could not be parsed due to an issue with your node_modules (see above)`).log();
        return;
    }
    initializeNetworkFiltering();
    await initializeFirebaseFunctionsStubs();
    await initializeFirebaseAdminStubs();
}
async function loadTriggers() {
    let triggerModule;
    try {
        triggerModule = require(process.cwd());
    }
    catch (err) {
        if (typeof err === "object" && err !== null && "code" in err) {
            const code = err.code;
            if (code !== "ERR_REQUIRE_ESM") {
                await moduleResolutionDetective(err);
                throw err;
            }
        }
        else {
            throw err;
        }
        const modulePath = require.resolve(process.cwd());
        const moduleURL = (0, url_1.pathToFileURL)(modulePath).href;
        triggerModule = await dynamicImport(moduleURL);
    }
    return triggerModule;
}
async function flushAndExit(code) {
    await types_1.EmulatorLog.waitForFlush();
    process.exit(code);
}
async function handleMessage(message) {
    let debug;
    try {
        debug = JSON.parse(message);
    }
    catch (e) {
        new types_1.EmulatorLog("FATAL", "runtime-error", `Got unexpected message body: ${message}`).log();
        await flushAndExit(1);
        return;
    }
    if (FUNCTION_DEBUG_MODE) {
        if (debug) {
            FUNCTION_TARGET_NAME = debug.functionTarget;
            FUNCTION_SIGNATURE = debug.functionSignature;
        }
        else {
            new types_1.EmulatorLog("WARN", "runtime-warning", "Expected debug payload while in debug mode.");
        }
    }
}
async function main() {
    let lastSignal = new Date().getTime();
    let signalCount = 0;
    process.on("SIGINT", () => {
        const now = new Date().getTime();
        if (now - lastSignal < 100) {
            return;
        }
        signalCount = signalCount + 1;
        lastSignal = now;
        if (signalCount >= 2) {
            process.exit(1);
        }
    });
    await initializeRuntime();
    try {
        functionModule = await loadTriggers();
    }
    catch (e) {
        new types_1.EmulatorLog("FATAL", "runtime-status", `Failed to initialize and load triggers. This shouldn't happen: ${(0, error_1.getErrMsg)(e)}`).log();
        await flushAndExit(1);
    }
    const app = express();
    app.enable("trust proxy");
    const bodyParserLimit = "32mb";
    app.use(bodyParser.json({
        limit: bodyParserLimit,
        verify: rawBodySaver,
    }));
    app.use(bodyParser.text({
        limit: bodyParserLimit,
        verify: rawBodySaver,
    }));
    app.use(bodyParser.urlencoded({
        extended: true,
        limit: bodyParserLimit,
        verify: rawBodySaver,
    }));
    app.use(bodyParser.raw({
        type: "*/*",
        limit: bodyParserLimit,
        verify: rawBodySaver,
    }));
    app.get("/__/health", (req, res) => {
        res.status(200).send();
    });
    app.all("/favicon.ico|/robots.txt", (req, res) => {
        res.status(404).send();
    });
    app.all(`/*`, async (req, res) => {
        try {
            const trigger = FUNCTION_TARGET_NAME.split(".").reduce((mod, functionTargetPart) => {
                return mod?.[functionTargetPart];
            }, functionModule);
            if (!trigger) {
                throw new Error(`Failed to find function ${FUNCTION_TARGET_NAME} in the loaded module`);
            }
            switch (FUNCTION_SIGNATURE) {
                case "event":
                case "cloudevent":
                    let reqBody;
                    const rawBody = req.rawBody;
                    if (types_2.EventUtils.isBinaryCloudEvent(req)) {
                        reqBody = types_2.EventUtils.extractBinaryCloudEventContext(req);
                        reqBody.data = req.body;
                    }
                    else {
                        reqBody = JSON.parse(rawBody.toString());
                    }
                    await processBackground(trigger, reqBody, FUNCTION_SIGNATURE);
                    res.send({ status: "acknowledged" });
                    break;
                case "http":
                    await runHTTPS(trigger, [req, res]);
            }
        }
        catch (err) {
            new types_1.EmulatorLog("FATAL", "runtime-error", (0, error_1.getErrStack)(err)).log();
            res.status(500).send((0, error_1.getErrMsg)(err));
        }
    });
    app.listen(process.env.PORT, () => {
        logDebug(`Listening to port: ${process.env.PORT}`);
    });
    let messageHandlePromise = Promise.resolve();
    process.on("message", (message) => {
        messageHandlePromise = messageHandlePromise
            .then(() => {
            return handleMessage(message);
        })
            .catch((err) => {
            logDebug(`Error in handleMessage: ${message} => ${err}: ${err.stack}`);
            new types_1.EmulatorLog("FATAL", "runtime-error", err.message || err, err).log();
            return flushAndExit(1);
        });
    });
}
if (require.main === module) {
    main()
        .then(() => {
        logDebug("Functions runtime initialized.", {
            cwd: process.cwd(),
            node_version: process.versions.node,
        });
    })
        .catch((err) => {
        new types_1.EmulatorLog("FATAL", "runtime-error", err.message || err, err).log();
        return flushAndExit(1);
    });
}
