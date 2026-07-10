"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const utils = require("../utils");
const auth = require("../auth");
const error_1 = require("../error");
exports.command = new command_1.Command("login:use <email>")
    .description("set the default account to use for this project directory or the global default account if not in a Firebase project directory")
    .action((email, options) => {
    auth.assertAccount(email);
    const projectDir = options.projectRoot;
    if (projectDir) {
        if (options.user.email === email) {
            throw new error_1.FirebaseError(`Already using account ${email} for this project directory.`);
        }
        auth.setProjectAccount(projectDir, email);
        utils.logSuccess(`Set default account ${email} for current project directory.`);
        return email;
    }
    else {
        if (options.user.email === email) {
            throw new error_1.FirebaseError(`Already using account ${email} for the global default account.`);
        }
        const oldDefaultAccount = auth.getGlobalDefaultAccount();
        if (!oldDefaultAccount) {
            throw new error_1.FirebaseError("Could not determine global default account");
        }
        auth.setGlobalDefaultAccount(email);
        auth.addAdditionalAccount(oldDefaultAccount);
        utils.logSuccess(`Set global default account to ${email}.`);
        return email;
    }
});
