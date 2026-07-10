"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.claude = void 0;
const promptUpdater_1 = require("./promptUpdater");
const MCP_CONFIG_PATH = ".mcp.json";
const CLAUDE_PROMPT_PATH = "CLAUDE.md";
exports.claude = {
    name: "claude",
    displayName: "Claude Code",
    async configure(config, projectPath, enabledFeatures) {
        const files = [];
        let existingConfig = {};
        let mcpUpdated = false;
        try {
            const existingContent = config.readProjectFile(MCP_CONFIG_PATH);
            if (existingContent) {
                existingConfig = JSON.parse(existingContent);
            }
        }
        catch (e) {
        }
        if (!existingConfig.mcpServers?.firebase) {
            if (!existingConfig.mcpServers) {
                existingConfig.mcpServers = {};
            }
            existingConfig.mcpServers.firebase = {
                command: "npx",
                args: ["-y", "firebase-tools", "mcp", "--dir", projectPath],
            };
            config.writeProjectFile(MCP_CONFIG_PATH, JSON.stringify(existingConfig, null, 2));
            mcpUpdated = true;
        }
        files.push({ path: MCP_CONFIG_PATH, updated: mcpUpdated });
        const { updated } = await (0, promptUpdater_1.updateFirebaseSection)(config, CLAUDE_PROMPT_PATH, enabledFeatures, {
            interactive: true,
        });
        files.push({
            path: CLAUDE_PROMPT_PATH,
            updated,
        });
        return { files };
    },
};
