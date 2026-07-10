import Tokenizer from './lexer/Tokenizer.js';
const cache = new Map();
/**
 * Factory function for building Dialect objects.
 * When called repeatedly with same options object returns the cached Dialect,
 * to avoid the cost of creating it again.
 */
export const createDialect = (options) => {
    let dialect = cache.get(options);
    if (!dialect) {
        dialect = dialectFromOptions(options);
        cache.set(options, dialect);
    }
    return dialect;
};
const dialectFromOptions = (dialectOptions) => ({
    tokenizer: new Tokenizer(dialectOptions.tokenizerOptions, dialectOptions.name),
    formatOptions: processDialectFormatOptions(dialectOptions),
});
const processDialectFormatOptions = ({ tokenizerOptions, formatOptions: options, }) => {
    var _a, _b;
    return ({
        alwaysDenseOperators: options.alwaysDenseOperators || [],
        onelineClauses: Object.fromEntries(options.onelineClauses.map(name => [name, true])),
        tabularOnelineClauses: Object.fromEntries(((_a = options.tabularOnelineClauses) !== null && _a !== void 0 ? _a : options.onelineClauses).map(name => [name, true])),
        identifierDashes: Boolean((_b = tokenizerOptions.identChars) === null || _b === void 0 ? void 0 : _b.dashes),
    });
};
//# sourceMappingURL=dialect.js.map