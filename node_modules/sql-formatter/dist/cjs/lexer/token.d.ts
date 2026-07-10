/** Token type enum for all possible Token categories */
export declare enum TokenType {
    QUOTED_IDENTIFIER = "QUOTED_IDENTIFIER",
    IDENTIFIER = "IDENTIFIER",
    STRING = "STRING",
    VARIABLE = "VARIABLE",
    RESERVED_DATA_TYPE = "RESERVED_DATA_TYPE",
    RESERVED_PARAMETERIZED_DATA_TYPE = "RESERVED_PARAMETERIZED_DATA_TYPE",
    RESERVED_KEYWORD = "RESERVED_KEYWORD",
    RESERVED_FUNCTION_NAME = "RESERVED_FUNCTION_NAME",
    RESERVED_KEYWORD_PHRASE = "RESERVED_KEYWORD_PHRASE",
    RESERVED_DATA_TYPE_PHRASE = "RESERVED_DATA_TYPE_PHRASE",
    RESERVED_SET_OPERATION = "RESERVED_SET_OPERATION",
    RESERVED_CLAUSE = "RESERVED_CLAUSE",
    RESERVED_SELECT = "RESERVED_SELECT",
    RESERVED_JOIN = "RESERVED_JOIN",
    ARRAY_IDENTIFIER = "ARRAY_IDENTIFIER",
    ARRAY_KEYWORD = "ARRAY_KEYWORD",
    CASE = "CASE",
    END = "END",
    WHEN = "WHEN",
    ELSE = "ELSE",
    THEN = "THEN",
    LIMIT = "LIMIT",
    BETWEEN = "BETWEEN",
    AND = "AND",
    OR = "OR",
    XOR = "XOR",
    OPERATOR = "OPERATOR",
    COMMA = "COMMA",
    ASTERISK = "ASTERISK",
    PROPERTY_ACCESS_OPERATOR = "PROPERTY_ACCESS_OPERATOR",
    OPEN_PAREN = "OPEN_PAREN",
    CLOSE_PAREN = "CLOSE_PAREN",
    LINE_COMMENT = "LINE_COMMENT",
    BLOCK_COMMENT = "BLOCK_COMMENT",
    DISABLE_COMMENT = "DISABLE_COMMENT",
    NUMBER = "NUMBER",
    NAMED_PARAMETER = "NAMED_PARAMETER",
    QUOTED_PARAMETER = "QUOTED_PARAMETER",
    NUMBERED_PARAMETER = "NUMBERED_PARAMETER",
    POSITIONAL_PARAMETER = "POSITIONAL_PARAMETER",
    CUSTOM_PARAMETER = "CUSTOM_PARAMETER",
    DELIMITER = "DELIMITER",
    EOF = "EOF"
}
/** Struct to store the most basic cohesive unit of language grammar */
export interface Token {
    type: TokenType;
    raw: string;
    text: string;
    key?: string;
    start: number;
    precedingWhitespace?: string;
}
/** Creates EOF token positioned at given location */
export declare const createEofToken: (index: number) => {
    type: TokenType;
    raw: string;
    text: string;
    start: number;
};
/**
 * For use as a "missing token"
 * e.g. in lookAhead and lookBehind to avoid dealing with null values
 */
export declare const EOF_TOKEN: {
    type: TokenType;
    raw: string;
    text: string;
    start: number;
};
/** Checks if two tokens are equivalent */
export declare const testToken: (compareToken: {
    type: TokenType;
    text: string;
}) => (token: Token) => boolean;
/** Util object that allows for easy checking of Reserved Keywords */
export declare const isToken: {
    ARRAY: (token: Token) => boolean;
    BY: (token: Token) => boolean;
    SET: (token: Token) => boolean;
    STRUCT: (token: Token) => boolean;
    WINDOW: (token: Token) => boolean;
    VALUES: (token: Token) => boolean;
};
/** Checks if token is any Reserved Keyword or Clause */
export declare const isReserved: (type: TokenType) => boolean;
export declare const isLogicalOperator: (type: TokenType) => boolean;
