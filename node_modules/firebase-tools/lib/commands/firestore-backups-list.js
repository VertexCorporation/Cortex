"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const firestore_1 = require("../gcp/firestore");
const utils_1 = require("../utils");
const pretty_print_1 = require("../firestore/pretty-print");
exports.command = new command_1.Command("firestore:backups:list")
    .description("list all Cloud Firestore backups in a given location")
    .option("-l, --location <locationId>", "location to search for backups, for example 'nam5'. Run 'firebase firestore:locations' to get a list of eligible locations. Defaults to all locations")
    .before(requirePermissions_1.requirePermissions, ["datastore.backups.list"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (options) => {
    const printer = new pretty_print_1.PrettyPrint();
    const location = options.location ?? "-";
    const listBackupsResponse = await (0, firestore_1.listBackups)(options.project, location);
    const backups = listBackupsResponse.backups || [];
    printer.prettyPrintBackups(backups);
    if (listBackupsResponse.unreachable && listBackupsResponse.unreachable.length > 0) {
        (0, utils_1.logWarning)("We were not able to reach the following locations: " +
            listBackupsResponse.unreachable.join(", "));
    }
    return listBackupsResponse;
});
