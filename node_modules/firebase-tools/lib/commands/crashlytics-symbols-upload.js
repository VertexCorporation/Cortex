"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const os = require("os");
const path = require("path");
const crypto_1 = require("crypto");
const command_1 = require("../command");
const error_1 = require("../error");
const utils = require("../utils");
const buildToolsJarHelper_1 = require("../crashlytics/buildToolsJarHelper");
var SymbolGenerator;
(function (SymbolGenerator) {
    SymbolGenerator["breakpad"] = "breakpad";
    SymbolGenerator["csym"] = "csym";
})(SymbolGenerator || (SymbolGenerator = {}));
const SYMBOL_CACHE_ROOT_DIR = process.env.FIREBASE_CRASHLYTICS_CACHE_PATH || os.tmpdir();
exports.command = new command_1.Command("crashlytics:symbols:upload <symbolFiles...>")
    .description("upload symbols for native code, to symbolicate stack traces")
    .option("--app <appID>", "the app id of your Firebase app")
    .option("--generator [breakpad|csym]", "the symbol generator being used, default is breakpad")
    .option("--dry-run", "generate symbols without uploading them")
    .action(async (symbolFiles, options) => {
    const app = getGoogleAppID(options);
    const generator = getSymbolGenerator(options);
    const dryRun = !!options.dryRun;
    const debug = !!options.debug;
    const jarFile = await (0, buildToolsJarHelper_1.fetchBuildtoolsJar)();
    const jarOptions = {
        app,
        generator,
        cachePath: path.join(SYMBOL_CACHE_ROOT_DIR, `crashlytics-${(0, crypto_1.randomUUID)()}`, "nativeSymbols", app.replace(/:/g, "-"), generator),
        symbolFile: "",
        generate: true,
    };
    for (const symbolFile of symbolFiles) {
        utils.logBullet(`Generating symbols for ${symbolFile}`);
        const generateArgs = buildArgs({ ...jarOptions, symbolFile });
        (0, buildToolsJarHelper_1.runBuildtoolsCommand)(jarFile, generateArgs, debug);
        utils.logBullet(`Generated symbols for ${symbolFile}`);
        utils.logBullet(`Output Path: ${jarOptions.cachePath}`);
    }
    if (dryRun) {
        utils.logBullet("Skipping upload because --dry-run was passed");
        return;
    }
    utils.logBullet(`Uploading all generated symbols...`);
    const uploadArgs = buildArgs({ ...jarOptions, generate: false });
    (0, buildToolsJarHelper_1.runBuildtoolsCommand)(jarFile, uploadArgs, debug);
    utils.logBullet("Successfully uploaded all symbols");
});
function getGoogleAppID(options) {
    if (!options.app) {
        throw new error_1.FirebaseError("set --app <appId> to a valid Firebase application id, e.g. 1:00000000:android:0000000");
    }
    return options.app;
}
function getSymbolGenerator(options) {
    if (!options.generator) {
        return SymbolGenerator.breakpad;
    }
    if (!Object.values(SymbolGenerator).includes(options.generator)) {
        throw new error_1.FirebaseError('--symbol-generator should be set to either "breakpad" or "csym"');
    }
    return options.generator;
}
function buildArgs(options) {
    const baseArgs = [
        "-symbolGenerator",
        options.generator,
        "-symbolFileCacheDir",
        options.cachePath,
        "-verbose",
    ];
    if (options.generate) {
        return baseArgs.concat(["-generateNativeSymbols", "-unstrippedLibrary", options.symbolFile]);
    }
    return baseArgs.concat(["-uploadNativeSymbols", "-googleAppId", options.app]);
}
