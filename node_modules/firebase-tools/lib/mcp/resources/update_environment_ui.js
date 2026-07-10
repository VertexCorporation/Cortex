"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.update_environment_ui = void 0;
const resource_1 = require("../resource");
const path = require("path");
const fs = require("fs/promises");
const RESOURCE_MIME_TYPE = "text/html;profile=mcp-app";
const resourceUri = "ui://core/update_environment/mcp-app.html";
exports.update_environment_ui = (0, resource_1.resource)({
    uri: resourceUri,
    name: "Update Environment UI",
    description: "Visual interface for selecting active Firebase project",
    mimeType: RESOURCE_MIME_TYPE,
}, async () => {
    try {
        const htmlPath = path.join(__dirname, "../apps/update_environment/mcp-app.html");
        const html = await fs.readFile(htmlPath, "utf-8");
        return {
            contents: [
                {
                    uri: resourceUri,
                    mimeType: RESOURCE_MIME_TYPE,
                    text: html,
                },
            ],
        };
    }
    catch (e) {
        const message = e instanceof Error ? e.message : String(e);
        throw new Error(`Failed to load Update Environment UI: ${message}`);
    }
});
