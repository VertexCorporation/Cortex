"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.schemaToText = schemaToText;
exports.connectorToText = connectorToText;
exports.sourceToText = sourceToText;
exports.graphqlResponseToToolResponse = graphqlResponseToToolResponse;
exports.parseVariables = parseVariables;
const js_yaml_1 = require("js-yaml");
const types_1 = require("../../../dataconnect/types");
const util_1 = require("../../util");
function schemaToText(s) {
    return ((0, js_yaml_1.dump)({
        name: s.name,
        datasources: s.datasources,
    }) +
        "\n\n" +
        sourceToText(s.source));
}
function connectorToText(s) {
    return ((0, js_yaml_1.dump)({
        name: s.name,
    }) +
        "\n\n" +
        sourceToText(s.source));
}
function sourceToText(s) {
    let output = "";
    s.files?.forEach((f) => {
        output += `\n# ${f.path}`;
        output += "\n```graphql\n";
        output += `${f.content.trim()}\n`;
        output += "```\n";
    });
    return output;
}
function graphqlResponseToToolResponse(g) {
    if ((0, types_1.isGraphQLResponse)(g)) {
        const isError = g.errors?.length > 0;
        const contentString = `${isError ? "A GraphQL error occurred while executing the operation:" : ""}${JSON.stringify(g, null, 2)}`;
        return {
            isError,
            content: [{ type: "text", text: contentString }],
        };
    }
    else {
        return (0, util_1.mcpError)(JSON.stringify(g, null, 2));
    }
}
function parseVariables(unparsedVariables) {
    let obj;
    try {
        obj = JSON.parse(unparsedVariables || "{}");
    }
    catch (e) {
        throw new Error("Provided variables string `" + unparsedVariables + "` is not valid JSON.");
    }
    if (typeof obj !== "object" || obj == null)
        throw new Error("not an object");
    return obj;
}
