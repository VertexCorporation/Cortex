export const dedupe = (arr) => [...new Set(arr)];
// Last element from array
export const last = (arr) => arr[arr.length - 1];
// Sorts strings by length, so that longer ones are first
// Also sorts alphabetically after sorting by length.
export const sortByLengthDesc = (strings) => strings.sort((a, b) => b.length - a.length || a.localeCompare(b));
/** Get length of longest string in list of strings */
export const maxLength = (strings) => strings.reduce((max, cur) => Math.max(max, cur.length), 0);
// replaces long whitespace sequences with just one space
export const equalizeWhitespace = (s) => s.replace(/\s+/gu, ' ');
// True when string contains multiple lines
export const isMultiline = (text) => /\n/.test(text);
//# sourceMappingURL=utils.js.map