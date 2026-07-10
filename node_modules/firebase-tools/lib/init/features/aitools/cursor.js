"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.cursor = void 0;
const path = require("path");
const templates_1 = require("../../../templates");
const promptUpdater_1 = require("./promptUpdater");
const CURSOR_MCP_PATH = ".cursor/mcp.json";
const CURSOR_RULES_DIR = ".cursor/rules";
exports.cursor = {
    name: "cursor",
    displayName: "Cursor",
    async configure(config, projectPath, enabledFeatures) {
        const files = [];
        let mcpUpdated = false;
        let existingMcpConfig = {};
        try {
            const existingMcp = config.readProjectFile(CURSOR_MCP_PATH);
            if (existingMcp) {
                existingMcpConfig = JSON.parse(existingMcp);
            }
        }
        catch (e) {
        }
        if (!existingMcpConfig.mcpServers?.firebase) {
            if (!existingMcpConfig.mcpServers) {
                existingMcpConfig.mcpServers = {};
            }
            existingMcpConfig.mcpServers.firebase = {
                command: "npx",
                args: ["-y", "firebase-tools", "mcp", "--dir", projectPath],
            };
            config.writeProjectFile(CURSOR_MCP_PATH, JSON.stringify(existingMcpConfig, null, 2));
            mcpUpdated = true;
        }
        files.push({ path: CURSOR_MCP_PATH, updated: mcpUpdated });
        const header = (0, templates_1.readTemplateSync)("init/aitools/cursor-rules-header.txt");
        const baseContent = (0, promptUpdater_1.generateFeaturePromptSection)("base");
        const basePromptPath = path.join(CURSOR_RULES_DIR, "FIREBASE_BASE.md");
        const baseResult = await (0, promptUpdater_1.replaceFirebaseFile)(config, basePromptPath, baseContent);
        files.push({ path: basePromptPath, updated: baseResult.updated });
        if (enabledFeatures.includes("functions")) {
            const functionsContent = (0, promptUpdater_1.generateFeaturePromptSection)("functions");
            const functionsPromptPath = path.join(CURSOR_RULES_DIR, "FIREBASE_FUNCTIONS.md");
            const functionsResult = await (0, promptUpdater_1.replaceFirebaseFile)(config, functionsPromptPath, functionsContent);
            files.push({ path: functionsPromptPath, updated: functionsResult.updated });
        }
        const imports = ["@FIREBASE_BASE.md"];
        if (enabledFeatures.includes("functions")) {
            imports.push("@FIREBASE_FUNCTIONS.md");
        }
        const importContent = `# Firebase Context\n\n${imports.join("\n")}\n`;
        const { content: mainContent } = (0, promptUpdater_1.generatePromptSection)(enabledFeatures, {
            customContent: importContent,
        });
        const fullContent = header + "\n" + mainContent;
        const firebaseMDCPath = path.join(CURSOR_RULES_DIR, "FIREBASE.mdc");
        const mainResult = await (0, promptUpdater_1.replaceFirebaseFile)(config, firebaseMDCPath, fullContent);
        files.push({ path: firebaseMDCPath, updated: mainResult.updated });
        return { files };
    },
};
