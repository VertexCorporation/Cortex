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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.extractSchema = extractSchema;
const lodash_1 = __importDefault(require("lodash"));
const json_schema_traverse_1 = __importDefault(require("json-schema-traverse"));
const jsonPaths = __importStar(require("./jsonPaths"));
const jsonPtr = __importStar(require("json-ptr"));
const json_schema_resolve_ref_1 = require("./json-schema-resolve-ref");
function extractSchemaPriv(subtreeRef, refResolver, options, context) {
    const subtreeObject = refResolver(subtreeRef);
    if (!subtreeObject) {
        throw new Error(`Could not find ref ${subtreeRef}`);
    }
    const result = lodash_1.default.cloneDeep(subtreeObject);
    const ctx = context || {
        result: result,
        replaced: {},
        replacements: [],
        schemaCount: 0,
        rootSubtreeRef: subtreeRef,
    };
    (0, json_schema_traverse_1.default)(result, (schema) => {
        if (schema.$ref && typeof schema.$ref === 'string') {
            if (ctx.replaced[schema.$ref]) {
                schema.$ref = ctx.replaced[schema.$ref];
            }
            else if (jsonPaths.jsonPointerStartsWith(schema.$ref, ctx.rootSubtreeRef + '/')) {
                ctx.replaced[schema.$ref] = jsonPaths.jsonPointerStripPrefix(schema.$ref, ctx.rootSubtreeRef);
                schema.$ref = ctx.replaced[schema.$ref];
            }
            else if (!refResolver(schema.$ref)) {
                // Don't know how to resolve this ref
                if (!options.skipUnknownRefs) {
                    throw new Error(`Can't find ref ${schema.$ref}`);
                }
            }
            else {
                ctx.result.definitions = ctx.result.definitions || {};
                // Find a name to store this under in 'definitions'.
                //
                // Because we try to pick a "sensible" name for the new definition,
                // when we recurse into `extractSchemaPriv` below, if there's a child
                // schema with the same name as the one we just picked, we could
                // end up accidentally giving two different schemas the same name
                // and clobbering one with the other.  To avoid this, we record
                // all the `newRefSuffix`es we pick in `ctx.replacements`, and
                // then we can make sure this doesn't happen.
                const origRef = schema.$ref;
                const jsonPath = jsonPtr.JsonPointer.decode(schema.$ref);
                let newRefSuffix = jsonPath.length > 0 ? `${jsonPath[jsonPath.length - 1]}` : undefined;
                while (!newRefSuffix ||
                    ctx.result.definitions[newRefSuffix] ||
                    ctx.replacements.includes(newRefSuffix)) {
                    newRefSuffix = `schema${ctx.schemaCount++}`;
                }
                ctx.replacements.push(newRefSuffix);
                // Do the replacement.
                schema.$ref = ctx.replaced[schema.$ref] = `#/definitions/${newRefSuffix}`;
                ctx.result.definitions[newRefSuffix] = extractSchemaPriv(origRef, refResolver, options, ctx);
            }
        }
    });
    return result;
}
/**
 * Extracts a subtree from a JSON document, fixing any "$ref" JSON refs so they
 * now
 *
 * @param document - The document to extract a subtree from.
 * @param subtree - A JSON ref to the subtree to extract, or a child node of `document`.
 * @param [options.resolveRef] - A function which, given a JSON reference, resolves the node
 *   it refers to.
 * @param [options.skipUnknownRefs] - If true, skip any unknown refs instead of
 *   throwing an error.
 * @returns the extracted document.  The returned document is a copy, and shares
 *   no children with the original document.
 */
function extractSchema(document, subtreeRef, options = {}) {
    const refResolver = options.resolveRef || json_schema_resolve_ref_1.resolveRef.bind(null, document);
    return extractSchemaPriv(subtreeRef, refResolver, options, undefined);
}
//# sourceMappingURL=jsonSchema.js.map