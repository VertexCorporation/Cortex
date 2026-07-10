"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.apptestingTools = void 0;
const experiments_1 = require("../../../experiments");
const tests_1 = require("./tests");
exports.apptestingTools = [];
if ((0, experiments_1.isEnabled)("mcpalpha")) {
    exports.apptestingTools.push(...[tests_1.run_tests, tests_1.check_status]);
}
