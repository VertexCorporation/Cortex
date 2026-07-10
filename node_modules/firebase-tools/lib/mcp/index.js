"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.FirebaseMcpServer = void 0;
const index_js_1 = require("@modelcontextprotocol/sdk/server/index.js");
const stdio_js_1 = require("@modelcontextprotocol/sdk/server/stdio.js");
const sse_js_1 = require("@modelcontextprotocol/sdk/server/sse.js");
const express = require("express");
const cors = require("cors");
const types_js_1 = require("@modelcontextprotocol/sdk/types.js");
const crossSpawn = require("cross-spawn");
const node_fs_1 = require("node:fs");
const experiments = require("../experiments");
const command_1 = require("../command");
const config_1 = require("../config");
const configstore_1 = require("../configstore");
const hubClient_1 = require("../emulator/hubClient");
const env_1 = require("../env");
const projectUtils_1 = require("../projectUtils");
const rc_1 = require("../rc");
const requireAuth_1 = require("../requireAuth");
const timeout_1 = require("../timeout");
const track_1 = require("../track");
const errors_1 = require("./errors");
const logging_transport_1 = require("./logging-transport");
const index_1 = require("./prompts/index");
const resources_1 = require("./resources");
const index_2 = require("./tools/index");
const types_1 = require("./types");
const util_1 = require("./util");
const availability_1 = require("./util/availability");
const cloudbilling_1 = require("../gcp/cloudbilling");
const SERVER_VERSION = "0.3.0";
const cmd = new command_1.Command("mcp");
const orderedLogLevels = [
    "debug",
    "info",
    "notice",
    "warning",
    "error",
    "critical",
    "alert",
    "emergency",
];
class FirebaseMcpServer {
    async trackGA4(event, params = {}) {
        if (!this.clientInfo)
            await (0, timeout_1.timeoutFallback)(this.ready(), null, 2000);
        const clientInfoParams = {
            mcp_client_name: this.clientInfo?.name || "<unknown-client>",
            mcp_client_version: this.clientInfo?.version || "<unknown-version>",
            gemini_cli_extension: process.env.IS_GEMINI_CLI_EXTENSION ? "true" : "false",
        };
        return (0, track_1.trackGA4)(event, { ...params, ...clientInfoParams });
    }
    constructor(options) {
        this._ready = false;
        this._readyPromises = [];
        this._pendingMessages = [];
        this.currentLogLevel = process.env.FIREBASE_MCP_DEBUG_LOG ? "debug" : undefined;
        this.activeFeatures = options.activeFeatures;
        this.startupRoot = options.projectRoot || process.env.PROJECT_ROOT;
        this.enabledTools = options.enabledTools;
        this.server = new index_js_1.Server({ name: "firebase", version: SERVER_VERSION });
        this.server.registerCapabilities({
            tools: { listChanged: true },
            logging: {},
            prompts: { listChanged: true },
            resources: {},
        });
        this.server.setRequestHandler(types_js_1.ListToolsRequestSchema, this.mcpListTools.bind(this));
        this.server.setRequestHandler(types_js_1.CallToolRequestSchema, this.mcpCallTool.bind(this));
        this.server.setRequestHandler(types_js_1.ListPromptsRequestSchema, this.mcpListPrompts.bind(this));
        this.server.setRequestHandler(types_js_1.GetPromptRequestSchema, this.mcpGetPrompt.bind(this));
        this.server.setRequestHandler(types_js_1.ListResourceTemplatesRequestSchema, this.mcpListResourceTemplates.bind(this));
        this.server.setRequestHandler(types_js_1.ListResourcesRequestSchema, this.mcpListResources.bind(this));
        this.server.setRequestHandler(types_js_1.ReadResourceRequestSchema, this.mcpReadResource.bind(this));
        const onInitialized = () => {
            const clientInfo = this.server.getClientVersion();
            this.clientInfo = clientInfo;
            if (clientInfo?.name) {
                void this.trackGA4("mcp_client_connected");
                if (!process.env.AI_AGENT?.trim()) {
                    process.env.AI_AGENT = clientInfo.name;
                }
            }
            if (!this.clientInfo?.name)
                this.clientInfo = { name: "<unknown-client>" };
            this._ready = true;
            while (this._readyPromises.length) {
                this._readyPromises.pop()?.resolve();
            }
        };
        this.server.oninitialized = () => {
            void onInitialized();
        };
        this.server.setRequestHandler(types_js_1.SetLevelRequestSchema, async ({ params }) => {
            this.currentLogLevel = params.level;
            return {};
        });
        void this.detectProjectSetup();
    }
    ready() {
        if (this._ready)
            return Promise.resolve();
        return new Promise((resolve, reject) => {
            this._readyPromises.push({ resolve: resolve, reject });
        });
    }
    get clientName() {
        return this.clientInfo?.name ?? ((0, env_1.isFirebaseStudio)() ? "Firebase Studio" : "<unknown-client>");
    }
    get clientConfigKey() {
        return `mcp.clientConfigs.${this.clientName}:${this.startupRoot || process.cwd()}`;
    }
    getStoredClientConfig() {
        return configstore_1.configstore.get(this.clientConfigKey) || {};
    }
    updateStoredClientConfig(update) {
        const config = configstore_1.configstore.get(this.clientConfigKey) || {};
        const newConfig = { ...config, ...update };
        configstore_1.configstore.set(this.clientConfigKey, newConfig);
        return newConfig;
    }
    async detectProjectSetup() {
        await this.detectProjectRoot();
        if (this.activeFeatures?.length || this.enabledTools?.length)
            return;
        await this.detectActiveFeatures();
    }
    async detectProjectRoot() {
        await (0, timeout_1.timeoutFallback)(this.ready(), null, 2000);
        if (this.cachedProjectDir)
            return this.cachedProjectDir;
        const storedRoot = this.getStoredClientConfig().projectRoot;
        this.cachedProjectDir = storedRoot || this.startupRoot || process.cwd();
        this.logger.debug(`detected and cached project root: ${this.cachedProjectDir}`);
        return this.cachedProjectDir;
    }
    async detectActiveFeatures() {
        if (this.detectedFeatures?.length)
            return this.detectedFeatures;
        this.logger.debug("detecting active features of Firebase MCP server...");
        const projectId = (await this.getProjectId()) || "";
        const accountEmail = await this.getAuthenticatedUser();
        const isBillingEnabled = projectId ? await this.safeCheckBillingEnabled(projectId) : false;
        const ctx = this._createMcpContext(projectId, accountEmail, isBillingEnabled);
        const detected = await Promise.all(types_1.SERVER_FEATURES.map(async (f) => {
            const availabilityCheck = (0, availability_1.getDefaultFeatureAvailabilityCheck)(f);
            if (await availabilityCheck(ctx))
                return f;
            return null;
        }));
        this.detectedFeatures = detected.filter((f) => !!f);
        this.logger.debug(`detected features of Firebase MCP server:  ${this.detectedFeatures.join(", ") || "<none>"}`);
        return this.detectedFeatures;
    }
    async getEmulatorHubClient() {
        if (this.emulatorHubClient) {
            return this.emulatorHubClient;
        }
        const projectId = await this.getProjectId();
        this.emulatorHubClient = new hubClient_1.EmulatorHubClient(projectId);
        return this.emulatorHubClient;
    }
    async getEmulatorUrl(emulatorType) {
        const hubClient = await this.getEmulatorHubClient();
        if (!hubClient) {
            throw Error("Emulator Hub not found or is not running. You can start the emulator by running `firebase emulators:start` in your firebase project directory.");
        }
        const emulators = await hubClient.getEmulators();
        const emulatorInfo = emulators[emulatorType];
        if (!emulatorInfo) {
            throw Error(`No ${emulatorType} Emulator found running. Make sure your project firebase.json file includes ${emulatorType} and then rerun emulator using \`firebase emulators:start\` from your project directory.`);
        }
        const host = emulatorInfo.host.includes(":") ? `[${emulatorInfo.host}]` : emulatorInfo.host;
        return `http://${host}:${emulatorInfo.port}`;
    }
    async getAvailableTools() {
        const projectId = (await this.getProjectId()) || "";
        const accountEmail = await this.getAuthenticatedUser();
        const isBillingEnabled = projectId ? await this.safeCheckBillingEnabled(projectId) : false;
        const ctx = this._createMcpContext(projectId, accountEmail, isBillingEnabled);
        return (0, index_2.availableTools)(ctx, this.activeFeatures, this.detectedFeatures, this.enabledTools);
    }
    async getTool(name) {
        const tools = await this.getAvailableTools();
        return tools.find((t) => t.mcp.name === name) || null;
    }
    async getAvailablePrompts() {
        const projectId = (await this.getProjectId()) || "";
        const accountEmail = await this.getAuthenticatedUser();
        const isBillingEnabled = projectId ? await this.safeCheckBillingEnabled(projectId) : false;
        const ctx = this._createMcpContext(projectId, accountEmail, isBillingEnabled);
        return (0, index_1.availablePrompts)(ctx, this.activeFeatures, this.detectedFeatures);
    }
    async getPrompt(name) {
        const prompts = await this.getAvailablePrompts();
        return prompts.find((p) => p.mcp.name === name) || null;
    }
    setProjectRoot(newRoot) {
        this.updateStoredClientConfig({ projectRoot: newRoot });
        this.cachedProjectDir = newRoot || undefined;
        this.detectedFeatures = undefined;
        void this.server.sendToolListChanged();
        void this.server.sendPromptListChanged();
    }
    async resolveOptions() {
        const options = { cwd: this.cachedProjectDir, isMCP: true };
        await cmd.prepare(options);
        return options;
    }
    async getProjectId() {
        return (0, projectUtils_1.getProjectId)(await this.resolveOptions());
    }
    async getAuthenticatedUser(skipAutoAuth = false) {
        try {
            this.logger.debug("calling requireAuth");
            const email = await (0, requireAuth_1.requireAuth)(await this.resolveOptions(), skipAutoAuth);
            this.logger.debug(`detected authenticated account: ${email || "<none>"}`);
            return email ?? (skipAutoAuth ? null : "Application Default Credentials");
        }
        catch (e) {
            this.logger.debug(`error in requireAuth: ${e}`);
            return null;
        }
    }
    _createMcpContext(projectId, accountEmail, isBillingEnabled) {
        const options = { projectDir: this.cachedProjectDir, cwd: this.cachedProjectDir };
        return {
            projectId: projectId,
            host: this,
            config: config_1.Config.load(options, true) || new config_1.Config({}, options),
            rc: (0, rc_1.loadRC)(options),
            accountEmail,
            firebaseCliCommand: this._getFirebaseCliCommand(),
            isBillingEnabled,
        };
    }
    _getFirebaseCliCommand() {
        if (!this.cliCommand) {
            const testCommand = crossSpawn.sync("firebase --version");
            this.cliCommand = testCommand.error ? "npx firebase-tools@latest" : "firebase";
        }
        return this.cliCommand;
    }
    async mcpListTools() {
        await Promise.all([this.detectActiveFeatures(), this.detectProjectRoot()]);
        const hasActiveProject = !!(await this.getProjectId());
        await this.trackGA4("mcp_list_tools");
        const skipAutoAuthForStudio = (0, env_1.isFirebaseStudio)();
        this.logger.debug(`skip auto-auth in studio environment: ${skipAutoAuthForStudio}`);
        const availableTools = await this.getAvailableTools();
        const isMcpAppsEnabled = experiments.isEnabled("mcpapps");
        return {
            tools: availableTools.map((t) => {
                if (isMcpAppsEnabled)
                    return t.mcp;
                if (t.mcp._meta?.ui) {
                    const restMeta = { ...t.mcp._meta };
                    delete restMeta.ui;
                    return { ...t.mcp, _meta: restMeta };
                }
                return t.mcp;
            }),
            _meta: {
                projectRoot: this.cachedProjectDir,
                projectDetected: hasActiveProject,
                authenticatedUser: await this.getAuthenticatedUser(skipAutoAuthForStudio),
                activeFeatures: this.activeFeatures,
                detectedFeatures: this.detectedFeatures,
            },
        };
    }
    async mcpCallTool(request) {
        await this.detectProjectRoot();
        const toolName = request.params.name;
        const toolArgs = request.params.arguments ?? {};
        const tool = await this.getTool(toolName);
        if (!tool)
            throw new Error(`Tool '${toolName}' could not be found.`);
        if (!tool.mcp._meta?.optionalProjectDir) {
            if (!this.cachedProjectDir || !(0, node_fs_1.existsSync)(this.cachedProjectDir)) {
                return (0, errors_1.noProjectDirectory)(this.cachedProjectDir);
            }
        }
        let projectId = await this.getProjectId();
        if (tool.mcp._meta?.requiresProject && !projectId) {
            return errors_1.NO_PROJECT_ERROR;
        }
        projectId = projectId || "";
        const skipAutoAuthForStudio = (0, env_1.isFirebaseStudio)();
        const accountEmail = await this.getAuthenticatedUser(skipAutoAuthForStudio);
        if (tool.mcp._meta?.requiresAuth && !accountEmail) {
            return (0, errors_1.mcpAuthError)(skipAutoAuthForStudio);
        }
        const isBillingEnabled = projectId ? await this.safeCheckBillingEnabled(projectId) : false;
        const toolsCtx = this._createMcpContext(projectId, accountEmail, isBillingEnabled);
        if (request.params._meta?.progressToken) {
            toolsCtx.progressToken = request.params._meta.progressToken;
        }
        try {
            const res = await tool.fn(toolArgs, toolsCtx);
            await this.trackGA4("mcp_tool_call", {
                tool_name: toolName,
                error: res.isError ? 1 : 0,
            });
            return res;
        }
        catch (err) {
            await this.trackGA4("mcp_tool_call", {
                tool_name: toolName,
                error: 1,
            });
            return (0, util_1.mcpError)(err);
        }
    }
    async mcpListPrompts() {
        await Promise.all([this.detectActiveFeatures(), this.detectProjectRoot()]);
        const hasActiveProject = !!(await this.getProjectId());
        await this.trackGA4("mcp_list_prompts");
        const skipAutoAuthForStudio = (0, env_1.isFirebaseStudio)();
        return {
            prompts: (await this.getAvailablePrompts()).map((p) => ({
                name: p.mcp.name,
                description: p.mcp.description,
                annotations: p.mcp.annotations,
                arguments: p.mcp.arguments,
            })),
            _meta: {
                projectRoot: this.cachedProjectDir,
                projectDetected: hasActiveProject,
                authenticatedUser: await this.getAuthenticatedUser(skipAutoAuthForStudio),
                activeFeatures: this.activeFeatures,
                detectedFeatures: this.detectedFeatures,
            },
        };
    }
    async mcpGetPrompt(req) {
        await this.detectProjectRoot();
        const promptName = req.params.name;
        const promptArgs = req.params.arguments || {};
        const prompt = await this.getPrompt(promptName);
        if (!prompt) {
            throw new Error(`Prompt '${promptName}' could not be found.`);
        }
        let projectId = await this.getProjectId();
        projectId = projectId || "";
        const skipAutoAuthForStudio = (0, env_1.isFirebaseStudio)();
        const accountEmail = await this.getAuthenticatedUser(skipAutoAuthForStudio);
        const isBillingEnabled = projectId ? await this.safeCheckBillingEnabled(projectId) : false;
        const promptsCtx = this._createMcpContext(projectId, accountEmail, isBillingEnabled);
        try {
            const messages = await prompt.fn(promptArgs, promptsCtx);
            await this.trackGA4("mcp_get_prompt", {
                tool_name: promptName,
            });
            return {
                messages,
            };
        }
        catch (err) {
            await this.trackGA4("mcp_get_prompt", {
                tool_name: promptName,
                error: 1,
            });
            throw err;
        }
    }
    async mcpListResources() {
        await this.trackGA4("mcp_list_resources", { resource_name: "__list__" });
        return {
            resources: resources_1.resources.map((r) => r.mcp),
        };
    }
    async mcpListResourceTemplates() {
        return {
            resourceTemplates: resources_1.resourceTemplates.map((rt) => rt.mcp),
        };
    }
    async mcpReadResource(req) {
        let projectId = await this.getProjectId();
        projectId = projectId || "";
        const skipAutoAuthForStudio = (0, env_1.isFirebaseStudio)();
        const accountEmail = await this.getAuthenticatedUser(skipAutoAuthForStudio);
        const isBillingEnabled = projectId ? await this.safeCheckBillingEnabled(projectId) : false;
        const resourceCtx = this._createMcpContext(projectId, accountEmail, isBillingEnabled);
        const resolved = await (0, resources_1.resolveResource)(req.params.uri, resourceCtx);
        if (!resolved) {
            throw new types_js_1.McpError(types_js_1.ErrorCode.InvalidParams, `Resource '${req.params.uri}' could not be found.`);
        }
        return resolved.result;
    }
    async start(options) {
        if (options?.useSSE) {
            const app = express();
            app.use(cors());
            const port = options.port || 3000;
            const transports = {};
            app.get("/sse", async (req, res) => {
                this.logger.debug(`[SSE] GET /sse connection attempt from ${req.ip}`);
                try {
                    const transport = new sse_js_1.SSEServerTransport("/message", res);
                    const sessionId = transport.sessionId;
                    transports[sessionId] = transport;
                    this.logger.debug(`[SSE] Connected session ${sessionId}`);
                    await this.server.connect(transport);
                    this.logger.debug(`[SSE] Server connected to transport`);
                    await new Promise((resolve) => {
                        req.on("close", () => {
                            this.logger.debug(`[SSE] Session ${sessionId} disconnected`);
                            delete transports[sessionId];
                            resolve();
                        });
                    });
                }
                catch (err) {
                    this.logger.error(`[SSE] Connection error: ${err}`);
                }
            });
            app.post("/message", async (req, res) => {
                const sessionId = req.query.sessionId;
                this.logger.debug(`[SSE] POST /message attempt for session ${sessionId}`);
                const transport = transports[sessionId];
                if (transport) {
                    try {
                        await transport.handlePostMessage(req, res);
                        this.logger.debug(`[SSE] Handled message for session ${sessionId}`);
                    }
                    catch (err) {
                        this.logger.error(`[SSE] Error handling message for session ${sessionId}: ${err}`);
                    }
                }
                else {
                    this.logger.error(`[SSE] Rejecting message: No active transport found for session ${sessionId}`);
                    res.status(400).send("No active SSE transport connection found for this session");
                }
            });
            app.listen(port, "127.0.0.1", () => {
                this.logger.info(`MCP Server running on HTTP/SSE mode at http://127.0.0.1:${port}`);
            });
            return;
        }
        const transport = process.env.FIREBASE_MCP_DEBUG_LOG
            ? new logging_transport_1.LoggingStdioServerTransport(process.env.FIREBASE_MCP_DEBUG_LOG)
            : new stdio_js_1.StdioServerTransport();
        await this.server.connect(transport);
    }
    async safeCheckBillingEnabled(projectId) {
        try {
            return await (0, cloudbilling_1.checkBillingEnabled)(projectId);
        }
        catch (e) {
            this.logger.debug("[mcp] Error on billingInfo for " +
                projectId +
                ", failing open (assuming false): " +
                (e instanceof Error ? e.message : String(e)));
            return false;
        }
    }
    get logger() {
        const logAtLevel = (level, message) => {
            let data = message;
            if (typeof message === "string") {
                data = { message };
            }
            if (!this.currentLogLevel) {
                return;
            }
            if (orderedLogLevels.indexOf(this.currentLogLevel) > orderedLogLevels.indexOf(level)) {
                return;
            }
            if (this._ready) {
                while (this._pendingMessages.length) {
                    const message = this._pendingMessages.shift();
                    if (!message)
                        continue;
                    this.server.sendLoggingMessage({
                        level: message.level,
                        data: message.data,
                    });
                }
                void this.server.sendLoggingMessage({ level, data });
            }
            else {
                this._pendingMessages.push({ level, data });
            }
        };
        return Object.fromEntries(orderedLogLevels.map((logLevel) => [
            logLevel,
            (message) => logAtLevel(logLevel, message),
        ]));
    }
}
exports.FirebaseMcpServer = FirebaseMcpServer;
