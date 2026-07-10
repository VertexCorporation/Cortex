"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.LoggingStdioServerTransport = void 0;
const stdio_js_1 = require("@modelcontextprotocol/sdk/server/stdio.js");
const fs_1 = require("fs");
const promises_1 = require("fs/promises");
class LoggingStdioServerTransport extends stdio_js_1.StdioServerTransport {
    constructor(path) {
        super();
        this.path = path;
        (0, fs_1.appendFileSync)(path, "--- new process start ---\n");
        const origOnData = this._ondata;
        this._ondata = (chunk) => {
            origOnData(chunk);
            (0, fs_1.appendFileSync)(path, chunk.toString(), { encoding: "utf8" });
        };
    }
    async send(message) {
        await super.send(message);
        await (0, promises_1.appendFile)(this.path, JSON.stringify(message) + "\n");
    }
}
exports.LoggingStdioServerTransport = LoggingStdioServerTransport;
