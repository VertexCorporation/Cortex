"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.BASE = void 0;
exports.value = value;
exports.labels = labels;
exports.isFirebaseManaged = isFirebaseManaged;
exports.BASE = "cli-firebase";
function value() {
    if (!process.env.FIREBASE_DEPLOY_AGENT) {
        return exports.BASE;
    }
    return [exports.BASE, process.env.FIREBASE_DEPLOY_AGENT].join("--");
}
function labels() {
    return {
        "deployment-tool": value(),
    };
}
function isFirebaseManaged(labels) {
    return labels?.["deployment-tool"]?.startsWith(exports.BASE);
}
