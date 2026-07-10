"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_environment = void 0;
exports.hydrateTemplate = hydrateTemplate;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const projectUtils_1 = require("../../../projectUtils");
const js_yaml_1 = require("js-yaml");
const auth_1 = require("../../../auth");
const configstore_1 = require("../../../configstore");
const appUtils_1 = require("../../../appUtils");
function hydrateTemplate(config) {
    const activeProject = config.projectId
        ? `${config.projectId}${config.projectAliases.length ? ` (alias: ${config.projectAliases.join(",")})` : ""}`
        : "<NONE>";
    const projectConfigPath = config.projectConfigPath || "<NO CONFIG PRESENT>";
    const geminiTosAccepted = config.geminiTosAccepted ? "Accepted" : "<NOT ACCEPTED>";
    const billingEnabled = config.projectId ? (config.isBillingEnabled ? "Yes" : "No") : "N/A";
    const authenticatedUser = config.authenticatedUser || "<NONE>";
    const detectedApps = Object.entries(config.detectedAppIds).length > 0
        ? `\n\n${(0, js_yaml_1.dump)(config.detectedAppIds).trim()}\n`
        : "<NONE>";
    const availableProjects = Object.entries(config.projectAliasMap).length > 0
        ? `\n\n${(0, js_yaml_1.dump)(config.projectAliasMap)}`
        : "<NONE>";
    const hasOtherAccounts = config.allAccounts.filter((email) => email !== config.authenticatedUser).length > 0;
    const availableAccounts = hasOtherAccounts ? `${(0, js_yaml_1.dump)(config.allAccounts).trim()}` : "";
    return `# Environment Information

Project Directory: ${config.projectDir}
Project Config Path: ${projectConfigPath}
Active Project ID: ${activeProject}
Gemini in Firebase Terms of Service: ${geminiTosAccepted}
Billing Enabled: ${billingEnabled}
Authenticated User: ${authenticatedUser}
Detected App IDs: ${detectedApps}
Available Project Aliases (format: '[alias]: [projectId]'): ${availableProjects}${hasOtherAccounts ? `\nAvailable Accounts: \n\n${availableAccounts}` : ""}
${config.projectFileContents
        ? `\nfirebase.json contents:

\`\`\`json
${config.projectFileContents}
\`\`\``
        : `\nNo firebase.json file was found.

If this project does not use Firebase services that require a firebase.json file, no action is necessary.

If this project uses Firebase services that require a firebase.json file, the user will most likely want to:

a) Change the project directory using the 'firebase_update_environment' tool to select a directory with a 'firebase.json' file in it, or
b) Initialize a new Firebase project directory using the 'firebase_init' tool.

Confirm with the user before taking action.`}`;
}
exports.get_environment = (0, tool_1.tool)("core", {
    name: "get_environment",
    description: "Use this to retrieve the current Firebase **environment** configuration for the Firebase CLI and Firebase MCP server, including current authenticated user, project directory, active Firebase Project, and more. All tools require the user to be authenticated, but not all information is required for all tools. Pay attention to the tool requirements for which pieces of information are required.",
    inputSchema: zod_1.z.object({}),
    annotations: {
        title: "Get Firebase Environment Info",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: false,
        requiresProject: false,
    },
}, async (_, { projectId, host, accountEmail, rc, config, isBillingEnabled }) => {
    const aliases = projectId ? (0, projectUtils_1.getAliases)({ rc }, projectId) : [];
    const geminiTosAccepted = !!configstore_1.configstore.get("gemini");
    const projectFileExists = config.projectFileExists("firebase.json");
    const detectedApps = await (0, appUtils_1.detectApps)(process.cwd());
    const allAccounts = (0, auth_1.getAllAccounts)().map((account) => account.user.email);
    const detectedAppsMap = {};
    detectedApps
        .filter((app) => !!app.appId)
        .reduce((map, app) => {
        if (app.appId) {
            map[app.appId] = app.bundleId ? app.bundleId : "<UNKNOWN BUNDLE ID>";
        }
        return map;
    }, detectedAppsMap);
    const environmentTemplateConfig = {
        projectId,
        projectAliases: aliases,
        projectDir: host.cachedProjectDir,
        projectConfigPath: projectFileExists ? config.path("firebase.json") : undefined,
        geminiTosAccepted,
        isBillingEnabled,
        authenticatedUser: accountEmail || undefined,
        projectAliasMap: rc.projects,
        allAccounts,
        detectedAppIds: detectedAppsMap,
        projectFileContents: projectFileExists ? config.readProjectFile("firebase.json") : undefined,
    };
    return (0, util_1.toContent)(hydrateTemplate(environmentTemplateConfig));
});
