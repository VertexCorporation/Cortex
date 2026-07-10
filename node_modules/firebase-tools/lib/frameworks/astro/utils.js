"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getBootstrapScript = getBootstrapScript;
exports.getConfig = getConfig;
exports.getAstroVersion = getAstroVersion;
const path_1 = require("path");
const utils_1 = require("../utils");
const semver_1 = require("semver");
const url_1 = require("url");
const { dynamicImport } = require(true && "../../dynamicImport");
function getBootstrapScript() {
    return `const entry = import('./server/entry.mjs');\nexport const handle = async (req, res) => (await entry).handler(req, res)`;
}
async function getConfig(cwd) {
    const astroDirectory = (0, path_1.dirname)(require.resolve("astro/package.json", { paths: [cwd] }));
    const version = getAstroVersion(cwd);
    let config;
    const configPath = (0, path_1.join)(astroDirectory, "dist", "core", "config", "config.js");
    if ((0, semver_1.gte)(version, "2.9.7")) {
        const { resolveConfig } = await dynamicImport(configPath);
        const { astroConfig } = await resolveConfig({ root: cwd }, "build");
        config = astroConfig;
    }
    else {
        const { openConfig } = await dynamicImport(configPath);
        const logging = undefined;
        const { astroConfig } = await openConfig({ cmd: "build", cwd, logging });
        config = astroConfig;
    }
    return {
        outDir: (0, path_1.relative)(cwd, (0, url_1.fileURLToPath)(config.outDir)),
        publicDir: (0, path_1.relative)(cwd, (0, url_1.fileURLToPath)(config.publicDir)),
        output: config.output,
        adapter: config.adapter,
    };
}
function getAstroVersion(cwd) {
    return (0, utils_1.findDependency)("astro", { cwd, depth: 0, omitDev: false })?.version;
}
