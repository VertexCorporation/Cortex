"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const Table = require("cli-table3");
const command_1 = require("../command");
const projectUtils_1 = require("../projectUtils");
const apps_1 = require("../management/apps");
const requireAuth_1 = require("../requireAuth");
const logger_1 = require("../logger");
const utils_1 = require("../utils");
function logCertificatesList(certificates) {
    if (certificates.length === 0) {
        logger_1.logger.info("No SHA certificate hashes found.");
        return;
    }
    const tableHead = ["App Id", "SHA Id", "SHA Hash", "SHA Hash Type"];
    const table = new Table({ head: tableHead, style: { head: ["green"] } });
    certificates.forEach(({ name, shaHash, certType }) => {
        const splitted = name.split("/");
        const appId = splitted[3];
        const shaId = splitted[5];
        table.push([appId, shaId, shaHash, certType]);
    });
    logger_1.logger.info(table.toString());
}
function logCertificatesCount(count = 0) {
    if (count === 0) {
        return;
    }
    logger_1.logger.info("");
    logger_1.logger.info(`${count} SHA hash(es) total.`);
}
exports.command = new command_1.Command("apps:android:sha:list <appId>")
    .description("list the SHA certificate hashes for a given app id")
    .before(requireAuth_1.requireAuth)
    .action(async (appId = "", options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const shaCertificates = await (0, utils_1.promiseWithSpinner)(async () => await (0, apps_1.listAppAndroidSha)(projectId, appId), "Preparing the list of your Firebase Android app SHA certificate hashes");
    logCertificatesList(shaCertificates);
    logCertificatesCount(shaCertificates.length);
    return shaCertificates;
});
