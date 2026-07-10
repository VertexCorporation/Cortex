"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.apptestingPrompts = void 0;
const experiments_1 = require("../../../experiments");
const run_test_1 = require("./run_test");
exports.apptestingPrompts = [];
if ((0, experiments_1.isEnabled)("mcpalpha")) {
    exports.apptestingPrompts.push(run_test_1.runTest);
}
