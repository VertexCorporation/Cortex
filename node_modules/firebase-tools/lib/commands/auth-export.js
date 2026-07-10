"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const fs = require("fs");
const os = require("os");
const command_1 = require("../command");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const requirePermissions_1 = require("../requirePermissions");
const accountExporter_1 = require("../accountExporter");
const MAX_BATCH_SIZE = 1000;
exports.command = new command_1.Command("auth:export [dataFile]")
    .description("export accounts from your Firebase project into a data file")
    .option("--format <format>", "Format of exported data (csv, json). Ignored if <dataFile> has format extension.")
    .before(requirePermissions_1.requirePermissions, ["firebaseauth.users.get"])
    .action((dataFile, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const checkRes = (0, accountExporter_1.validateOptions)(options, dataFile);
    if (!checkRes.format) {
        return checkRes;
    }
    const writeStream = fs.createWriteStream(dataFile);
    if (checkRes.format === "json") {
        writeStream.write('{"users": [' + os.EOL);
    }
    const exportOptions = {
        format: checkRes.format,
        writeStream,
        batchSize: MAX_BATCH_SIZE,
    };
    logger_1.logger.info("Exporting accounts to " + clc.bold(dataFile));
    return (0, accountExporter_1.serialExportUsers)(projectId, exportOptions).then(() => {
        if (exportOptions.format === "json") {
            writeStream.write("]}");
        }
        writeStream.end();
        return new Promise((resolve, reject) => {
            writeStream.on("finish", resolve);
            writeStream.on("close", resolve);
            writeStream.on("error", reject);
        });
    });
});
