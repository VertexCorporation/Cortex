"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
exports.logoutAction = logoutAction;
const command_1 = require("../command");
const logger_1 = require("../logger");
const clc = require("colorette");
const utils = require("../utils");
const auth_1 = require("../auth");
const prompt_1 = require("../prompt");
exports.command = new command_1.Command("logout [email]")
    .description("log the CLI out of Firebase")
    .action(logoutAction);
async function logoutAction(email, options) {
    const globalToken = utils.getInheritedOption(options, "token");
    utils.assertIsStringOrUndefined(globalToken);
    const allAccounts = (0, auth_1.getAllAccounts)();
    if (allAccounts.length === 0 && !globalToken) {
        logger_1.logger.info("No need to logout, not logged in");
        return;
    }
    const defaultAccount = (0, auth_1.getGlobalDefaultAccount)();
    const additionalAccounts = (0, auth_1.getAdditionalAccounts)();
    const accountsToLogOut = email ? allAccounts.filter((a) => a.user.email === email) : allAccounts;
    if (email && accountsToLogOut.length === 0) {
        utils.logWarning(`No account matches ${email}, can't log out.`);
        return;
    }
    const logoutDefault = email === defaultAccount?.user.email;
    let newDefaultAccount = undefined;
    if (logoutDefault && additionalAccounts.length > 0) {
        if (additionalAccounts.length === 1) {
            newDefaultAccount = additionalAccounts[0];
        }
        else {
            const choices = additionalAccounts.map((a) => {
                return {
                    name: a.user.email,
                    value: a,
                };
            });
            newDefaultAccount = await (0, prompt_1.select)({
                message: "You are logging out of your default account, which account should become the new default?",
                choices,
            });
        }
    }
    for (const account of accountsToLogOut) {
        const token = account.tokens.refresh_token;
        if (token) {
            (0, auth_1.setRefreshToken)(token);
            try {
                await (0, auth_1.logout)(token);
            }
            catch (e) {
                utils.logWarning(`Invalid refresh token for ${account.user.email}, did not need to deauthorize`);
            }
            utils.logSuccess(`Logged out from ${clc.bold(account.user.email)}`);
        }
    }
    if (globalToken) {
        (0, auth_1.setRefreshToken)(globalToken);
        try {
            await (0, auth_1.logout)(globalToken);
        }
        catch (e) {
            utils.logWarning("Invalid refresh token, did not need to deauthorize");
        }
        utils.logSuccess(`Logged out from token "${clc.bold(globalToken)}"`);
    }
    if (newDefaultAccount) {
        utils.logSuccess(`Setting default account to "${newDefaultAccount.user.email}"`);
        (0, auth_1.setGlobalDefaultAccount)(newDefaultAccount);
    }
}
