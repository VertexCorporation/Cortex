"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BUNDLE_PATH = void 0;
exports.genHookScript = genHookScript;
exports.BUNDLE_PATH = "/home/firebase/app/.firebase/.output/bundle.json";
function genHookScript(bundle, hook) {
    let hookSrc = hook.toString().trimLeft();
    if (!hookSrc.startsWith("(") && !hookSrc.startsWith("function ")) {
        hookSrc = `function ${hookSrc}`;
    }
    return `
const fs = require("node:fs");
const path = require("node:path");

const bundleDir = path.dirname("${exports.BUNDLE_PATH}");
if (!fs.existsSync(bundleDir)) {
  fs.mkdirSync(bundleDir, { recursive: true });
}
const bundle = (${hookSrc})(${JSON.stringify(bundle)});
fs.writeFileSync("${exports.BUNDLE_PATH}", JSON.stringify(bundle));
`;
}
