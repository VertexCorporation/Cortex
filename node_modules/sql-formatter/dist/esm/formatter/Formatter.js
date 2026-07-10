import { indentString } from './config.js';
import Params from './Params.js';
import { createParser } from '../parser/createParser.js';
import ExpressionFormatter from './ExpressionFormatter.js';
import Layout, { WS } from './Layout.js';
import Indentation from './Indentation.js';
/** Main formatter class that produces a final output string from list of tokens */
export default class Formatter {
    constructor(dialect, cfg) {
        this.dialect = dialect;
        this.cfg = cfg;
        this.params = new Params(this.cfg.params);
    }
    /**
     * Formats an SQL query.
     * @param {string} query - The SQL query string to be formatted
     * @return {string} The formatter query
     */
    format(query) {
        const ast = this.parse(query);
        const formattedQuery = this.formatAst(ast);
        return formattedQuery.trimEnd();
    }
    parse(query) {
        return createParser(this.dialect.tokenizer).parse(query, this.cfg.paramTypes || {});
    }
    formatAst(statements) {
        return statements
            .map(stat => this.formatStatement(stat))
            .join('\n'.repeat(this.cfg.linesBetweenQueries + 1));
    }
    formatStatement(statement) {
        const layout = new ExpressionFormatter({
            cfg: this.cfg,
            dialectCfg: this.dialect.formatOptions,
            params: this.params,
            layout: new Layout(new Indentation(indentString(this.cfg))),
        }).format(statement.children);
        if (!statement.hasSemicolon) {
            // do nothing
        }
        else if (this.cfg.newlineBeforeSemicolon) {
            layout.add(WS.NEWLINE, ';');
        }
        else {
            layout.add(WS.NO_NEWLINE, ';');
        }
        return layout.toString();
    }
}
//# sourceMappingURL=Formatter.js.map