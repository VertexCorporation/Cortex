var __rest = (this && this.__rest) || function (s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0)
        t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function")
        for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
            if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i]))
                t[p[i]] = s[p[i]];
        }
    return t;
};
import * as allDialects from './allDialects.js';
import { createDialect } from './dialect.js';
import Formatter from './formatter/Formatter.js';
import { ConfigError, validateConfig } from './validateConfig.js';
const dialectNameMap = {
    bigquery: 'bigquery',
    clickhouse: 'clickhouse',
    db2: 'db2',
    db2i: 'db2i',
    duckdb: 'duckdb',
    hive: 'hive',
    mariadb: 'mariadb',
    mysql: 'mysql',
    n1ql: 'n1ql',
    plsql: 'plsql',
    postgresql: 'postgresql',
    redshift: 'redshift',
    spark: 'spark',
    sqlite: 'sqlite',
    sql: 'sql',
    tidb: 'tidb',
    trino: 'trino',
    transactsql: 'transactsql',
    tsql: 'transactsql',
    singlestoredb: 'singlestoredb',
    snowflake: 'snowflake',
};
export const supportedDialects = Object.keys(dialectNameMap);
const defaultOptions = {
    tabWidth: 2,
    useTabs: false,
    keywordCase: 'preserve',
    identifierCase: 'preserve',
    dataTypeCase: 'preserve',
    functionCase: 'preserve',
    indentStyle: 'standard',
    logicalOperatorNewline: 'before',
    expressionWidth: 50,
    linesBetweenQueries: 1,
    denseOperators: false,
    newlineBeforeSemicolon: false,
};
/**
 * Format whitespace in a query to make it easier to read.
 *
 * @param {string} query - input SQL query string
 * @param {FormatOptionsWithLanguage} cfg Configuration options (see docs in README)
 * @return {string} formatted query
 */
export const format = (query, cfg = {}) => {
    if (typeof cfg.language === 'string' && !supportedDialects.includes(cfg.language)) {
        throw new ConfigError(`Unsupported SQL dialect: ${cfg.language}`);
    }
    const canonicalDialectName = dialectNameMap[cfg.language || 'sql'];
    return formatDialect(query, Object.assign(Object.assign({}, cfg), { dialect: allDialects[canonicalDialectName] }));
};
/**
 * Like the above format(), but language parameter is mandatory
 * and must be a Dialect object instead of a string.
 *
 * @param {string} query - input SQL query string
 * @param {FormatOptionsWithDialect} cfg Configuration options (see docs in README)
 * @return {string} formatted query
 */
export const formatDialect = (query, _a) => {
    var { dialect } = _a, cfg = __rest(_a, ["dialect"]);
    if (typeof query !== 'string') {
        throw new Error('Invalid query argument. Expected string, instead got ' + typeof query);
    }
    const options = validateConfig(Object.assign(Object.assign({}, defaultOptions), cfg));
    return new Formatter(createDialect(dialect), options).format(query);
};
//# sourceMappingURL=sqlFormatter.js.map