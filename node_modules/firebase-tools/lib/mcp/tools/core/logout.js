"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.logout = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const auth_1 = require("../../../auth");
const logger_1 = require("../../../logger");
exports.logout = (0, tool_1.tool)("core", {
    name: "logout",
    description: "Use this to sign the user out of the Firebase CLI and Firebase MCP server.",
    inputSchema: zod_1.z.object({
        email: zod_1.z
            .string()
            .optional()
            .describe("The email of the account to log out. If not provided, all accounts will be logged out."),
    }),
    _meta: {
        requiresAuth: false,
        requiresProject: false,
    },
}, async ({ email }) => {
    const allAccounts = (0, auth_1.getAllAccounts)();
    if (allAccounts.length === 0) {
        return (0, util_1.toContent)("No need to log out, not logged in");
    }
    const defaultAccount = (0, auth_1.getGlobalDefaultAccount)();
    const additionalAccounts = (0, auth_1.getAdditionalAccounts)();
    const accountsToLogOut = email
        ? allAccounts.filter((a) => a.user.email === email)
        : allAccounts;
    if (email && accountsToLogOut.length === 0) {
        return (0, util_1.toContent)(`No account matches ${email}, can't log out.`);
    }
    const logoutDefault = email === defaultAccount?.user.email;
    let newDefaultAccount = undefined;
    if (logoutDefault && additionalAccounts.length > 0) {
        newDefaultAccount = additionalAccounts[0];
    }
    const logoutMessages = [];
    for (const account of accountsToLogOut) {
        const token = account.tokens.refresh_token;
        if (token) {
            try {
                await (0, auth_1.logout)(token);
                logoutMessages.push(`Logged out from ${account.user.email}`);
            }
            catch (e) {
                if (e instanceof Error) {
                    logger_1.logger.debug(e.message);
                }
                logoutMessages.push(`Could not deauthorize ${account.user.email}, assuming already deauthorized.`);
            }
        }
    }
    if (newDefaultAccount) {
        (0, auth_1.setGlobalDefaultAccount)(newDefaultAccount);
        logoutMessages.push(`Setting default account to "${newDefaultAccount.user.email}"`);
    }
    return (0, util_1.toContent)(logoutMessages.join("\n"));
});
