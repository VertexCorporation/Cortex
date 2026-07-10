"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExprParseError = void 0;
exports.isCelExpression = isCelExpression;
exports.resolveExpression = resolveExpression;
const error_1 = require("../../error");
const functional_1 = require("../../functional");
const paramRegexp = /params\.(\S+)/;
const CMP = /((?:!=)|(?:==)|(?:>=)|(?:<=)|>|<)/.source;
const identityRegexp = /{{ params\.(\S+) }}/;
const dualComparisonRegexp = new RegExp(/{{ params\.(\S+) CMP params\.(\S+) }}/.source.replace("CMP", CMP));
const comparisonRegexp = new RegExp(/{{ params\.(\S+) CMP (.+) }}/.source.replace("CMP", CMP));
const dualTernaryRegexp = new RegExp(/{{ params\.(\S+) CMP params\.(\S+) \? (.+) : (.+) }/.source.replace("CMP", CMP));
const ternaryRegexp = new RegExp(/{{ params\.(\S+) CMP (.+) \? (.+) : (.+) }/.source.replace("CMP", CMP));
const literalTernaryRegexp = /{{ params\.(\S+) \? (.+) : (.+) }/;
function listEquals(a, b) {
    return a.every((item) => b.includes(item)) && b.every((item) => a.includes(item));
}
function isCelExpression(value) {
    return typeof value === "string" && value.includes("{{") && value.includes("}}");
}
function isIdentityExpression(value) {
    return identityRegexp.test(value);
}
function isComparisonExpression(value) {
    return comparisonRegexp.test(value);
}
function isDualComparisonExpression(value) {
    return dualComparisonRegexp.test(value);
}
function isTernaryExpression(value) {
    return ternaryRegexp.test(value);
}
function isLiteralTernaryExpression(value) {
    return literalTernaryRegexp.test(value);
}
function isDualTernaryExpression(value) {
    return dualTernaryRegexp.test(value);
}
class ExprParseError extends error_1.FirebaseError {
}
exports.ExprParseError = ExprParseError;
function resolveExpression(wantType, expr, params) {
    expr = preprocessLists(wantType, expr, params);
    if (isIdentityExpression(expr)) {
        return resolveIdentity(wantType, expr, params);
    }
    else if (isDualTernaryExpression(expr)) {
        return resolveDualTernary(wantType, expr, params);
    }
    else if (isLiteralTernaryExpression(expr)) {
        return resolveLiteralTernary(wantType, expr, params);
    }
    else if (isTernaryExpression(expr)) {
        return resolveTernary(wantType, expr, params);
    }
    else if (isDualComparisonExpression(expr)) {
        return resolveDualComparison(expr, params);
    }
    else if (isComparisonExpression(expr)) {
        return resolveComparison(expr, params);
    }
    else {
        throw new ExprParseError("CEL expression '" + expr + "' is of an unsupported form");
    }
}
function preprocessLists(wantType, expr, params) {
    let rv = expr;
    const listMatcher = /\[[^\[\]]*\]/g;
    let match;
    while ((match = listMatcher.exec(expr)) != null) {
        const list = match[0];
        const resolved = resolveList("string", list, params);
        rv = rv.replace(list, JSON.stringify(resolved));
    }
    return rv;
}
function resolveList(wantType, list, params) {
    if (!list.startsWith("[") || !list.endsWith("]")) {
        throw new ExprParseError("Invalid list: must start with '[' and end with ']'");
    }
    else if (list === "[]") {
        return [];
    }
    const rv = [];
    const entries = list.slice(1, -1).split(",");
    for (const entry of entries) {
        const trimmed = entry.trim();
        if (trimmed.startsWith('"') && trimmed.endsWith('"')) {
            rv.push(trimmed.slice(1, -1));
        }
        else if (trimmed.startsWith("{{") && trimmed.endsWith("}}")) {
            rv.push(resolveExpression("string", trimmed, params));
        }
        else {
            const paramMatch = paramRegexp.exec(trimmed);
            if (!paramMatch) {
                throw new ExprParseError(`Malformed list component ${trimmed}`);
            }
            else if (!(paramMatch[1] in params)) {
                throw new ExprParseError(`List expansion referenced nonexistent param ${paramMatch[1]}`);
            }
            rv.push(resolveParamListOrLiteral("string", trimmed, params));
        }
    }
    return rv;
}
function assertType(wantType, paramName, paramValue) {
    if ((wantType === "string" && !paramValue.legalString) ||
        (wantType === "number" && !paramValue.legalNumber) ||
        (wantType === "boolean" && !paramValue.legalBoolean) ||
        (wantType === "string[]" && !paramValue.legalList)) {
        throw new ExprParseError(`Illegal type coercion of param ${paramName} to type ${wantType}`);
    }
}
function readParamValue(wantType, paramName, paramValue) {
    assertType(wantType, paramName, paramValue);
    if (wantType === "string") {
        return paramValue.asString();
    }
    else if (wantType === "number") {
        return paramValue.asNumber();
    }
    else if (wantType === "boolean") {
        return paramValue.asBoolean();
    }
    else if (wantType === "string[]") {
        return paramValue.asList();
    }
    else {
        (0, functional_1.assertExhaustive)(wantType);
    }
}
function resolveIdentity(wantType, expr, params) {
    const match = identityRegexp.exec(expr);
    if (!match) {
        throw new ExprParseError("Malformed CEL identity expression '" + expr + "'");
    }
    const name = match[1];
    const value = params[name];
    if (!value) {
        throw new ExprParseError("CEL identity expression '" + expr + "' was not resolvable to a param");
    }
    return readParamValue(wantType, name, value);
}
function resolveComparison(expr, params) {
    const match = comparisonRegexp.exec(expr);
    if (!match) {
        throw new ExprParseError("Malformed CEL comparison expression '" + expr + "'");
    }
    const cmp = match[2];
    const test = function (a, b) {
        switch (cmp) {
            case "!=":
                return Array.isArray(a) ? !listEquals(a, b) : a !== b;
            case "==":
                return Array.isArray(a) ? listEquals(a, b) : a === b;
            case ">=":
                return a >= b;
            case "<=":
                return a <= b;
            case ">":
                return a > b;
            case "<":
                return a < b;
            default:
                throw new ExprParseError("Illegal comparison operator '" + cmp + "'");
        }
    };
    const lhsName = match[1];
    const lhsVal = params[lhsName];
    if (!lhsVal) {
        throw new ExprParseError("CEL comparison expression '" + expr + "' references missing param " + lhsName);
    }
    let rhs;
    if (lhsVal.legalString) {
        rhs = resolveLiteral("string", match[3]);
        return test(lhsVal.asString(), rhs);
    }
    else if (lhsVal.legalNumber) {
        rhs = resolveLiteral("number", match[3]);
        return test(lhsVal.asNumber(), rhs);
    }
    else if (lhsVal.legalBoolean) {
        rhs = resolveLiteral("boolean", match[3]);
        return test(lhsVal.asBoolean(), rhs);
    }
    else if (lhsVal.legalList) {
        if (!["==", "!="].includes(cmp)) {
            throw new ExprParseError(`Unsupported comparison operation ${cmp} on list operands in expression ${expr}`);
        }
        rhs = resolveLiteral("string[]", match[3]);
        return test(lhsVal.asList(), rhs);
    }
    else {
        throw new ExprParseError(`Could not infer type of param ${lhsName} used in comparison operation`);
    }
}
function resolveDualComparison(expr, params) {
    const match = dualComparisonRegexp.exec(expr);
    if (!match) {
        throw new ExprParseError("Malformed CEL comparison expression '" + expr + "'");
    }
    const cmp = match[2];
    const test = function (a, b) {
        switch (cmp) {
            case "!=":
                return Array.isArray(a) ? !listEquals(a, b) : a !== b;
            case "==":
                return Array.isArray(a) ? listEquals(a, b) : a === b;
            case ">=":
                return a >= b;
            case "<=":
                return a <= b;
            case ">":
                return a > b;
            case "<":
                return a < b;
            default:
                throw new ExprParseError("Illegal comparison operator '" + cmp + "'");
        }
    };
    const lhsName = match[1];
    const lhsVal = params[lhsName];
    if (!lhsVal) {
        throw new ExprParseError("CEL comparison expression '" + expr + "' references missing param " + lhsName);
    }
    const rhsName = match[3];
    const rhsVal = params[rhsName];
    if (!rhsVal) {
        throw new ExprParseError("CEL comparison expression '" + expr + "' references missing param " + lhsName);
    }
    if (lhsVal.legalString) {
        if (!rhsVal.legalString) {
            throw new ExprParseError(`CEL comparison expression ${expr} has type mismatch between the operands`);
        }
        return test(lhsVal.asString(), rhsVal.asString());
    }
    else if (lhsVal.legalNumber) {
        if (!rhsVal.legalNumber) {
            throw new ExprParseError(`CEL comparison expression ${expr} has type mismatch between the operands`);
        }
        return test(lhsVal.asNumber(), rhsVal.asNumber());
    }
    else if (lhsVal.legalBoolean) {
        if (!rhsVal.legalBoolean) {
            throw new ExprParseError(`CEL comparison expression ${expr} has type mismatch between the operands`);
        }
        return test(lhsVal.asBoolean(), rhsVal.asBoolean());
    }
    else if (lhsVal.legalList) {
        if (!rhsVal.legalList) {
            throw new ExprParseError(`CEL comparison expression ${expr} has type mismatch between the operands`);
        }
        if (!["==", "!="].includes(cmp)) {
            throw new ExprParseError(`Unsupported comparison operation ${cmp} on list operands in expression ${expr}`);
        }
        return test(lhsVal.asList(), rhsVal.asList());
    }
    else {
        throw new ExprParseError(`could not infer type of param ${lhsName} used in comparison operation`);
    }
}
function resolveTernary(wantType, expr, params) {
    const match = ternaryRegexp.exec(expr);
    if (!match) {
        throw new ExprParseError("malformed CEL ternary expression '" + expr + "'");
    }
    const comparisonExpr = `{{ params.${match[1]} ${match[2]} ${match[3]} }}`;
    const isTrue = resolveComparison(comparisonExpr, params);
    if (isTrue) {
        return resolveParamListOrLiteral(wantType, match[4], params);
    }
    else {
        return resolveParamListOrLiteral(wantType, match[5], params);
    }
}
function resolveDualTernary(wantType, expr, params) {
    const match = dualTernaryRegexp.exec(expr);
    if (!match) {
        throw new ExprParseError("Malformed CEL ternary expression '" + expr + "'");
    }
    const comparisonExpr = `{{ params.${match[1]} ${match[2]} params.${match[3]} }}`;
    const isTrue = resolveDualComparison(comparisonExpr, params);
    if (isTrue) {
        return resolveParamListOrLiteral(wantType, match[4], params);
    }
    else {
        return resolveParamListOrLiteral(wantType, match[5], params);
    }
}
function resolveLiteralTernary(wantType, expr, params) {
    const match = literalTernaryRegexp.exec(expr);
    if (!match) {
        throw new ExprParseError("Malformed CEL ternary expression '" + expr + "'");
    }
    const paramName = match[1];
    const paramValue = params[match[1]];
    if (!paramValue) {
        throw new ExprParseError("CEL ternary expression '" + expr + "' references missing param " + paramName);
    }
    if (!paramValue.legalBoolean) {
        throw new ExprParseError("CEL ternary expression '" + expr + "' is conditional on non-boolean param " + paramName);
    }
    if (paramValue.asBoolean()) {
        return resolveParamListOrLiteral(wantType, match[2], params);
    }
    else {
        return resolveParamListOrLiteral(wantType, match[3], params);
    }
}
function resolveParamListOrLiteral(wantType, field, params) {
    const match = paramRegexp.exec(field);
    if (!match) {
        return resolveLiteral(wantType, field);
    }
    const paramValue = params[match[1]];
    if (!paramValue) {
        throw new ExprParseError("CEL expression resolved to the value of a missing param " + match[1]);
    }
    return readParamValue(wantType, match[1], paramValue);
}
function resolveLiteral(wantType, value) {
    if (paramRegexp.exec(value)) {
        throw new ExprParseError("CEL tried to evaluate param." + value + " in a context which only permits literal values");
    }
    if (wantType === "string[]") {
        const parsed = JSON.parse(value);
        if (!Array.isArray(parsed)) {
            throw new ExprParseError(`CEL tried to read non-list ${JSON.stringify(parsed)} as a list`);
        }
        for (const shouldBeString of parsed) {
            if (typeof shouldBeString !== "string") {
                throw new ExprParseError(`Evaluated CEL list ${JSON.stringify(parsed)} contained non-string values`);
            }
        }
        return parsed;
    }
    else if (wantType === "number") {
        if (isNaN(+value)) {
            throw new ExprParseError("CEL literal " + value + " does not seem to be a number");
        }
        return +value;
    }
    else if (wantType === "string") {
        if (!value.startsWith('"') || !value.endsWith('"')) {
            throw new ExprParseError("CEL literal " + value + ' does not seem to be a "-delimited string');
        }
        return value.slice(1, -1);
    }
    else if (wantType === "boolean") {
        if (value === "true") {
            return true;
        }
        else if (value === "false") {
            return false;
        }
        else {
            throw new ExprParseError("CEL literal " + value + "does not seem to be a true/false boolean");
        }
    }
    else {
        throw new ExprParseError("CEL literal '" + value + "' somehow was resolved with a non-string/number/boolean type");
    }
}
