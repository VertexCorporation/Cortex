import { quotePatterns } from './regexFactory.js';
import { Token } from './token.js';
export interface IdentChars {
    first?: string;
    rest?: string;
    dashes?: boolean;
    allowFirstCharNumber?: boolean;
}
export type PlainQuoteType = keyof typeof quotePatterns;
export interface PrefixedQuoteType {
    quote: PlainQuoteType;
    prefixes: string[];
    requirePrefix?: boolean;
}
export interface RegexPattern {
    regex: string;
}
export type QuoteType = PlainQuoteType | PrefixedQuoteType | RegexPattern;
export type VariableType = RegexPattern | PrefixedQuoteType;
export interface ParamTypes {
    positional?: boolean;
    numbered?: ('?' | ':' | '$')[];
    named?: (':' | '@' | '$')[];
    quoted?: (':' | '@' | '$')[];
    custom?: CustomParameter[];
}
export interface CustomParameter {
    regex: string;
    key?: (text: string) => string;
}
export interface TokenizerOptions {
    reservedSelect: string[];
    reservedClauses: string[];
    supportsXor?: boolean;
    reservedSetOperations: string[];
    reservedJoins: string[];
    reservedKeywordPhrases?: string[];
    reservedDataTypePhrases?: string[];
    reservedFunctionNames: string[];
    reservedDataTypes: string[];
    reservedKeywords: string[];
    stringTypes: QuoteType[];
    identTypes: QuoteType[];
    variableTypes?: VariableType[];
    extraParens?: ('[]' | '{}')[];
    paramTypes?: ParamTypes;
    lineCommentTypes?: string[];
    nestedBlockComments?: boolean;
    identChars?: IdentChars;
    paramChars?: IdentChars;
    operators?: string[];
    propertyAccessOperators?: string[];
    operatorKeyword?: boolean;
    underscoresInNumbers?: boolean;
    postProcess?: (tokens: Token[]) => Token[];
}
