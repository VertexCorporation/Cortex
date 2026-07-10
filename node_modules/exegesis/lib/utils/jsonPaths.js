"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.toUriFragment = toUriFragment;
exports.jsonPointerStartsWith = jsonPointerStartsWith;
exports.jsonPointerStripPrefix = jsonPointerStripPrefix;
const jsonPtr = __importStar(require("json-ptr"));
function normalize(path) {
    return jsonPtr.encodePointer(jsonPtr.JsonPointer.decode(path));
}
function toUriFragment(path) {
    return jsonPtr.encodeUriFragmentIdentifier(jsonPtr.JsonPointer.decode(path));
}
function jsonPointerStartsWith(path, prefix) {
    path = normalize(path);
    prefix = normalize(prefix);
    return path.startsWith(prefix);
}
function jsonPointerStripPrefix(path, prefix) {
    const isUriFragment = path.startsWith('#');
    path = normalize(path);
    prefix = normalize(prefix);
    if (path.startsWith(prefix)) {
        const answer = path.slice(prefix.length);
        if (isUriFragment) {
            return toUriFragment(answer);
        }
        else {
            return answer;
        }
    }
    else {
        return path;
    }
}
//# sourceMappingURL=jsonPaths.js.map