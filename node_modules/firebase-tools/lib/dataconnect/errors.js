"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getIncompatibleSchemaError = getIncompatibleSchemaError;
exports.getInvalidConnectors = getInvalidConnectors;
exports.getGQLErrors = getGQLErrors;
const graphqlError_1 = require("./graphqlError");
const INCOMPATIBLE_SCHEMA_ERROR_TYPESTRING = "IncompatibleSqlSchemaError";
const PRECONDITION_ERROR_TYPESTRING = "type.googleapis.com/google.rpc.PreconditionFailure";
const INCOMPATIBLE_CONNECTOR_TYPE = "INCOMPATIBLE_CONNECTOR";
function getIncompatibleSchemaError(err) {
    const incompatibles = errorDetails(err, INCOMPATIBLE_SCHEMA_ERROR_TYPESTRING);
    if (incompatibles.length === 0) {
        return undefined;
    }
    const incompatible = incompatibles[0];
    const preconditionErrs = errorDetails(err, PRECONDITION_ERROR_TYPESTRING);
    const violationTypes = (incompatible.violationType = preconditionErrs
        .flatMap((preCondErr) => preCondErr.violations)
        .flatMap((viol) => viol.type)
        .filter((type) => type === "INACCESSIBLE_SCHEMA" || type === "INCOMPATIBLE_SCHEMA"));
    incompatible.violationType = violationTypes[0];
    return incompatible;
}
function getInvalidConnectors(err) {
    const preconditionErrs = errorDetails(err, PRECONDITION_ERROR_TYPESTRING);
    const invalidConns = [];
    for (const preconditionErr of preconditionErrs) {
        const incompatibleConnViolation = preconditionErr?.violations?.filter((v) => v.type === INCOMPATIBLE_CONNECTOR_TYPE);
        const newConns = incompatibleConnViolation?.map((i) => i.subject) ?? [];
        invalidConns.push(...newConns);
    }
    return invalidConns;
}
function getGQLErrors(err) {
    const gqlErrs = errorDetails(err, "GraphqlError");
    return gqlErrs.map(graphqlError_1.prettify).join("\n");
}
function errorDetails(err, ofType) {
    const original = err.context?.body?.error || err?.original;
    const details = original?.details;
    return details?.filter((d) => d["@type"]?.includes(ofType)) || [];
}
