"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getProjectId = getProjectId;
exports.needProjectId = needProjectId;
exports.needProjectNumber = needProjectNumber;
exports.getAliases = getAliases;
const projects_1 = require("./management/projects");
const clc = require("colorette");
const marked_1 = require("marked");
const { FirebaseError } = require("./error");
function getProjectId({ projectId, project, }) {
    return projectId || project;
}
function needProjectId({ projectId, project, rc, }) {
    if (projectId || project) {
        return projectId || project;
    }
    const aliases = rc?.projects || {};
    const aliasCount = Object.keys(aliases).length;
    if (aliasCount === 0) {
        throw new FirebaseError("No currently active project.\n" +
            "To run this command, you need to specify a project. You have two options:\n" +
            "- Run this command with " +
            clc.bold("--project <alias_or_project_id>") +
            ".\n" +
            "- Set an active project by running " +
            clc.bold("firebase use --add") +
            ", then rerun this command.\n" +
            "To list all the Firebase projects to which you have access, run " +
            clc.bold("firebase projects:list") +
            ".\n" +
            (0, marked_1.marked)("To learn about active projects for the CLI, visit https://firebase.google.com/docs/cli#project_aliases"));
    }
    const aliasList = Object.entries(aliases)
        .map(([aname, projectId]) => `  ${aname} (${projectId})`)
        .join("\n");
    throw new FirebaseError("No project active, but project aliases are available.\n\nRun " +
        clc.bold("firebase use <alias>") +
        " with one of these options:\n\n" +
        aliasList);
}
async function needProjectNumber(options) {
    if (options.projectNumber) {
        return options.projectNumber;
    }
    const projectId = needProjectId(options);
    const metadata = await (0, projects_1.getProject)(projectId);
    options.projectNumber = metadata.projectNumber;
    return options.projectNumber;
}
function getAliases(options, projectId) {
    if (options.rc.hasProjects) {
        return Object.entries(options.rc.projects)
            .filter((entry) => entry[1] === projectId)
            .map((entry) => entry[0]);
    }
    return [];
}
