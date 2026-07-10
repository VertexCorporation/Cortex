"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vite_1 = require("vite");
const vite_plugin_singlefile_1 = require("vite-plugin-singlefile");
const path = require("path");
exports.default = (0, vite_1.defineConfig)({
    plugins: [(0, vite_plugin_singlefile_1.viteSingleFile)()],
    root: __dirname,
    build: {
        outDir: path.resolve(__dirname, "../../../../lib/mcp/apps/deploy"),
        emptyOutDir: true,
        rollupOptions: {
            input: path.resolve(__dirname, "mcp-app.html"),
        },
    },
});
