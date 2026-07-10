"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.compileErrors = compileErrors;
const graphqlError_1 = require("../../../dataconnect/graphqlError");
const dataconnectEmulator_1 = require("../../../emulator/dataconnectEmulator");
async function compileErrors(configDir, errorFilter) {
    const errors = (await dataconnectEmulator_1.DataConnectEmulator.build({ configDir })).errors;
    return (errors
        ?.filter((e) => {
        const isOperationError = ["query", "mutation"].includes(e.path?.[0]);
        if (errorFilter === "operations")
            return isOperationError;
        if (errorFilter === "schema")
            return !isOperationError;
        return true;
    })
        .map(graphqlError_1.prettify)
        .join("\n") || "");
}
