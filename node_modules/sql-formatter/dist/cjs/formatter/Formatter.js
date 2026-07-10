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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const config_js_1 = require("./config.js");
const Params_js_1 = __importDefault(require("./Params.js"));
const createParser_js_1 = require("../parser/createParser.js");
const ExpressionFormatter_js_1 = __importDefault(require("./ExpressionFormatter.js"));
const Layout_js_1 = __importStar(require("./Layout.js"));
const Indentation_js_1 = __importDefault(require("./Indentation.js"));
/** Main formatter class that produces a final output string from list of tokens */
class Formatter {
    constructor(dialect, cfg) {
        this.dialect = dialect;
        this.cfg = cfg;
        this.params = new Params_js_1.default(this.cfg.params);
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
        return (0, createParser_js_1.createParser)(this.dialect.tokenizer).parse(query, this.cfg.paramTypes || {});
    }
    formatAst(statements) {
        return statements
            .map(stat => this.formatStatement(stat))
            .join('\n'.repeat(this.cfg.linesBetweenQueries + 1));
    }
    formatStatement(statement) {
        const layout = new ExpressionFormatter_js_1.default({
            cfg: this.cfg,
            dialectCfg: this.dialect.formatOptions,
            params: this.params,
            layout: new Layout_js_1.default(new Indentation_js_1.default((0, config_js_1.indentString)(this.cfg))),
        }).format(statement.children);
        if (!statement.hasSemicolon) {
            // do nothing
        }
        else if (this.cfg.newlineBeforeSemicolon) {
            layout.add(Layout_js_1.WS.NEWLINE, ';');
        }
        else {
            layout.add(Layout_js_1.WS.NO_NEWLINE, ';');
        }
        return layout.toString();
    }
}
exports.default = Formatter;
//# sourceMappingURL=Formatter.js.map