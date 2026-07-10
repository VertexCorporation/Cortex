"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const requireAuth_1 = require("../requireAuth");
exports.command = new command_1.Command("mcp")
    .alias("experimental:mcp")
    .description("Run the multi-modal conversational platform (MCP) server.")
    .before(requireAuth_1.requireAuth)
    .action(() => {
    throw new Error("MCP logic is implemented elsewhere, this should never be reached.");
});
