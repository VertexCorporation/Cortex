"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const Table = require("cli-table3");
const command_1 = require("../command");
const error_1 = require("../error");
const utils_1 = require("../utils");
const publisherApi_1 = require("../extensions/publisherApi");
const logger_1 = require("../logger");
const extensionsHelper_1 = require("../extensions/extensionsHelper");
const requireAuth_1 = require("../requireAuth");
exports.command = new command_1.Command("ext:dev:list <publisherId>")
    .description("list all extensions uploaded under publisher ID")
    .before(requireAuth_1.requireAuth)
    .action(async (publisherId) => {
    let extensions;
    try {
        extensions = await (0, publisherApi_1.listExtensions)(publisherId);
    }
    catch (err) {
        throw new error_1.FirebaseError((0, error_1.getErrMsg)(err));
    }
    if (extensions.length < 1) {
        throw new error_1.FirebaseError(`There are no extensions uploaded under publisher ID ${clc.bold(publisherId)}. This could happen for two reasons:\n` +
            "  - The publisher ID doesn't exist or could be misspelled\n" +
            "  - This publisher has not uploaded any extensions\n\n" +
            "If you are expecting some extensions to appear, please make sure you have the correct publisher ID and try again.");
    }
    const table = new Table({
        head: ["Extension ID", "State", "Latest Version", "Version in Extensions Hub"],
        style: { head: ["yellow"] },
    });
    const sorted = extensions.sort((a, b) => a.ref.localeCompare(b.ref));
    sorted.forEach((extension) => {
        table.push([
            (0, utils_1.last)(extension.ref.split("/")),
            (0, extensionsHelper_1.unpackExtensionState)(extension),
            extension.latestVersion ?? "-",
            extension.latestApprovedVersion ?? "-",
        ]);
    });
    (0, utils_1.logLabeledBullet)(extensionsHelper_1.logPrefix, `list of uploaded extensions for publisher ${clc.bold(publisherId)}:`);
    logger_1.logger.info(table.toString());
    return { extensions: sorted };
});
