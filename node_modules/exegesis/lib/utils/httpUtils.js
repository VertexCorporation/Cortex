"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.httpHasBody = httpHasBody;
exports.requestMayHaveBody = requestMayHaveBody;
function httpHasBody(headers) {
    const contentLength = headers['content-length'];
    return (!!headers['transfer-encoding'] ||
        (contentLength && contentLength !== '0' && contentLength !== 0));
}
// `delete` might have a body. See: https://developer.mozilla.org/en-US/docs/Web/HTTP/Methods/DELETE
const HTTP_METHODS_WITHOUT_BODY = ['get', 'head', 'trace', 'options'];
function requestMayHaveBody(method) {
    return HTTP_METHODS_WITHOUT_BODY.indexOf(method.toLowerCase()) === -1;
}
//# sourceMappingURL=httpUtils.js.map