"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.appHostingTools = void 0;
const fetch_logs_1 = require("./fetch_logs");
const list_backends_1 = require("./list_backends");
exports.appHostingTools = [fetch_logs_1.fetch_logs, list_backends_1.list_backends];
