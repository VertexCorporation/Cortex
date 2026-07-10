"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.redshift = void 0;
const expandPhrases_js_1 = require("../../expandPhrases.js");
const redshift_functions_js_1 = require("./redshift.functions.js");
const redshift_keywords_js_1 = require("./redshift.keywords.js");
const reservedSelect = (0, expandPhrases_js_1.expandPhrases)(['SELECT [ALL | DISTINCT]']);
const reservedClauses = (0, expandPhrases_js_1.expandPhrases)([
    // queries
    'WITH [RECURSIVE]',
    'FROM',
    'WHERE',
    'GROUP BY',
    'HAVING',
    'QUALIFY',
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
]);
const standardOnelineClauses = (0, expandPhrases_js_1.expandPhrases)([
    'CREATE [TEMPORARY | TEMP | LOCAL TEMPORARY | LOCAL TEMP] TABLE [IF NOT EXISTS]',
]);
const tabularOnelineClauses = (0, expandPhrases_js_1.expandPhrases)([
    // - create:
    'CREATE [OR REPLACE | MATERIALIZED] VIEW',
    // - update:
    'UPDATE',
    // - delete:
    'DELETE [FROM]',
    // - drop table:
    'DROP TABLE [IF EXISTS]',
    // - alter table:
    'ALTER TABLE',
    'ALTER TABLE APPEND',
    'ADD [COLUMN]',
    'DROP [COLUMN]',
    'RENAME TO',
    'RENAME COLUMN',
    'ALTER COLUMN',
    'TYPE',
    'ENCODE',
    // - truncate:
    'TRUNCATE [TABLE]',
    // https://docs.aws.amazon.com/redshift/latest/dg/c_SQL_commands.html
    'ABORT',
    'ALTER DATABASE',
    'ALTER DATASHARE',
    'ALTER DEFAULT PRIVILEGES',
    'ALTER GROUP',
    'ALTER MATERIALIZED VIEW',
    'ALTER PROCEDURE',
    'ALTER SCHEMA',
    'ALTER USER',
    'ANALYSE',
    'ANALYZE',
    'ANALYSE COMPRESSION',
    'ANALYZE COMPRESSION',
    'BEGIN',
    'CALL',
    'CANCEL',
    'CLOSE',
    'COMMIT',
    'COPY',
    'CREATE DATABASE',
    'CREATE DATASHARE',
    'CREATE EXTERNAL FUNCTION',
    'CREATE EXTERNAL SCHEMA',
    'CREATE EXTERNAL TABLE',
    'CREATE FUNCTION',
    'CREATE GROUP',
    'CREATE LIBRARY',
    'CREATE MODEL',
    'CREATE PROCEDURE',
    'CREATE SCHEMA',
    'CREATE USER',
    'DEALLOCATE',
    'DECLARE',
    'DESC DATASHARE',
    'DROP DATABASE',
    'DROP DATASHARE',
    'DROP FUNCTION',
    'DROP GROUP',
    'DROP LIBRARY',
    'DROP MODEL',
    'DROP MATERIALIZED VIEW',
    'DROP PROCEDURE',
    'DROP SCHEMA',
    'DROP USER',
    'DROP VIEW',
    'DROP',
    'EXECUTE',
    'EXPLAIN',
    'FETCH',
    'GRANT',
    'LOCK',
    'PREPARE',
    'REFRESH MATERIALIZED VIEW',
    'RESET',
    'REVOKE',
    'ROLLBACK',
    'SELECT INTO',
    'SET SESSION AUTHORIZATION',
    'SET SESSION CHARACTERISTICS',
    'SHOW',
    'SHOW EXTERNAL TABLE',
    'SHOW MODEL',
    'SHOW DATASHARES',
    'SHOW PROCEDURE',
    'SHOW TABLE',
    'SHOW VIEW',
    'START TRANSACTION',
    'UNLOAD',
    'VACUUM',
]);
const reservedSetOperations = (0, expandPhrases_js_1.expandPhrases)(['UNION [ALL]', 'EXCEPT', 'INTERSECT', 'MINUS']);
const reservedJoins = (0, expandPhrases_js_1.expandPhrases)([
    'JOIN',
    '{LEFT | RIGHT | FULL} [OUTER] JOIN',
    '{INNER | CROSS} JOIN',
    'NATURAL [INNER] JOIN',
    'NATURAL {LEFT | RIGHT | FULL} [OUTER] JOIN',
]);
const reservedKeywordPhrases = (0, expandPhrases_js_1.expandPhrases)([
    // https://docs.aws.amazon.com/redshift/latest/dg/copy-parameters-data-conversion.html
    'NULL AS',
    // https://docs.aws.amazon.com/redshift/latest/dg/r_CREATE_EXTERNAL_SCHEMA.html
    'DATA CATALOG',
    'HIVE METASTORE',
    // in window specifications
    '{ROWS | RANGE} BETWEEN',
]);
const reservedDataTypePhrases = (0, expandPhrases_js_1.expandPhrases)([]);
// https://docs.aws.amazon.com/redshift/latest/dg/cm_chap_SQLCommandRef.html
exports.redshift = {
    name: 'redshift',
    tokenizerOptions: {
        reservedSelect,
        reservedClauses: [...reservedClauses, ...standardOnelineClauses, ...tabularOnelineClauses],
        reservedSetOperations,
        reservedJoins,
        reservedKeywordPhrases,
        reservedDataTypePhrases,
        reservedKeywords: redshift_keywords_js_1.keywords,
        reservedDataTypes: redshift_keywords_js_1.dataTypes,
        reservedFunctionNames: redshift_functions_js_1.functions,
        extraParens: ['[]'],
        stringTypes: ["''-qq"],
        identTypes: [`""-qq`],
        identChars: { first: '#' },
        paramTypes: { numbered: ['$'] },
        operators: [
            '^',
            '%',
            '@',
            '|/',
            '||/',
            '&',
            '|',
            // '#', conflicts with first char of identifier
            '~',
            '<<',
            '>>',
            '||',
            '::',
        ],
    },
    formatOptions: {
        alwaysDenseOperators: ['::'],
        onelineClauses: [...standardOnelineClauses, ...tabularOnelineClauses],
        tabularOnelineClauses,
    },
};
//# sourceMappingURL=redshift.formatter.js.map