"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.command = void 0;
const marked_1 = require("marked");
const marked_terminal_1 = require("marked-terminal");
const checkMinRequiredVersion_1 = require("../checkMinRequiredVersion");
const command_1 = require("../command");
const config_1 = require("../config");
const error_1 = require("../error");
const prompt_1 = require("../prompt");
const logger_1 = require("../logger");
const npmDependencies = require("../init/features/functions/npm-dependencies");
const templates_1 = require("../templates");
marked_1.marked.use((0, marked_terminal_1.markedTerminal)());
function readCommonTemplates() {
    return {
        integrationTestFirebaseJsonTemplate: (0, templates_1.readTemplateSync)("extensions/integration-test.json"),
        integrationTestEnvTemplate: (0, templates_1.readTemplateSync)("extensions/integration-test.env"),
        extSpecTemplate: (0, templates_1.readTemplateSync)("extensions/extension.yaml"),
        preinstallTemplate: (0, templates_1.readTemplateSync)("extensions/PREINSTALL.md"),
        postinstallTemplate: (0, templates_1.readTemplateSync)("extensions/POSTINSTALL.md"),
        changelogTemplate: (0, templates_1.readTemplateSync)("extensions/CL-template.md"),
    };
}
exports.command = new command_1.Command("ext:dev:init")
    .description("initialize files for writing an extension in the current directory")
    .before(checkMinRequiredVersion_1.checkMinRequiredVersion, "extDevMinVersion")
    .action(async (options) => {
    const cwd = options.cwd || process.cwd();
    const config = new config_1.Config({}, { projectDir: cwd, cwd: cwd });
    try {
        let welcome;
        const lang = await (0, prompt_1.select)({
            message: "In which language do you want to write the Cloud Functions for your extension?",
            default: "javascript",
            choices: [
                {
                    name: "JavaScript",
                    value: "javascript",
                },
                {
                    name: "TypeScript",
                    value: "typescript",
                },
            ],
        });
        switch (lang) {
            case "javascript": {
                await javascriptSelected(config);
                welcome = (0, templates_1.readTemplateSync)("extensions/javascript/WELCOME.md");
                break;
            }
            case "typescript": {
                await typescriptSelected(config);
                welcome = (0, templates_1.readTemplateSync)("extensions/typescript/WELCOME.md");
                break;
            }
            default: {
                throw new error_1.FirebaseError(`${lang} is not supported.`);
            }
        }
        await npmDependencies.askInstallDependencies({ source: "functions" }, config);
        return logger_1.logger.info("\n" + (0, marked_1.marked)(welcome));
    }
    catch (err) {
        if (!(err instanceof error_1.FirebaseError)) {
            throw new error_1.FirebaseError(`Error occurred when initializing files for new extension: ${(0, error_1.getErrMsg)(err)}`, {
                original: (0, error_1.getError)(err),
            });
        }
        throw err;
    }
});
async function typescriptSelected(config) {
    const packageLintingTemplate = (0, templates_1.readTemplateSync)("extensions/typescript/package.lint.json");
    const packageNoLintingTemplate = (0, templates_1.readTemplateSync)("extensions/typescript/package.nolint.json");
    const tsconfigTemplate = (0, templates_1.readTemplateSync)("extensions/typescript/tsconfig.json");
    const tsconfigDevTemplate = (0, templates_1.readTemplateSync)("extensions/typescript/tsconfig.dev.json");
    const indexTemplate = (0, templates_1.readTemplateSync)("extensions/typescript/index.ts");
    const integrationTestTemplate = (0, templates_1.readTemplateSync)("extensions/typescript/integration-test.ts");
    const gitignoreTemplate = (0, templates_1.readTemplateSync)("extensions/typescript/_gitignore");
    const mocharcTemplate = (0, templates_1.readTemplateSync)("extensions/typescript/_mocharc");
    const eslintTemplate = (0, templates_1.readTemplateSync)("init/functions/typescript/_eslintrc");
    const lint = await (0, prompt_1.confirm)({
        message: "Do you want to use ESLint to catch probable bugs and enforce style?",
        default: true,
    });
    const templates = readCommonTemplates();
    await config.askWriteProjectFile("extension.yaml", templates.extSpecTemplate);
    await config.askWriteProjectFile("PREINSTALL.md", templates.preinstallTemplate);
    await config.askWriteProjectFile("POSTINSTALL.md", templates.postinstallTemplate);
    await config.askWriteProjectFile("CHANGELOG.md", templates.changelogTemplate);
    await config.askWriteProjectFile("functions/.mocharc.json", mocharcTemplate);
    await config.askWriteProjectFile("functions/src/index.ts", indexTemplate);
    await config.askWriteProjectFile("functions/integration-tests/integration-test.spec.ts", integrationTestTemplate);
    await config.askWriteProjectFile("functions/integration-tests/firebase.json", templates.integrationTestFirebaseJsonTemplate);
    await config.askWriteProjectFile("functions/integration-tests/extensions/greet-the-world.env", templates.integrationTestEnvTemplate);
    if (lint) {
        await config.askWriteProjectFile("functions/package.json", packageLintingTemplate);
        await config.askWriteProjectFile("functions/.eslintrc.js", eslintTemplate);
    }
    else {
        await config.askWriteProjectFile("functions/package.json", packageNoLintingTemplate);
    }
    await config.askWriteProjectFile("functions/tsconfig.json", tsconfigTemplate);
    if (lint) {
        await config.askWriteProjectFile("functions/tsconfig.dev.json", tsconfigDevTemplate);
    }
    await config.askWriteProjectFile("functions/.gitignore", gitignoreTemplate);
}
async function javascriptSelected(config) {
    const indexTemplate = (0, templates_1.readTemplateSync)("extensions/javascript/index.js");
    const integrationTestTemplate = (0, templates_1.readTemplateSync)("extensions/javascript/integration-test.js");
    const packageLintingTemplate = (0, templates_1.readTemplateSync)("extensions/javascript/package.lint.json");
    const packageNoLintingTemplate = (0, templates_1.readTemplateSync)("extensions/javascript/package.nolint.json");
    const gitignoreTemplate = (0, templates_1.readTemplateSync)("extensions/javascript/_gitignore");
    const eslintTemplate = (0, templates_1.readTemplateSync)("init/functions/javascript/_eslintrc");
    const lint = await (0, prompt_1.confirm)("Do you want to use ESLint to catch probable bugs and enforce style?");
    const templates = readCommonTemplates();
    await config.askWriteProjectFile("extension.yaml", templates.extSpecTemplate);
    await config.askWriteProjectFile("PREINSTALL.md", templates.preinstallTemplate);
    await config.askWriteProjectFile("POSTINSTALL.md", templates.postinstallTemplate);
    await config.askWriteProjectFile("CHANGELOG.md", templates.changelogTemplate);
    await config.askWriteProjectFile("functions/index.js", indexTemplate);
    await config.askWriteProjectFile("functions/integration-tests/integration-test.spec.js", integrationTestTemplate);
    await config.askWriteProjectFile("functions/integration-tests/firebase.json", templates.integrationTestFirebaseJsonTemplate);
    await config.askWriteProjectFile("functions/integration-tests/extensions/greet-the-world.env", templates.integrationTestEnvTemplate);
    if (lint) {
        await config.askWriteProjectFile("functions/package.json", packageLintingTemplate);
        await config.askWriteProjectFile("functions/.eslintrc.js", eslintTemplate);
    }
    else {
        await config.askWriteProjectFile("functions/package.json", packageNoLintingTemplate);
    }
    await config.askWriteProjectFile("functions/.gitignore", gitignoreTemplate);
}
