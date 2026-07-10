"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.hasTemplates = hasTemplates;
exports.compileTemplatePath = compileTemplatePath;
const lodash_1 = require("lodash");
const TEMPLATE_RE = /^(.*?){(.*?)}(.*)$/;
/**
 * @param path - The path to check.
 * @returns true if the specified path uses templating, false otherwise.
 */
function hasTemplates(path) {
    return !!TEMPLATE_RE.exec(path);
}
/**
 * Given a path containing template parts (e.g. "/foo/{bar}/baz"), returns
 * a regular expression that matches the path, and a list of parameters found.
 *
 * @param path - The path to convert.
 * @param options.openEnded - If true, then the returned `regex` will
 *   accept extra input at the end of the path.
 *
 * @returns A `{regex, params, parser}`, where:
 * - `params` is a list of parameters found in the path.
 * - `regex` is a regular expression that will match the path.  When calling
 *   `match = regex.exec(str)`, each parameter in `params[i]` will be present
 *   in `match[i+1]`.
 * - `parser` is a `fn(str)` that, given a path, will return null if
 *   the string does not match, and a `{matched, pathParams}` object if the
 *   path matches.  `pathParams` is an object where keys are parameter names
 *   and values are strings from the `path`.  `matched` is full string matched
 *   by the regex.
 */
function compileTemplatePath(path, options = {}) {
    const params = [];
    // Split up the path at each parameter.
    const regexParts = [];
    let remainingPath = path;
    let tempateMatch;
    do {
        tempateMatch = TEMPLATE_RE.exec(remainingPath);
        if (tempateMatch) {
            regexParts.push(tempateMatch[1]);
            params.push(tempateMatch[2]);
            remainingPath = tempateMatch[3];
        }
    } while (tempateMatch);
    regexParts.push(remainingPath);
    const regexStr = regexParts.map(lodash_1.escapeRegExp).join('([^/]*)');
    const regex = options.openEnded ? new RegExp(`^${regexStr}`) : new RegExp(`^${regexStr}$`);
    const parser = (urlPathname) => {
        const match = regex.exec(urlPathname);
        if (match) {
            return {
                matched: match[0],
                rawPathParams: params.reduce((result, paramName, index) => {
                    result[paramName] = match[index + 1];
                    return result;
                }, {}),
            };
        }
        else {
            return null;
        }
    };
    return { regex, params, parser };
}
class PathResolver {
    // TODO: Pass in variable styles.  Some variable styles start with a special
    // character, and we can check to see if the character is there or not.
    // (Or, replace this whole class with a uri-template engine.)
    constructor() {
        this._staticPaths = Object.create(null);
        this._dynamicPaths = [];
    }
    registerPath(path, value) {
        if (!path.startsWith('/')) {
            throw new Error(`Invalid path "${path}"`);
        }
        if (hasTemplates(path)) {
            const { parser } = compileTemplatePath(path);
            this._dynamicPaths.push({ value, parser, path });
        }
        else {
            this._staticPaths[path] = value;
        }
    }
    /**
     * Given a `pathname` from a URL (e.g. "/foo/bar") this will return the
     * a static path if one exists, otherwise a path with templates if one
     * exists.
     *
     * @param urlPathname - The pathname to search for.
     * @returns A `{value, rawPathParams} object if a path is matched, or
     *   undefined if there was no match.
     */
    resolvePath(urlPathname) {
        let value = this._staticPaths[urlPathname];
        let rawPathParams;
        let path = urlPathname;
        if (!value) {
            for (const dynamicPath of this._dynamicPaths) {
                const matched = dynamicPath.parser(urlPathname);
                if (matched) {
                    value = dynamicPath.value;
                    rawPathParams = matched.rawPathParams;
                    path = dynamicPath.path;
                }
            }
        }
        if (value) {
            return {
                value,
                rawPathParams,
                path,
            };
        }
        else {
            return undefined;
        }
    }
}
exports.default = PathResolver;
//# sourceMappingURL=PathResolver.js.map