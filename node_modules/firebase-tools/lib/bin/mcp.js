#!/usr/bin/env node
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.mcp = mcp;
const path_1 = require("path");
const promises_1 = require("fs/promises");
const os_1 = require("os");
const util_1 = require("util");
const logger_1 = require("../logger");
const index_1 = require("../mcp/index");
const env_1 = require("../env");
const index_js_1 = require("../mcp/prompts/index.js");
const index_js_2 = require("../mcp/resources/index.js");
const index_js_3 = require("../mcp/tools/index.js");
const types_1 = require("../mcp/types");
const STARTUP_MESSAGE = `
This is a running process of the Firebase MCP server. This command should only be executed by an MCP client. An example MCP client configuration might be:

{
  "mcpServers": {
    "firebase": {
      "command": "firebase",
      "args": ["mcp", "--dir", "/path/to/firebase/project"]
    }
  }
}
`;
const HELP_TEXT = `Usage: firebase mcp [options]

Description:
  Starts the Model Context Protocol (MCP) server for the Firebase CLI. This server provides a
  standardized way for AI agents and IDEs to interact with your Firebase project.

Tool Discovery & Loading:
  The server automatically determines which tools to expose based on your project context.

  1. Auto-Detection (Default):
     - Scans 'firebase.json' for configured services (e.g., Hosting, Firestore).
     - Checks enabled Google Cloud APIs for the active project.
     - Inspects project files for specific SDKs (e.g., Crashlytics in Android/iOS).

  2. Manual Overrides:
     - Use '--only' to restrict tool discovery to specific feature sets (e.g., core, firestore).
     - Use '--tools' to disable auto-detection entirely and load specific tools by name.

Options:
  --dir <path>              Project root directory (defaults to current working directory).
  --only <features>         Comma-separated list of features to enable (e.g. core, firestore).
                            If specified, auto-detection is disabled for other features.
  --tools <tools>           Comma-separated list of specific tools to enable. Disables
                            auto-detection entirely.
  --mode <mode>             Server mode: stdio, sse (defaults to stdio).
  --port <port>             The port to listen on when running in SSE mode (defaults to 3000).
  -h, --help                Show this help message.
`;
async function mcp() {
    const { values } = (0, util_1.parseArgs)({
        options: {
            only: { type: "string", default: "" },
            tools: { type: "string", default: "" },
            dir: { type: "string" },
            mode: { type: "string", default: "stdio" },
            port: { type: "string", default: "3000" },
            "generate-tool-list": { type: "boolean", default: false },
            "generate-prompt-list": { type: "boolean", default: false },
            "generate-resource-list": { type: "boolean", default: false },
            help: { type: "boolean", default: false, short: "h" },
        },
        allowPositionals: true,
    });
    let earlyExit = false;
    if (values.help) {
        console.log(HELP_TEXT);
        earlyExit = true;
    }
    if (values["generate-tool-list"]) {
        console.log(await (0, index_js_3.markdownDocsOfTools)());
        earlyExit = true;
    }
    if (values["generate-prompt-list"]) {
        console.log((0, index_js_1.markdownDocsOfPrompts)());
        earlyExit = true;
    }
    if (values["generate-resource-list"]) {
        console.log((0, index_js_2.markdownDocsOfResources)());
        earlyExit = true;
    }
    if (earlyExit)
        return;
    if (values.mode !== "stdio" && values.mode !== "sse") {
        console.error("Error: --mode must be either 'stdio' or 'sse'");
        process.exit(1);
    }
    (0, env_1.setFirebaseMcp)(true);
    const mcpLogDir = (0, path_1.join)((0, os_1.homedir)(), ".cache", "firebase");
    await (0, promises_1.mkdir)(mcpLogDir, { recursive: true });
    (0, logger_1.useFileLogger)((0, path_1.join)(mcpLogDir, "firebase-debug.log"));
    const activeFeatures = (values.only || "")
        .split(",")
        .map((f) => f.trim())
        .filter((f) => types_1.SERVER_FEATURES.includes(f));
    const enabledTools = (values.tools || "")
        .split(",")
        .map((t) => t.trim())
        .filter((t) => t.length > 0);
    const server = new index_1.FirebaseMcpServer({
        activeFeatures,
        enabledTools,
        projectRoot: values.dir ? (0, path_1.resolve)(values.dir) : undefined,
    });
    await server.start({
        useSSE: values.mode === "sse",
        port: values.port ? parseInt(values.port, 10) : undefined,
    });
    if (process.stdin.isTTY)
        process.stderr.write(STARTUP_MESSAGE);
}
