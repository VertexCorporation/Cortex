"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.isReadable = isReadable;
function isReadable(obj) {
    return obj && obj.pipe && typeof obj.pipe === 'function';
}
//# sourceMappingURL=typeUtils.js.map