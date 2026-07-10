"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RTDBRemoveRemote = void 0;
const apiv2_1 = require("../apiv2");
const url_1 = require("url");
const logger_1 = require("../logger");
const utils = require("../utils");
class RTDBRemoveRemote {
    constructor(instance, host, disableTriggers) {
        this.instance = instance;
        this.host = host;
        this.disableTriggers = disableTriggers;
        const url = new url_1.URL(utils.getDatabaseUrl(this.host, this.instance, "/"));
        this.apiClient = new apiv2_1.Client({ urlPrefix: url.origin, auth: true });
    }
    deletePath(path) {
        return this.patch(path, null, "all data");
    }
    deleteSubPath(path, subPaths) {
        const body = {};
        for (const c of subPaths) {
            body[c] = null;
        }
        return this.patch(path, body, `${subPaths.length} subpaths`);
    }
    async patch(path, body, note) {
        const t0 = Date.now();
        const url = new url_1.URL(utils.getDatabaseUrl(this.host, this.instance, path + ".json"));
        const queryParams = {
            print: "silent",
            writeSizeLimit: "tiny",
            disableTriggers: this.disableTriggers.toString(),
        };
        const res = await this.apiClient.request({
            method: "PATCH",
            path: url.pathname,
            body,
            queryParams,
            responseType: "stream",
            resolveOnHTTPError: true,
        });
        const dt = Date.now() - t0;
        if (res.status >= 400) {
            logger_1.logger.debug(`[database] Failed to remove ${note} at ${path} time: ${dt}ms, will try recursively chunked deletes.`);
            return false;
        }
        logger_1.logger.debug(`[database] Sucessfully removed ${note} at ${path} time: ${dt}ms`);
        return true;
    }
}
exports.RTDBRemoveRemote = RTDBRemoveRemote;
