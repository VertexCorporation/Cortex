"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.prefixesPattern = exports.withDashes = exports.toCaseInsensitivePattern = exports.patternToRegex = exports.WHITESPACE_REGEX = exports.escapeRegExp = void 0;
// Escapes regex special chars
const escapeRegExp = (string) => string.replace(/[.*+?^${}()|[\]\\]/gu, '\\$&');
exports.escapeRegExp = escapeRegExp;
exports.WHITESPACE_REGEX = /\s+/uy;
const patternToRegex = (pattern) => new RegExp(`(?:${pattern})`, 'uy');
exports.patternToRegex = patternToRegex;
// Converts "ab" to "[Aa][Bb]"
const toCaseInsensitivePattern = (prefix) => prefix
    .split('')
    .map(char => (/ /gu.test(char) ? '\\s+' : `[${char.toUpperCase()}${char.toLowerCase()}]`))
    .join('');
exports.toCaseInsensitivePattern = toCaseInsensitivePattern;
const withDashes = (pattern) => pattern + '(?:-' + pattern + ')*';
exports.withDashes = withDashes;
// Converts ["a", "b"] to "(?:[Aa]|[Bb]|)" or "(?:[Aa]|[Bb])" when required = true
const prefixesPattern = ({ prefixes, requirePrefix }) => `(?:${prefixes.map(exports.toCaseInsensitivePattern).join('|')}${requirePrefix ? '' : '|'})`;
exports.prefixesPattern = prefixesPattern;
//# sourceMappingURL=regexUtil.js.map