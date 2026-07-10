"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const logger_1 = require("../logger");
const migrate_1 = require("../firebase_studio/migrate");
const path = require("path");
const error_1 = require("../error");
const unzip_1 = require("../unzip");
const fs = require("fs");
exports.command = new command_1.Command("studio:export [path]")
    .description("Bootstrap Firebase Studio apps for migration to Antigravity. Run on the unzipped folder from the Firebase Studio download, or directly on the downloaded zip file.")
    .option("--no-start-antigravity", "skip starting the Antigravity IDE after migration")
    .action(async (exportPath, options) => {
    if (!exportPath) {
        throw new error_1.FirebaseError("Must specify the path to the Firebase Studio downloaded zip file or the unzipped folder path.", { exit: 1 });
    }
    let rootPath = path.resolve(exportPath);
    if (fs.existsSync(rootPath) && fs.statSync(rootPath).isFile() && rootPath.endsWith(".zip")) {
        logger_1.logger.info(`⏳ Unzipping ${rootPath}...`);
        const parsedPath = path.parse(rootPath);
        let extractDirName = parsedPath.name;
        if (!extractDirName || extractDirName === ".") {
            extractDirName = "studio-export";
        }
        const extractPath = path.join(parsedPath.dir, extractDirName);
        await (0, unzip_1.unzip)(rootPath, extractPath);
        const extractedItems = fs.readdirSync(extractPath);
        if (extractedItems.length === 1 &&
            fs.statSync(path.join(extractPath, extractedItems[0])).isDirectory()) {
            rootPath = path.join(extractPath, extractedItems[0]);
        }
        else {
            rootPath = extractPath;
        }
    }
    logger_1.logger.info(`⏳ Exporting Studio app from ${rootPath} to Antigravity...`);
    await (0, migrate_1.migrate)(rootPath, options);
});
