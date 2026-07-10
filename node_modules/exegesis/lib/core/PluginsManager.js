"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const promise_breaker_1 = __importDefault(require("promise-breaker"));
function callFn(plugin, fnName, param) {
    const fnLength = plugin[fnName].length;
    if (fnLength < 2) {
        return plugin[fnName](param);
    }
    else {
        promise_breaker_1.default.call((done) => plugin[fnName](param, done));
    }
}
class PluginsManager {
    constructor(apiDoc, plugins) {
        this._plugins = plugins.map((plugin) => plugin.makeExegesisPlugin({ apiDoc }));
        this._preRoutingPlugins = this._plugins.filter((p) => !!p.preRouting);
        this._postRoutingPlugins = this._plugins.filter((p) => !!p.postRouting);
        this._postSecurityPlugins = this._plugins.filter((p) => !!p.postSecurity);
        this._postControllerPlugins = this._plugins.filter((p) => !!p.postController);
        this._postResponseValidation = this._plugins.filter((p) => !!p.postResponseValidation);
    }
    preCompile(data) {
        return __awaiter(this, void 0, void 0, function* () {
            for (const plugin of this._plugins) {
                if (plugin.preCompile) {
                    yield callFn(plugin, 'preCompile', data);
                }
            }
        });
    }
    preRouting(data) {
        return __awaiter(this, void 0, void 0, function* () {
            for (const plugin of this._preRoutingPlugins) {
                yield callFn(plugin, 'preRouting', data);
            }
        });
    }
    postRouting(pluginContext) {
        return __awaiter(this, void 0, void 0, function* () {
            for (const plugin of this._postRoutingPlugins) {
                yield callFn(plugin, 'postRouting', pluginContext);
            }
        });
    }
    postSecurity(pluginContext) {
        return __awaiter(this, void 0, void 0, function* () {
            for (const plugin of this._postSecurityPlugins) {
                yield callFn(plugin, 'postSecurity', pluginContext);
            }
        });
    }
    postController(context) {
        return __awaiter(this, void 0, void 0, function* () {
            for (const plugin of this._postControllerPlugins) {
                yield callFn(plugin, 'postController', context);
            }
        });
    }
    postResponseValidation(context) {
        return __awaiter(this, void 0, void 0, function* () {
            for (const plugin of this._postResponseValidation) {
                yield callFn(plugin, 'postResponseValidation', context);
            }
        });
    }
}
exports.default = PluginsManager;
//# sourceMappingURL=PluginsManager.js.map