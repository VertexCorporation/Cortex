"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.createParser = void 0;
const nearley_1 = __importDefault(require("nearley"));
const disambiguateTokens_js_1 = require("../lexer/disambiguateTokens.js");
const grammar_js_1 = __importDefault(require("./grammar.js"));
const LexerAdapter_js_1 = __importDefault(require("./LexerAdapter.js"));
const token_js_1 = require("../lexer/token.js");
const { Parser: NearleyParser, Grammar } = nearley_1.default;
/**
 * Creates a parser object which wraps the setup of Nearley parser
 */
function createParser(tokenizer) {
    let paramTypesOverrides = {};
    const lexer = new LexerAdapter_js_1.default(chunk => [
        ...(0, disambiguateTokens_js_1.disambiguateTokens)(tokenizer.tokenize(chunk, paramTypesOverrides)),
        (0, token_js_1.createEofToken)(chunk.length),
    ]);
    const parser = new NearleyParser(Grammar.fromCompiled(grammar_js_1.default), { lexer });
    return {
        parse: (sql, paramTypes) => {
            // share paramTypesOverrides with Tokenizer
            paramTypesOverrides = paramTypes;
            const { results } = parser.feed(sql);
            if (results.length === 1) {
                return results[0];
            }
            else if (results.length === 0) {
                // Ideally we would report a line number where the parser failed,
                // but I haven't found a way to get this info from Nearley :(
                throw new Error('Parse error: Invalid SQL');
            }
            else {
                throw new Error(`Parse error: Ambiguous grammar\n${JSON.stringify(results, undefined, 2)}`);
            }
        },
    };
}
exports.createParser = createParser;
//# sourceMappingURL=createParser.js.map