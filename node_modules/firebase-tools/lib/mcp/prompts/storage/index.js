"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.storagePrompts = void 0;
const generate_security_rules_1 = require("./generate_security_rules");
exports.storagePrompts = [];
exports.storagePrompts.push(generate_security_rules_1.generateSecurityRules);
