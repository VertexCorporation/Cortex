"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.init_ui = exports.RESOURCE_MIME_TYPE = void 0;
const resource_1 = require("../resource");
const path = require("path");
const fs = require("fs/promises");
exports.RESOURCE_MIME_TYPE = "text/html;profile=mcp-app";
const resourceUri = "ui://core/init/mcp-app.html";
exports.init_ui = (0, resource_1.resource)({
    uri: resourceUri,
    name: "Init UI",
    description: "Visual interface for Firebase Init",
    mimeType: exports.RESOURCE_MIME_TYPE,
}, async (_uri, _ctx) => {
    try {
        const htmlPath = path.join(__dirname, "../apps/init/mcp-app.html");
        const html = await fs.readFile(htmlPath, "utf-8");
        return {
            contents: [
                {
                    uri: resourceUri,
                    mimeType: exports.RESOURCE_MIME_TYPE,
                    text: html,
                },
            ],
        };
    }
    catch (e) {
        throw new Error(`Failed to load Init UI: ${e.message}`);
    }
});
