"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isLogicalOperator = exports.isReserved = exports.isToken = exports.testToken = exports.EOF_TOKEN = exports.createEofToken = exports.TokenType = void 0;
/** Token type enum for all possible Token categories */
var TokenType;
(function (TokenType) {
    TokenType["QUOTED_IDENTIFIER"] = "QUOTED_IDENTIFIER";
    TokenType["IDENTIFIER"] = "IDENTIFIER";
    TokenType["STRING"] = "STRING";
    TokenType["VARIABLE"] = "VARIABLE";
    TokenType["RESERVED_DATA_TYPE"] = "RESERVED_DATA_TYPE";
    TokenType["RESERVED_PARAMETERIZED_DATA_TYPE"] = "RESERVED_PARAMETERIZED_DATA_TYPE";
    TokenType["RESERVED_KEYWORD"] = "RESERVED_KEYWORD";
    TokenType["RESERVED_FUNCTION_NAME"] = "RESERVED_FUNCTION_NAME";
    TokenType["RESERVED_KEYWORD_PHRASE"] = "RESERVED_KEYWORD_PHRASE";
    TokenType["RESERVED_DATA_TYPE_PHRASE"] = "RESERVED_DATA_TYPE_PHRASE";
    TokenType["RESERVED_SET_OPERATION"] = "RESERVED_SET_OPERATION";
    TokenType["RESERVED_CLAUSE"] = "RESERVED_CLAUSE";
    TokenType["RESERVED_SELECT"] = "RESERVED_SELECT";
    TokenType["RESERVED_JOIN"] = "RESERVED_JOIN";
    TokenType["ARRAY_IDENTIFIER"] = "ARRAY_IDENTIFIER";
    TokenType["ARRAY_KEYWORD"] = "ARRAY_KEYWORD";
    TokenType["CASE"] = "CASE";
    TokenType["END"] = "END";
    TokenType["WHEN"] = "WHEN";
    TokenType["ELSE"] = "ELSE";
    TokenType["THEN"] = "THEN";
    TokenType["LIMIT"] = "LIMIT";
    TokenType["BETWEEN"] = "BETWEEN";
    TokenType["AND"] = "AND";
    TokenType["OR"] = "OR";
    TokenType["XOR"] = "XOR";
    TokenType["OPERATOR"] = "OPERATOR";
    TokenType["COMMA"] = "COMMA";
    TokenType["ASTERISK"] = "ASTERISK";
    TokenType["PROPERTY_ACCESS_OPERATOR"] = "PROPERTY_ACCESS_OPERATOR";
    TokenType["OPEN_PAREN"] = "OPEN_PAREN";
    TokenType["CLOSE_PAREN"] = "CLOSE_PAREN";
    TokenType["LINE_COMMENT"] = "LINE_COMMENT";
    TokenType["BLOCK_COMMENT"] = "BLOCK_COMMENT";
    // Text between /* sql-formatter-disable */ and /* sql-formatter-enable */
    TokenType["DISABLE_COMMENT"] = "DISABLE_COMMENT";
    TokenType["NUMBER"] = "NUMBER";
    TokenType["NAMED_PARAMETER"] = "NAMED_PARAMETER";
    TokenType["QUOTED_PARAMETER"] = "QUOTED_PARAMETER";
    TokenType["NUMBERED_PARAMETER"] = "NUMBERED_PARAMETER";
    TokenType["POSITIONAL_PARAMETER"] = "POSITIONAL_PARAMETER";
    TokenType["CUSTOM_PARAMETER"] = "CUSTOM_PARAMETER";
    TokenType["DELIMITER"] = "DELIMITER";
    TokenType["EOF"] = "EOF";
})(TokenType = exports.TokenType || (exports.TokenType = {}));
/** Creates EOF token positioned at given location */
const createEofToken = (index) => ({
    type: TokenType.EOF,
    raw: '«EOF»',
    text: '«EOF»',
    start: index,
});
exports.createEofToken = createEofToken;
/**
 * For use as a "missing token"
 * e.g. in lookAhead and lookBehind to avoid dealing with null values
 */
exports.EOF_TOKEN = (0, exports.createEofToken)(Infinity);
/** Checks if two tokens are equivalent */
const testToken = (compareToken) => (token) => token.type === compareToken.type && token.text === compareToken.text;
exports.testToken = testToken;
/** Util object that allows for easy checking of Reserved Keywords */
exports.isToken = {
    ARRAY: (0, exports.testToken)({ text: 'ARRAY', type: TokenType.RESERVED_DATA_TYPE }),
    BY: (0, exports.testToken)({ text: 'BY', type: TokenType.RESERVED_KEYWORD }),
    SET: (0, exports.testToken)({ text: 'SET', type: TokenType.RESERVED_CLAUSE }),
    STRUCT: (0, exports.testToken)({ text: 'STRUCT', type: TokenType.RESERVED_DATA_TYPE }),
    WINDOW: (0, exports.testToken)({ text: 'WINDOW', type: TokenType.RESERVED_CLAUSE }),
    VALUES: (0, exports.testToken)({ text: 'VALUES', type: TokenType.RESERVED_CLAUSE }),
};
/** Checks if token is any Reserved Keyword or Clause */
const isReserved = (type) => type === TokenType.RESERVED_DATA_TYPE ||
    type === TokenType.RESERVED_KEYWORD ||
    type === TokenType.RESERVED_FUNCTION_NAME ||
    type === TokenType.RESERVED_KEYWORD_PHRASE ||
    type === TokenType.RESERVED_DATA_TYPE_PHRASE ||
    type === TokenType.RESERVED_CLAUSE ||
    type === TokenType.RESERVED_SELECT ||
    type === TokenType.RESERVED_SET_OPERATION ||
    type === TokenType.RESERVED_JOIN ||
    type === TokenType.ARRAY_KEYWORD ||
    type === TokenType.CASE ||
    type === TokenType.END ||
    type === TokenType.WHEN ||
    type === TokenType.ELSE ||
    type === TokenType.THEN ||
    type === TokenType.LIMIT ||
    type === TokenType.BETWEEN ||
    type === TokenType.AND ||
    type === TokenType.OR ||
    type === TokenType.XOR;
exports.isReserved = isReserved;
const isLogicalOperator = (type) => type === TokenType.AND || type === TokenType.OR || type === TokenType.XOR;
exports.isLogicalOperator = isLogicalOperator;
//# sourceMappingURL=token.js.map