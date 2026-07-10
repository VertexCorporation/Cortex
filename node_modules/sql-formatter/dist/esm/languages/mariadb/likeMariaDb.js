import { EOF_TOKEN, isToken, TokenType } from '../../lexer/token.js';
// Shared functionality used by all MariaDB-like SQL dialects.
export function postProcess(tokens) {
    return tokens.map((token, i) => {
        const nextToken = tokens[i + 1] || EOF_TOKEN;
        if (isToken.SET(token) && nextToken.text === '(') {
            // This is SET datatype, not SET statement
            return Object.assign(Object.assign({}, token), { type: TokenType.RESERVED_FUNCTION_NAME });
        }
        const prevToken = tokens[i - 1] || EOF_TOKEN;
        if (isToken.VALUES(token) && prevToken.text === '=') {
            // This is VALUES() function, not VALUES clause
            return Object.assign(Object.assign({}, token), { type: TokenType.RESERVED_FUNCTION_NAME });
        }
        return token;
    });
}
//# sourceMappingURL=likeMariaDb.js.map