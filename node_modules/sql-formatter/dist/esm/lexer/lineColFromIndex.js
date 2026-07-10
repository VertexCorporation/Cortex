/**
 * Determines line and column number of character index in source code.
 */
export function lineColFromIndex(source, index) {
    const lines = source.slice(0, index).split(/\n/);
    return { line: lines.length, col: lines[lines.length - 1].length + 1 };
}
//# sourceMappingURL=lineColFromIndex.js.map