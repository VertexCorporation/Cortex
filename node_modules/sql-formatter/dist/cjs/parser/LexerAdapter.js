"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const lineColFromIndex_js_1 = require("../lexer/lineColFromIndex.js");
const token_js_1 = require("../lexer/token.js");
class LexerAdapter {
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
        const { line, col } = (0, lineColFromIndex_js_1.lineColFromIndex)(this.input, token.start);
        return `Parse error at token: ${token.text} at line ${line} column ${col}`;
    }
    has(name) {
        return name in token_js_1.TokenType;
    }
}
exports.default = LexerAdapter;
//# sourceMappingURL=LexerAdapter.js.map