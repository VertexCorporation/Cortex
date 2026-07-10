"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExpressBasedEmulator = void 0;
const cors = require("cors");
const express = require("express");
const bodyParser = require("body-parser");
const utils = require("../utils");
const node_http_1 = require("node:http");
const dns_1 = require("./dns");
class ExpressBasedEmulator {
    constructor(options) {
        this.options = options;
        this.destroyers = new Set();
    }
    createExpressApp() {
        const app = express();
        if (!this.options.noCors) {
            app.use(cors({ origin: true }));
            app.use((req, res, next) => {
                if (req.headers["access-control-request-private-network"]) {
                    res.setHeader("access-control-allow-private-network", "true");
                }
                next();
            });
        }
        if (!this.options.noBodyParser) {
            app.use(bodyParser.json({ limit: "130mb" }));
        }
        app.set("json spaces", 2);
        return Promise.resolve(app);
    }
    async start() {
        const app = await this.createExpressApp();
        const promises = [];
        const specs = this.options.listen;
        for (const opt of ExpressBasedEmulator.listenOptionsFromSpecs(specs)) {
            promises.push(new Promise((resolve, reject) => {
                const server = (0, node_http_1.createServer)(app).listen(opt);
                server.once("listening", resolve);
                server.once("error", reject);
                this.destroyers.add(utils.createDestroyer(server));
            }));
        }
    }
    static listenOptionsFromSpecs(specs) {
        const listenOptions = [];
        const dualStackPorts = new Set();
        for (const spec of specs) {
            if (spec.address === dns_1.IPV6_UNSPECIFIED.address) {
                if (specs.some((s) => s.port === spec.port && s.address === dns_1.IPV4_UNSPECIFIED.address)) {
                    listenOptions.push({
                        port: spec.port,
                        ipv6Only: false,
                    });
                    dualStackPorts.add(spec.port);
                }
            }
        }
        for (const spec of specs) {
            if (!dualStackPorts.has(spec.port)) {
                listenOptions.push({
                    host: spec.address,
                    port: spec.port,
                    ipv6Only: spec.family === "IPv6",
                });
            }
        }
        return listenOptions;
    }
    async connect() {
    }
    async stop() {
        const promises = [];
        for (const destroyer of this.destroyers) {
            promises.push(destroyer().then(() => this.destroyers.delete(destroyer)));
        }
        await Promise.all(promises);
    }
    getInfo() {
        return {
            name: this.getName(),
            listen: this.options.listen,
            host: this.options.listen[0].address,
            port: this.options.listen[0].port,
        };
    }
}
exports.ExpressBasedEmulator = ExpressBasedEmulator;
ExpressBasedEmulator.PATH_EXPORT = "/_admin/export";
ExpressBasedEmulator.PATH_DISABLE_FUNCTIONS = "/functions/disableBackgroundTriggers";
ExpressBasedEmulator.PATH_ENABLE_FUNCTIONS = "/functions/enableBackgroundTriggers";
ExpressBasedEmulator.PATH_EMULATORS = "/emulators";
