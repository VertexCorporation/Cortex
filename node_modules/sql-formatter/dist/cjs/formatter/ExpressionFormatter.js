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
Object.defineProperty(exports, "__esModule", { value: true });
const utils_js_1 = require("../utils.js");
const config_js_1 = require("./config.js");
const token_js_1 = require("../lexer/token.js");
const ast_js_1 = require("../parser/ast.js");
const Layout_js_1 = require("./Layout.js");
const tabularStyle_js_1 = __importStar(require("./tabularStyle.js"));
const InlineLayout_js_1 = __importStar(require("./InlineLayout.js"));
/** Formats a generic SQL expression */
class ExpressionFormatter {
    constructor({ cfg, dialectCfg, params, layout, inline = false }) {
        this.inline = false;
        this.nodes = [];
        this.index = -1;
        this.cfg = cfg;
        this.dialectCfg = dialectCfg;
        this.inline = inline;
        this.params = params;
        this.layout = layout;
    }
    format(nodes) {
        this.nodes = nodes;
        for (this.index = 0; this.index < this.nodes.length; this.index++) {
            this.formatNode(this.nodes[this.index]);
        }
        return this.layout;
    }
    formatNode(node) {
        this.formatComments(node.leadingComments);
        this.formatNodeWithoutComments(node);
        this.formatComments(node.trailingComments);
    }
    formatNodeWithoutComments(node) {
        switch (node.type) {
            case ast_js_1.NodeType.function_call:
                return this.formatFunctionCall(node);
            case ast_js_1.NodeType.parameterized_data_type:
                return this.formatParameterizedDataType(node);
            case ast_js_1.NodeType.array_subscript:
                return this.formatArraySubscript(node);
            case ast_js_1.NodeType.property_access:
                return this.formatPropertyAccess(node);
            case ast_js_1.NodeType.parenthesis:
                return this.formatParenthesis(node);
            case ast_js_1.NodeType.between_predicate:
                return this.formatBetweenPredicate(node);
            case ast_js_1.NodeType.case_expression:
                return this.formatCaseExpression(node);
            case ast_js_1.NodeType.case_when:
                return this.formatCaseWhen(node);
            case ast_js_1.NodeType.case_else:
                return this.formatCaseElse(node);
            case ast_js_1.NodeType.clause:
                return this.formatClause(node);
            case ast_js_1.NodeType.set_operation:
                return this.formatSetOperation(node);
            case ast_js_1.NodeType.limit_clause:
                return this.formatLimitClause(node);
            case ast_js_1.NodeType.all_columns_asterisk:
                return this.formatAllColumnsAsterisk(node);
            case ast_js_1.NodeType.literal:
                return this.formatLiteral(node);
            case ast_js_1.NodeType.identifier:
                return this.formatIdentifier(node);
            case ast_js_1.NodeType.parameter:
                return this.formatParameter(node);
            case ast_js_1.NodeType.operator:
                return this.formatOperator(node);
            case ast_js_1.NodeType.comma:
                return this.formatComma(node);
            case ast_js_1.NodeType.line_comment:
                return this.formatLineComment(node);
            case ast_js_1.NodeType.block_comment:
                return this.formatBlockComment(node);
            case ast_js_1.NodeType.disable_comment:
                return this.formatBlockComment(node);
            case ast_js_1.NodeType.data_type:
                return this.formatDataType(node);
            case ast_js_1.NodeType.keyword:
                return this.formatKeywordNode(node);
        }
    }
    formatFunctionCall(node) {
        this.withComments(node.nameKw, () => {
            this.layout.add(this.showFunctionKw(node.nameKw));
        });
        this.formatNode(node.parenthesis);
    }
    formatParameterizedDataType(node) {
        this.withComments(node.dataType, () => {
            this.layout.add(this.showDataType(node.dataType));
        });
        this.formatNode(node.parenthesis);
    }
    formatArraySubscript(node) {
        let formattedArray;
        switch (node.array.type) {
            case ast_js_1.NodeType.data_type:
                formattedArray = this.showDataType(node.array);
                break;
            case ast_js_1.NodeType.keyword:
                formattedArray = this.showKw(node.array);
                break;
            default:
                formattedArray = this.showIdentifier(node.array);
                break;
        }
        this.withComments(node.array, () => {
            this.layout.add(formattedArray);
        });
        this.formatNode(node.parenthesis);
    }
    formatPropertyAccess(node) {
        this.formatNode(node.object);
        this.layout.add(Layout_js_1.WS.NO_SPACE, node.operator);
        this.formatNode(node.property);
    }
    formatParenthesis(node) {
        const inlineLayout = this.formatInlineExpression(node.children);
        if (inlineLayout) {
            this.layout.add(node.openParen);
            this.layout.add(...inlineLayout.getLayoutItems());
            this.layout.add(Layout_js_1.WS.NO_SPACE, node.closeParen, Layout_js_1.WS.SPACE);
        }
        else {
            this.layout.add(node.openParen, Layout_js_1.WS.NEWLINE);
            if ((0, config_js_1.isTabularStyle)(this.cfg)) {
                this.layout.add(Layout_js_1.WS.INDENT);
                this.layout = this.formatSubExpression(node.children);
            }
            else {
                this.layout.indentation.increaseBlockLevel();
                this.layout.add(Layout_js_1.WS.INDENT);
                this.layout = this.formatSubExpression(node.children);
                this.layout.indentation.decreaseBlockLevel();
            }
            this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT, node.closeParen, Layout_js_1.WS.SPACE);
        }
    }
    formatBetweenPredicate(node) {
        this.layout.add(this.showKw(node.betweenKw), Layout_js_1.WS.SPACE);
        this.layout = this.formatSubExpression(node.expr1);
        this.layout.add(Layout_js_1.WS.NO_SPACE, Layout_js_1.WS.SPACE, this.showNonTabularKw(node.andKw), Layout_js_1.WS.SPACE);
        this.layout = this.formatSubExpression(node.expr2);
        this.layout.add(Layout_js_1.WS.SPACE);
    }
    formatCaseExpression(node) {
        this.formatNode(node.caseKw);
        this.layout.indentation.increaseBlockLevel();
        this.layout = this.formatSubExpression(node.expr);
        this.layout = this.formatSubExpression(node.clauses);
        this.layout.indentation.decreaseBlockLevel();
        this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT);
        this.formatNode(node.endKw);
    }
    formatCaseWhen(node) {
        this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT);
        this.formatNode(node.whenKw);
        this.layout = this.formatSubExpression(node.condition);
        this.formatNode(node.thenKw);
        this.layout = this.formatSubExpression(node.result);
    }
    formatCaseElse(node) {
        this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT);
        this.formatNode(node.elseKw);
        this.layout = this.formatSubExpression(node.result);
    }
    formatClause(node) {
        if (this.isOnelineClause(node)) {
            this.formatClauseInOnelineStyle(node);
        }
        else if ((0, config_js_1.isTabularStyle)(this.cfg)) {
            this.formatClauseInTabularStyle(node);
        }
        else {
            this.formatClauseInIndentedStyle(node);
        }
    }
    isOnelineClause(node) {
        if ((0, config_js_1.isTabularStyle)(this.cfg)) {
            return this.dialectCfg.tabularOnelineClauses[node.nameKw.text];
        }
        else {
            return this.dialectCfg.onelineClauses[node.nameKw.text];
        }
    }
    formatClauseInIndentedStyle(node) {
        this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT, this.showKw(node.nameKw), Layout_js_1.WS.NEWLINE);
        this.layout.indentation.increaseTopLevel();
        this.layout.add(Layout_js_1.WS.INDENT);
        this.layout = this.formatSubExpression(node.children);
        this.layout.indentation.decreaseTopLevel();
    }
    formatClauseInOnelineStyle(node) {
        this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT, this.showKw(node.nameKw), Layout_js_1.WS.SPACE);
        this.layout = this.formatSubExpression(node.children);
    }
    formatClauseInTabularStyle(node) {
        this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT, this.showKw(node.nameKw), Layout_js_1.WS.SPACE);
        this.layout.indentation.increaseTopLevel();
        this.layout = this.formatSubExpression(node.children);
        this.layout.indentation.decreaseTopLevel();
    }
    formatSetOperation(node) {
        this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT, this.showKw(node.nameKw), Layout_js_1.WS.NEWLINE);
        this.layout.add(Layout_js_1.WS.INDENT);
        this.layout = this.formatSubExpression(node.children);
    }
    formatLimitClause(node) {
        this.withComments(node.limitKw, () => {
            this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT, this.showKw(node.limitKw));
        });
        this.layout.indentation.increaseTopLevel();
        if ((0, config_js_1.isTabularStyle)(this.cfg)) {
            this.layout.add(Layout_js_1.WS.SPACE);
        }
        else {
            this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT);
        }
        if (node.offset) {
            this.layout = this.formatSubExpression(node.offset);
            this.layout.add(Layout_js_1.WS.NO_SPACE, ',', Layout_js_1.WS.SPACE);
            this.layout = this.formatSubExpression(node.count);
        }
        else {
            this.layout = this.formatSubExpression(node.count);
        }
        this.layout.indentation.decreaseTopLevel();
    }
    formatAllColumnsAsterisk(_node) {
        this.layout.add('*', Layout_js_1.WS.SPACE);
    }
    formatLiteral(node) {
        this.layout.add(node.text, Layout_js_1.WS.SPACE);
    }
    formatIdentifier(node) {
        this.layout.add(this.showIdentifier(node), Layout_js_1.WS.SPACE);
    }
    formatParameter(node) {
        this.layout.add(this.params.get(node), Layout_js_1.WS.SPACE);
    }
    formatOperator({ text }) {
        // In dialects that allow dashes inside identifiers (e.g. BigQuery) the "-"
        // operator must keep its surrounding spaces. Densing "a - b" into "a-b"
        // would otherwise re-parse as a single dashed identifier.
        if (text === '-' && this.dialectCfg.identifierDashes) {
            this.layout.add(text, Layout_js_1.WS.SPACE);
        }
        else if (this.cfg.denseOperators || this.dialectCfg.alwaysDenseOperators.includes(text)) {
            this.layout.add(Layout_js_1.WS.NO_SPACE, text);
        }
        else if (text === ':') {
            this.layout.add(Layout_js_1.WS.NO_SPACE, text, Layout_js_1.WS.SPACE);
        }
        else {
            this.layout.add(text, Layout_js_1.WS.SPACE);
        }
    }
    formatComma(_node) {
        if (!this.inline) {
            this.layout.add(Layout_js_1.WS.NO_SPACE, ',', Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT);
        }
        else {
            this.layout.add(Layout_js_1.WS.NO_SPACE, ',', Layout_js_1.WS.SPACE);
        }
    }
    withComments(node, fn) {
        this.formatComments(node.leadingComments);
        fn();
        this.formatComments(node.trailingComments);
    }
    formatComments(comments) {
        if (!comments) {
            return;
        }
        comments.forEach(com => {
            if (com.type === ast_js_1.NodeType.line_comment) {
                this.formatLineComment(com);
            }
            else {
                this.formatBlockComment(com);
            }
        });
    }
    formatLineComment(node) {
        if ((0, utils_js_1.isMultiline)(node.precedingWhitespace || '')) {
            this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT, node.text, Layout_js_1.WS.MANDATORY_NEWLINE, Layout_js_1.WS.INDENT);
        }
        else if (this.layout.getLayoutItems().length > 0) {
            this.layout.add(Layout_js_1.WS.NO_NEWLINE, Layout_js_1.WS.SPACE, node.text, Layout_js_1.WS.MANDATORY_NEWLINE, Layout_js_1.WS.INDENT);
        }
        else {
            // comment is the first item in code - no need to add preceding spaces
            this.layout.add(node.text, Layout_js_1.WS.MANDATORY_NEWLINE, Layout_js_1.WS.INDENT);
        }
    }
    formatBlockComment(node) {
        if (node.type === ast_js_1.NodeType.block_comment && this.isStandaloneBlockComment(node)) {
            this.splitBlockComment(node.text).forEach(line => {
                this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT, line);
            });
            this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT);
        }
        else {
            this.layout.add(node.text, Layout_js_1.WS.SPACE);
        }
    }
    // True when:
    //
    // - the source text had a newline before the comment
    // - the comment itself is multi-line
    // - we have already added a newline to output text (right before this to-be added comment)
    //
    // The last one will ensure the comment position stays idempotent - so that
    // re-formatting the same SQL won't result in comment position changing.
    isStandaloneBlockComment(node) {
        return ((0, utils_js_1.isMultiline)(node.text) ||
            (0, utils_js_1.isMultiline)(node.precedingWhitespace || '') ||
            this.layout.isAtStartOfLine());
    }
    isDocComment(comment) {
        const lines = comment.split(/\n/);
        return (
        // first line starts with /* or /**
        /^\/\*\*?$/.test(lines[0]) &&
            // intermediate lines start with *
            lines.slice(1, lines.length - 1).every(line => /^\s*\*/.test(line)) &&
            // last line ends with */
            /^\s*\*\/$/.test((0, utils_js_1.last)(lines)));
    }
    // Breaks up block comment to multiple lines.
    // For example this doc-comment (dots representing leading whitespace):
    //
    //   ..../**
    //   .....* Some description here
    //   .....* and here too
    //   .....*/
    //
    // gets broken to this array (note the leading single spaces):
    //
    //   [ '/**',
    //     '.* Some description here',
    //     '.* and here too',
    //     '.*/' ]
    //
    // However, a normal comment (non-doc-comment) like this:
    //
    //   ..../*
    //   ....Some description here
    //   ....*/
    //
    // gets broken to this array (no leading spaces):
    //
    //   [ '/*',
    //     'Some description here',
    //     '*/' ]
    //
    splitBlockComment(comment) {
        if (this.isDocComment(comment)) {
            return comment.split(/\n/).map(line => {
                if (/^\s*\*/.test(line)) {
                    return ' ' + line.replace(/^\s*/, '');
                }
                else {
                    return line;
                }
            });
        }
        else {
            return comment.split(/\n/).map(line => line.replace(/^\s*/, ''));
        }
    }
    formatSubExpression(nodes) {
        return new ExpressionFormatter({
            cfg: this.cfg,
            dialectCfg: this.dialectCfg,
            params: this.params,
            layout: this.layout,
            inline: this.inline,
        }).format(nodes);
    }
    formatInlineExpression(nodes) {
        const oldParamIndex = this.params.getPositionalParameterIndex();
        try {
            return new ExpressionFormatter({
                cfg: this.cfg,
                dialectCfg: this.dialectCfg,
                params: this.params,
                layout: new InlineLayout_js_1.default(this.cfg.expressionWidth),
                inline: true,
            }).format(nodes);
        }
        catch (e) {
            if (e instanceof InlineLayout_js_1.InlineLayoutError) {
                // While formatting, some of the positional parameters might have
                // been consumed, which increased the current parameter index.
                // We reset the index to an earlier state, so we can run the
                // formatting again and re-consume these parameters in non-inline mode.
                this.params.setPositionalParameterIndex(oldParamIndex);
                return undefined;
            }
            else {
                // forward all unexpected errors
                throw e;
            }
        }
    }
    formatKeywordNode(node) {
        switch (node.tokenType) {
            case token_js_1.TokenType.RESERVED_JOIN:
                return this.formatJoin(node);
            case token_js_1.TokenType.AND:
            case token_js_1.TokenType.OR:
            case token_js_1.TokenType.XOR:
                return this.formatLogicalOperator(node);
            default:
                return this.formatKeyword(node);
        }
    }
    formatJoin(node) {
        if ((0, config_js_1.isTabularStyle)(this.cfg)) {
            // in tabular style JOINs are at the same level as clauses
            this.layout.indentation.decreaseTopLevel();
            this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT, this.showKw(node), Layout_js_1.WS.SPACE);
            this.layout.indentation.increaseTopLevel();
        }
        else {
            this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT, this.showKw(node), Layout_js_1.WS.SPACE);
        }
    }
    formatKeyword(node) {
        this.layout.add(this.showKw(node), Layout_js_1.WS.SPACE);
    }
    formatLogicalOperator(node) {
        if (this.cfg.logicalOperatorNewline === 'before') {
            if ((0, config_js_1.isTabularStyle)(this.cfg)) {
                // In tabular style AND/OR is placed on the same level as clauses
                this.layout.indentation.decreaseTopLevel();
                this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT, this.showKw(node), Layout_js_1.WS.SPACE);
                this.layout.indentation.increaseTopLevel();
            }
            else {
                this.layout.add(Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT, this.showKw(node), Layout_js_1.WS.SPACE);
            }
        }
        else {
            this.layout.add(this.showKw(node), Layout_js_1.WS.NEWLINE, Layout_js_1.WS.INDENT);
        }
    }
    formatDataType(node) {
        this.layout.add(this.showDataType(node), Layout_js_1.WS.SPACE);
    }
    showKw(node) {
        if ((0, tabularStyle_js_1.isTabularToken)(node.tokenType)) {
            return (0, tabularStyle_js_1.default)(this.showNonTabularKw(node), this.cfg.indentStyle);
        }
        else {
            return this.showNonTabularKw(node);
        }
    }
    // Like showKw(), but skips tabular formatting
    showNonTabularKw(node) {
        switch (this.cfg.keywordCase) {
            case 'preserve':
                return (0, utils_js_1.equalizeWhitespace)(node.raw);
            case 'upper':
                return node.text;
            case 'lower':
                return node.text.toLowerCase();
        }
    }
    showFunctionKw(node) {
        if ((0, tabularStyle_js_1.isTabularToken)(node.tokenType)) {
            return (0, tabularStyle_js_1.default)(this.showNonTabularFunctionKw(node), this.cfg.indentStyle);
        }
        else {
            return this.showNonTabularFunctionKw(node);
        }
    }
    // Like showFunctionKw(), but skips tabular formatting
    showNonTabularFunctionKw(node) {
        switch (this.cfg.functionCase) {
            case 'preserve':
                return (0, utils_js_1.equalizeWhitespace)(node.raw);
            case 'upper':
                return node.text;
            case 'lower':
                return node.text.toLowerCase();
        }
    }
    showIdentifier(node) {
        if (node.quoted) {
            return node.text;
        }
        else {
            switch (this.cfg.identifierCase) {
                case 'preserve':
                    return node.text;
                case 'upper':
                    return node.text.toUpperCase();
                case 'lower':
                    return node.text.toLowerCase();
            }
        }
    }
    showDataType(node) {
        switch (this.cfg.dataTypeCase) {
            case 'preserve':
                return (0, utils_js_1.equalizeWhitespace)(node.raw);
            case 'upper':
                return node.text;
            case 'lower':
                return node.text.toLowerCase();
        }
    }
}
exports.default = ExpressionFormatter;
//# sourceMappingURL=ExpressionFormatter.js.map