// Escapes regex special chars
export const escapeRegExp = (string) => string.replace(/[.*+?^${}()|[\]\\]/gu, '\\$&');
export const WHITESPACE_REGEX = /\s+/uy;
export const patternToRegex = (pattern) => new RegExp(`(?:${pattern})`, 'uy');
// Converts "ab" to "[Aa][Bb]"
export const toCaseInsensitivePattern = (prefix) => prefix
    .split('')
    .map(char => (/ /gu.test(char) ? '\\s+' : `[${char.toUpperCase()}${char.toLowerCase()}]`))
    .join('');
export const withDashes = (pattern) => pattern + '(?:-' + pattern + ')*';
// Converts ["a", "b"] to "(?:[Aa]|[Bb]|)" or "(?:[Aa]|[Bb])" when required = true
export const prefixesPattern = ({ prefixes, requirePrefix }) => `(?:${prefixes.map(toCaseInsensitivePattern).join('|')}${requirePrefix ? '' : '|'})`;
//# sourceMappingURL=regexUtil.js.map