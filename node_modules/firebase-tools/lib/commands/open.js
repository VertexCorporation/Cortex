"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const open = require("open");
const error_1 = require("../error");
const api = require("../api");
const command_1 = require("../command");
const logger_1 = require("../logger");
const prompt_1 = require("../prompt");
const requirePermissions_1 = require("../requirePermissions");
const requireDatabaseInstance_1 = require("../requireDatabaseInstance");
const utils = require("../utils");
const requireHostingSite_1 = require("../requireHostingSite");
const LINKS = [
    { name: "Analytics", arg: "analytics", consolePath: "/analytics" },
    { name: "App Hosting", arg: "apphosting", consolePath: "/apphosting" },
    { name: "Authentication: Providers", arg: "auth", consolePath: "/authentication/providers" },
    { name: "Authentication: Users", arg: "auth:users", consolePath: "/authentication/users" },
    { name: "Crash Reporting", arg: "crash", consolePath: "/crashlytics" },
    { name: "Database: Data", arg: "database", consolePath: "/database/data" },
    { name: "Database: Rules", arg: "database:rules", consolePath: "/database/rules" },
    { name: "SQL Connect", arg: "dataconnect", consolePath: "/dataconnect" },
    { name: "Docs", arg: "docs", url: "https://firebase.google.com/docs" },
    { name: "Dynamic Links", arg: "links", consolePath: "/durablelinks" },
    { name: "Extensions", arg: "extensions", consolePath: "/extensions" },
    { name: "Firestore: Data", arg: "firestore", consolePath: "/firestore/data" },
    { name: "Firestore: Rules", arg: "firestore:rules", consolePath: "/firestore/rules" },
    { name: "Firestore: Indexes", arg: "firestore:indexes", consolePath: "/firestore/indexes" },
    {
        name: "Firestore: Databases List",
        arg: "firestore:databases:list",
        consolePath: "/firestore/databases/list",
    },
    {
        name: "Firestore: Locations",
        arg: "firestore:locations",
        consolePath: "/firestore/locations",
    },
    { name: "Firestore: Usage", arg: "firestore:usage", consolePath: "/firestore/usage" },
    { name: "Functions", arg: "functions", consolePath: "/functions/list" },
    { name: "Functions Log", arg: "functions:log" },
    { name: "Hosting: Deployed Site", arg: "hosting:site" },
    { name: "Hosting", arg: "hosting", consolePath: "/hosting/sites" },
    { name: "Notifications", arg: "notifications", consolePath: "/notification" },
    { name: "Project Dashboard", arg: "dashboard", consolePath: "/overview" },
    { name: "Project Settings", arg: "settings", consolePath: "/settings/general" },
    {
        name: "Remote Config: Conditions",
        arg: "config:conditions",
        consolePath: "/config/conditions",
    },
    { name: "Remote Config", arg: "config", consolePath: "/config" },
    { name: "Storage: Files", arg: "storage", consolePath: "/storage/files" },
    { name: "Storage: Rules", arg: "storage:rules", consolePath: "/storage/rules" },
    { name: "Test Lab", arg: "testlab", consolePath: "/testlab/histories/" },
];
const CHOICES = LINKS.map((l) => l.name);
exports.command = new command_1.Command("open [link]")
    .description("quickly open a browser to relevant project resources")
    .before(requirePermissions_1.requirePermissions)
    .before(requireDatabaseInstance_1.requireDatabaseInstance)
    .before(requireHostingSite_1.requireHostingSite)
    .action(async (linkName, options) => {
    let link = LINKS.find((l) => l.arg === linkName);
    if (linkName && !link) {
        throw new error_1.FirebaseError("Unrecognized link name. Valid links are:\n\n" + LINKS.map((l) => l.arg).join("\n"));
    }
    if (!link) {
        const name = await (0, prompt_1.select)({
            message: "What link would you like to open?",
            choices: CHOICES,
        });
        link = LINKS.find((l) => l.name === name);
    }
    if (!link) {
        throw new error_1.FirebaseError("Unrecognized link name. Valid links are:\n\n" + LINKS.map((l) => l.arg).join("\n"));
    }
    let url;
    if (link.consolePath) {
        url = utils.consoleUrl(options.project, link.consolePath);
    }
    else if (link.url) {
        url = link.url;
    }
    else if (link.arg === "hosting:site") {
        url = utils.addSubdomain(api.hostingOrigin(), options.site);
    }
    else if (link.arg === "functions:log") {
        url = `https://console.developers.google.com/logs/viewer?resource=cloudfunctions.googleapis.com&project=${options.project}`;
    }
    else {
        throw new error_1.FirebaseError(`Unable to determine URL for link: ${link}`);
    }
    if (link.arg !== linkName) {
        logger_1.logger.info(`${clc.bold(clc.cyan("Tip:"))} You can also run ${clc.bold(clc.underline(`firebase open ${link.arg}`))}`);
        logger_1.logger.info();
    }
    logger_1.logger.info(`Opening ${clc.bold(link.name)} link in your default browser:`);
    logger_1.logger.info(clc.bold(clc.underline(url)));
    open(url);
});
