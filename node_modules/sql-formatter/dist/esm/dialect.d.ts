import { DialectFormatOptions, ProcessedDialectFormatOptions } from './formatter/ExpressionFormatter.js';
import Tokenizer from './lexer/Tokenizer.js';
import { TokenizerOptions } from './lexer/TokenizerOptions.js';
export interface DialectOptions {
    name: string;
    tokenizerOptions: TokenizerOptions;
    formatOptions: DialectFormatOptions;
}
export interface Dialect {
    tokenizer: Tokenizer;
    formatOptions: ProcessedDialectFormatOptions;
}
/**
 * Factory function for building Dialect objects.
 * When called repeatedly with same options object returns the cached Dialect,
 * to avoid the cost of creating it again.
 */
export declare const createDialect: (options: DialectOptions) => Dialect;
