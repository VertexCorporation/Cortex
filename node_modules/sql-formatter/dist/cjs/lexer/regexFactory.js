"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.identifierPattern = exports.identifier = exports.string = exports.stringPattern = exports.variable = exports.quotePatterns = exports.parameter = exports.reservedWord = exports.operator = exports.parenthesis = exports.lineComment = void 0;
const utils_js_1 = require("../utils.js");
const regexUtil_js_1 = require("./regexUtil.js");
/**
 * Builds a RegExp for valid line comments in a SQL dialect
 * @param {string[]} lineCommentTypes - list of character strings that denote line comments
 */
const lineComment = (lineCommentTypes) => new RegExp(`(?:${lineCommentTypes.map(regexUtil_js_1.escapeRegExp).join('|')}).*?(?=\r\n|\r|\n|$)`, 'uy');
exports.lineComment = lineComment;
/**
 * Builds a RegExp for matching either open- or close-parenthesis patterns
 */
const parenthesis = (kind, extraParens = []) => {
    const index = kind === 'open' ? 0 : 1;
    const parens = ['()', ...extraParens].map(pair => pair[index]);
    return (0, regexUtil_js_1.patternToRegex)(parens.map(regexUtil_js_1.escapeRegExp).join('|'));
};
exports.parenthesis = parenthesis;
/**
 * Builds a RegExp containing all operators for a SQL dialect
 */
const operator = (operators) => (0, regexUtil_js_1.patternToRegex)(`${(0, utils_js_1.sortByLengthDesc)(operators).map(regexUtil_js_1.escapeRegExp).join('|')}`);
exports.operator = operator;
// Negative lookahead to avoid matching a keyword that's actually part of identifier,
// which can happen when identifier allows word-boundary characters inside it.
//
// For example "SELECT$ME" should be tokenized as:
// - ["SELECT$ME"] when $ is allowed inside identifiers
// - ["SELECT", "$", "ME"] when $ can't be part of identifiers.
const rejectIdentCharsPattern = ({ rest, dashes }) => rest || dashes ? `(?![${rest || ''}${dashes ? '-' : ''}])` : '';
/**
 * Builds a RegExp for all Reserved Keywords in a SQL dialect
 */
const reservedWord = (reservedKeywords, identChars = {}) => {
    if (reservedKeywords.length === 0) {
        return /^\b$/u;
    }
    const avoidIdentChars = rejectIdentCharsPattern(identChars);
    const reservedKeywordsPattern = (0, utils_js_1.sortByLengthDesc)(reservedKeywords)
        .map(regexUtil_js_1.escapeRegExp)
        .join('|')
        .replace(/ /gu, '\\s+');
    return new RegExp(`(?:${reservedKeywordsPattern})${avoidIdentChars}\\b`, 'iuy');
};
exports.reservedWord = reservedWord;
/**
 * Builds a RegExp for parameter placeholder patterns
 * @param {string[]} paramTypes - list of strings that denote placeholder types
 * @param {string} pattern - string that denotes placeholder pattern
 */
const parameter = (paramTypes, pattern) => {
    if (!paramTypes.length) {
        return undefined;
    }
    const typesRegex = paramTypes.map(regexUtil_js_1.escapeRegExp).join('|');
    return (0, regexUtil_js_1.patternToRegex)(`(?:${typesRegex})(?:${pattern})`);
};
exports.parameter = parameter;
const buildQStringPatterns = () => {
    const specialDelimiterMap = {
        '<': '>',
        '[': ']',
        '(': ')',
        '{': '}',
    };
    // base pattern for special delimiters, left must correspond with right
    const singlePattern = "{left}(?:(?!{right}').)*?{right}";
    // replace {left} and {right} with delimiters, collect as array
    const patternList = Object.entries(specialDelimiterMap).map(([left, right]) => singlePattern.replace(/{left}/g, (0, regexUtil_js_1.escapeRegExp)(left)).replace(/{right}/g, (0, regexUtil_js_1.escapeRegExp)(right)));
    const specialDelimiters = (0, regexUtil_js_1.escapeRegExp)(Object.keys(specialDelimiterMap).join(''));
    // standard pattern for common delimiters, ignores special delimiters
    const standardDelimiterPattern = String.raw `(?<tag>[^\s${specialDelimiters}])(?:(?!\k<tag>').)*?\k<tag>`;
    // constructs final pattern by joining all cases
    const qStringPattern = `[Qq]'(?:${standardDelimiterPattern}|${patternList.join('|')})'`;
    return qStringPattern;
};
// Regex patterns for all supported quote styles.
//
// Most of them have a single escaping-style built in,
// but "" and '' support multiple versions of escapes,
// which must be selected with suffixes: -qq, -bs, -qq-bs, -raw
exports.quotePatterns = {
    // - backtick quoted (using `` to escape)
    '``': '(?:`[^`]*`)+',
    // - Transact-SQL square bracket quoted (using ]] to escape)
    '[]': String.raw `(?:\[[^\]]*\])(?:\][^\]]*\])*`,
    // double-quoted
    '""-qq': String.raw `(?:"[^"]*")+`,
    '""-bs': String.raw `(?:"[^"\\]*(?:\\.[^"\\]*)*")`,
    '""-qq-bs': String.raw `(?:"[^"\\]*(?:\\.[^"\\]*)*")+`,
    '""-raw': String.raw `(?:"[^"]*")`,
    // single-quoted
    "''-qq": String.raw `(?:'[^']*')+`,
    "''-bs": String.raw `(?:'[^'\\]*(?:\\.[^'\\]*)*')`,
    "''-qq-bs": String.raw `(?:'[^'\\]*(?:\\.[^'\\]*)*')+`,
    "''-raw": String.raw `(?:'[^']*')`,
    // PostgreSQL dollar-quoted
    '$$': String.raw `(?<tag>\$\w*\$)[\s\S]*?\k<tag>`,
    // BigQuery '''triple-quoted''' (using \' to escape)
    "'''..'''": String.raw `'''[^\\]*?(?:\\.[^\\]*?)*?'''`,
    // BigQuery """triple-quoted""" (using \" to escape)
    '""".."""': String.raw `"""[^\\]*?(?:\\.[^\\]*?)*?"""`,
    // Hive and Spark variables: ${name}
    '{}': String.raw `(?:\{[^\}]*\})`,
    // Oracle q'' strings: q'<text>' q'|text|' ...
    "q''": buildQStringPatterns(),
};
const singleQuotePattern = (quoteTypes) => {
    if (typeof quoteTypes === 'string') {
        return exports.quotePatterns[quoteTypes];
    }
    else if ('regex' in quoteTypes) {
        return quoteTypes.regex;
    }
    else {
        return (0, regexUtil_js_1.prefixesPattern)(quoteTypes) + exports.quotePatterns[quoteTypes.quote];
    }
};
/** Builds a RegExp for matching variables */
const variable = (varTypes) => (0, regexUtil_js_1.patternToRegex)(varTypes
    .map(varType => ('regex' in varType ? varType.regex : singleQuotePattern(varType)))
    .join('|'));
exports.variable = variable;
/** Builds a quote-delimited pattern for matching all given quote types */
const stringPattern = (quoteTypes) => quoteTypes.map(singleQuotePattern).join('|');
exports.stringPattern = stringPattern;
/** Builds a RegExp for matching quote-delimited patterns */
const string = (quoteTypes) => (0, regexUtil_js_1.patternToRegex)((0, exports.stringPattern)(quoteTypes));
exports.string = string;
/**
 * Builds a RegExp for valid identifiers in a SQL dialect
 */
const identifier = (specialChars = {}) => (0, regexUtil_js_1.patternToRegex)((0, exports.identifierPattern)(specialChars));
exports.identifier = identifier;
/**
 * Builds a RegExp string for valid identifiers in a SQL dialect
 */
const identifierPattern = ({ first, rest, dashes, allowFirstCharNumber, } = {}) => {
    // Unicode letters, diacritical marks and underscore
    const letter = '\\p{Alphabetic}\\p{Mark}_';
    // Numbers 0..9, plus various unicode numbers
    const number = '\\p{Decimal_Number}';
    const firstChars = (0, regexUtil_js_1.escapeRegExp)(first !== null && first !== void 0 ? first : '');
    const restChars = (0, regexUtil_js_1.escapeRegExp)(rest !== null && rest !== void 0 ? rest : '');
    const pattern = allowFirstCharNumber
        ? `[${letter}${number}${firstChars}][${letter}${number}${restChars}]*`
        : `[${letter}${firstChars}][${letter}${number}${restChars}]*`;
    return dashes ? (0, regexUtil_js_1.withDashes)(pattern) : pattern;
};
exports.identifierPattern = identifierPattern;
//# sourceMappingURL=regexFactory.js.map