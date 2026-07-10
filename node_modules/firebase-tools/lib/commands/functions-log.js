"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const opn = require("open");
const qs = require("querystring");
const command_1 = require("../command");
const error_1 = require("../error");
const cloudlogging = require("../gcp/cloudlogging");
const functionsLog = require("../functions/functionslog");
const projectUtils_1 = require("../projectUtils");
const requirePermissions_1 = require("../requirePermissions");
exports.command = new command_1.Command("functions:log")
    .description("read logs from deployed functions")
    .option("--only <function_names>", 'only show logs of specified, comma-seperated functions (e.g. "funcA,funcB")')
    .option("-n, --lines <num_lines>", "specify number of log lines to fetch")
    .option("--open", "open logs page in web browser")
    .before(requirePermissions_1.requirePermissions, ["logging.logEntries.list", "logging.logs.list"])
    .action(async (options) => {
    try {
        const projectId = (0, projectUtils_1.needProjectId)(options);
        const apiFilter = functionsLog.getApiFilter(options.only);
        if (options.open) {
            const url = `https://console.developers.google.com/logs/viewer?advancedFilter=${qs.escape(apiFilter)}&project=${projectId}`;
            opn(url);
            return;
        }
        const { entries } = await cloudlogging.listEntries(projectId, apiFilter, options.lines || 35, "desc");
        functionsLog.logEntries(entries);
        return entries;
    }
    catch (err) {
        throw new error_1.FirebaseError(`Failed to list log entries ${err.message}`, { exit: 1 });
    }
});
