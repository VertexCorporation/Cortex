"use strict";
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const oasUtils_1 = require("../oasUtils");
const Path_1 = __importDefault(require("../Path"));
const PathResolver_1 = __importDefault(require("./PathResolver"));
const extensions_1 = require("../extensions");
class Paths {
    constructor(context, exegesisController) {
        this._pathResolver = new PathResolver_1.default();
        const { openApiDoc } = context;
        exegesisController = openApiDoc.paths[extensions_1.EXEGESIS_CONTROLLER] || exegesisController;
        for (const path of Object.keys(openApiDoc.paths)) {
            const pathObject = new Path_1.default(context.childContext(path), openApiDoc.paths[path], exegesisController);
            if ((0, oasUtils_1.isSpecificationExtension)(path)) {
                // Skip extentions
                continue;
            }
            this._pathResolver.registerPath(path, pathObject);
        }
    }
    /**
     * Given a `pathname` from a URL (e.g. "/foo/bar") this will return the
     * PathObject from the OpenAPI document's `paths` section.
     *
     * @param urlPathname - The pathname to search for.  Note that any
     *   URL prefix defined by the `servers` section of the OpenAPI doc needs
     *   to be stripped before calling this.
     * @returns A `{path, rawPathParams}` object.
     *   `rawPathParams` will be an object where keys are parameter names from path
     *   templating.  If the path cannot be resolved, returns null, although
     *   note that if the path is resolved and the operation is not found, this
     *   will return an object with a null `operationObject`.
     */
    resolvePath(urlPathname) {
        const result = this._pathResolver.resolvePath(urlPathname);
        if (result) {
            return {
                path: result.value,
                rawPathParams: result.rawPathParams,
                pathKey: result.path,
            };
        }
        else {
            return undefined;
        }
    }
}
exports.default = Paths;
//# sourceMappingURL=index.js.map