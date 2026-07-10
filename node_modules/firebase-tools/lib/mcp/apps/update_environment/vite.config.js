"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const vite_1 = require("vite");
const vite_plugin_singlefile_1 = require("vite-plugin-singlefile");
const path_1 = require("path");
exports.default = (0, vite_1.defineConfig)({
    plugins: [(0, vite_plugin_singlefile_1.viteSingleFile)()],
    root: __dirname,
    build: {
        outDir: path_1.default.resolve(__dirname, "../../../../lib/mcp/apps/update_environment"),
        emptyOutDir: true,
        rollupOptions: {
            input: path_1.default.resolve(__dirname, "mcp-app.html"),
        },
    },
});
