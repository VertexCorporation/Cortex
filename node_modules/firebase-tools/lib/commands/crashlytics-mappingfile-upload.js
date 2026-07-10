"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const error_1 = require("../error");
const utils = require("../utils");
const buildToolsJarHelper_1 = require("../crashlytics/buildToolsJarHelper");
exports.command = new command_1.Command("crashlytics:mappingfile:upload <mappingFile>")
    .description("upload a ProGuard/R8-compatible mapping file to deobfuscate stack traces")
    .option("--app <appID>", "the app id of your Firebase app")
    .option("--resource-file <resourceFile>", "path to the Android resource XML file that includes the mapping file id")
    .action(async (mappingFile, options) => {
    const app = getGoogleAppID(options);
    const debug = !!options.debug;
    if (!mappingFile) {
        throw new error_1.FirebaseError("set `--mapping-file <mappingFile>` to a valid mapping file path, e.g. app/build/outputs/mapping.txt");
    }
    const mappingFilePath = mappingFile;
    const resourceFilePath = options.resourceFile;
    if (!resourceFilePath) {
        throw new error_1.FirebaseError("set --resource-file <resourceFile> to a valid Android resource file path, e.g. app/main/res/values/strings.xml");
    }
    const jarFile = await (0, buildToolsJarHelper_1.fetchBuildtoolsJar)();
    const jarOptions = { app, mappingFilePath, resourceFilePath };
    utils.logBullet(`Uploading mapping file: ${mappingFilePath}`);
    const uploadArgs = buildArgs(jarOptions);
    (0, buildToolsJarHelper_1.runBuildtoolsCommand)(jarFile, uploadArgs, debug);
    utils.logBullet("Successfully uploaded mapping file");
});
function getGoogleAppID(options) {
    if (!options.app) {
        throw new error_1.FirebaseError("set --app <appId> to a valid Firebase application id, e.g. 1:00000000:android:0000000");
    }
    return options.app;
}
function buildArgs(options) {
    return [
        "-uploadMappingFile",
        options.mappingFilePath,
        "-resourceFile",
        options.resourceFilePath,
        "-googleAppId",
        options.app,
        "-verbose",
    ];
}
