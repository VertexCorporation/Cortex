"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.resource = resource;
exports.resourceTemplate = resourceTemplate;
function resource(options, fnOrText) {
    const fn = typeof fnOrText === "string"
        ? async (uri) => ({ contents: [{ uri, text: fnOrText }] })
        : fnOrText;
    return { mcp: options, fn };
}
function resourceTemplate(options, fnOrText) {
    let matchFn;
    const { match, ...mcp } = options;
    if (match instanceof RegExp) {
        matchFn = (uri) => match.test(uri);
    }
    else if (typeof match === "string") {
        matchFn = (uri) => uri.startsWith(match);
    }
    else {
        matchFn = match;
    }
    const fn = typeof fnOrText === "string"
        ? async (uri) => ({ contents: [{ uri, text: fnOrText }] })
        : fnOrText;
    return { mcp, match: matchFn, fn };
}
