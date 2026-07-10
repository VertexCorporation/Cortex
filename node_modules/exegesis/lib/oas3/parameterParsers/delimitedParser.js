"use strict";
// Implements 'spaceDelimited' and 'pipeDelimited' from OAS 3.
Object.defineProperty(exports, "__esModule", { value: true });
exports.spaceDelimitedParser = exports.pipeDelimitedParser = void 0;
exports.generateDelimitedParser = generateDelimitedParser;
function generateDelimitedParser(delimiter) {
    return function delimitedParser(location, rawParamValues) {
        const value = rawParamValues[location.name];
        if (value === null || value === undefined) {
            return value;
        }
        else if (Array.isArray(value)) {
            // Client is supposed to send us a delimited string, but it looks
            // like they sent us multiple copies of the var instead.  Just
            // decode the array.
            return value.map(decodeURIComponent);
        }
        else {
            return decodeURIComponent(value).split(delimiter);
        }
    };
}
exports.pipeDelimitedParser = generateDelimitedParser('|');
exports.spaceDelimitedParser = generateDelimitedParser(' ');
//# sourceMappingURL=delimitedParser.js.map