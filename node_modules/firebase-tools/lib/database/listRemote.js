"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RTDBListRemote = void 0;
const apiv2_1 = require("../apiv2");
const url_1 = require("url");
const logger_1 = require("../logger");
const utils = require("../utils");
class RTDBListRemote {
    constructor(instance, host) {
        this.instance = instance;
        this.host = host;
        const url = new url_1.URL(utils.getDatabaseUrl(this.host, this.instance, "/"));
        this.apiClient = new apiv2_1.Client({ urlPrefix: url.origin, auth: true });
    }
    async listPath(path, numSubPath, startAfter, timeout) {
        const url = new url_1.URL(utils.getDatabaseUrl(this.host, this.instance, path + ".json"));
        const params = {
            shallow: true,
            limitToFirst: numSubPath,
        };
        if (startAfter) {
            params.startAfter = startAfter;
        }
        if (timeout) {
            params.timeout = `${timeout}ms`;
        }
        const t0 = Date.now();
        const res = await this.apiClient.get(url.pathname, {
            queryParams: params,
        });
        const paths = res.body ? Object.keys(res.body) : [];
        const dt = Date.now() - t0;
        logger_1.logger.debug(`[database] sucessfully fetched ${paths.length} path at ${path} ${dt}`);
        return paths;
    }
}
exports.RTDBListRemote = RTDBListRemote;
