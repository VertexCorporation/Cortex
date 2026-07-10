import { Token } from '../lexer/token.js';
type NearleyToken = Token & {
    value: string;
};
export default class LexerAdapter {
    private tokenize;
    private index;
    private tokens;
    private input;
    constructor(tokenize: (chunk: string) => Token[]);
    reset(chunk: string, _info: any): void;
    next(): NearleyToken | undefined;
    save(): any;
    formatError(token: NearleyToken): string;
    has(name: string): boolean;
}
export {};
