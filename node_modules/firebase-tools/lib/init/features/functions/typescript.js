"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.setup = setup;
const npm_dependencies_1 = require("./npm-dependencies");
const utils_1 = require("./utils");
const prompt_1 = require("../../../prompt");
const projectConfig_1 = require("../../../functions/projectConfig");
const templates_1 = require("../../../templates");
const supported = require("../../../deploy/functions/runtimes/supported");
const PACKAGE_LINTING_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/typescript/package.lint.json");
const PACKAGE_NO_LINTING_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/typescript/package.nolint.json");
const PACKAGE_GRAPH_LINTING_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/typescript/package-ongraphrequest.lint.json");
const PACKAGE_GRAPH_NO_LINTING_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/typescript/package-ongraphrequest.nolint.json");
const ESLINT_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/typescript/_eslintrc");
const TSCONFIG_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/typescript/tsconfig.json");
const TSCONFIG_DEV_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/typescript/tsconfig.dev.json");
const INDEX_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/typescript/index.ts");
const GRAPH_INDEX_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/typescript/index-ongraphrequest.ts");
const GITIGNORE_TEMPLATE = (0, templates_1.readTemplateSync)("init/functions/typescript/_gitignore");
async function setup(setup, config) {
    setup.functions.lint =
        setup.functions.lint ||
            (await (0, prompt_1.confirm)({
                message: "Do you want to use ESLint to catch probable bugs and enforce style?",
                default: true,
            }));
    const cbconfig = (0, projectConfig_1.configForCodebase)(setup.config.functions, setup.functions.codebase);
    cbconfig.predeploy = [];
    if (setup.functions.lint) {
        cbconfig.predeploy.push('npm --prefix "$RESOURCE_DIR" run lint');
        cbconfig.predeploy.push('npm --prefix "$RESOURCE_DIR" run build');
        await config.askWriteProjectFile(`${setup.functions.source}/.eslintrc.js`, ESLINT_TEMPLATE);
        await config.askWriteProjectFile(`${setup.functions.source}/tsconfig.dev.json`, TSCONFIG_DEV_TEMPLATE);
    }
    else {
        cbconfig.predeploy.push('npm --prefix "$RESOURCE_DIR" run build');
    }
    let packageTemplate = PACKAGE_LINTING_TEMPLATE;
    if (setup.featureInfo?.dataconnectResolver) {
        packageTemplate = setup.functions.lint
            ? PACKAGE_GRAPH_LINTING_TEMPLATE
            : PACKAGE_GRAPH_NO_LINTING_TEMPLATE;
    }
    else if (!setup.functions.lint) {
        packageTemplate = PACKAGE_NO_LINTING_TEMPLATE;
    }
    await config.askWriteProjectFile(`${setup.functions.source}/package.json`, packageTemplate.replace("{{RUNTIME}}", supported.latest("nodejs").replace("nodejs", "")));
    await config.askWriteProjectFile(`${setup.functions.source}/tsconfig.json`, TSCONFIG_TEMPLATE);
    if (setup.featureInfo?.dataconnectResolver) {
        await config.askWriteProjectFile(`${setup.functions.source}/src/index.ts`, (0, utils_1.templateWithSubbedResolverId)(setup.featureInfo.dataconnectResolver.id, GRAPH_INDEX_TEMPLATE));
    }
    else {
        await config.askWriteProjectFile(`${setup.functions.source}/src/index.ts`, INDEX_TEMPLATE);
    }
    await config.askWriteProjectFile(`${setup.functions.source}/.gitignore`, GITIGNORE_TEMPLATE);
    await (0, npm_dependencies_1.askInstallDependencies)(setup.functions, config);
}
