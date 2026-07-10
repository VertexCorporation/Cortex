import { lineColFromIndex } from '../lexer/lineColFromIndex.js';
import { TokenType } from '../lexer/token.js';
export default class LexerAdapter {
    constructor(tokenize) {
        this.tokenize = tokenize;
        this.index = 0;
        this.tokens = [];
        this.input = '';
    }
    reset(chunk, _info) {
        this.input = chunk;
        this.index = 0;
        this.tokens = this.tokenize(chunk);
    }
    next() {
        return this.tokens[this.index++];
    }
    save() { }
    formatError(token) {
        const { line, col } = lineColFromIndex(this.input, token.start);
        return `Parse error at token: ${token.text} at line ${line} column ${col}`;
    }
    has(name) {
        return name in TokenType;
    }
}
//# sourceMappingURL=LexerAdapter.js.map