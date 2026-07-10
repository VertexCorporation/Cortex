"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isFirebaseStudio = isFirebaseStudio;
exports.isFirebaseMcp = isFirebaseMcp;
exports.setFirebaseMcp = setFirebaseMcp;
exports.detectAIAgent = detectAIAgent;
const fsutils_1 = require("./fsutils");
let googleIdxFolderExists;
function isFirebaseStudio() {
    if (googleIdxFolderExists === true || process.env.MONOSPACE_ENV)
        return true;
    if (googleIdxFolderExists === false)
        return false;
    googleIdxFolderExists = (0, fsutils_1.dirExistsSync)("/google/idx");
    return googleIdxFolderExists;
}
let isFirebaseMcpFlag = false;
function isFirebaseMcp() {
    return isFirebaseMcpFlag || process.env.IS_FIREBASE_MCP === "true";
}
function setFirebaseMcp(value) {
    isFirebaseMcpFlag = value;
    if (value) {
        process.env.IS_FIREBASE_MCP = "true";
    }
    else {
        delete process.env.IS_FIREBASE_MCP;
    }
}
function detectAIAgent() {
    const aiAgent = process.env.AI_AGENT?.trim();
    if (aiAgent) {
        return aiAgent;
    }
    if (process.env.ANTIGRAVITY_AGENT)
        return "antigravity";
    if (process.env.CLAUDECODE || process.env.CLAUDE_CODE)
        return "claude_code";
    if (process.env.CLINE_ACTIVE)
        return "cline";
    if (process.env.CODEX_SANDBOX || process.env.CODEX_CI || process.env.CODEX_THREAD_ID) {
        return "codex_cli";
    }
    if (process.env.CURSOR_AGENT ||
        process.env.CURSOR_TRACE_ID ||
        process.env.CURSOR_EXTENSION_HOST_ROLE === "agent-exec") {
        return "cursor";
    }
    if (process.env.GEMINI_CLI)
        return "gemini_cli";
    if (process.env.OPENCODE || process.env.OPENCODE_CLIENT)
        return "open_code";
    if (process.env.ANDROID_STUDIO_AGENT)
        return "android_studio_agent";
    if (process.env.KIRO_AGENT_PATH)
        return "kiro";
    if (process.env.COPILOT_MODEL ||
        process.env.COPILOT_ALLOW_ALL ||
        process.env.COPILOT_GITHUB_TOKEN) {
        return "github_copilot";
    }
    if (process.env.REPL_ID)
        return "replit";
    if (process.env.AUGMENT_AGENT)
        return "augment";
    return "unknown";
}
