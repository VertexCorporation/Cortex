"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || function (mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (k !== "default" && Object.prototype.hasOwnProperty.call(mod, k)) __createBinding(result, mod, k);
    __setModuleDefault(result, mod);
    return result;
};
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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatDialect = exports.format = exports.supportedDialects = void 0;
const allDialects = __importStar(require("./allDialects.js"));
const dialect_js_1 = require("./dialect.js");
const Formatter_js_1 = __importDefault(require("./formatter/Formatter.js"));
const validateConfig_js_1 = require("./validateConfig.js");
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
exports.supportedDialects = Object.keys(dialectNameMap);
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
const format = (query, cfg = {}) => {
    if (typeof cfg.language === 'string' && !exports.supportedDialects.includes(cfg.language)) {
        throw new validateConfig_js_1.ConfigError(`Unsupported SQL dialect: ${cfg.language}`);
    }
    const canonicalDialectName = dialectNameMap[cfg.language || 'sql'];
    return (0, exports.formatDialect)(query, Object.assign(Object.assign({}, cfg), { dialect: allDialects[canonicalDialectName] }));
};
exports.format = format;
/**
 * Like the above format(), but language parameter is mandatory
 * and must be a Dialect object instead of a string.
 *
 * @param {string} query - input SQL query string
 * @param {FormatOptionsWithDialect} cfg Configuration options (see docs in README)
 * @return {string} formatted query
 */
const formatDialect = (query, _a) => {
    var { dialect } = _a, cfg = __rest(_a, ["dialect"]);
    if (typeof query !== 'string') {
        throw new Error('Invalid query argument. Expected string, instead got ' + typeof query);
    }
    const options = (0, validateConfig_js_1.validateConfig)(Object.assign(Object.assign({}, defaultOptions), cfg));
    return new Formatter_js_1.default((0, dialect_js_1.createDialect)(dialect), options).format(query);
};
exports.formatDialect = formatDialect;
//# sourceMappingURL=sqlFormatter.js.map