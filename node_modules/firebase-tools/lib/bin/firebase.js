#!/usr/bin/env node
"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const semver = require("semver");
const pkg = require("../../package.json");
const IGNORED_WARNINGS = [
    "DEP0040",
];
process.on("warning", (warning) => {
    const nodeWarning = warning;
    if (nodeWarning.code && IGNORED_WARNINGS.includes(nodeWarning.code)) {
        return;
    }
    console.warn(nodeWarning.stack || nodeWarning.message);
});
const nodeVersion = process.version;
if (!semver.satisfies(nodeVersion, pkg.engines.node)) {
    console.error(`Firebase CLI v${pkg.version} is incompatible with Node.js ${nodeVersion} Please upgrade Node.js to version ${pkg.engines.node}`);
    process.exit(1);
}
if (process.argv[2] === "mcp" || process.argv[2] === "experimental:mcp") {
    const { mcp } = require("./mcp");
    mcp();
}
else {
    const { cli } = require("./cli");
    cli(pkg);
}
