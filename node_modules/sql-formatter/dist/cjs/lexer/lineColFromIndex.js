"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.lineColFromIndex = void 0;
/**
 * Determines line and column number of character index in source code.
 */
function lineColFromIndex(source, index) {
    const lines = source.slice(0, index).split(/\n/);
    return { line: lines.length, col: lines[lines.length - 1].length + 1 };
}
exports.lineColFromIndex = lineColFromIndex;
//# sourceMappingURL=lineColFromIndex.js.map