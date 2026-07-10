"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.corePrompts = void 0;
const init_1 = require("./init");
const deploy_1 = require("./deploy");
const corePrompts = [deploy_1.deploy, init_1.init];
exports.corePrompts = corePrompts;
