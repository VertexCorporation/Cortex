"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const utils = require("../utils");
const buildToolsJarHelper_1 = require("../crashlytics/buildToolsJarHelper");
const error_1 = require("../error");
exports.command = new command_1.Command("crashlytics:mappingfile:generateid")
    .description("generate a mapping file id and write it to an Android resource file, which will be built into the app")
    .option("--resource-file <resourceFile>", "path to the Android resource XML file that will be created or updated.")
    .action(async (options) => {
    const debug = !!options.debug;
    const resourceFilePath = options.resourceFile;
    if (!resourceFilePath) {
        throw new error_1.FirebaseError("set --resource-file <resourceFile> to an Android resource file path, e.g. app/src/main/res/values/crashlytics.xml");
    }
    const jarFile = await (0, buildToolsJarHelper_1.fetchBuildtoolsJar)();
    const jarOptions = { resourceFilePath };
    utils.logBullet(`Updating resource file: ${resourceFilePath}`);
    const generateIdArgs = buildArgs(jarOptions);
    (0, buildToolsJarHelper_1.runBuildtoolsCommand)(jarFile, generateIdArgs, debug);
    utils.logBullet("Successfully updated mapping file id");
});
function buildArgs(options) {
    return ["-injectMappingFileIdIntoResource", options.resourceFilePath, "-verbose"];
}
