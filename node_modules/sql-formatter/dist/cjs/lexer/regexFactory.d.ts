import { IdentChars, QuoteType, VariableType } from './TokenizerOptions.js';
/**
 * Builds a RegExp for valid line comments in a SQL dialect
 * @param {string[]} lineCommentTypes - list of character strings that denote line comments
 */
export declare const lineComment: (lineCommentTypes: string[]) => RegExp;
/**
 * Builds a RegExp for matching either open- or close-parenthesis patterns
 */
export declare const parenthesis: (kind: 'open' | 'close', extraParens?: ('[]' | '{}')[]) => RegExp;
/**
 * Builds a RegExp containing all operators for a SQL dialect
 */
export declare const operator: (operators: string[]) => RegExp;
/**
 * Builds a RegExp for all Reserved Keywords in a SQL dialect
 */
export declare const reservedWord: (reservedKeywords: string[], identChars?: IdentChars) => RegExp;
/**
 * Builds a RegExp for parameter placeholder patterns
 * @param {string[]} paramTypes - list of strings that denote placeholder types
 * @param {string} pattern - string that denotes placeholder pattern
 */
export declare const parameter: (paramTypes: string[], pattern: string) => RegExp | undefined;
export declare const quotePatterns: {
    '``': string;
    '[]': string;
    '""-qq': string;
    '""-bs': string;
    '""-qq-bs': string;
    '""-raw': string;
    "''-qq": string;
    "''-bs": string;
    "''-qq-bs": string;
    "''-raw": string;
    $$: string;
    "'''..'''": string;
    '""".."""': string;
    '{}': string;
    "q''": string;
};
/** Builds a RegExp for matching variables */
export declare const variable: (varTypes: VariableType[]) => RegExp;
/** Builds a quote-delimited pattern for matching all given quote types */
export declare const stringPattern: (quoteTypes: QuoteType[]) => string;
/** Builds a RegExp for matching quote-delimited patterns */
export declare const string: (quoteTypes: QuoteType[]) => RegExp;
/**
 * Builds a RegExp for valid identifiers in a SQL dialect
 */
export declare const identifier: (specialChars?: IdentChars) => RegExp;
/**
 * Builds a RegExp string for valid identifiers in a SQL dialect
 */
export declare const identifierPattern: ({ first, rest, dashes, allowFirstCharNumber, }?: IdentChars) => string;
