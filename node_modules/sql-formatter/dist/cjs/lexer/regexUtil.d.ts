import { PrefixedQuoteType } from './TokenizerOptions.js';
export declare const escapeRegExp: (string: string) => string;
export declare const WHITESPACE_REGEX: RegExp;
export declare const patternToRegex: (pattern: string) => RegExp;
export declare const toCaseInsensitivePattern: (prefix: string) => string;
export declare const withDashes: (pattern: string) => string;
export declare const prefixesPattern: ({ prefixes, requirePrefix }: PrefixedQuoteType) => string;
