"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
exports.printBackendsTable = printBackendsTable;
const command_1 = require("../command");
const utils_1 = require("../utils");
const error_1 = require("../error");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const requireAuth_1 = require("../requireAuth");
const apphosting = require("../gcp/apphosting");
const experiments_1 = require("../experiments");
const Table = require("cli-table3");
exports.command = new command_1.Command("apphosting:backends:list")
    .description("list Firebase App Hosting backends")
    .before(requireAuth_1.requireAuth)
    .before(apphosting.ensureApiEnabled)
    .action(async (options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    let backendRes;
    try {
        backendRes = await apphosting.listBackends(projectId, "-");
    }
    catch (err) {
        throw new error_1.FirebaseError(`Unable to list backends present for project: ${projectId}. Please check the parameters you have provided.`, { original: err });
    }
    const backends = backendRes.backends ?? [];
    printBackendsTable(backends);
    return backends;
});
function printBackendsTable(backends) {
    const abiuEnabled = (0, experiments_1.isEnabled)("abiu");
    const head = ["Backend", "Repository", "URL", "Primary Region"];
    if (abiuEnabled) {
        head.push("ABIU");
        head.push("Runtime");
    }
    head.push("Updated Date");
    const table = new Table({
        head: head,
        style: { head: ["green"] },
    });
    for (const backend of backends) {
        const { location, id } = apphosting.parseBackendName(backend.name);
        const row = [
            id,
            backend.codebase?.repository?.split("/").pop() ?? "",
            backend.uri.startsWith("https:") ? backend.uri : "https://" + backend.uri,
            location,
        ];
        if (abiuEnabled) {
            let abiuStatus = "N/A";
            const runtimeValue = backend.runtime?.value ?? "";
            if (runtimeValue === "" || runtimeValue === "nodejs") {
                abiuStatus = "Disabled";
            }
            else {
                abiuStatus = backend.automaticBaseImageUpdatesDisabled ? "Disabled" : "Enabled";
            }
            row.push(abiuStatus);
            row.push(backend.runtime?.value ?? "N/A");
        }
        row.push((0, utils_1.datetimeString)(new Date(backend.updateTime)));
        table.push(row);
    }
    logger_1.logger.info(table.toString());
}
