import { IndentStyle } from '../FormatOptions.js';
import { TokenType } from '../lexer/token.js';
/**
 * When tabular style enabled,
 * produces a 10-char wide version of token text.
 */
export default function toTabularFormat(tokenText: string, indentStyle: IndentStyle): string;
/**
 * True when the token can be formatted in tabular style
 */
export declare function isTabularToken(type: TokenType): boolean;
