import * as allDialects from './allDialects.js';
import { FormatOptions } from './FormatOptions.js';
import { DialectOptions } from './dialect.js';
declare const dialectNameMap: Record<keyof typeof allDialects | 'tsql', keyof typeof allDialects>;
export declare const supportedDialects: string[];
export type SqlLanguage = keyof typeof dialectNameMap;
export type FormatOptionsWithLanguage = Partial<FormatOptions> & {
    language?: SqlLanguage;
};
export type FormatOptionsWithDialect = Partial<FormatOptions> & {
    dialect: DialectOptions;
};
/**
 * Format whitespace in a query to make it easier to read.
 *
 * @param {string} query - input SQL query string
 * @param {FormatOptionsWithLanguage} cfg Configuration options (see docs in README)
 * @return {string} formatted query
 */
export declare const format: (query: string, cfg?: FormatOptionsWithLanguage) => string;
/**
 * Like the above format(), but language parameter is mandatory
 * and must be a Dialect object instead of a string.
 *
 * @param {string} query - input SQL query string
 * @param {FormatOptionsWithDialect} cfg Configuration options (see docs in README)
 * @return {string} formatted query
 */
export declare const formatDialect: (query: string, { dialect, ...cfg }: FormatOptionsWithDialect) => string;
export type FormatFn = typeof format;
export {};
