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
exports.loadControllersSync = loadControllersSync;
const fs_1 = __importDefault(require("fs"));
const glob = __importStar(require("glob"));
const path_1 = __importDefault(require("path"));
/**
 * Load a set of controllers.
 *
 * @param folder - The folder to load controllers from.
 * @param [pattern] - A glob pattern for controllers to load.  Defaults to only
 *   .js files.
 * @param [loader] - The function to call to load each controller.  Defaults to
 *   `require`.
 *
 * @example
 *   // Assuming controllers has files "foo.js" and "bar/bar.js", then `controllers`
 *   // will be a `{"foo", "foo.js", "bar/bar.js", "bar/bar"}` object.
 *   const controllers = loadControllersSync('controlers', '**\/*.js');
 */
function loadControllersSync(folder, pattern = '**/*.js', loader = require) {
    const controllerNames = glob.sync(pattern, { cwd: folder });
    return controllerNames.reduce((result, controllerName) => {
        const fullPath = path_1.default.resolve(folder, controllerName);
        if (fs_1.default.statSync(fullPath).isDirectory()) {
            // Skip directories.
            return result;
        }
        try {
            // Add the file at the full path
            const mod = loader(fullPath);
            result[controllerName] = mod;
            // Add the file at the full path, minus the extension
            const ext = path_1.default.extname(controllerName);
            result[controllerName.slice(0, -ext.length)] = mod;
            // If the file is an "index" file, then add it at the folder
            // name (unless there's already something there.)
            const basename = path_1.default.basename(controllerName, ext);
            if (basename === 'index') {
                const indexFolder = controllerName.slice(0, -(ext.length + basename.length + 1));
                result[indexFolder] = result[indexFolder] || mod;
            }
        }
        catch (err) {
            throw new Error(`Could not load controller '${fullPath}': ${err}`);
        }
        return result;
    }, {});
}
//# sourceMappingURL=loadControllers.js.map