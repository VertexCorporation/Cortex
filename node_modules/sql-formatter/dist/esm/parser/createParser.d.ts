import Tokenizer from '../lexer/Tokenizer.js';
import { ParamTypes } from '../lexer/TokenizerOptions.js';
import { StatementNode } from './ast.js';
export interface Parser {
    parse(sql: string, paramTypesOverrides: ParamTypes): StatementNode[];
}
/**
 * Creates a parser object which wraps the setup of Nearley parser
 */
export declare function createParser(tokenizer: Tokenizer): Parser;
