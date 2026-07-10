"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.configstore = void 0;
const Configstore = require("configstore");
const pkg = require("../package.json");
exports.configstore = new Configstore(pkg.name);
