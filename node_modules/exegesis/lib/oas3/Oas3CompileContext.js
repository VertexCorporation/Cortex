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
const ld = __importStar(require("lodash"));
const jsonPtr = __importStar(require("json-ptr"));
const json_schema_resolve_ref_1 = require("../utils/json-schema-resolve-ref");
/**
 * This has common stuff that we want to pass all the way down through the OAS
 * heirarchy.  This also keeps track of the `path` that a given object was
 * generated from.
 */
class Oas3CompileContext {
    constructor(a, path, options) {
        if (a instanceof Oas3CompileContext) {
            // TODO: Could make this WAY more efficient with Object.create().
            const parent = a;
            this.path = parent.path.concat(path);
            this.openApiDoc = parent.openApiDoc;
            this.options = parent.options;
        }
        else if (options) {
            this.path = path.slice();
            this.openApiDoc = a;
            this.options = options;
        }
        else {
            throw new Error('Invalid parameters to Oas3CompileContext constructor');
        }
        this.jsonPointer = jsonPtr.encodePointer(this.path);
    }
    childContext(relativePath) {
        if (ld.isArray(relativePath)) {
            return new Oas3CompileContext(this, relativePath);
        }
        else {
            return new Oas3CompileContext(this, [relativePath]);
        }
    }
    resolveRef(ref) {
        return (0, json_schema_resolve_ref_1.resolveRef)(this.openApiDoc, ref);
    }
}
exports.default = Oas3CompileContext;
//# sourceMappingURL=Oas3CompileContext.js.map