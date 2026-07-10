"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.login = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const auth_1 = require("../../../auth");
const util_1 = require("../../util");
const LoginInputSchema = zod_1.z.object({
    authCode: zod_1.z.string().optional().describe("The authorization code from the login flow"),
});
exports.login = (0, tool_1.tool)("core", {
    name: "login",
    description: "Use this to sign the user into the Firebase CLI and Firebase MCP server. This requires a Google Account, and sign in is required to create and work with Firebase Projects.",
    inputSchema: LoginInputSchema,
    _meta: {
        requiresAuth: false,
    },
}, async (input, ctx) => {
    const { authCode } = input;
    const serverWithState = ctx.host;
    if (authCode) {
        if (!serverWithState.authorize) {
            return (0, util_1.mcpError)("Login flow not started. Please call this tool without the authCode argument first to get a login URI.");
        }
        try {
            const creds = await serverWithState.authorize(authCode);
            delete serverWithState.authorize;
            const user = creds.user;
            return (0, util_1.toContent)(`Successfully logged in as ${user.email}`);
        }
        catch (e) {
            delete serverWithState.authorize;
            return (0, util_1.mcpError)(`Login failed: ${e.message}`);
        }
    }
    else {
        const prototyper = await (0, auth_1.loginPrototyper)();
        serverWithState.authorize = prototyper.authorize;
        const result = {
            uri: prototyper.uri,
            sessionId: prototyper.sessionId,
        };
        const humanReadable = `Please visit this URL to login: ${result.uri}\nYour session ID is: ${result.sessionId}\nInstruct the use to copy the authorization code from that link, and paste it into chat.\nThen, run this tool again with that as the authCode argument to complete the login.`;
        return (0, util_1.toContent)(humanReadable);
    }
});
