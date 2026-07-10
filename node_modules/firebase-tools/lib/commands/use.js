"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
exports.setNewActive = setNewActive;
const clc = require("colorette");
const command_1 = require("../command");
const projects_1 = require("../management/projects");
const studio_1 = require("../management/studio");
const logger_1 = require("../logger");
const prompt_1 = require("../prompt");
const requireAuth_1 = require("../requireAuth");
const command_2 = require("../command");
const utils = require("../utils");
const error_1 = require("../error");
const env_1 = require("../env");
function listAliases(options) {
    if (options.rc.hasProjects) {
        logger_1.logger.info("Project aliases for", clc.bold(options.projectRoot || "") + ":");
        logger_1.logger.info();
        for (const [alias, projectId] of Object.entries(options.rc.projects)) {
            const listing = alias + " (" + projectId + ")";
            if (options.project === projectId || options.projectAlias === alias) {
                logger_1.logger.info(clc.cyan(clc.bold("* " + listing)));
            }
            else {
                logger_1.logger.info("  " + listing);
            }
        }
        logger_1.logger.info();
    }
    logger_1.logger.info("Run", clc.bold("firebase use --add"), "to define a new project alias.");
}
function verifyMessage(name) {
    return "please verify project " + clc.bold(name) + " exists and you have access.";
}
async function setNewActive(projectOrAlias, aliasOpt, rc, projectRoot) {
    let project;
    const hasAlias = rc.hasProjectAlias(projectOrAlias);
    const resolvedProject = rc.resolveAlias(projectOrAlias);
    (0, command_2.validateProjectId)(resolvedProject);
    try {
        project = await (0, projects_1.getProject)(resolvedProject);
    }
    catch {
        throw new error_1.FirebaseError("Invalid project selection, " + verifyMessage(projectOrAlias));
    }
    if ((0, env_1.isFirebaseStudio)()) {
        await (0, studio_1.updateStudioFirebaseProject)(resolvedProject);
    }
    if (aliasOpt) {
        if (!project) {
            throw new error_1.FirebaseError(`Cannot create alias ${clc.bold(aliasOpt)}, ${verifyMessage(projectOrAlias)}`);
        }
        rc.addProjectAlias(aliasOpt, projectOrAlias);
        logger_1.logger.info("Created alias", clc.bold(aliasOpt), "for", resolvedProject + ".");
    }
    if (hasAlias) {
        if (!project) {
            throw new error_1.FirebaseError(`Unable to use alias ${clc.bold(projectOrAlias)}, ${verifyMessage(resolvedProject)}`);
        }
        utils.makeActiveProject(projectRoot, projectOrAlias);
        logger_1.logger.info("Now using alias", clc.bold(projectOrAlias), "(" + resolvedProject + ")");
    }
    else if (project) {
        utils.makeActiveProject(projectRoot, projectOrAlias);
        logger_1.logger.info("Now using project", clc.bold(projectOrAlias));
    }
    else {
        throw new error_1.FirebaseError(`Invalid project selection, ${verifyMessage(projectOrAlias)}`);
    }
}
function unalias(alias, options) {
    if (options.rc.hasProjectAlias(alias)) {
        options.rc.removeProjectAlias(alias);
        logger_1.logger.info("Removed alias", clc.bold(alias));
        logger_1.logger.info();
        listAliases(options);
    }
}
async function addAlias(options) {
    if (options.nonInteractive) {
        return utils.reject("Cannot run " +
            clc.bold("firebase use --add") +
            " in non-interactive mode. Use " +
            clc.bold("firebase use <project_id> --alias <alias>") +
            " instead.");
    }
    const projects = await (0, projects_1.listFirebaseProjects)();
    const project = await (0, prompt_1.select)({
        message: "Which project do you want to add?",
        choices: projects.map((p) => p.projectId).sort(),
    });
    const alias = await (0, prompt_1.input)({
        message: "What alias do you want to use for this project? (e.g. staging)",
        validate: (input) => {
            return input && input.length > 0;
        },
    });
    const results = {
        project,
        alias,
    };
    options.rc.addProjectAlias(alias, project);
    utils.makeActiveProject(options.projectRoot, results.alias);
    logger_1.logger.info();
    logger_1.logger.info("Created alias", clc.bold(results.alias || ""), "for", results.project + ".");
    logger_1.logger.info("Now using alias", clc.bold(results.alias || "") + " (" + results.project + ")");
}
function clearAlias(options) {
    utils.makeActiveProject(options.projectRoot, undefined);
    delete options.projectAlias;
    delete options.project;
    logger_1.logger.info("Cleared active project.");
    logger_1.logger.info();
    listAliases(options);
}
async function genericUse(options) {
    if (options.nonInteractive || !process.stdout.isTTY) {
        if (options.project) {
            logger_1.logger.info(options.project);
            return options.project;
        }
        return utils.reject("No active project");
    }
    if (options.projectAlias) {
        logger_1.logger.info("Active Project:", clc.bold(clc.cyan(options.projectAlias + " (" + options.project + ")")));
    }
    else if (options.project) {
        logger_1.logger.info("Active Project:", clc.bold(clc.cyan(options.project)));
    }
    else {
        let msg = "No project is currently active";
        if (options.rc.hasProjects) {
            msg += ", and no aliases have been created.";
        }
        logger_1.logger.info(msg + ".");
    }
    logger_1.logger.info();
    listAliases(options);
    return options.project;
}
exports.command = new command_1.Command("use [alias_or_project_id]")
    .description("set an active Firebase project for your working directory")
    .option("--add", "create a new project alias interactively")
    .option("--alias <name>", "create a new alias for the provided project id")
    .option("--unalias <name>", "remove an already created project alias")
    .option("--clear", "clear the active project selection")
    .before(requireAuth_1.requireAuth)
    .action((newActive, options) => {
    let aliasOpt;
    const i = process.argv.indexOf("--alias");
    if (i >= 0 && process.argv.length > i + 1) {
        aliasOpt = process.argv[i + 1];
    }
    if (!options.projectRoot) {
        return utils.reject(clc.bold("firebase use") +
            " must be run from a Firebase project directory.\n\nRun " +
            clc.bold("firebase init") +
            " to start a project directory in the current folder.");
    }
    if (newActive) {
        return setNewActive(newActive, aliasOpt, options.rc, options.projectRoot);
    }
    if (options.unalias) {
        return unalias(options.unalias, options);
    }
    if (options.add) {
        return addAlias(options);
    }
    if (options.clear) {
        return clearAlias(options);
    }
    return genericUse(options);
});
