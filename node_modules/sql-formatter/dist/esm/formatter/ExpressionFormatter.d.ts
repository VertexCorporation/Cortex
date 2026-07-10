import { FormatOptions } from '../FormatOptions.js';
import Params from './Params.js';
import { AstNode } from '../parser/ast.js';
import Layout from './Layout.js';
interface ExpressionFormatterParams {
    cfg: FormatOptions;
    dialectCfg: ProcessedDialectFormatOptions;
    params: Params;
    layout: Layout;
    inline?: boolean;
}
export interface DialectFormatOptions {
    alwaysDenseOperators?: string[];
    onelineClauses: string[];
    tabularOnelineClauses?: string[];
}
export interface ProcessedDialectFormatOptions {
    alwaysDenseOperators: string[];
    onelineClauses: Record<string, boolean>;
    tabularOnelineClauses: Record<string, boolean>;
    identifierDashes: boolean;
}
/** Formats a generic SQL expression */
export default class ExpressionFormatter {
    private cfg;
    private dialectCfg;
    private params;
    private layout;
    private inline;
    private nodes;
    private index;
    constructor({ cfg, dialectCfg, params, layout, inline }: ExpressionFormatterParams);
    format(nodes: AstNode[]): Layout;
    private formatNode;
    private formatNodeWithoutComments;
    private formatFunctionCall;
    private formatParameterizedDataType;
    private formatArraySubscript;
    private formatPropertyAccess;
    private formatParenthesis;
    private formatBetweenPredicate;
    private formatCaseExpression;
    private formatCaseWhen;
    private formatCaseElse;
    private formatClause;
    private isOnelineClause;
    private formatClauseInIndentedStyle;
    private formatClauseInOnelineStyle;
    private formatClauseInTabularStyle;
    private formatSetOperation;
    private formatLimitClause;
    private formatAllColumnsAsterisk;
    private formatLiteral;
    private formatIdentifier;
    private formatParameter;
    private formatOperator;
    private formatComma;
    private withComments;
    private formatComments;
    private formatLineComment;
    private formatBlockComment;
    private isStandaloneBlockComment;
    private isDocComment;
    private splitBlockComment;
    private formatSubExpression;
    private formatInlineExpression;
    private formatKeywordNode;
    private formatJoin;
    private formatKeyword;
    private formatLogicalOperator;
    private formatDataType;
    private showKw;
    private showNonTabularKw;
    private showFunctionKw;
    private showNonTabularFunctionKw;
    private showIdentifier;
    private showDataType;
}
export {};
