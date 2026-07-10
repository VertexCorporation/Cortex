"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const ora = require("ora");
const fs = require("fs-extra");
const command_1 = require("../command");
const apps_1 = require("../management/apps");
const projectUtils_1 = require("../projectUtils");
const projects_1 = require("../management/projects");
const error_1 = require("../error");
const requireAuth_1 = require("../requireAuth");
const logger_1 = require("../logger");
const prompt_1 = require("../prompt");
function checkForApps(apps, appPlatform) {
    if (!apps.length) {
        throw new error_1.FirebaseError(`There are no ${appPlatform === apps_1.AppPlatform.ANY ? "" : appPlatform + " "}apps ` +
            "associated with this Firebase project");
    }
}
async function selectAppInteractively(apps, appPlatform) {
    checkForApps(apps, appPlatform);
    const choices = apps.map((app) => {
        return {
            name: `${app.displayName || app.bundleId || app.packageName}` +
                ` - ${app.appId} (${app.platform})`,
            value: app,
        };
    });
    return await (0, prompt_1.select)({
        message: `Select the ${appPlatform === apps_1.AppPlatform.ANY ? "" : appPlatform + " "}` +
            "app to get the configuration data:",
        choices,
    });
}
exports.command = new command_1.Command("apps:sdkconfig [platform] [appId]")
    .description("print the Google Services config of a Firebase app. " +
    "[platform] can be IOS, ANDROID or WEB (case insensitive)")
    .option("-o, --out [file]", "(optional) write config output to a file")
    .before(requireAuth_1.requireAuth)
    .action(async (platform = "", appId = "", options) => {
    let appPlatform = (0, apps_1.getAppPlatform)(platform);
    if (!appId) {
        let projectId = (0, projectUtils_1.needProjectId)(options);
        if (options.nonInteractive && !projectId) {
            throw new error_1.FirebaseError("Must supply app and project ids in non-interactive mode.");
        }
        else if (!projectId) {
            const result = await (0, projects_1.getOrPromptProject)(options);
            projectId = result.projectId;
        }
        const apps = await (0, apps_1.listFirebaseApps)(projectId, appPlatform);
        checkForApps(apps, appPlatform);
        if (apps.length === 1) {
            appId = apps[0].appId;
            appPlatform = apps[0].platform;
        }
        else if (options.nonInteractive) {
            throw new error_1.FirebaseError(`Project ${projectId} has multiple apps, must specify an app id.`);
        }
        else {
            const appMetadata = await selectAppInteractively(apps, appPlatform);
            appId = appMetadata.appId;
            appPlatform = appMetadata.platform;
        }
    }
    let configData;
    const spinner = ora(`Downloading configuration data of your Firebase ${appPlatform} app`).start();
    try {
        configData = await (0, apps_1.getAppConfig)(appId, appPlatform);
    }
    catch (err) {
        spinner.fail();
        throw err;
    }
    spinner.succeed();
    const fileInfo = (0, apps_1.getAppConfigFile)(configData, appPlatform);
    if (appPlatform === apps_1.AppPlatform.WEB) {
        fileInfo.sdkConfig = configData;
    }
    if (options.out === undefined) {
        logger_1.logger.info(fileInfo.fileContents);
        return fileInfo;
    }
    const shouldUseDefaultFilename = options.out === true || options.out === "";
    const filename = shouldUseDefaultFilename ? fileInfo.fileName : options.out;
    if (fs.existsSync(filename)) {
        if (options.nonInteractive) {
            throw new error_1.FirebaseError(`${filename} already exists`);
        }
        const overwrite = await (0, prompt_1.confirm)(`${filename} already exists. Do you want to overwrite?`);
        if (!overwrite) {
            return fileInfo;
        }
    }
    fs.writeFileSync(filename, fileInfo.fileContents);
    logger_1.logger.info(`App configuration is written in ${filename}`);
    return fileInfo;
});
