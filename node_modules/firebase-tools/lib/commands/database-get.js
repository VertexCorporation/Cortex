"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const fs = require("fs");
const url = require("url");
const apiv2_1 = require("../apiv2");
const command_1 = require("../command");
const types_1 = require("../emulator/types");
const error_1 = require("../error");
const database_1 = require("../management/database");
const commandUtils_1 = require("../emulator/commandUtils");
const api_1 = require("../database/api");
const requirePermissions_1 = require("../requirePermissions");
const logger_1 = require("../logger");
const requireDatabaseInstance_1 = require("../requireDatabaseInstance");
const responseToError_1 = require("../responseToError");
const utils = require("../utils");
function applyStringOpts(dest, src, keys, jsonKeys) {
    for (const key of keys) {
        if (src[key]) {
            dest[key] = src[key];
        }
    }
    for (const key of jsonKeys) {
        let jsonVal;
        try {
            jsonVal = JSON.parse(src[key]);
        }
        catch (_) {
            jsonVal = src[key];
        }
        if (src[key]) {
            dest[key] = JSON.stringify(jsonVal);
        }
    }
}
exports.command = new command_1.Command("database:get <path>")
    .description("fetch and print JSON data at the specified path")
    .option("-o, --output <filename>", "save output to the specified file")
    .option("--pretty", "pretty print response")
    .option("--shallow", "return shallow response")
    .option("--export", "include priorities in the output response")
    .option("--order-by <key>", "select a child key by which to order results")
    .option("--order-by-key", "order by key name")
    .option("--order-by-value", "order by primitive value")
    .option("--limit-to-first <num>", "limit to the first <num> results")
    .option("--limit-to-last <num>", "limit to the last <num> results")
    .option("--start-at <val>", "start results at <val> (based on specified ordering)")
    .option("--end-at <val>", "end results at <val> (based on specified ordering)")
    .option("--equal-to <val>", "restrict results to <val> (based on specified ordering)")
    .option("--instance <instance>", "use the database <instance>.firebaseio.com (if omitted, use default database instance)")
    .before(requirePermissions_1.requirePermissions, ["firebasedatabase.instances.get"])
    .before(requireDatabaseInstance_1.requireDatabaseInstance)
    .before(database_1.populateInstanceDetails)
    .before(commandUtils_1.printNoticeIfEmulated, types_1.Emulators.DATABASE)
    .action(async (path, options) => {
    if (!path.startsWith("/")) {
        return utils.reject("Path must begin with /", { exit: 1 });
    }
    const dbHost = (0, api_1.realtimeOriginOrEmulatorOrCustomUrl)(options.instanceDetails.databaseUrl);
    const dbUrl = utils.getDatabaseUrl(dbHost, options.instance, path + ".json");
    const query = {};
    if (options.shallow) {
        query.shallow = "true";
    }
    if (options.pretty) {
        query.print = "pretty";
    }
    if (options.export) {
        query.format = "export";
    }
    if (options.orderByKey) {
        options.orderBy = "$key";
    }
    if (options.orderByValue) {
        options.orderBy = "$value";
    }
    applyStringOpts(query, options, ["limitToFirst", "limitToLast"], ["orderBy", "startAt", "endAt", "equalTo"]);
    const urlObj = new url.URL(dbUrl);
    const client = new apiv2_1.Client({
        urlPrefix: urlObj.origin,
        auth: true,
    });
    const res = await client.request({
        method: "GET",
        path: urlObj.pathname,
        queryParams: query,
        responseType: "stream",
        resolveOnHTTPError: true,
    });
    const fileOut = !!options.output;
    const outStream = fileOut ? fs.createWriteStream(options.output) : process.stdout;
    if (res.status >= 400) {
        const r = await res.response.text();
        let d;
        try {
            d = JSON.parse(r);
        }
        catch (e) {
            throw new error_1.FirebaseError("Malformed JSON response", { original: e, exit: 2 });
        }
        throw (0, responseToError_1.responseToError)({ statusCode: res.status }, d);
    }
    res.body.pipe(outStream, { end: false });
    return new Promise((resolve) => {
        res.body.once("end", () => {
            if (outStream === process.stdout) {
                outStream.write("\n");
                resolve();
            }
            else if (outStream instanceof fs.WriteStream) {
                outStream.write("\n");
                outStream.on("close", () => resolve());
                outStream.close();
            }
            else {
                logger_1.logger.debug("[database:get] Could not write line break to outStream");
                resolve();
            }
        });
    });
});
