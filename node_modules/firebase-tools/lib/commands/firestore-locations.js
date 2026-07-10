"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const command_1 = require("../command");
const fsi = require("../firestore/api");
const requirePermissions_1 = require("../requirePermissions");
const types_1 = require("../emulator/types");
const commandUtils_1 = require("../emulator/commandUtils");
const pretty_print_1 = require("../firestore/pretty-print");
exports.command = new command_1.Command("firestore:locations")
    .description("list possible locations for your Cloud Firestore database")
    .before(requirePermissions_1.requirePermissions, ["datastore.locations.list"])
    .before(commandUtils_1.warnEmulatorNotSupported, types_1.Emulators.FIRESTORE)
    .action(async (options) => {
    const api = new fsi.FirestoreApi();
    const printer = new pretty_print_1.PrettyPrint();
    const locations = await api.locations(options.project);
    printer.prettyPrintLocations(locations);
    return locations;
});
