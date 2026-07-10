"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.extractMetadata = extractMetadata;
exports.uploadSecrets = uploadSecrets;
exports.migrate = migrate;
const fs = require("fs/promises");
const path = require("path");
const child_process_1 = require("child_process");
const semver = require("semver");
const logger_1 = require("../logger");
const prompt = require("../prompt");
const apphosting = require("../gcp/apphosting");
const utils = require("../utils");
const templates_1 = require("../templates");
const track = require("../track");
const secrets_1 = require("../apphosting/secrets");
const env = require("../functions/env");
const error_1 = require("../error");
const os = require("os");
const agentSkills_1 = require("../agentSkills");
async function setupAntigravityMcpServer(rootPath, appType, nonInteractive) {
    const mcpConfigDir = path.join(os.homedir(), ".gemini", "antigravity");
    const mcpConfigPath = path.join(mcpConfigDir, "mcp_config.json");
    let mcpConfig = { mcpServers: {} };
    try {
        await fs.mkdir(mcpConfigDir, { recursive: true });
        const content = await fs
            .readFile(mcpConfigPath, "utf-8")
            .catch((err) => {
            if (err.code === "ENOENT") {
                return null;
            }
            throw err;
        });
        if (content) {
            mcpConfig = JSON.parse(content);
            if (!mcpConfig.mcpServers) {
                mcpConfig.mcpServers = {};
            }
        }
        let updated = false;
        if (!mcpConfig.mcpServers["firebase"]) {
            if (utils.commandExistsSync("npx")) {
                const confirmFirebase = await prompt.confirm({
                    message: "Would you like to enable the Firebase MCP server for Antigravity?",
                    default: true,
                    nonInteractive,
                });
                if (confirmFirebase) {
                    mcpConfig.mcpServers["firebase"] = {
                        command: "npx",
                        args: ["-y", "firebase-tools@latest", "mcp", "--dir", path.resolve(rootPath)],
                    };
                    updated = true;
                    logger_1.logger.info(`✅ Configured Firebase MCP server in ${mcpConfigPath}`);
                }
            }
            else {
                logger_1.logger.info("ℹ️ npx not found on PATH, skipping Firebase MCP server configuration.");
            }
        }
        else {
            logger_1.logger.info("ℹ️ Firebase MCP server already configured in Antigravity, skipping.");
        }
        if (appType === "FLUTTER") {
            if (utils.commandExistsSync("dart")) {
                if (!mcpConfig.mcpServers["dart"]) {
                    const confirmDart = await prompt.confirm({
                        message: "Would you like to enable the Dart MCP server for Antigravity?",
                        default: true,
                        nonInteractive,
                    });
                    if (confirmDart) {
                        mcpConfig.mcpServers["dart"] = {
                            command: "dart",
                            args: ["mcp-server"],
                        };
                        updated = true;
                        logger_1.logger.info(`✅ Configured Dart MCP server in ${mcpConfigPath}`);
                    }
                }
                else {
                    logger_1.logger.info("ℹ️ Dart MCP server already configured in Antigravity, skipping.");
                }
            }
            else {
                utils.logWarning("Couldn't find Dart/Flutter on PATH. Install Flutter by following the instruction at https://docs.flutter.dev/install.");
            }
        }
        if (updated) {
            await fs.writeFile(mcpConfigPath, JSON.stringify(mcpConfig, null, 2));
        }
    }
    catch (err) {
        utils.logWarning(`Could not configure Antigravity MCP server: ${(0, error_1.getErrMsg)(err)}`);
    }
}
async function detectAppType(rootPath) {
    try {
        await fs.access(path.join(rootPath, "pubspec.yaml"));
        return "FLUTTER";
    }
    catch {
    }
    try {
        await fs.access(path.join(rootPath, "angular.json"));
        return "ANGULAR";
    }
    catch {
    }
    try {
        const packageJsonPath = path.join(rootPath, "package.json");
        const packageJsonContent = await fs.readFile(packageJsonPath, "utf8");
        const packageJson = JSON.parse(packageJsonContent);
        const deps = { ...packageJson.dependencies, ...packageJson.devDependencies };
        if (deps.next) {
            return "NEXT_JS";
        }
        if (deps["@angular/core"]) {
            return "ANGULAR";
        }
    }
    catch {
    }
    for (const configFile of ["next.config.js", "next.config.mjs"]) {
        try {
            await fs.access(path.join(rootPath, configFile));
            return "NEXT_JS";
        }
        catch {
        }
    }
    return "OTHER";
}
const isValidFirebaseProjectId = (projectId) => {
    const projectIdRegex = /^[a-z][a-z0-9-]{4,28}[a-z0-9]$/;
    return projectIdRegex.test(projectId);
};
async function extractMetadata(rootPath, overrideProjectId) {
    const studioJsonPath = path.join(rootPath, "studio.json");
    const metadataPath = path.join(rootPath, "metadata.json");
    let metadata = {};
    for (const metadataFile of [metadataPath, studioJsonPath]) {
        try {
            const metadataContent = await fs.readFile(metadataFile, "utf8");
            metadata = JSON.parse(metadataContent);
            logger_1.logger.info(`✅ Read ${metadataFile}`);
        }
        catch (err) {
            logger_1.logger.debug(`Could not read metadata at ${metadataFile}: ${err}`);
        }
    }
    logger_1.logger.debug(`overrideProjectId ${overrideProjectId}`);
    logger_1.logger.debug(`metadata.projectId ${metadata.projectId}`);
    let projectId = overrideProjectId || metadata.projectId;
    if (!projectId) {
        try {
            const firebasercContent = await fs.readFile(path.join(rootPath, ".firebaserc"), "utf8");
            const firebaserc = JSON.parse(firebasercContent);
            projectId = firebaserc.projects?.default;
        }
        catch (err) {
            logger_1.logger.debug(`Could not read .firebaserc at ${rootPath}: ${err}`);
        }
    }
    if (projectId) {
        if (!isValidFirebaseProjectId(projectId)) {
            throw new error_1.FirebaseError(`Invalid project ID: ${projectId}.`, {
                exit: 1,
            });
        }
        logger_1.logger.info(`✅ Using Firebase Project: ${projectId}`);
    }
    else {
        logger_1.logger.debug(`❌ Failed to determine the Firebase Project ID. You can set a project later by setting the '--project' flag.`);
    }
    let appName = "firebase-studio-export";
    const blueprintPath = path.join(rootPath, "docs", "blueprint.md");
    try {
        const content = await fs.readFile(blueprintPath, "utf8");
        const nameMatch = content.match(/# \*\*App Name\*\*: (.*)/);
        if (nameMatch && nameMatch[1]) {
            appName = nameMatch[1].trim();
        }
    }
    catch (err) {
        logger_1.logger.debug(`Could not read blueprint.md at ${blueprintPath}: ${err}`);
    }
    if (appName !== "firebase-studio-export") {
        logger_1.logger.info(`✅ Detected App Name: ${appName}`);
    }
    return { projectId, appName };
}
async function updateReadme(rootPath, framework) {
    const readmePath = path.join(rootPath, "README.md");
    const readmeTemplate = await (0, templates_1.readTemplate)("firebase-studio-export/readme_template.md");
    const frameworkConfigs = {
        NEXT_JS: { startCommand: "npm run dev", localUrl: "http://localhost:9002" },
        ANGULAR: { startCommand: "npm run start", localUrl: "http://localhost:4200" },
        FLUTTER: {
            startCommand: "flutter run -d chrome --web-port=8080",
            localUrl: "http://localhost:8080",
        },
        OTHER: { startCommand: "npm run dev", localUrl: "http://localhost:9002" },
    };
    const { startCommand, localUrl } = frameworkConfigs[framework];
    let existingReadme = "";
    try {
        existingReadme = await fs.readFile(readmePath, "utf8");
    }
    catch (err) {
    }
    let newReadme = readmeTemplate
        .replace("${exportDate}", new Date().toISOString().split("T")[0])
        .replace("${startCommand}", startCommand)
        .replace("${localUrl}", localUrl);
    if (existingReadme.trim()) {
        newReadme += `\n\n---\n\n## Previous README.md contents:\n\n${existingReadme}`;
    }
    await fs.writeFile(readmePath, newReadme);
    logger_1.logger.info("✅ Updated README.md with project details and origin info");
}
async function injectAntigravityContext(rootPath, projectId, appName, nonInteractive) {
    const agentDir = path.join(rootPath, ".agents");
    const rulesDir = path.join(agentDir, "rules");
    const workflowsDir = path.join(agentDir, "workflows");
    const skillsDir = path.join(agentDir, "skills");
    await fs.mkdir(rulesDir, { recursive: true });
    await fs.mkdir(workflowsDir, { recursive: true });
    await fs.mkdir(skillsDir, { recursive: true });
    const installLocation = await prompt.select({
        message: "Where would you like to install Firebase project skills?",
        choices: [
            { name: "Locally in the project", value: "local" },
            { name: "Globally for all projects", value: "global" },
        ],
        default: "local",
        nonInteractive: nonInteractive || process.env.NODE_ENV === "test",
    });
    await (0, agentSkills_1.installAgentSkills)({
        cwd: rootPath,
        global: installLocation === "global",
        background: false,
        agentName: "gemini-cli",
        skillPackage: "firebase/agent-skills",
    });
    await (0, agentSkills_1.installAgentSkills)({
        cwd: rootPath,
        global: installLocation === "global",
        background: false,
        agentName: "gemini-cli",
        skillPackage: "genkit-ai/skills",
    });
    const systemInstructionsTemplate = await (0, templates_1.readTemplate)("firebase-studio-export/system_instructions_template.md");
    const systemInstructions = systemInstructionsTemplate.replace("${appName}", appName);
    await fs.writeFile(path.join(rulesDir, "migration-context.md"), systemInstructions);
    logger_1.logger.info("✅ Injected Antigravity rules");
    try {
        const cleanupWorkflow = await (0, templates_1.readTemplate)("firebase-studio-export/workflows/cleanup.md");
        await fs.writeFile(path.join(workflowsDir, "cleanup.md"), cleanupWorkflow);
        logger_1.logger.info("✅ Created Antigravity startup workflow");
    }
    catch (err) {
        logger_1.logger.debug(`Could not read or write startup workflow: ${(0, error_1.getErrMsg)(err)}`);
    }
}
async function getAgyCommand(startAgy) {
    if (!startAgy) {
        return undefined;
    }
    const commands = ["agy", "antigravity"];
    for (const cmd of commands) {
        if (utils.commandExistsSync(cmd)) {
            logger_1.logger.info(`✅ Antigravity IDE detected`);
            return cmd;
        }
    }
    if (process.platform === "darwin") {
        const macPath = "/Applications/Antigravity.app/Contents/Resources/app/bin/agy";
        try {
            await fs.access(macPath);
            logger_1.logger.info(`✅ Antigravity IDE detected at ${macPath}`);
            return macPath;
        }
        catch {
        }
    }
    if (process.platform === "win32") {
        const winPath = path.join(process.env.LOCALAPPDATA || "", "Programs", "Antigravity", "bin", "agy.exe");
        try {
            await fs.access(winPath);
            logger_1.logger.info(`✅ Antigravity IDE CLI detected at ${winPath}`);
            return winPath;
        }
        catch {
        }
    }
    const downloadLink = "https://antigravity.google/download";
    logger_1.logger.info(`⚠️ Antigravity IDE not found in your PATH. To ensure a seamless migration, please download and install Antigravity: ${downloadLink}`);
    return undefined;
}
async function createFirebaseConfigs(rootPath, projectId, nonInteractive) {
    if (!projectId) {
        return;
    }
    const firebaserc = {
        projects: {
            default: projectId,
        },
    };
    await fs.writeFile(path.join(rootPath, ".firebaserc"), JSON.stringify(firebaserc, null, 2));
    logger_1.logger.info("✅ Created .firebaserc");
    const firebaseJsonPath = path.join(rootPath, "firebase.json");
    try {
        await fs.access(firebaseJsonPath);
        logger_1.logger.info("ℹ️ firebase.json already exists, skipping creation.");
    }
    catch {
        let backendId = "studio";
        try {
            logger_1.logger.info(`⏳ Fetching App Hosting backends for project ${projectId}...`);
            const backendsData = await apphosting.listBackends(projectId, "-");
            const backends = backendsData.backends || [];
            if (backends.length > 0) {
                const backendIds = backends.map((b) => b.name.split("/").pop());
                const studioBackend = backends.find((b) => b.name.endsWith("/studio") || b.name.toLowerCase().includes("studio"));
                let selectedBackendId = "";
                if (studioBackend) {
                    selectedBackendId = studioBackend.name.split("/").pop();
                }
                else {
                    selectedBackendId = backendIds[0];
                }
                const confirmBackend = await prompt.confirm({
                    message: `Would you like to use the App Hosting backend "${selectedBackendId}"?`,
                    default: true,
                    nonInteractive: nonInteractive || process.env.NODE_ENV === "test",
                });
                if (confirmBackend) {
                    backendId = selectedBackendId;
                }
                else {
                    logger_1.logger.info("Available App Hosting backends:");
                    for (const id of backendIds) {
                        logger_1.logger.info(`  - ${id}`);
                    }
                    const inputBackendId = await prompt.input({
                        message: "Please enter the name of the backend you would like to use:",
                    });
                    if (!backendIds.includes(inputBackendId)) {
                        throw new error_1.FirebaseError(`Invalid backend selected: ${inputBackendId}`, { exit: 1 });
                    }
                    backendId = inputBackendId;
                }
                logger_1.logger.info(`✅ Selected App Hosting backend: ${backendId}`);
            }
            else {
                utils.logWarning('No App Hosting backends found, using default "studio"');
            }
        }
        catch (err) {
            utils.logWarning(`Could not fetch backends from Firebase CLI, using default "studio". ${(0, error_1.getErrMsg)(err)}`);
        }
        const firebaseJson = {
            apphosting: {
                backendId: backendId,
                ignore: [
                    "node_modules",
                    ".git",
                    ".agents",
                    ".idx",
                    "firebase-debug.log",
                    "firebase-debug.*.log",
                    "functions",
                ],
            },
        };
        await fs.writeFile(firebaseJsonPath, JSON.stringify(firebaseJson, null, 2));
        logger_1.logger.info(`✅ Created firebase.json with backendId: ${backendId}`);
    }
}
async function writeAntigravityConfigs(rootPath, framework) {
    const vscodeDir = path.join(rootPath, ".vscode");
    await fs.mkdir(vscodeDir, { recursive: true });
    const tasksJson = {
        version: "2.0.0",
        tasks: [],
    };
    if (framework === "FLUTTER") {
        tasksJson.tasks.push({
            label: "flutter-pub-get",
            type: "shell",
            command: "flutter pub get",
            problemMatcher: [],
            group: {
                kind: "build",
                isDefault: true,
            },
        });
    }
    else {
        tasksJson.tasks.push({
            label: "npm-install",
            type: "shell",
            command: "npm install",
            problemMatcher: [],
        });
    }
    await fs.writeFile(path.join(vscodeDir, "tasks.json"), JSON.stringify(tasksJson, null, 2));
    logger_1.logger.info("✅ Created .vscode/tasks.json");
    const settingsPath = path.join(vscodeDir, "settings.json");
    let settings = {};
    try {
        const settingsContent = await fs.readFile(settingsPath, "utf8");
        settings = JSON.parse(settingsContent);
    }
    catch (err) {
        logger_1.logger.debug(`Could not read ${settingsPath}: ${(0, error_1.getErrMsg)(err)}`);
    }
    const cleanSettings = {};
    for (const [key, value] of Object.entries(settings)) {
        if (!key.startsWith("IDX.")) {
            cleanSettings[key] = value;
        }
    }
    cleanSettings["workbench.startupEditor"] = "readme";
    await fs.writeFile(settingsPath, JSON.stringify(cleanSettings, null, 2));
    logger_1.logger.info("✅ Updated .vscode/settings.json with startup preferences");
    const launchJson = {
        version: "0.2.0",
        configurations: [],
    };
    if (framework === "ANGULAR") {
        launchJson.configurations.push({
            type: "node",
            request: "launch",
            name: "Angular: debug server-side",
            runtimeExecutable: "npm",
            runtimeArgs: ["run", "start"],
            port: 4200,
            console: "integratedTerminal",
            preLaunchTask: "npm-install",
        });
    }
    else if (framework === "NEXT_JS") {
        launchJson.configurations.push({
            type: "node",
            request: "launch",
            name: "Next.js: debug server-side",
            runtimeExecutable: "npm",
            runtimeArgs: ["run", "dev"],
            port: 9002,
            console: "integratedTerminal",
            preLaunchTask: "npm-install",
        });
    }
    else if (framework === "FLUTTER") {
        launchJson.configurations.push({
            name: "Flutter",
            request: "launch",
            type: "dart",
            preLaunchTask: "flutter-pub-get",
        });
    }
    else {
        return;
    }
    await fs.writeFile(path.join(vscodeDir, "launch.json"), JSON.stringify(launchJson, null, 2));
    logger_1.logger.info("✅ Created .vscode/launch.json");
}
async function cleanupUnusedFiles(rootPath) {
    const docsDir = path.join(rootPath, "docs");
    try {
        const files = await fs.readdir(docsDir);
        if (files.length === 0) {
            await fs.rmdir(docsDir);
            logger_1.logger.info("✅ Removed empty docs directory");
        }
    }
    catch (err) {
        logger_1.logger.debug(`Could not remove ${docsDir}: ${(0, error_1.getErrMsg)(err)}`);
    }
    const modifiedPath = path.join(rootPath, ".modified");
    try {
        await fs.unlink(modifiedPath);
        logger_1.logger.info("✅ Cleaned up .modified");
    }
    catch (err) {
        logger_1.logger.debug(`Could not delete ${modifiedPath}: ${(0, error_1.getErrMsg)(err)}`);
    }
    const mcpJsonPath = path.join(rootPath, ".idx", "mcp.json");
    try {
        await fs.unlink(mcpJsonPath);
        logger_1.logger.info("✅ Cleaned up .idx/mcp.json");
    }
    catch (err) {
        logger_1.logger.debug(`Could not delete ${mcpJsonPath}: ${(0, error_1.getErrMsg)(err)}`);
    }
}
async function upgradeGenkitVersion(rootPath) {
    const packageJsonPath = path.join(rootPath, "package.json");
    try {
        const packageJsonContent = await fs.readFile(packageJsonPath, "utf8");
        const packageJson = JSON.parse(packageJsonContent);
        let modified = false;
        const targetVersion = "1.29.0";
        const checkAndUpgrade = (deps) => {
            if (!deps || !deps["genkit-cli"]) {
                return;
            }
            const currentVersion = deps["genkit-cli"];
            if (currentVersion.startsWith("^")) {
                return;
            }
            const coerced = semver.coerce(currentVersion);
            if (coerced && semver.lt(coerced, targetVersion)) {
                deps["genkit-cli"] = "^1.29";
                modified = true;
            }
        };
        checkAndUpgrade(packageJson.dependencies);
        checkAndUpgrade(packageJson.devDependencies);
        if (modified) {
            await fs.writeFile(packageJsonPath, JSON.stringify(packageJson, null, 2) + "\n");
            logger_1.logger.info("✅ Upgraded genkit-cli version to 1.29 in package.json");
        }
    }
    catch (err) {
        logger_1.logger.debug(`Could not upgrade Genkit version: ${(0, error_1.getErrMsg)(err)}`);
    }
}
async function uploadSecrets(rootPath, projectId) {
    if (!projectId) {
        return;
    }
    const envPath = path.join(rootPath, ".env");
    try {
        await fs.access(envPath);
    }
    catch {
        return;
    }
    try {
        const envContent = await fs.readFile(envPath, "utf8");
        const parsedEnv = env.parse(envContent);
        const geminiApiKey = parsedEnv.envs["GEMINI_API_KEY"];
        if (geminiApiKey && geminiApiKey.trim().length > 0) {
            logger_1.logger.info("⏳ Uploading GEMINI_API_KEY from .env to App Hosting secrets...");
            await (0, secrets_1.apphostingSecretsSetAction)("GEMINI_API_KEY", projectId, undefined, undefined, envPath, true);
            logger_1.logger.info("✅ Uploaded GEMINI_API_KEY secret");
        }
        else {
            logger_1.logger.debug("Skipping GEMINI_API_KEY upload: key is missing or blank in .env");
        }
    }
    catch (err) {
        utils.logWarning(`Failed to upload GEMINI_API_KEY secret: ${(0, error_1.getErrMsg)(err)}`);
    }
}
async function askToOpenAntigravity(rootPath, appName, startAntigravity, nonInteractive) {
    const agyCommand = await getAgyCommand(startAntigravity);
    logger_1.logger.info(`\n🎉 Your Firebase Studio project "${appName}" is now ready for Antigravity!`);
    logger_1.logger.info("Antigravity is Google's agentic IDE, where you can collaborate with AI agents to build, test, and deploy your application.");
    logger_1.logger.info("\nWhat to do next inside Antigravity:");
    logger_1.logger.info("  1.  Review the README.md: It has been updated with specifics about this migrated project.");
    logger_1.logger.info("  2.  Open the Agent Chat: Use the side panel or press Cmd+L (Ctrl+L on Windows/Linux). This is your main interface with the AI.");
    logger_1.logger.info("\nFile any bugs at https://github.com/firebase/firebase-tools/issues");
    if (!startAntigravity || !agyCommand) {
        return;
    }
    const answer = await prompt.confirm({
        message: "Would you like to open it in Antigravity now?",
        default: true,
        nonInteractive,
    });
    if (answer) {
        logger_1.logger.info(`⏳ Opening ${appName} in Antigravity...`);
        try {
            const antigravityProcess = (0, child_process_1.spawn)(agyCommand, ["."], {
                cwd: rootPath,
                stdio: "ignore",
                detached: true,
                shell: process.platform === "win32",
            });
            antigravityProcess.unref();
        }
        catch (err) {
            utils.logWarning("Could not open Antigravity IDE automatically. Please open it manually.");
        }
    }
}
async function checkDirectoryExists(dir) {
    try {
        const stat = await fs.stat(dir);
        if (!stat.isDirectory()) {
            throw new error_1.FirebaseError(`The path ${dir} is not a directory.`, { exit: 1 });
        }
    }
    catch (err) {
        if (err.code === "ENOENT") {
            throw new error_1.FirebaseError(`The directory ${dir} does not exist.`, { exit: 1 });
        }
        throw err;
    }
}
async function migrate(rootPath, options = { startAntigravity: true }) {
    await checkDirectoryExists(rootPath);
    const appType = await detectAppType(rootPath);
    await track.trackGA4("firebase_studio_migrate", { app_type: appType, result: "started" });
    logger_1.logger.info("🚀 Starting Firebase Studio to Antigravity migration...");
    logger_1.logger.info("\nFile any bugs at https://github.com/firebase/firebase-tools/issues");
    const { projectId, appName } = await extractMetadata(rootPath, options.project);
    if (appType) {
        logger_1.logger.info(`✅ Detected framework: ${appType}`);
    }
    await updateReadme(rootPath, appType);
    await createFirebaseConfigs(rootPath, projectId, options.nonInteractive);
    await uploadSecrets(rootPath, projectId);
    await upgradeGenkitVersion(rootPath);
    await injectAntigravityContext(rootPath, projectId, appName, options.nonInteractive);
    await writeAntigravityConfigs(rootPath, appType);
    await setupAntigravityMcpServer(rootPath, appType, options.nonInteractive);
    await cleanupUnusedFiles(rootPath);
    const currentFolderName = path.basename(rootPath);
    if (currentFolderName === "download") {
        logger_1.logger.info(`\n💡 Tip: You may want to rename this folder to "${appName.toLowerCase().replace(/\s+/g, "-")}"`);
    }
    await track.trackGA4("firebase_studio_migrate", { app_type: appType, result: "success" });
    await askToOpenAntigravity(rootPath, appName, options.startAntigravity, options.nonInteractive);
}
