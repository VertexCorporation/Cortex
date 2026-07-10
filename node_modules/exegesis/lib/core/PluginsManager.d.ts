import * as exegesis from '../types';
import http from 'http';
export default class PluginsManager {
    private readonly _plugins;
    private readonly _preRoutingPlugins;
    private readonly _postRoutingPlugins;
    private readonly _postSecurityPlugins;
    private readonly _postControllerPlugins;
    private readonly _postResponseValidation;
    constructor(apiDoc: any, plugins: exegesis.ExegesisPlugin[]);
    preCompile(data: {
        apiDoc: any;
        options: exegesis.ExegesisOptions;
    }): Promise<void>;
    preRouting(data: {
        req: http.IncomingMessage;
        res: http.ServerResponse;
    }): Promise<void>;
    postRouting(pluginContext: exegesis.ExegesisPluginContext): Promise<void>;
    postSecurity(pluginContext: exegesis.ExegesisPluginContext): Promise<void>;
    postController(context: exegesis.ExegesisContext): Promise<void>;
    postResponseValidation(context: exegesis.ExegesisContext): Promise<void>;
}
