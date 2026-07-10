"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.profiler = profiler;
const fs = require("fs");
const ora = require("ora");
const readline = require("readline");
const tmp = require("tmp");
const abort_controller_1 = require("abort-controller");
const apiv2_1 = require("./apiv2");
const api_1 = require("./database/api");
const logger_1 = require("./logger");
const profileReport_1 = require("./profileReport");
const responseToError_1 = require("./responseToError");
const utils = require("./utils");
tmp.setGracefulCleanup();
async function profiler(options) {
    const origin = (0, api_1.realtimeOriginOrEmulatorOrCustomUrl)(options.instanceDetails.databaseUrl);
    const url = new URL(utils.getDatabaseUrl(origin, options.instance, "/.settings/profile.json?"));
    const rl = readline.createInterface({ input: process.stdin });
    const fileOut = !!options.output;
    const tmpFile = tmp.tmpNameSync();
    const tmpStream = fs.createWriteStream(tmpFile);
    const outStream = fileOut ? fs.createWriteStream(options.output) : process.stdout;
    const spinner = ora({
        text: "0 operations recorded. Press [enter] to stop",
        color: "yellow",
    });
    const outputFormat = options.raw ? "RAW" : options.parent.json ? "JSON" : "TXT";
    const controller = new abort_controller_1.default();
    const generateReport = () => {
        rl.close();
        spinner.stop();
        controller.abort();
        const dataFile = options.input || tmpFile;
        const reportOptions = {
            format: outputFormat,
            isFile: fileOut,
            isInput: !!options.input,
            collapse: options.collapse,
        };
        const report = new profileReport_1.ProfileReport(dataFile, outStream, reportOptions);
        return report.generate();
    };
    if (options.input) {
        return generateReport();
    }
    const c = new apiv2_1.Client({ urlPrefix: url.origin, auth: true });
    const res = await c.request({
        method: "GET",
        path: url.pathname,
        responseType: "stream",
        resolveOnHTTPError: true,
        headers: {
            Accept: "text/event-stream",
        },
        signal: controller.signal,
    });
    if (res.response.status >= 400) {
        throw (0, responseToError_1.responseToError)(res.response, await res.response.text());
    }
    if (!options.duration) {
        spinner.start();
    }
    let counter = 0;
    res.body.on("data", (chunk) => {
        if (chunk.toString().includes("event: log")) {
            counter++;
            spinner.text = `${counter} operations recorded. Press [enter] to stop`;
        }
    });
    res.body.on("end", () => {
        spinner.text = counter + " operations recorded.\n";
    });
    let resError;
    res.body.on("error", (e) => {
        if (e.type !== "aborted") {
            resError = e;
            logger_1.logger.error("Unexpected error from response stream:", e);
        }
    });
    const p = new Promise((resolve, reject) => {
        const fn = () => {
            controller.abort();
            if (resError) {
                return reject(resError);
            }
            resolve(generateReport());
        };
        if (options.duration) {
            setTimeout(fn, options.duration * 1000);
        }
        else {
            rl.question("", fn);
        }
    });
    res.body.pipe(tmpStream);
    return p;
}
