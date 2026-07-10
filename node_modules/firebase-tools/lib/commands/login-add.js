"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const command_1 = require("../command");
const logger_1 = require("../logger");
const utils = require("../utils");
const error_1 = require("../error");
const auth = require("../auth");
exports.command = new command_1.Command("login:add [email]")
    .description("authorize the CLI for an additional account")
    .option("--no-localhost", "copy and paste a code instead of starting a local server for authentication")
    .action(async (email, options) => {
    if (options.nonInteractive) {
        throw new error_1.FirebaseError(`Cannot run "${clc.bold("login:add")}" in non-interactive mode.`);
    }
    const account = auth.getGlobalDefaultAccount();
    if (!account) {
        throw new error_1.FirebaseError(`No existing accounts found, please run "${clc.bold("firebase login")}" to add your first account`);
    }
    const hintUser = auth.getAllAccounts().find((a) => a.user.email === email);
    if (email && hintUser) {
        throw new error_1.FirebaseError(`Already signed in as ${email}, use "${clc.bold("firebase login --reauth")}" to reauthenticate.`);
    }
    const useLocalhost = utils.isCloudEnvironment() ? false : options.localhost;
    const newAccount = await auth.loginAdditionalAccount(useLocalhost, email);
    if (newAccount) {
        logger_1.logger.info();
        utils.logSuccess("Success! Added account " + clc.bold(newAccount.user.email));
    }
    return newAccount;
});
