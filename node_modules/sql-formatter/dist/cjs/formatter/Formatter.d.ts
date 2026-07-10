import { FormatOptions } from '../FormatOptions.js';
import { Dialect } from '../dialect.js';
/** Main formatter class that produces a final output string from list of tokens */
export default class Formatter {
    private dialect;
    private cfg;
    private params;
    constructor(dialect: Dialect, cfg: FormatOptions);
    /**
     * Formats an SQL query.
     * @param {string} query - The SQL query string to be formatted
     * @return {string} The formatter query
     */
    format(query: string): string;
    private parse;
    private formatAst;
    private formatStatement;
}
