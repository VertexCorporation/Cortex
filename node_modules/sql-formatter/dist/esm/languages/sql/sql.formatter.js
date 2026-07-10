import { expandPhrases } from '../../expandPhrases.js';
import { functions } from './sql.functions.js';
import { dataTypes, keywords } from './sql.keywords.js';
const reservedSelect = expandPhrases(['SELECT [ALL | DISTINCT]']);
const reservedClauses = expandPhrases([
    // queries
    'WITH [RECURSIVE]',
    'FROM',
    'WHERE',
    'GROUP BY [ALL | DISTINCT]',
    'HAVING',
    'WINDOW',
    'PARTITION BY',
    'ORDER BY',
    'LIMIT',
    'OFFSET',
    'FETCH {FIRST | NEXT}',
    // Data manipulation
    // - insert:
    'INSERT INTO',
    'VALUES',
    // - update:
    'SET',
]);
const standardOnelineClauses = expandPhrases(['CREATE [GLOBAL TEMPORARY | LOCAL TEMPORARY] TABLE']);
const tabularOnelineClauses = expandPhrases([
    // - create:
    'CREATE [RECURSIVE] VIEW',
    // - update:
    'UPDATE',
    'WHERE CURRENT OF',
    // - delete:
    'DELETE FROM',
    // - drop table:
    'DROP TABLE',
    // - alter table:
    'ALTER TABLE',
    'ADD COLUMN',
    'DROP [COLUMN]',
    'RENAME COLUMN',
    'RENAME TO',
    'ALTER [COLUMN]',
    '{SET | DROP} DEFAULT',
    'ADD SCOPE',
    'DROP SCOPE {CASCADE | RESTRICT}',
    'RESTART WITH',
    // - truncate:
    'TRUNCATE TABLE',
    // other
    'SET SCHEMA',
]);
const reservedSetOperations = expandPhrases([
    'UNION [ALL | DISTINCT]',
    'EXCEPT [ALL | DISTINCT]',
    'INTERSECT [ALL | DISTINCT]',
]);
const reservedJoins = expandPhrases([
    'JOIN',
    '{LEFT | RIGHT | FULL} [OUTER] JOIN',
    '{INNER | CROSS} JOIN',
    'NATURAL [INNER] JOIN',
    'NATURAL {LEFT | RIGHT | FULL} [OUTER] JOIN',
]);
const reservedKeywordPhrases = expandPhrases([
    'ON {UPDATE | DELETE} [SET NULL | SET DEFAULT]',
    '{ROWS | RANGE} BETWEEN',
]);
const reservedDataTypePhrases = expandPhrases([]);
export const sql = {
    name: 'sql',
    tokenizerOptions: {
        reservedSelect,
        reservedClauses: [...reservedClauses, ...standardOnelineClauses, ...tabularOnelineClauses],
        reservedSetOperations,
        reservedJoins,
        reservedKeywordPhrases,
        reservedDataTypePhrases,
        reservedKeywords: keywords,
        reservedDataTypes: dataTypes,
        reservedFunctionNames: functions,
        stringTypes: [
            { quote: "''-qq-bs", prefixes: ['N', 'U&'] },
            { quote: "''-raw", prefixes: ['X'], requirePrefix: true },
        ],
        identTypes: [`""-qq`, '``'],
        paramTypes: { positional: true },
        operators: ['||'],
    },
    formatOptions: {
        onelineClauses: [...standardOnelineClauses, ...tabularOnelineClauses],
        tabularOnelineClauses,
    },
};
//# sourceMappingURL=sql.formatter.js.map