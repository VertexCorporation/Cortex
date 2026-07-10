"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isMultiline = exports.equalizeWhitespace = exports.maxLength = exports.sortByLengthDesc = exports.last = exports.dedupe = void 0;
const dedupe = (arr) => [...new Set(arr)];
exports.dedupe = dedupe;
// Last element from array
const last = (arr) => arr[arr.length - 1];
exports.last = last;
// Sorts strings by length, so that longer ones are first
// Also sorts alphabetically after sorting by length.
const sortByLengthDesc = (strings) => strings.sort((a, b) => b.length - a.length || a.localeCompare(b));
exports.sortByLengthDesc = sortByLengthDesc;
/** Get length of longest string in list of strings */
const maxLength = (strings) => strings.reduce((max, cur) => Math.max(max, cur.length), 0);
exports.maxLength = maxLength;
// replaces long whitespace sequences with just one space
const equalizeWhitespace = (s) => s.replace(/\s+/gu, ' ');
exports.equalizeWhitespace = equalizeWhitespace;
// True when string contains multiple lines
const isMultiline = (text) => /\n/.test(text);
exports.isMultiline = isMultiline;
//# sourceMappingURL=utils.js.map