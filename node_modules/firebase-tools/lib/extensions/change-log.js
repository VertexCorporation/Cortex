"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getReleaseNotesForUpdate = getReleaseNotesForUpdate;
exports.breakingChangesInUpdate = breakingChangesInUpdate;
exports.getLocalChangelog = getLocalChangelog;
exports.parseChangelog = parseChangelog;
const marked_1 = require("marked");
const path = require("path");
const semver = require("semver");
const marked_terminal_1 = require("marked-terminal");
const extensionsApi_1 = require("./extensionsApi");
const localHelper_1 = require("./localHelper");
const refs = require("./refs");
marked_1.marked.use((0, marked_terminal_1.markedTerminal)());
const EXTENSIONS_CHANGELOG = "CHANGELOG.md";
const VERSION_LINE_REGEX = /##.+?(\d+\.\d+\.\d+(?:-((\d+|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(\d+|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?).*/;
async function getReleaseNotesForUpdate(args) {
    const releaseNotes = {};
    const filter = `id<="${args.toVersion}" AND id>"${args.fromVersion}"`;
    const extensionVersions = await (0, extensionsApi_1.listExtensionVersions)(args.extensionRef, filter);
    extensionVersions.sort((ev1, ev2) => {
        return -semver.compare(ev1.spec.version, ev2.spec.version);
    });
    for (const extensionVersion of extensionVersions) {
        if (extensionVersion.releaseNotes) {
            const version = refs.parse(extensionVersion.ref).version;
            releaseNotes[version] = extensionVersion.releaseNotes;
        }
    }
    return releaseNotes;
}
function breakingChangesInUpdate(versionsInUpdate) {
    const breakingVersions = [];
    const semvers = versionsInUpdate.map((v) => semver.parse(v)).sort(semver.compare);
    for (let i = 1; i < semvers.length; i++) {
        const hasMajorBump = semvers[i - 1].major < semvers[i].major;
        const hasMinorBumpInPreview = semvers[i - 1].major === 0 &&
            semvers[i].major === 0 &&
            semvers[i - 1].minor < semvers[i].minor;
        if (hasMajorBump || hasMinorBumpInPreview) {
            breakingVersions.push(semvers[i].raw);
        }
    }
    return breakingVersions;
}
function getLocalChangelog(directory) {
    const rawChangelog = (0, localHelper_1.readFile)(path.resolve(directory, EXTENSIONS_CHANGELOG));
    return parseChangelog(rawChangelog);
}
function parseChangelog(rawChangelog) {
    const changelog = {};
    let currentVersion = "";
    for (const line of rawChangelog.split("\n")) {
        const matches = line.match(VERSION_LINE_REGEX);
        if (matches) {
            currentVersion = matches[1];
        }
        else if (currentVersion) {
            if (!changelog[currentVersion]) {
                changelog[currentVersion] = line;
            }
            else {
                changelog[currentVersion] += `\n${line}`;
            }
        }
    }
    return changelog;
}
