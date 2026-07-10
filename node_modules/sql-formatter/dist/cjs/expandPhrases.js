"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.expandSinglePhrase = exports.expandPhrases = void 0;
/**
 * Performs expandSinglePhrase() on array
 */
const expandPhrases = (phrases) => phrases.flatMap(exports.expandSinglePhrase);
exports.expandPhrases = expandPhrases;
/**
 * Expands a syntax description like
 *
 *     "CREATE [OR REPLACE] [TEMP|TEMPORARY] TABLE"
 *
 * into an array of all possible combinations like:
 *
 *     [ "CREATE TABLE",
 *       "CREATE TEMP TABLE",
 *       "CREATE TEMPORARY TABLE",
 *       "CREATE OR REPLACE TABLE",
 *       "CREATE OR REPLACE TEMP TABLE",
 *       "CREATE OR REPLACE TEMPORARY TABLE" ]
 *
 * The [] and {} parenthesis can also be nested like
 *
 *     "FOR [OF {UNIQUE | MANDATORY} TABLES]"
 *
 * resulting in:
 *
 *     [ "FOR",
 *       "FOR OF UNIQUE TABLES",
 *       "FOR OF MANDATORY TABLES" ]
 */
const expandSinglePhrase = (phrase) => buildCombinations(parsePhrase(phrase)).map(stripExtraWhitespace);
exports.expandSinglePhrase = expandSinglePhrase;
const stripExtraWhitespace = (text) => text.replace(/ +/g, ' ').trim();
const parsePhrase = (text) => ({
    type: 'mandatory_block',
    items: parseAlteration(text, 0)[0],
});
const parseAlteration = (text, index, expectClosing) => {
    const alterations = [];
    while (text[index]) {
        const [term, newIndex] = parseConcatenation(text, index);
        alterations.push(term);
        index = newIndex;
        if (text[index] === '|') {
            index++;
        }
        else if (text[index] === '}' || text[index] === ']') {
            if (expectClosing !== text[index]) {
                throw new Error(`Unbalanced parenthesis in: ${text}`);
            }
            index++;
            return [alterations, index];
        }
        else if (index === text.length) {
            if (expectClosing) {
                throw new Error(`Unbalanced parenthesis in: ${text}`);
            }
            return [alterations, index];
        }
        else {
            throw new Error(`Unexpected "${text[index]}"`);
        }
    }
    return [alterations, index];
};
const parseConcatenation = (text, index) => {
    const items = [];
    while (true) {
        const [term, newIndex] = parseTerm(text, index);
        if (term) {
            items.push(term);
            index = newIndex;
        }
        else {
            break;
        }
    }
    return items.length === 1 ? [items[0], index] : [{ type: 'concatenation', items }, index];
};
const parseTerm = (text, index) => {
    if (text[index] === '{') {
        return parseMandatoryBlock(text, index + 1);
    }
    else if (text[index] === '[') {
        return parseOptionalBlock(text, index + 1);
    }
    else {
        let word = '';
        while (text[index] && /[A-Za-z0-9_ ]/.test(text[index])) {
            word += text[index];
            index++;
        }
        return [word, index];
    }
};
const parseMandatoryBlock = (text, index) => {
    const [items, newIndex] = parseAlteration(text, index, '}');
    return [{ type: 'mandatory_block', items }, newIndex];
};
const parseOptionalBlock = (text, index) => {
    const [items, newIndex] = parseAlteration(text, index, ']');
    return [{ type: 'optional_block', items }, newIndex];
};
const buildCombinations = (node) => {
    if (typeof node === 'string') {
        return [node];
    }
    else if (node.type === 'concatenation') {
        return node.items.map(buildCombinations).reduce(stringCombinations, ['']);
    }
    else if (node.type === 'mandatory_block') {
        return node.items.flatMap(buildCombinations);
    }
    else if (node.type === 'optional_block') {
        return ['', ...node.items.flatMap(buildCombinations)];
    }
    else {
        throw new Error(`Unknown node type: ${node}`);
    }
};
const stringCombinations = (xs, ys) => {
    const results = [];
    for (const x of xs) {
        for (const y of ys) {
            results.push(x + y);
        }
    }
    return results;
};
//# sourceMappingURL=expandPhrases.js.map