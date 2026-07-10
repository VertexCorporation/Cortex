import { TokenType } from './token.js';
import * as regex from './regexFactory.js';
import TokenizerEngine from './TokenizerEngine.js';
import { escapeRegExp, patternToRegex } from './regexUtil.js';
import { equalizeWhitespace } from '../utils.js';
import { NestedComment } from './NestedComment.js';
export default class Tokenizer {
    constructor(cfg, dialectName) {
        this.cfg = cfg;
        this.dialectName = dialectName;
        this.rulesBeforeParams = this.buildRulesBeforeParams(cfg);
        this.rulesAfterParams = this.buildRulesAfterParams(cfg);
    }
    tokenize(input, paramTypesOverrides) {
        const rules = [
            ...this.rulesBeforeParams,
            ...this.buildParamRules(this.cfg, paramTypesOverrides),
            ...this.rulesAfterParams,
        ];
        const tokens = new TokenizerEngine(rules, this.dialectName).tokenize(input);
        return this.cfg.postProcess ? this.cfg.postProcess(tokens) : tokens;
    }
    // These rules can be cached as they only depend on
    // the Tokenizer config options specified for each SQL dialect
    buildRulesBeforeParams(cfg) {
        var _a, _b, _c;
        return this.validRules([
            {
                type: TokenType.DISABLE_COMMENT,
                regex: /(\/\* *sql-formatter-disable *\*\/[\s\S]*?(?:\/\* *sql-formatter-enable *\*\/|$))/uy,
            },
            {
                type: TokenType.BLOCK_COMMENT,
                regex: cfg.nestedBlockComments ? new NestedComment() : /(\/\*[^]*?\*\/)/uy,
            },
            {
                type: TokenType.LINE_COMMENT,
                regex: regex.lineComment((_a = cfg.lineCommentTypes) !== null && _a !== void 0 ? _a : ['--']),
            },
            {
                type: TokenType.QUOTED_IDENTIFIER,
                regex: regex.string(cfg.identTypes),
            },
            {
                type: TokenType.NUMBER,
                regex: cfg.underscoresInNumbers
                    ? /(?:0x[0-9a-fA-F_]+|0b[01_]+|(?:-\s*)?(?:[0-9_]*\.[0-9_]+|[0-9_]+(?:\.[0-9_]*)?)(?:[eE][-+]?[0-9_]+(?:\.[0-9_]+)?)?)(?![\w\p{Alphabetic}])/uy
                    : /(?:0x[0-9a-fA-F]+|0b[01]+|(?:-\s*)?(?:[0-9]*\.[0-9]+|[0-9]+(?:\.[0-9]*)?)(?:[eE][-+]?[0-9]+(?:\.[0-9]+)?)?)(?![\w\p{Alphabetic}])/uy,
            },
            // RESERVED_KEYWORD_PHRASE and RESERVED_DATA_TYPE_PHRASE  is matched before all other keyword tokens
            // to e.g. prioritize matching "TIMESTAMP WITH TIME ZONE" phrase over "WITH" clause.
            {
                type: TokenType.RESERVED_KEYWORD_PHRASE,
                regex: regex.reservedWord((_b = cfg.reservedKeywordPhrases) !== null && _b !== void 0 ? _b : [], cfg.identChars),
                text: toCanonical,
            },
            {
                type: TokenType.RESERVED_DATA_TYPE_PHRASE,
                regex: regex.reservedWord((_c = cfg.reservedDataTypePhrases) !== null && _c !== void 0 ? _c : [], cfg.identChars),
                text: toCanonical,
            },
            {
                type: TokenType.CASE,
                regex: /CASE\b/iuy,
                text: toCanonical,
            },
            {
                type: TokenType.END,
                regex: /END\b/iuy,
                text: toCanonical,
            },
            {
                type: TokenType.BETWEEN,
                regex: /BETWEEN\b/iuy,
                text: toCanonical,
            },
            {
                type: TokenType.LIMIT,
                regex: cfg.reservedClauses.includes('LIMIT') ? /LIMIT\b/iuy : undefined,
                text: toCanonical,
            },
            {
                type: TokenType.RESERVED_CLAUSE,
                regex: regex.reservedWord(cfg.reservedClauses, cfg.identChars),
                text: toCanonical,
            },
            {
                type: TokenType.RESERVED_SELECT,
                regex: regex.reservedWord(cfg.reservedSelect, cfg.identChars),
                text: toCanonical,
            },
            {
                type: TokenType.RESERVED_SET_OPERATION,
                regex: regex.reservedWord(cfg.reservedSetOperations, cfg.identChars),
                text: toCanonical,
            },
            {
                type: TokenType.WHEN,
                regex: /WHEN\b/iuy,
                text: toCanonical,
            },
            {
                type: TokenType.ELSE,
                regex: /ELSE\b/iuy,
                text: toCanonical,
            },
            {
                type: TokenType.THEN,
                regex: /THEN\b/iuy,
                text: toCanonical,
            },
            {
                type: TokenType.RESERVED_JOIN,
                regex: regex.reservedWord(cfg.reservedJoins, cfg.identChars),
                text: toCanonical,
            },
            {
                type: TokenType.AND,
                regex: /AND\b/iuy,
                text: toCanonical,
            },
            {
                type: TokenType.OR,
                regex: /OR\b/iuy,
                text: toCanonical,
            },
            {
                type: TokenType.XOR,
                regex: cfg.supportsXor ? /XOR\b/iuy : undefined,
                text: toCanonical,
            },
            ...(cfg.operatorKeyword
                ? [
                    {
                        type: TokenType.OPERATOR,
                        regex: /OPERATOR *\([^)]+\)/iuy,
                    },
                ]
                : []),
            {
                type: TokenType.RESERVED_FUNCTION_NAME,
                regex: regex.reservedWord(cfg.reservedFunctionNames, cfg.identChars),
                text: toCanonical,
            },
            {
                type: TokenType.RESERVED_DATA_TYPE,
                regex: regex.reservedWord(cfg.reservedDataTypes, cfg.identChars),
                text: toCanonical,
            },
            {
                type: TokenType.RESERVED_KEYWORD,
                regex: regex.reservedWord(cfg.reservedKeywords, cfg.identChars),
                text: toCanonical,
            },
        ]);
    }
    // These rules can also be cached as they only depend on
    // the Tokenizer config options specified for each SQL dialect
    buildRulesAfterParams(cfg) {
        var _a, _b;
        return this.validRules([
            {
                type: TokenType.VARIABLE,
                regex: cfg.variableTypes ? regex.variable(cfg.variableTypes) : undefined,
            },
            { type: TokenType.STRING, regex: regex.string(cfg.stringTypes) },
            {
                type: TokenType.IDENTIFIER,
                regex: regex.identifier(cfg.identChars),
            },
            { type: TokenType.DELIMITER, regex: /[;]/uy },
            { type: TokenType.COMMA, regex: /[,]/y },
            {
                type: TokenType.OPEN_PAREN,
                regex: regex.parenthesis('open', cfg.extraParens),
            },
            {
                type: TokenType.CLOSE_PAREN,
                regex: regex.parenthesis('close', cfg.extraParens),
            },
            {
                type: TokenType.OPERATOR,
                regex: regex.operator([
                    // standard operators
                    '+',
                    '-',
                    '/',
                    '>',
                    '<',
                    '=',
                    '<>',
                    '<=',
                    '>=',
                    '!=',
                    ...((_a = cfg.operators) !== null && _a !== void 0 ? _a : []),
                ]),
            },
            { type: TokenType.ASTERISK, regex: /[*]/uy },
            {
                type: TokenType.PROPERTY_ACCESS_OPERATOR,
                regex: regex.operator(['.', ...((_b = cfg.propertyAccessOperators) !== null && _b !== void 0 ? _b : [])]),
            },
        ]);
    }
    // These rules can't be blindly cached as the paramTypesOverrides object
    // can differ on each invocation of the format() function.
    buildParamRules(cfg, paramTypesOverrides) {
        var _a, _b, _c, _d, _e;
        // Each dialect has its own default parameter types (if any),
        // but these can be overriden by the user of the library.
        const paramTypes = {
            named: (paramTypesOverrides === null || paramTypesOverrides === void 0 ? void 0 : paramTypesOverrides.named) || ((_a = cfg.paramTypes) === null || _a === void 0 ? void 0 : _a.named) || [],
            quoted: (paramTypesOverrides === null || paramTypesOverrides === void 0 ? void 0 : paramTypesOverrides.quoted) || ((_b = cfg.paramTypes) === null || _b === void 0 ? void 0 : _b.quoted) || [],
            numbered: (paramTypesOverrides === null || paramTypesOverrides === void 0 ? void 0 : paramTypesOverrides.numbered) || ((_c = cfg.paramTypes) === null || _c === void 0 ? void 0 : _c.numbered) || [],
            positional: typeof (paramTypesOverrides === null || paramTypesOverrides === void 0 ? void 0 : paramTypesOverrides.positional) === 'boolean'
                ? paramTypesOverrides.positional
                : (_d = cfg.paramTypes) === null || _d === void 0 ? void 0 : _d.positional,
            custom: (paramTypesOverrides === null || paramTypesOverrides === void 0 ? void 0 : paramTypesOverrides.custom) || ((_e = cfg.paramTypes) === null || _e === void 0 ? void 0 : _e.custom) || [],
        };
        return this.validRules([
            {
                type: TokenType.NAMED_PARAMETER,
                regex: regex.parameter(paramTypes.named, regex.identifierPattern(cfg.paramChars || cfg.identChars)),
                key: v => v.slice(1),
            },
            {
                type: TokenType.QUOTED_PARAMETER,
                regex: regex.parameter(paramTypes.quoted, regex.stringPattern(cfg.identTypes)),
                key: v => (({ tokenKey, quoteChar }) => tokenKey.replace(new RegExp(escapeRegExp('\\' + quoteChar), 'gu'), quoteChar))({
                    tokenKey: v.slice(2, -1),
                    quoteChar: v.slice(-1),
                }),
            },
            {
                type: TokenType.NUMBERED_PARAMETER,
                regex: regex.parameter(paramTypes.numbered, '[0-9]+'),
                key: v => v.slice(1),
            },
            {
                type: TokenType.POSITIONAL_PARAMETER,
                regex: paramTypes.positional ? /[?]/y : undefined,
            },
            ...paramTypes.custom.map((customParam) => {
                var _a;
                return ({
                    type: TokenType.CUSTOM_PARAMETER,
                    regex: patternToRegex(customParam.regex),
                    key: (_a = customParam.key) !== null && _a !== void 0 ? _a : (v => v),
                });
            }),
        ]);
    }
    // filters out rules for token types whose regex is undefined
    validRules(rules) {
        return rules.filter((rule) => Boolean(rule.regex));
    }
}
/**
 * Converts keywords (and keyword sequences) to canonical form:
 * - in uppercase
 * - single spaces between words
 */
const toCanonical = (v) => equalizeWhitespace(v.toUpperCase());
//# sourceMappingURL=Tokenizer.js.map