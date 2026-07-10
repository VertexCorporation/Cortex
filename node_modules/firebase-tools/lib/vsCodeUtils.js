"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isVSCodeExtension = isVSCodeExtension;
exports.setIsVSCodeExtension = setIsVSCodeExtension;
let _IS_WEBPACKED_FOR_VSCE = false;
function isVSCodeExtension() {
    return _IS_WEBPACKED_FOR_VSCE;
}
function setIsVSCodeExtension(v) {
    _IS_WEBPACKED_FOR_VSCE = v;
}
