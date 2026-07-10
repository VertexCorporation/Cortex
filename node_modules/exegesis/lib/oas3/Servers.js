"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const PathResolver_1 = require("./Paths/PathResolver");
const FULL_URL_RE = /^(.*?):\/\/([^/]*?)(?:\/(.*))?$/; // e.g. https://foo.bar/v1
const ABSOLUTE_URL_RE = /^(\/.*)$/; // e.g. /v1
function generateServerParser(oaServer) {
    // Strip trailing '/'.
    const serverUrl = oaServer.url.endsWith('/')
        ? oaServer.url.slice(0, oaServer.url.length - 1)
        : oaServer.url;
    let result;
    let match;
    if (serverUrl === '') {
        result = (_host, pathname) => ({
            oaServer,
            pathnameRest: pathname,
            serverParams: Object.create(null),
            baseUrl: '',
        });
    }
    else if ((match = FULL_URL_RE.exec(serverUrl))) {
        const hostname = match[2];
        const basepath = match[3] || '';
        const { parser: hostnameAcceptFunction } = (0, PathResolver_1.compileTemplatePath)(hostname);
        let basepathAcceptFunction;
        if (basepath) {
            basepathAcceptFunction = (0, PathResolver_1.compileTemplatePath)('/' + basepath, { openEnded: true })
                .parser;
        }
        else {
            basepathAcceptFunction = () => ({
                matched: '',
                rawPathParams: Object.create(null),
            });
        }
        result = (host, pathname) => {
            const hostMatch = hostnameAcceptFunction(host);
            const pathMatch = basepathAcceptFunction(pathname);
            if (hostMatch && pathMatch) {
                return {
                    oaServer,
                    pathnameRest: pathname.slice(pathMatch.matched.length),
                    serverParams: Object.assign({}, hostMatch.rawPathParams, pathMatch.rawPathParams),
                    baseUrl: pathMatch.matched,
                };
            }
            else {
                return null;
            }
        };
    }
    else if ((match = ABSOLUTE_URL_RE.exec(serverUrl))) {
        const basepath = match[1];
        const { parser: basepathParser } = (0, PathResolver_1.compileTemplatePath)(basepath, { openEnded: true });
        result = (_host, pathname) => {
            const pathMatch = basepathParser(pathname);
            if (pathMatch) {
                return {
                    oaServer,
                    serverParams: pathMatch.rawPathParams,
                    pathnameRest: pathname.slice(pathMatch.matched.length),
                    baseUrl: pathMatch.matched,
                };
            }
            else {
                return null;
            }
        };
    }
    else {
        // TODO: deal with relative URLs.
        throw new Error(`Don't know how to deal with server URL ${oaServer.url}`);
    }
    return result;
}
class Servers {
    constructor(servers) {
        servers = servers || [{ url: '/' }];
        this._servers = servers.map((server) => generateServerParser(server));
    }
    /**
     * Resolve the `server` that's being accessed.
     *
     * @param host - The hostname to match.
     * @param pathname - The URL pathname to match.
     * @returns If a matching `server` is found, returns a
     * `ResolvedServer` object.  Returns `null` if no match was found.
     */
    resolveServer(host, pathname) {
        for (const server of this._servers) {
            const result = server(host, pathname);
            if (result) {
                return result;
            }
        }
        return null;
    }
}
exports.default = Servers;
//# sourceMappingURL=Servers.js.map