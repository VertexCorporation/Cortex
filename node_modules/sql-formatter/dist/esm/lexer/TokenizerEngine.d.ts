import { Token, TokenType } from './token.js';
export interface RegExpLike {
    lastIndex: number;
    exec(input: string): string[] | null;
}
export interface TokenRule {
    type: TokenType;
    regex: RegExpLike;
    text?: (rawText: string) => string;
    key?: (rawText: string) => string;
}
export default class TokenizerEngine {
    private rules;
    private dialectName;
    private input;
    private index;
    constructor(rules: TokenRule[], dialectName: string);
    /**
     * Takes a SQL string and breaks it into tokens.
     * Each token is an object with type and value.
     *
     * @param {string} input - The SQL string
     * @returns {Token[]} output token stream
     */
    tokenize(input: string): Token[];
    private createParseError;
    private dialectInfo;
    private getWhitespace;
    private getNextToken;
    private match;
}
