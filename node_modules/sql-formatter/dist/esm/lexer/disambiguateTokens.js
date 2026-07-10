import { isReserved, TokenType } from './token.js';
/**
 * Ensures that no keyword token (RESERVED_*) is preceded or followed by a dot (.)
 * or any other property-access operator.
 *
 * Ensures that all RESERVED_FUNCTION_NAME tokens are followed by "(".
 * If they're not, converts the token to IDENTIFIER.
 *
 * Converts RESERVED_DATA_TYPE tokens followed by "(" to RESERVED_PARAMETERIZED_DATA_TYPE.
 *
 * When IDENTIFIER or RESERVED_DATA_TYPE token is followed by "["
 * converts it to ARRAY_IDENTIFIER or ARRAY_KEYWORD accordingly.
 *
 * This is needed to avoid ambiguity in parser which expects function names
 * to always be followed by open-paren, and to distinguish between
 * array accessor `foo[1]` and array literal `[1, 2, 3]`.
 */
export function disambiguateTokens(tokens) {
    return tokens
        .map(propertyNameKeywordToIdent)
        .map(funcNameToIdent)
        .map(dataTypeToParameterizedDataType)
        .map(identToArrayIdent)
        .map(dataTypeToArrayKeyword);
}
const propertyNameKeywordToIdent = (token, i, tokens) => {
    if (isReserved(token.type)) {
        const prevToken = prevNonCommentToken(tokens, i);
        if (prevToken && prevToken.type === TokenType.PROPERTY_ACCESS_OPERATOR) {
            return Object.assign(Object.assign({}, token), { type: TokenType.IDENTIFIER, text: token.raw });
        }
        const nextToken = nextNonCommentToken(tokens, i);
        if (nextToken && nextToken.type === TokenType.PROPERTY_ACCESS_OPERATOR) {
            return Object.assign(Object.assign({}, token), { type: TokenType.IDENTIFIER, text: token.raw });
        }
    }
    return token;
};
const funcNameToIdent = (token, i, tokens) => {
    if (token.type === TokenType.RESERVED_FUNCTION_NAME) {
        const nextToken = nextNonCommentToken(tokens, i);
        if (!nextToken || !isOpenParen(nextToken)) {
            return Object.assign(Object.assign({}, token), { type: TokenType.IDENTIFIER, text: token.raw });
        }
    }
    return token;
};
const dataTypeToParameterizedDataType = (token, i, tokens) => {
    if (token.type === TokenType.RESERVED_DATA_TYPE) {
        const nextToken = nextNonCommentToken(tokens, i);
        if (nextToken && isOpenParen(nextToken)) {
            return Object.assign(Object.assign({}, token), { type: TokenType.RESERVED_PARAMETERIZED_DATA_TYPE });
        }
    }
    return token;
};
const identToArrayIdent = (token, i, tokens) => {
    if (token.type === TokenType.IDENTIFIER) {
        const nextToken = nextNonCommentToken(tokens, i);
        if (nextToken && isOpenBracket(nextToken)) {
            return Object.assign(Object.assign({}, token), { type: TokenType.ARRAY_IDENTIFIER });
        }
    }
    return token;
};
const dataTypeToArrayKeyword = (token, i, tokens) => {
    if (token.type === TokenType.RESERVED_DATA_TYPE) {
        const nextToken = nextNonCommentToken(tokens, i);
        if (nextToken && isOpenBracket(nextToken)) {
            return Object.assign(Object.assign({}, token), { type: TokenType.ARRAY_KEYWORD });
        }
    }
    return token;
};
const prevNonCommentToken = (tokens, index) => nextNonCommentToken(tokens, index, -1);
const nextNonCommentToken = (tokens, index, dir = 1) => {
    let i = 1;
    while (tokens[index + i * dir] && isComment(tokens[index + i * dir])) {
        i++;
    }
    return tokens[index + i * dir];
};
const isOpenParen = (t) => t.type === TokenType.OPEN_PAREN && t.text === '(';
const isOpenBracket = (t) => t.type === TokenType.OPEN_PAREN && t.text === '[';
const isComment = (t) => t.type === TokenType.BLOCK_COMMENT || t.type === TokenType.LINE_COMMENT;
//# sourceMappingURL=disambiguateTokens.js.map