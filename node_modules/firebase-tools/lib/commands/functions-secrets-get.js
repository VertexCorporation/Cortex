"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const requireAuth_1 = require("../requireAuth");
const command_1 = require("../command");
const requirePermissions_1 = require("../requirePermissions");
const secretManager = require("../gcp/secretManager");
const secrets = require("../functions/secrets");
exports.command = new command_1.Command("functions:secrets:get <KEY>")
    .description("get metadata for secret and its versions")
    .before(requireAuth_1.requireAuth)
    .before(secretManager.ensureApi)
    .before(requirePermissions_1.requirePermissions, ["secretmanager.secrets.get"])
    .action(secrets.describeSecret);
