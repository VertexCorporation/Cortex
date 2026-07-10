"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const logger_1 = require("../logger");
const projectUtils_1 = require("../projectUtils");
const secretManager_1 = require("../gcp/secretManager");
const requireAuth_1 = require("../requireAuth");
const secretManager = require("../gcp/secretManager");
const secrets_1 = require("../apphosting/secrets");
exports.command = new command_1.Command("functions:secrets:access <KEY>[@version]")
    .description("access secret value given secret and its version. Defaults to accessing the latest version")
    .before(requireAuth_1.requireAuth)
    .before(secretManager.ensureApi)
    .action(async (key, options) => {
    const projectId = (0, projectUtils_1.needProjectId)(options);
    const [name, version] = (0, secrets_1.getSecretNameParts)(key);
    const value = await (0, secretManager_1.accessSecretVersion)(projectId, name, version);
    logger_1.logger.info(value);
});
