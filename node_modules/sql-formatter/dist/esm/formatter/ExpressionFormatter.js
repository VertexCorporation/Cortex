import { equalizeWhitespace, isMultiline, last } from '../utils.js';
import { isTabularStyle } from './config.js';
import { TokenType } from '../lexer/token.js';
import { NodeType, } from '../parser/ast.js';
import { WS } from './Layout.js';
import toTabularFormat, { isTabularToken } from './tabularStyle.js';
import InlineLayout, { InlineLayoutError } from './InlineLayout.js';
/** Formats a generic SQL expression */
export default class ExpressionFormatter {
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
            case NodeType.function_call:
                return this.formatFunctionCall(node);
            case NodeType.parameterized_data_type:
                return this.formatParameterizedDataType(node);
            case NodeType.array_subscript:
                return this.formatArraySubscript(node);
            case NodeType.property_access:
                return this.formatPropertyAccess(node);
            case NodeType.parenthesis:
                return this.formatParenthesis(node);
            case NodeType.between_predicate:
                return this.formatBetweenPredicate(node);
            case NodeType.case_expression:
                return this.formatCaseExpression(node);
            case NodeType.case_when:
                return this.formatCaseWhen(node);
            case NodeType.case_else:
                return this.formatCaseElse(node);
            case NodeType.clause:
                return this.formatClause(node);
            case NodeType.set_operation:
                return this.formatSetOperation(node);
            case NodeType.limit_clause:
                return this.formatLimitClause(node);
            case NodeType.all_columns_asterisk:
                return this.formatAllColumnsAsterisk(node);
            case NodeType.literal:
                return this.formatLiteral(node);
            case NodeType.identifier:
                return this.formatIdentifier(node);
            case NodeType.parameter:
                return this.formatParameter(node);
            case NodeType.operator:
                return this.formatOperator(node);
            case NodeType.comma:
                return this.formatComma(node);
            case NodeType.line_comment:
                return this.formatLineComment(node);
            case NodeType.block_comment:
                return this.formatBlockComment(node);
            case NodeType.disable_comment:
                return this.formatBlockComment(node);
            case NodeType.data_type:
                return this.formatDataType(node);
            case NodeType.keyword:
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
            case NodeType.data_type:
                formattedArray = this.showDataType(node.array);
                break;
            case NodeType.keyword:
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
        this.layout.add(WS.NO_SPACE, node.operator);
        this.formatNode(node.property);
    }
    formatParenthesis(node) {
        const inlineLayout = this.formatInlineExpression(node.children);
        if (inlineLayout) {
            this.layout.add(node.openParen);
            this.layout.add(...inlineLayout.getLayoutItems());
            this.layout.add(WS.NO_SPACE, node.closeParen, WS.SPACE);
        }
        else {
            this.layout.add(node.openParen, WS.NEWLINE);
            if (isTabularStyle(this.cfg)) {
                this.layout.add(WS.INDENT);
                this.layout = this.formatSubExpression(node.children);
            }
            else {
                this.layout.indentation.increaseBlockLevel();
                this.layout.add(WS.INDENT);
                this.layout = this.formatSubExpression(node.children);
                this.layout.indentation.decreaseBlockLevel();
            }
            this.layout.add(WS.NEWLINE, WS.INDENT, node.closeParen, WS.SPACE);
        }
    }
    formatBetweenPredicate(node) {
        this.layout.add(this.showKw(node.betweenKw), WS.SPACE);
        this.layout = this.formatSubExpression(node.expr1);
        this.layout.add(WS.NO_SPACE, WS.SPACE, this.showNonTabularKw(node.andKw), WS.SPACE);
        this.layout = this.formatSubExpression(node.expr2);
        this.layout.add(WS.SPACE);
    }
    formatCaseExpression(node) {
        this.formatNode(node.caseKw);
        this.layout.indentation.increaseBlockLevel();
        this.layout = this.formatSubExpression(node.expr);
        this.layout = this.formatSubExpression(node.clauses);
        this.layout.indentation.decreaseBlockLevel();
        this.layout.add(WS.NEWLINE, WS.INDENT);
        this.formatNode(node.endKw);
    }
    formatCaseWhen(node) {
        this.layout.add(WS.NEWLINE, WS.INDENT);
        this.formatNode(node.whenKw);
        this.layout = this.formatSubExpression(node.condition);
        this.formatNode(node.thenKw);
        this.layout = this.formatSubExpression(node.result);
    }
    formatCaseElse(node) {
        this.layout.add(WS.NEWLINE, WS.INDENT);
        this.formatNode(node.elseKw);
        this.layout = this.formatSubExpression(node.result);
    }
    formatClause(node) {
        if (this.isOnelineClause(node)) {
            this.formatClauseInOnelineStyle(node);
        }
        else if (isTabularStyle(this.cfg)) {
            this.formatClauseInTabularStyle(node);
        }
        else {
            this.formatClauseInIndentedStyle(node);
        }
    }
    isOnelineClause(node) {
        if (isTabularStyle(this.cfg)) {
            return this.dialectCfg.tabularOnelineClauses[node.nameKw.text];
        }
        else {
            return this.dialectCfg.onelineClauses[node.nameKw.text];
        }
    }
    formatClauseInIndentedStyle(node) {
        this.layout.add(WS.NEWLINE, WS.INDENT, this.showKw(node.nameKw), WS.NEWLINE);
        this.layout.indentation.increaseTopLevel();
        this.layout.add(WS.INDENT);
        this.layout = this.formatSubExpression(node.children);
        this.layout.indentation.decreaseTopLevel();
    }
    formatClauseInOnelineStyle(node) {
        this.layout.add(WS.NEWLINE, WS.INDENT, this.showKw(node.nameKw), WS.SPACE);
        this.layout = this.formatSubExpression(node.children);
    }
    formatClauseInTabularStyle(node) {
        this.layout.add(WS.NEWLINE, WS.INDENT, this.showKw(node.nameKw), WS.SPACE);
        this.layout.indentation.increaseTopLevel();
        this.layout = this.formatSubExpression(node.children);
        this.layout.indentation.decreaseTopLevel();
    }
    formatSetOperation(node) {
        this.layout.add(WS.NEWLINE, WS.INDENT, this.showKw(node.nameKw), WS.NEWLINE);
        this.layout.add(WS.INDENT);
        this.layout = this.formatSubExpression(node.children);
    }
    formatLimitClause(node) {
        this.withComments(node.limitKw, () => {
            this.layout.add(WS.NEWLINE, WS.INDENT, this.showKw(node.limitKw));
        });
        this.layout.indentation.increaseTopLevel();
        if (isTabularStyle(this.cfg)) {
            this.layout.add(WS.SPACE);
        }
        else {
            this.layout.add(WS.NEWLINE, WS.INDENT);
        }
        if (node.offset) {
            this.layout = this.formatSubExpression(node.offset);
            this.layout.add(WS.NO_SPACE, ',', WS.SPACE);
            this.layout = this.formatSubExpression(node.count);
        }
        else {
            this.layout = this.formatSubExpression(node.count);
        }
        this.layout.indentation.decreaseTopLevel();
    }
    formatAllColumnsAsterisk(_node) {
        this.layout.add('*', WS.SPACE);
    }
    formatLiteral(node) {
        this.layout.add(node.text, WS.SPACE);
    }
    formatIdentifier(node) {
        this.layout.add(this.showIdentifier(node), WS.SPACE);
    }
    formatParameter(node) {
        this.layout.add(this.params.get(node), WS.SPACE);
    }
    formatOperator({ text }) {
        // In dialects that allow dashes inside identifiers (e.g. BigQuery) the "-"
        // operator must keep its surrounding spaces. Densing "a - b" into "a-b"
        // would otherwise re-parse as a single dashed identifier.
        if (text === '-' && this.dialectCfg.identifierDashes) {
            this.layout.add(text, WS.SPACE);
        }
        else if (this.cfg.denseOperators || this.dialectCfg.alwaysDenseOperators.includes(text)) {
            this.layout.add(WS.NO_SPACE, text);
        }
        else if (text === ':') {
            this.layout.add(WS.NO_SPACE, text, WS.SPACE);
        }
        else {
            this.layout.add(text, WS.SPACE);
        }
    }
    formatComma(_node) {
        if (!this.inline) {
            this.layout.add(WS.NO_SPACE, ',', WS.NEWLINE, WS.INDENT);
        }
        else {
            this.layout.add(WS.NO_SPACE, ',', WS.SPACE);
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
            if (com.type === NodeType.line_comment) {
                this.formatLineComment(com);
            }
            else {
                this.formatBlockComment(com);
            }
        });
    }
    formatLineComment(node) {
        if (isMultiline(node.precedingWhitespace || '')) {
            this.layout.add(WS.NEWLINE, WS.INDENT, node.text, WS.MANDATORY_NEWLINE, WS.INDENT);
        }
        else if (this.layout.getLayoutItems().length > 0) {
            this.layout.add(WS.NO_NEWLINE, WS.SPACE, node.text, WS.MANDATORY_NEWLINE, WS.INDENT);
        }
        else {
            // comment is the first item in code - no need to add preceding spaces
            this.layout.add(node.text, WS.MANDATORY_NEWLINE, WS.INDENT);
        }
    }
    formatBlockComment(node) {
        if (node.type === NodeType.block_comment && this.isStandaloneBlockComment(node)) {
            this.splitBlockComment(node.text).forEach(line => {
                this.layout.add(WS.NEWLINE, WS.INDENT, line);
            });
            this.layout.add(WS.NEWLINE, WS.INDENT);
        }
        else {
            this.layout.add(node.text, WS.SPACE);
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
        return (isMultiline(node.text) ||
            isMultiline(node.precedingWhitespace || '') ||
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
            /^\s*\*\/$/.test(last(lines)));
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
                layout: new InlineLayout(this.cfg.expressionWidth),
                inline: true,
            }).format(nodes);
        }
        catch (e) {
            if (e instanceof InlineLayoutError) {
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
            case TokenType.RESERVED_JOIN:
                return this.formatJoin(node);
            case TokenType.AND:
            case TokenType.OR:
            case TokenType.XOR:
                return this.formatLogicalOperator(node);
            default:
                return this.formatKeyword(node);
        }
    }
    formatJoin(node) {
        if (isTabularStyle(this.cfg)) {
            // in tabular style JOINs are at the same level as clauses
            this.layout.indentation.decreaseTopLevel();
            this.layout.add(WS.NEWLINE, WS.INDENT, this.showKw(node), WS.SPACE);
            this.layout.indentation.increaseTopLevel();
        }
        else {
            this.layout.add(WS.NEWLINE, WS.INDENT, this.showKw(node), WS.SPACE);
        }
    }
    formatKeyword(node) {
        this.layout.add(this.showKw(node), WS.SPACE);
    }
    formatLogicalOperator(node) {
        if (this.cfg.logicalOperatorNewline === 'before') {
            if (isTabularStyle(this.cfg)) {
                // In tabular style AND/OR is placed on the same level as clauses
                this.layout.indentation.decreaseTopLevel();
                this.layout.add(WS.NEWLINE, WS.INDENT, this.showKw(node), WS.SPACE);
                this.layout.indentation.increaseTopLevel();
            }
            else {
                this.layout.add(WS.NEWLINE, WS.INDENT, this.showKw(node), WS.SPACE);
            }
        }
        else {
            this.layout.add(this.showKw(node), WS.NEWLINE, WS.INDENT);
        }
    }
    formatDataType(node) {
        this.layout.add(this.showDataType(node), WS.SPACE);
    }
    showKw(node) {
        if (isTabularToken(node.tokenType)) {
            return toTabularFormat(this.showNonTabularKw(node), this.cfg.indentStyle);
        }
        else {
            return this.showNonTabularKw(node);
        }
    }
    // Like showKw(), but skips tabular formatting
    showNonTabularKw(node) {
        switch (this.cfg.keywordCase) {
            case 'preserve':
                return equalizeWhitespace(node.raw);
            case 'upper':
                return node.text;
            case 'lower':
                return node.text.toLowerCase();
        }
    }
    showFunctionKw(node) {
        if (isTabularToken(node.tokenType)) {
            return toTabularFormat(this.showNonTabularFunctionKw(node), this.cfg.indentStyle);
        }
        else {
            return this.showNonTabularFunctionKw(node);
        }
    }
    // Like showFunctionKw(), but skips tabular formatting
    showNonTabularFunctionKw(node) {
        switch (this.cfg.functionCase) {
            case 'preserve':
                return equalizeWhitespace(node.raw);
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
                return equalizeWhitespace(node.raw);
            case 'upper':
                return node.text;
            case 'lower':
                return node.text.toLowerCase();
        }
    }
}
//# sourceMappingURL=ExpressionFormatter.js.map