"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const clc = require("colorette");
const ora = require("ora");
const Table = require("cli-table3");
const command_1 = require("../command");
const projects_1 = require("../management/projects");
const requireAuth_1 = require("../requireAuth");
const logger_1 = require("../logger");
const NOT_SPECIFIED = clc.yellow("[Not specified]");
function logProjectsList(projects, currentProjectId) {
    if (!projects.length) {
        return;
    }
    const tableHead = [
        "Project Display Name",
        "Project ID",
        "Project Number",
        "Resource Location ID",
    ];
    const table = new Table({ head: tableHead, style: { head: ["green"] } });
    projects.forEach(({ projectId, projectNumber, displayName, resources }) => {
        if (projectId === currentProjectId) {
            projectId = clc.cyan(clc.bold(`${projectId} (current)`));
        }
        table.push([
            displayName || NOT_SPECIFIED,
            projectId,
            projectNumber,
            (resources && resources.locationId) || NOT_SPECIFIED,
        ]);
    });
    logger_1.logger.info(table.toString());
}
function logProjectCount(arr = []) {
    if (!arr.length) {
        logger_1.logger.info(clc.bold("No projects found."));
        return;
    }
    logger_1.logger.info("");
    logger_1.logger.info(`${arr.length} project(s) total.`);
}
exports.command = new command_1.Command("projects:list")
    .description("list all Firebase projects you have access to")
    .before(requireAuth_1.requireAuth)
    .action(async (options) => {
    const spinner = ora("Preparing the list of your Firebase projects").start();
    let projects;
    try {
        projects = await (0, projects_1.listFirebaseProjects)();
    }
    catch (err) {
        spinner.fail();
        throw err;
    }
    spinner.succeed();
    logProjectsList(projects, options.project);
    logProjectCount(projects);
    return projects;
});
