"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.n1ql = void 0;
const expandPhrases_js_1 = require("../../expandPhrases.js");
const n1ql_functions_js_1 = require("./n1ql.functions.js");
const n1ql_keywords_js_1 = require("./n1ql.keywords.js");
const reservedSelect = (0, expandPhrases_js_1.expandPhrases)(['SELECT [ALL | DISTINCT]']);
const reservedClauses = (0, expandPhrases_js_1.expandPhrases)([
    // queries
    'WITH',
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
    'INSERT INTO',
    'VALUES',
    // - update:
    'SET',
    // - merge:
    'MERGE INTO',
    'WHEN [NOT] MATCHED THEN',
    'UPDATE SET',
    'INSERT',
    // other
    'NEST',
    'UNNEST',
    'RETURNING',
]);
const onelineClauses = (0, expandPhrases_js_1.expandPhrases)([
    // - update:
    'UPDATE',
    // - delete:
    'DELETE FROM',
    // - set schema:
    'SET SCHEMA',
    // https://docs.couchbase.com/server/current/n1ql/n1ql-language-reference/reservedwords.html
    'ADVISE',
    'ALTER INDEX',
    'BEGIN TRANSACTION',
    'BUILD INDEX',
    'COMMIT TRANSACTION',
    'CREATE COLLECTION',
    'CREATE FUNCTION',
    'CREATE INDEX',
    'CREATE PRIMARY INDEX',
    'CREATE SCOPE',
    'DROP COLLECTION',
    'DROP FUNCTION',
    'DROP INDEX',
    'DROP PRIMARY INDEX',
    'DROP SCOPE',
    'EXECUTE',
    'EXECUTE FUNCTION',
    'EXPLAIN',
    'GRANT',
    'INFER',
    'PREPARE',
    'REVOKE',
    'ROLLBACK TRANSACTION',
    'SAVEPOINT',
    'SET TRANSACTION',
    'UPDATE STATISTICS',
    'UPSERT',
    // other
    'LET',
    'SET CURRENT SCHEMA',
    'SHOW',
    'USE [PRIMARY] KEYS',
]);
const reservedSetOperations = (0, expandPhrases_js_1.expandPhrases)(['UNION [ALL]', 'EXCEPT [ALL]', 'INTERSECT [ALL]']);
const reservedJoins = (0, expandPhrases_js_1.expandPhrases)(['JOIN', '{LEFT | RIGHT} [OUTER] JOIN', 'INNER JOIN']);
const reservedKeywordPhrases = (0, expandPhrases_js_1.expandPhrases)(['{ROWS | RANGE | GROUPS} BETWEEN']);
const reservedDataTypePhrases = (0, expandPhrases_js_1.expandPhrases)([]);
// For reference: http://docs.couchbase.com.s3-website-us-west-1.amazonaws.com/server/6.0/n1ql/n1ql-language-reference/index.html
exports.n1ql = {
    name: 'n1ql',
    tokenizerOptions: {
        reservedSelect,
        reservedClauses: [...reservedClauses, ...onelineClauses],
        reservedSetOperations,
        reservedJoins,
        reservedKeywordPhrases,
        reservedDataTypePhrases,
        supportsXor: true,
        reservedKeywords: n1ql_keywords_js_1.keywords,
        reservedDataTypes: n1ql_keywords_js_1.dataTypes,
        reservedFunctionNames: n1ql_functions_js_1.functions,
        // NOTE: single quotes are actually not supported in N1QL,
        // but we support them anyway as all other SQL dialects do,
        // which simplifies writing tests that are shared between all dialects.
        stringTypes: ['""-bs', "''-bs"],
        identTypes: ['``'],
        extraParens: ['[]', '{}'],
        paramTypes: { positional: true, numbered: ['$'], named: ['$'] },
        lineCommentTypes: ['#', '--'],
        operators: ['%', '==', ':', '||'],
    },
    formatOptions: {
        onelineClauses,
    },
};
//# sourceMappingURL=n1ql.formatter.js.map