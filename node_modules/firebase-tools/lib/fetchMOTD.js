"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.fetchMOTD = fetchMOTD;
const clc = require("colorette");
const semver = require("semver");
const apiv2_1 = require("./apiv2");
const configstore_1 = require("./configstore");
const logger_1 = require("./logger");
const api_1 = require("./api");
const utils = require("./utils");
const pkg = require("../package.json");
const ONE_DAY_MS = 1000 * 60 * 60 * 24;
function fetchMOTD() {
    let motd = configstore_1.configstore.get("motd");
    const motdFetched = configstore_1.configstore.get("motd.fetched") || 0;
    if (motd && motdFetched > Date.now() - ONE_DAY_MS) {
        if (motd.minVersion && semver.gt(motd.minVersion, pkg.version)) {
            console.error(clc.red("Error:"), "CLI is out of date (on", clc.bold(pkg.version), ", need at least", clc.bold(motd.minVersion) + ")\n\nRun", clc.bold("npm install -g firebase-tools"), "to upgrade.");
            process.exit(1);
        }
        if (motd.message && process.stdout.isTTY) {
            const lastMessage = configstore_1.configstore.get("motd.lastMessage");
            if (lastMessage !== motd.message) {
                console.log();
                console.log(motd.message);
                console.log();
                configstore_1.configstore.set("motd.lastMessage", motd.message);
            }
        }
    }
    else {
        const origin = utils.addSubdomain((0, api_1.realtimeOrigin)(), "firebase-public");
        const c = new apiv2_1.Client({ urlPrefix: origin, auth: false });
        c.get("/cli.json")
            .then((res) => {
            motd = Object.assign({}, res.body);
            configstore_1.configstore.set("motd", motd);
            configstore_1.configstore.set("motd.fetched", Date.now());
        })
            .catch((err) => {
            utils.logWarning("Unable to fetch the CLI MOTD and remote config. This is not a fatal error, but may indicate an issue with your network connection.");
            logger_1.logger.debug(`Failed to fetch MOTD ${err}`);
        });
    }
}
