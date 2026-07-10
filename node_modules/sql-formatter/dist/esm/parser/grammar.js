// Generated automatically by nearley, version 2.20.1
// http://github.com/Hardmath123/nearley
// Bypasses TS6133. Allow declared but unused functions.
// @ts-ignore
function id(d) { return d[0]; }
import LexerAdapter from './LexerAdapter.js';
import { NodeType } from './ast.js';
import { TokenType } from '../lexer/token.js';
// The lexer here is only to provide the has() method,
// that's used inside the generated grammar definition.
// A proper lexer gets passed to Nearley Parser constructor.
const lexer = new LexerAdapter(chunk => []);
// Used for unwrapping grammar rules like:
//
//   rule -> ( foo | bar | baz )
//
// which otherwise produce single element nested inside two arrays
const unwrap = ([[el]]) => el;
const toKeywordNode = (token) => ({
    type: NodeType.keyword,
    tokenType: token.type,
    text: token.text,
    raw: token.raw,
});
const toDataTypeNode = (token) => ({
    type: NodeType.data_type,
    text: token.text,
    raw: token.raw,
});
const addComments = (node, { leading, trailing }) => {
    if (leading === null || leading === void 0 ? void 0 : leading.length) {
        node = Object.assign(Object.assign({}, node), { leadingComments: leading });
    }
    if (trailing === null || trailing === void 0 ? void 0 : trailing.length) {
        node = Object.assign(Object.assign({}, node), { trailingComments: trailing });
    }
    return node;
};
const addCommentsToArray = (nodes, { leading, trailing }) => {
    if (leading === null || leading === void 0 ? void 0 : leading.length) {
        const [first, ...rest] = nodes;
        nodes = [addComments(first, { leading }), ...rest];
    }
    if (trailing === null || trailing === void 0 ? void 0 : trailing.length) {
        const lead = nodes.slice(0, -1);
        const last = nodes[nodes.length - 1];
        nodes = [...lead, addComments(last, { trailing })];
    }
    return nodes;
};
;
;
;
;
const grammar = {
    Lexer: lexer,
    ParserRules: [
        { "name": "main$ebnf$1", "symbols": [] },
        { "name": "main$ebnf$1", "symbols": ["main$ebnf$1", "statement"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "main", "symbols": ["main$ebnf$1"], "postprocess": ([statements]) => {
                const last = statements[statements.length - 1];
                if (last && !last.hasSemicolon) {
                    // we have fully parsed the whole file
                    // discard the last statement when it's empty
                    return last.children.length > 0 ? statements : statements.slice(0, -1);
                }
                else {
                    // parsing still in progress, do nothing
                    return statements;
                }
            }
        },
        { "name": "statement$subexpression$1", "symbols": [(lexer.has("DELIMITER") ? { type: "DELIMITER" } : DELIMITER)] },
        { "name": "statement$subexpression$1", "symbols": [(lexer.has("EOF") ? { type: "EOF" } : EOF)] },
        { "name": "statement", "symbols": ["expressions_or_clauses", "statement$subexpression$1"], "postprocess": ([children, [delimiter]]) => ({
                type: NodeType.statement,
                children,
                hasSemicolon: delimiter.type === TokenType.DELIMITER,
            })
        },
        { "name": "expressions_or_clauses$ebnf$1", "symbols": [] },
        { "name": "expressions_or_clauses$ebnf$1", "symbols": ["expressions_or_clauses$ebnf$1", "free_form_sql"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "expressions_or_clauses$ebnf$2", "symbols": [] },
        { "name": "expressions_or_clauses$ebnf$2", "symbols": ["expressions_or_clauses$ebnf$2", "clause"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "expressions_or_clauses", "symbols": ["expressions_or_clauses$ebnf$1", "expressions_or_clauses$ebnf$2"], "postprocess": ([expressions, clauses]) => [...expressions, ...clauses]
        },
        { "name": "clause$subexpression$1", "symbols": ["limit_clause"] },
        { "name": "clause$subexpression$1", "symbols": ["select_clause"] },
        { "name": "clause$subexpression$1", "symbols": ["other_clause"] },
        { "name": "clause$subexpression$1", "symbols": ["set_operation"] },
        { "name": "clause", "symbols": ["clause$subexpression$1"], "postprocess": unwrap },
        { "name": "limit_clause$ebnf$1$subexpression$1$ebnf$1", "symbols": ["free_form_sql"] },
        { "name": "limit_clause$ebnf$1$subexpression$1$ebnf$1", "symbols": ["limit_clause$ebnf$1$subexpression$1$ebnf$1", "free_form_sql"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "limit_clause$ebnf$1$subexpression$1", "symbols": [(lexer.has("COMMA") ? { type: "COMMA" } : COMMA), "limit_clause$ebnf$1$subexpression$1$ebnf$1"] },
        { "name": "limit_clause$ebnf$1", "symbols": ["limit_clause$ebnf$1$subexpression$1"], "postprocess": id },
        { "name": "limit_clause$ebnf$1", "symbols": [], "postprocess": () => null },
        { "name": "limit_clause", "symbols": [(lexer.has("LIMIT") ? { type: "LIMIT" } : LIMIT), "_", "expression_chain_", "limit_clause$ebnf$1"], "postprocess": ([limitToken, _, exp1, optional]) => {
                if (optional) {
                    const [comma, exp2] = optional;
                    return {
                        type: NodeType.limit_clause,
                        limitKw: addComments(toKeywordNode(limitToken), { trailing: _ }),
                        offset: exp1,
                        count: exp2,
                    };
                }
                else {
                    return {
                        type: NodeType.limit_clause,
                        limitKw: addComments(toKeywordNode(limitToken), { trailing: _ }),
                        count: exp1,
                    };
                }
            }
        },
        { "name": "select_clause$subexpression$1$ebnf$1", "symbols": [] },
        { "name": "select_clause$subexpression$1$ebnf$1", "symbols": ["select_clause$subexpression$1$ebnf$1", "free_form_sql"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "select_clause$subexpression$1", "symbols": ["all_columns_asterisk", "select_clause$subexpression$1$ebnf$1"] },
        { "name": "select_clause$subexpression$1$ebnf$2", "symbols": [] },
        { "name": "select_clause$subexpression$1$ebnf$2", "symbols": ["select_clause$subexpression$1$ebnf$2", "free_form_sql"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "select_clause$subexpression$1", "symbols": ["asteriskless_free_form_sql", "select_clause$subexpression$1$ebnf$2"] },
        { "name": "select_clause", "symbols": [(lexer.has("RESERVED_SELECT") ? { type: "RESERVED_SELECT" } : RESERVED_SELECT), "select_clause$subexpression$1"], "postprocess": ([nameToken, [exp, expressions]]) => ({
                type: NodeType.clause,
                nameKw: toKeywordNode(nameToken),
                children: [exp, ...expressions],
            })
        },
        { "name": "select_clause", "symbols": [(lexer.has("RESERVED_SELECT") ? { type: "RESERVED_SELECT" } : RESERVED_SELECT)], "postprocess": ([nameToken]) => ({
                type: NodeType.clause,
                nameKw: toKeywordNode(nameToken),
                children: [],
            })
        },
        { "name": "all_columns_asterisk", "symbols": [(lexer.has("ASTERISK") ? { type: "ASTERISK" } : ASTERISK)], "postprocess": () => ({ type: NodeType.all_columns_asterisk })
        },
        { "name": "other_clause$ebnf$1", "symbols": [] },
        { "name": "other_clause$ebnf$1", "symbols": ["other_clause$ebnf$1", "free_form_sql"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "other_clause", "symbols": [(lexer.has("RESERVED_CLAUSE") ? { type: "RESERVED_CLAUSE" } : RESERVED_CLAUSE), "other_clause$ebnf$1"], "postprocess": ([nameToken, children]) => ({
                type: NodeType.clause,
                nameKw: toKeywordNode(nameToken),
                children,
            })
        },
        { "name": "set_operation$ebnf$1", "symbols": [] },
        { "name": "set_operation$ebnf$1", "symbols": ["set_operation$ebnf$1", "free_form_sql"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "set_operation", "symbols": [(lexer.has("RESERVED_SET_OPERATION") ? { type: "RESERVED_SET_OPERATION" } : RESERVED_SET_OPERATION), "set_operation$ebnf$1"], "postprocess": ([nameToken, children]) => ({
                type: NodeType.set_operation,
                nameKw: toKeywordNode(nameToken),
                children,
            })
        },
        { "name": "expression_chain_$ebnf$1", "symbols": ["expression_with_comments_"] },
        { "name": "expression_chain_$ebnf$1", "symbols": ["expression_chain_$ebnf$1", "expression_with_comments_"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "expression_chain_", "symbols": ["expression_chain_$ebnf$1"], "postprocess": id },
        { "name": "expression_chain$ebnf$1", "symbols": [] },
        { "name": "expression_chain$ebnf$1", "symbols": ["expression_chain$ebnf$1", "_expression_with_comments"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "expression_chain", "symbols": ["expression", "expression_chain$ebnf$1"], "postprocess": ([expr, chain]) => [expr, ...chain]
        },
        { "name": "andless_expression_chain$ebnf$1", "symbols": [] },
        { "name": "andless_expression_chain$ebnf$1", "symbols": ["andless_expression_chain$ebnf$1", "_andless_expression_with_comments"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "andless_expression_chain", "symbols": ["andless_expression", "andless_expression_chain$ebnf$1"], "postprocess": ([expr, chain]) => [expr, ...chain]
        },
        { "name": "expression_with_comments_", "symbols": ["expression", "_"], "postprocess": ([expr, _]) => addComments(expr, { trailing: _ })
        },
        { "name": "_expression_with_comments", "symbols": ["_", "expression"], "postprocess": ([_, expr]) => addComments(expr, { leading: _ })
        },
        { "name": "_andless_expression_with_comments", "symbols": ["_", "andless_expression"], "postprocess": ([_, expr]) => addComments(expr, { leading: _ })
        },
        { "name": "free_form_sql$subexpression$1", "symbols": ["asteriskless_free_form_sql"] },
        { "name": "free_form_sql$subexpression$1", "symbols": ["asterisk"] },
        { "name": "free_form_sql", "symbols": ["free_form_sql$subexpression$1"], "postprocess": unwrap },
        { "name": "asteriskless_free_form_sql$subexpression$1", "symbols": ["asteriskless_andless_expression"] },
        { "name": "asteriskless_free_form_sql$subexpression$1", "symbols": ["logic_operator"] },
        { "name": "asteriskless_free_form_sql$subexpression$1", "symbols": ["comma"] },
        { "name": "asteriskless_free_form_sql$subexpression$1", "symbols": ["comment"] },
        { "name": "asteriskless_free_form_sql$subexpression$1", "symbols": ["other_keyword"] },
        { "name": "asteriskless_free_form_sql", "symbols": ["asteriskless_free_form_sql$subexpression$1"], "postprocess": unwrap },
        { "name": "expression$subexpression$1", "symbols": ["andless_expression"] },
        { "name": "expression$subexpression$1", "symbols": ["logic_operator"] },
        { "name": "expression", "symbols": ["expression$subexpression$1"], "postprocess": unwrap },
        { "name": "andless_expression$subexpression$1", "symbols": ["asteriskless_andless_expression"] },
        { "name": "andless_expression$subexpression$1", "symbols": ["asterisk"] },
        { "name": "andless_expression", "symbols": ["andless_expression$subexpression$1"], "postprocess": unwrap },
        { "name": "asteriskless_andless_expression$subexpression$1", "symbols": ["atomic_expression"] },
        { "name": "asteriskless_andless_expression$subexpression$1", "symbols": ["between_predicate"] },
        { "name": "asteriskless_andless_expression$subexpression$1", "symbols": ["case_expression"] },
        { "name": "asteriskless_andless_expression", "symbols": ["asteriskless_andless_expression$subexpression$1"], "postprocess": unwrap },
        { "name": "atomic_expression$subexpression$1", "symbols": ["array_subscript"] },
        { "name": "atomic_expression$subexpression$1", "symbols": ["function_call"] },
        { "name": "atomic_expression$subexpression$1", "symbols": ["property_access"] },
        { "name": "atomic_expression$subexpression$1", "symbols": ["parenthesis"] },
        { "name": "atomic_expression$subexpression$1", "symbols": ["curly_braces"] },
        { "name": "atomic_expression$subexpression$1", "symbols": ["square_brackets"] },
        { "name": "atomic_expression$subexpression$1", "symbols": ["operator"] },
        { "name": "atomic_expression$subexpression$1", "symbols": ["identifier"] },
        { "name": "atomic_expression$subexpression$1", "symbols": ["parameter"] },
        { "name": "atomic_expression$subexpression$1", "symbols": ["literal"] },
        { "name": "atomic_expression$subexpression$1", "symbols": ["data_type"] },
        { "name": "atomic_expression$subexpression$1", "symbols": ["keyword"] },
        { "name": "atomic_expression", "symbols": ["atomic_expression$subexpression$1"], "postprocess": unwrap },
        { "name": "array_subscript", "symbols": [(lexer.has("ARRAY_IDENTIFIER") ? { type: "ARRAY_IDENTIFIER" } : ARRAY_IDENTIFIER), "_", "square_brackets"], "postprocess": ([arrayToken, _, brackets]) => ({
                type: NodeType.array_subscript,
                array: addComments({ type: NodeType.identifier, quoted: false, text: arrayToken.text }, { trailing: _ }),
                parenthesis: brackets,
            })
        },
        { "name": "array_subscript", "symbols": [(lexer.has("ARRAY_KEYWORD") ? { type: "ARRAY_KEYWORD" } : ARRAY_KEYWORD), "_", "square_brackets"], "postprocess": ([arrayToken, _, brackets]) => ({
                type: NodeType.array_subscript,
                array: addComments(toKeywordNode(arrayToken), { trailing: _ }),
                parenthesis: brackets,
            })
        },
        { "name": "function_call", "symbols": [(lexer.has("RESERVED_FUNCTION_NAME") ? { type: "RESERVED_FUNCTION_NAME" } : RESERVED_FUNCTION_NAME), "_", "parenthesis"], "postprocess": ([nameToken, _, parens]) => ({
                type: NodeType.function_call,
                nameKw: addComments(toKeywordNode(nameToken), { trailing: _ }),
                parenthesis: parens,
            })
        },
        { "name": "parenthesis", "symbols": [{ "literal": "(" }, "expressions_or_clauses", { "literal": ")" }], "postprocess": ([open, children, close]) => ({
                type: NodeType.parenthesis,
                children: children,
                openParen: "(",
                closeParen: ")",
            })
        },
        { "name": "curly_braces$ebnf$1", "symbols": [] },
        { "name": "curly_braces$ebnf$1", "symbols": ["curly_braces$ebnf$1", "free_form_sql"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "curly_braces", "symbols": [{ "literal": "{" }, "curly_braces$ebnf$1", { "literal": "}" }], "postprocess": ([open, children, close]) => ({
                type: NodeType.parenthesis,
                children: children,
                openParen: "{",
                closeParen: "}",
            })
        },
        { "name": "square_brackets$ebnf$1", "symbols": [] },
        { "name": "square_brackets$ebnf$1", "symbols": ["square_brackets$ebnf$1", "free_form_sql"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "square_brackets", "symbols": [{ "literal": "[" }, "square_brackets$ebnf$1", { "literal": "]" }], "postprocess": ([open, children, close]) => ({
                type: NodeType.parenthesis,
                children: children,
                openParen: "[",
                closeParen: "]",
            })
        },
        { "name": "property_access$subexpression$1", "symbols": ["identifier"] },
        { "name": "property_access$subexpression$1", "symbols": ["array_subscript"] },
        { "name": "property_access$subexpression$1", "symbols": ["all_columns_asterisk"] },
        { "name": "property_access$subexpression$1", "symbols": ["parameter"] },
        { "name": "property_access", "symbols": ["atomic_expression", "_", (lexer.has("PROPERTY_ACCESS_OPERATOR") ? { type: "PROPERTY_ACCESS_OPERATOR" } : PROPERTY_ACCESS_OPERATOR), "_", "property_access$subexpression$1"], "postprocess": 
            // Allowing property to be <array_subscript> is currently a hack.
            // A better way would be to allow <property_access> on the left side of array_subscript,
            // but we currently can't do that because of another hack that requires
            // %ARRAY_IDENTIFIER on the left side of <array_subscript>.
            ([object, _1, dot, _2, [property]]) => {
                return {
                    type: NodeType.property_access,
                    object: addComments(object, { trailing: _1 }),
                    operator: dot.text,
                    property: addComments(property, { leading: _2 }),
                };
            }
        },
        { "name": "between_predicate", "symbols": [(lexer.has("BETWEEN") ? { type: "BETWEEN" } : BETWEEN), "_", "andless_expression_chain", "_", (lexer.has("AND") ? { type: "AND" } : AND), "_", "andless_expression"], "postprocess": ([betweenToken, _1, expr1, _2, andToken, _3, expr2]) => ({
                type: NodeType.between_predicate,
                betweenKw: toKeywordNode(betweenToken),
                expr1: addCommentsToArray(expr1, { leading: _1, trailing: _2 }),
                andKw: toKeywordNode(andToken),
                expr2: [addComments(expr2, { leading: _3 })],
            })
        },
        { "name": "case_expression$ebnf$1", "symbols": ["expression_chain_"], "postprocess": id },
        { "name": "case_expression$ebnf$1", "symbols": [], "postprocess": () => null },
        { "name": "case_expression$ebnf$2", "symbols": [] },
        { "name": "case_expression$ebnf$2", "symbols": ["case_expression$ebnf$2", "case_clause"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "case_expression", "symbols": [(lexer.has("CASE") ? { type: "CASE" } : CASE), "_", "case_expression$ebnf$1", "case_expression$ebnf$2", (lexer.has("END") ? { type: "END" } : END)], "postprocess": ([caseToken, _, expr, clauses, endToken]) => ({
                type: NodeType.case_expression,
                caseKw: addComments(toKeywordNode(caseToken), { trailing: _ }),
                endKw: toKeywordNode(endToken),
                expr: expr || [],
                clauses,
            })
        },
        { "name": "case_clause", "symbols": [(lexer.has("WHEN") ? { type: "WHEN" } : WHEN), "_", "expression_chain_", (lexer.has("THEN") ? { type: "THEN" } : THEN), "_", "expression_chain_"], "postprocess": ([whenToken, _1, cond, thenToken, _2, expr]) => ({
                type: NodeType.case_when,
                whenKw: addComments(toKeywordNode(whenToken), { trailing: _1 }),
                thenKw: addComments(toKeywordNode(thenToken), { trailing: _2 }),
                condition: cond,
                result: expr,
            })
        },
        { "name": "case_clause", "symbols": [(lexer.has("ELSE") ? { type: "ELSE" } : ELSE), "_", "expression_chain_"], "postprocess": ([elseToken, _, expr]) => ({
                type: NodeType.case_else,
                elseKw: addComments(toKeywordNode(elseToken), { trailing: _ }),
                result: expr,
            })
        },
        { "name": "comma$subexpression$1", "symbols": [(lexer.has("COMMA") ? { type: "COMMA" } : COMMA)] },
        { "name": "comma", "symbols": ["comma$subexpression$1"], "postprocess": ([[token]]) => ({ type: NodeType.comma }) },
        { "name": "asterisk$subexpression$1", "symbols": [(lexer.has("ASTERISK") ? { type: "ASTERISK" } : ASTERISK)] },
        { "name": "asterisk", "symbols": ["asterisk$subexpression$1"], "postprocess": ([[token]]) => ({ type: NodeType.operator, text: token.text }) },
        { "name": "operator$subexpression$1", "symbols": [(lexer.has("OPERATOR") ? { type: "OPERATOR" } : OPERATOR)] },
        { "name": "operator", "symbols": ["operator$subexpression$1"], "postprocess": ([[token]]) => ({ type: NodeType.operator, text: token.text }) },
        { "name": "identifier$subexpression$1", "symbols": [(lexer.has("IDENTIFIER") ? { type: "IDENTIFIER" } : IDENTIFIER)] },
        { "name": "identifier$subexpression$1", "symbols": [(lexer.has("QUOTED_IDENTIFIER") ? { type: "QUOTED_IDENTIFIER" } : QUOTED_IDENTIFIER)] },
        { "name": "identifier$subexpression$1", "symbols": [(lexer.has("VARIABLE") ? { type: "VARIABLE" } : VARIABLE)] },
        { "name": "identifier", "symbols": ["identifier$subexpression$1"], "postprocess": ([[token]]) => ({ type: NodeType.identifier, quoted: token.type !== "IDENTIFIER", text: token.text }) },
        { "name": "parameter$subexpression$1", "symbols": [(lexer.has("NAMED_PARAMETER") ? { type: "NAMED_PARAMETER" } : NAMED_PARAMETER)] },
        { "name": "parameter$subexpression$1", "symbols": [(lexer.has("QUOTED_PARAMETER") ? { type: "QUOTED_PARAMETER" } : QUOTED_PARAMETER)] },
        { "name": "parameter$subexpression$1", "symbols": [(lexer.has("NUMBERED_PARAMETER") ? { type: "NUMBERED_PARAMETER" } : NUMBERED_PARAMETER)] },
        { "name": "parameter$subexpression$1", "symbols": [(lexer.has("POSITIONAL_PARAMETER") ? { type: "POSITIONAL_PARAMETER" } : POSITIONAL_PARAMETER)] },
        { "name": "parameter$subexpression$1", "symbols": [(lexer.has("CUSTOM_PARAMETER") ? { type: "CUSTOM_PARAMETER" } : CUSTOM_PARAMETER)] },
        { "name": "parameter", "symbols": ["parameter$subexpression$1"], "postprocess": ([[token]]) => ({ type: NodeType.parameter, key: token.key, text: token.text }) },
        { "name": "literal$subexpression$1", "symbols": [(lexer.has("NUMBER") ? { type: "NUMBER" } : NUMBER)] },
        { "name": "literal$subexpression$1", "symbols": [(lexer.has("STRING") ? { type: "STRING" } : STRING)] },
        { "name": "literal", "symbols": ["literal$subexpression$1"], "postprocess": ([[token]]) => ({ type: NodeType.literal, text: token.text }) },
        { "name": "keyword$subexpression$1", "symbols": [(lexer.has("RESERVED_KEYWORD") ? { type: "RESERVED_KEYWORD" } : RESERVED_KEYWORD)] },
        { "name": "keyword$subexpression$1", "symbols": [(lexer.has("RESERVED_KEYWORD_PHRASE") ? { type: "RESERVED_KEYWORD_PHRASE" } : RESERVED_KEYWORD_PHRASE)] },
        { "name": "keyword$subexpression$1", "symbols": [(lexer.has("RESERVED_JOIN") ? { type: "RESERVED_JOIN" } : RESERVED_JOIN)] },
        { "name": "keyword", "symbols": ["keyword$subexpression$1"], "postprocess": ([[token]]) => toKeywordNode(token)
        },
        { "name": "data_type$subexpression$1", "symbols": [(lexer.has("RESERVED_DATA_TYPE") ? { type: "RESERVED_DATA_TYPE" } : RESERVED_DATA_TYPE)] },
        { "name": "data_type$subexpression$1", "symbols": [(lexer.has("RESERVED_DATA_TYPE_PHRASE") ? { type: "RESERVED_DATA_TYPE_PHRASE" } : RESERVED_DATA_TYPE_PHRASE)] },
        { "name": "data_type", "symbols": ["data_type$subexpression$1"], "postprocess": ([[token]]) => toDataTypeNode(token)
        },
        { "name": "data_type", "symbols": [(lexer.has("RESERVED_PARAMETERIZED_DATA_TYPE") ? { type: "RESERVED_PARAMETERIZED_DATA_TYPE" } : RESERVED_PARAMETERIZED_DATA_TYPE), "_", "parenthesis"], "postprocess": ([nameToken, _, parens]) => ({
                type: NodeType.parameterized_data_type,
                dataType: addComments(toDataTypeNode(nameToken), { trailing: _ }),
                parenthesis: parens,
            })
        },
        { "name": "logic_operator$subexpression$1", "symbols": [(lexer.has("AND") ? { type: "AND" } : AND)] },
        { "name": "logic_operator$subexpression$1", "symbols": [(lexer.has("OR") ? { type: "OR" } : OR)] },
        { "name": "logic_operator$subexpression$1", "symbols": [(lexer.has("XOR") ? { type: "XOR" } : XOR)] },
        { "name": "logic_operator", "symbols": ["logic_operator$subexpression$1"], "postprocess": ([[token]]) => toKeywordNode(token)
        },
        { "name": "other_keyword$subexpression$1", "symbols": [(lexer.has("WHEN") ? { type: "WHEN" } : WHEN)] },
        { "name": "other_keyword$subexpression$1", "symbols": [(lexer.has("THEN") ? { type: "THEN" } : THEN)] },
        { "name": "other_keyword$subexpression$1", "symbols": [(lexer.has("ELSE") ? { type: "ELSE" } : ELSE)] },
        { "name": "other_keyword$subexpression$1", "symbols": [(lexer.has("END") ? { type: "END" } : END)] },
        { "name": "other_keyword", "symbols": ["other_keyword$subexpression$1"], "postprocess": ([[token]]) => toKeywordNode(token)
        },
        { "name": "_$ebnf$1", "symbols": [] },
        { "name": "_$ebnf$1", "symbols": ["_$ebnf$1", "comment"], "postprocess": (d) => d[0].concat([d[1]]) },
        { "name": "_", "symbols": ["_$ebnf$1"], "postprocess": ([comments]) => comments },
        { "name": "comment", "symbols": [(lexer.has("LINE_COMMENT") ? { type: "LINE_COMMENT" } : LINE_COMMENT)], "postprocess": ([token]) => ({
                type: NodeType.line_comment,
                text: token.text,
                precedingWhitespace: token.precedingWhitespace,
            })
        },
        { "name": "comment", "symbols": [(lexer.has("BLOCK_COMMENT") ? { type: "BLOCK_COMMENT" } : BLOCK_COMMENT)], "postprocess": ([token]) => ({
                type: NodeType.block_comment,
                text: token.text,
                precedingWhitespace: token.precedingWhitespace,
            })
        },
        { "name": "comment", "symbols": [(lexer.has("DISABLE_COMMENT") ? { type: "DISABLE_COMMENT" } : DISABLE_COMMENT)], "postprocess": ([token]) => ({
                type: NodeType.disable_comment,
                text: token.text,
                precedingWhitespace: token.precedingWhitespace,
            })
        }
    ],
    ParserStart: "main",
};
export default grammar;
//# sourceMappingURL=grammar.js.map