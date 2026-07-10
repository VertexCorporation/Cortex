"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.dataconnectTools = void 0;
const list_services_1 = require("./list_services");
const compile_1 = require("./compile");
const execute_1 = require("./execute");
exports.dataconnectTools = [compile_1.compile, list_services_1.list_services, execute_1.execute];
