"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isTabularToken = void 0;
const token_js_1 = require("../lexer/token.js");
/**
 * When tabular style enabled,
 * produces a 10-char wide version of token text.
 */
function toTabularFormat(tokenText, indentStyle) {
    if (indentStyle === 'standard') {
        return tokenText;
    }
    let tail = []; // rest of keyword
    if (tokenText.length >= 10 && tokenText.includes(' ')) {
        // split for long keywords like INNER JOIN or UNION DISTINCT
        [tokenText, ...tail] = tokenText.split(' ');
    }
    if (indentStyle === 'tabularLeft') {
        tokenText = tokenText.padEnd(9, ' ');
    }
    else {
        tokenText = tokenText.padStart(9, ' ');
    }
    return tokenText + ['', ...tail].join(' ');
}
exports.default = toTabularFormat;
/**
 * True when the token can be formatted in tabular style
 */
function isTabularToken(type) {
    return ((0, token_js_1.isLogicalOperator)(type) ||
        type === token_js_1.TokenType.RESERVED_CLAUSE ||
        type === token_js_1.TokenType.RESERVED_SELECT ||
        type === token_js_1.TokenType.RESERVED_SET_OPERATION ||
        type === token_js_1.TokenType.RESERVED_JOIN ||
        type === token_js_1.TokenType.LIMIT);
}
exports.isTabularToken = isTabularToken;
//# sourceMappingURL=tabularStyle.js.map