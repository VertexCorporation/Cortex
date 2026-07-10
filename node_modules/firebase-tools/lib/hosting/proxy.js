"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.proxyRequestHandler = proxyRequestHandler;
exports.errorRequestHandler = errorRequestHandler;
const lodash_1 = require("lodash");
const node_fetch_1 = require("node-fetch");
const stream_1 = require("stream");
const url_1 = require("url");
const apiv2_1 = require("../apiv2");
const error_1 = require("../error");
const logger_1 = require("../logger");
const REQUIRED_VARY_VALUES = ["Accept-Encoding", "Authorization", "Cookie"];
function makeVary(vary = "") {
    if (!vary) {
        return "Accept-Encoding, Authorization, Cookie";
    }
    const varies = vary.split(/, ?/).map((v) => {
        return v
            .split("-")
            .map((part) => (0, lodash_1.capitalize)(part))
            .join("-");
    });
    REQUIRED_VARY_VALUES.forEach((requiredVary) => {
        if (!(0, lodash_1.includes)(varies, requiredVary)) {
            varies.push(requiredVary);
        }
    });
    return varies.join(", ");
}
function proxyRequestHandler(url, rewriteIdentifier, options = {}) {
    return async (req, res, next) => {
        logger_1.logger.info(`[hosting] Rewriting ${req.url} to ${url} for ${rewriteIdentifier}`);
        const cookie = req.headers.cookie || "";
        const sessionCookie = cookie.split(/; ?/).find((c) => {
            return c.trim().startsWith("__session=");
        });
        const u = new url_1.URL(url + req.url);
        const c = new apiv2_1.Client({ urlPrefix: u.origin, auth: false });
        let passThrough;
        if (req.method && !["GET", "HEAD"].includes(req.method)) {
            passThrough = new stream_1.PassThrough();
            req.pipe(passThrough);
        }
        const headers = new node_fetch_1.Headers({
            "X-Forwarded-Host": req.headers.host || "",
            "X-Original-Url": req.url || "",
            Pragma: "no-cache",
            "Cache-Control": "no-cache, no-store",
            Cookie: sessionCookie || "",
        });
        const headersToSkip = new Set(["host"]);
        for (const key of Object.keys(req.headers)) {
            if (headersToSkip.has(key)) {
                continue;
            }
            const value = req.headers[key];
            if (value === undefined) {
                headers.delete(key);
            }
            else if (Array.isArray(value)) {
                headers.delete(key);
                for (const v of value) {
                    headers.append(key, v);
                }
            }
            else {
                headers.set(key, value);
            }
        }
        let proxyRes;
        try {
            proxyRes = await c.request({
                method: (req.method || "GET"),
                path: u.pathname,
                queryParams: u.searchParams,
                headers,
                resolveOnHTTPError: true,
                responseType: "stream",
                redirect: "manual",
                body: passThrough,
                timeout: 60000,
                compress: false,
            });
        }
        catch (err) {
            const isAbortError = err instanceof error_1.FirebaseError && err.original?.name.includes("AbortError");
            const isTimeoutError = err instanceof error_1.FirebaseError &&
                err.original instanceof node_fetch_1.FetchError &&
                err.original.code === "ETIMEDOUT";
            const isSocketTimeoutError = err instanceof error_1.FirebaseError &&
                err.original instanceof node_fetch_1.FetchError &&
                err.original.code === "ESOCKETTIMEDOUT";
            if (isAbortError || isTimeoutError || isSocketTimeoutError) {
                res.statusCode = 504;
                return res.end("Timed out waiting for function to respond.\n");
            }
            res.statusCode = 500;
            return res.end(`An internal error occurred while proxying for ${rewriteIdentifier}\n`);
        }
        if (proxyRes.status === 404) {
            const cascade = proxyRes.response.headers.get("x-cascade");
            if (options.forceCascade || (cascade && cascade.toUpperCase() === "PASS")) {
                return next();
            }
        }
        if (!proxyRes.response.headers.get("cache-control")) {
            proxyRes.response.headers.set("cache-control", "private");
        }
        const cc = proxyRes.response.headers.get("cache-control");
        if (cc && !cc.includes("private")) {
            proxyRes.response.headers.delete("set-cookie");
        }
        proxyRes.response.headers.set("vary", makeVary(proxyRes.response.headers.get("vary")));
        const location = proxyRes.response.headers.get("location");
        if (location) {
            try {
                const locationURL = new url_1.URL(location);
                if (locationURL.origin === u.origin) {
                    const unborkedLocation = location.replace(locationURL.origin, "");
                    proxyRes.response.headers.set("location", unborkedLocation);
                }
            }
            catch (e) {
                logger_1.logger.debug(`[hosting] had trouble parsing location header, but this may be okay: "${location}"`);
            }
        }
        for (const [key, value] of Object.entries(proxyRes.response.headers.raw())) {
            res.setHeader(key, value);
        }
        res.statusCode = proxyRes.status;
        proxyRes.response.body.pipe(res);
    };
}
function errorRequestHandler(error) {
    return (req, res) => {
        res.statusCode = 500;
        const out = `A problem occurred while trying to handle a proxied rewrite: ${error}`;
        logger_1.logger.error(out);
        res.end(out);
    };
}
