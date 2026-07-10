"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.sqlite = void 0;
const expandPhrases_js_1 = require("../../expandPhrases.js");
const sqlite_functions_js_1 = require("./sqlite.functions.js");
const sqlite_keywords_js_1 = require("./sqlite.keywords.js");
const reservedSelect = (0, expandPhrases_js_1.expandPhrases)(['SELECT [ALL | DISTINCT]']);
const reservedClauses = (0, expandPhrases_js_1.expandPhrases)([
    // queries
    'WITH [RECURSIVE]',
    'FROM',
    'WHERE',
    'GROUP BY',
    'HAVING',
    'WINDOW',
    'PARTITION BY',
    'ORDER BY',
    'LIMIT',
    'OFFSET',
    // Data manipulation
    // - insert:
    'INSERT [OR ABORT | OR FAIL | OR IGNORE | OR REPLACE | OR ROLLBACK] INTO',
    'REPLACE INTO',
    'VALUES',
    // - update:
    'SET',
    // other:
    'RETURNING',
]);
const standardOnelineClauses = (0, expandPhrases_js_1.expandPhrases)(['CREATE [TEMPORARY | TEMP] TABLE [IF NOT EXISTS]']);
const tabularOnelineClauses = (0, expandPhrases_js_1.expandPhrases)([
    // - create:
    'CREATE [TEMPORARY | TEMP] VIEW [IF NOT EXISTS]',
    // - update:
    'UPDATE [OR ABORT | OR FAIL | OR IGNORE | OR REPLACE | OR ROLLBACK]',
    // - insert:
    'ON CONFLICT',
    // - delete:
    'DELETE FROM',
    // - drop table:
    'DROP TABLE [IF EXISTS]',
    // - alter table:
    'ALTER TABLE',
    'ADD [COLUMN]',
    'DROP [COLUMN]',
    'RENAME [COLUMN]',
    'RENAME TO',
    // - set schema
    'SET SCHEMA',
]);
const reservedSetOperations = (0, expandPhrases_js_1.expandPhrases)(['UNION [ALL]', 'EXCEPT', 'INTERSECT']);
// joins - https://www.sqlite.org/syntax/join-operator.html
const reservedJoins = (0, expandPhrases_js_1.expandPhrases)([
    'JOIN',
    '{LEFT | RIGHT | FULL} [OUTER] JOIN',
    '{INNER | CROSS} JOIN',
    'NATURAL [INNER] JOIN',
    'NATURAL {LEFT | RIGHT | FULL} [OUTER] JOIN',
]);
const reservedKeywordPhrases = (0, expandPhrases_js_1.expandPhrases)([
    'ON {UPDATE | DELETE} [SET NULL | SET DEFAULT]',
    '{ROWS | RANGE | GROUPS} BETWEEN',
    'DO UPDATE',
]);
const reservedDataTypePhrases = (0, expandPhrases_js_1.expandPhrases)([]);
exports.sqlite = {
    name: 'sqlite',
    tokenizerOptions: {
        reservedSelect,
        reservedClauses: [...reservedClauses, ...standardOnelineClauses, ...tabularOnelineClauses],
        reservedSetOperations,
        reservedJoins,
        reservedKeywordPhrases,
        reservedDataTypePhrases,
        reservedKeywords: sqlite_keywords_js_1.keywords,
        reservedDataTypes: sqlite_keywords_js_1.dataTypes,
        reservedFunctionNames: sqlite_functions_js_1.functions,
        stringTypes: [
            "''-qq",
            { quote: "''-raw", prefixes: ['X'], requirePrefix: true },
            // Depending on context SQLite also supports double-quotes for strings,
            // and single-quotes for identifiers.
        ],
        identTypes: [`""-qq`, '``', '[]'],
        // https://www.sqlite.org/lang_expr.html#parameters
        // Note: the $-prefixed form follows Tcl variable syntax and may include
        // one or more "::"-separated suffixes and an optional "(...)" trailer.
        paramTypes: {
            positional: true,
            numbered: ['?'],
            named: [':', '@'],
            custom: [
                {
                    regex: String.raw `\$[a-zA-Z_][a-zA-Z0-9_]*(?:::[a-zA-Z_][a-zA-Z0-9_]*)*(?:\([^)]*\))?`,
                    key: v => v.slice(1),
                },
            ],
        },
        operators: ['%', '~', '&', '|', '<<', '>>', '==', '->', '->>', '||'],
    },
    formatOptions: {
        onelineClauses: [...standardOnelineClauses, ...tabularOnelineClauses],
        tabularOnelineClauses,
    },
};
//# sourceMappingURL=sqlite.formatter.js.map