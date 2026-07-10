"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createStorageRulesManager = createStorageRulesManager;
const chokidar = require("chokidar");
const emulatorLogger_1 = require("../../emulatorLogger");
const types_1 = require("../../types");
const runtime_1 = require("./runtime");
const fsutils_1 = require("../../../fsutils");
function createStorageRulesManager(rules, runtime) {
    return Array.isArray(rules)
        ? new ResourceBasedStorageRulesManager(rules, runtime)
        : new DefaultStorageRulesManager(rules, runtime);
}
class DefaultStorageRulesManager {
    constructor(_rules, _runtime) {
        this._runtime = _runtime;
        this._watcher = new chokidar.FSWatcher();
        this._logger = emulatorLogger_1.EmulatorLogger.forEmulator(types_1.Emulators.STORAGE);
        this._rules = _rules;
    }
    async start() {
        const issues = await this.loadRuleset();
        this.updateWatcher(this._rules.name);
        return issues;
    }
    getRuleset() {
        return this._ruleset;
    }
    async stop() {
        await this._watcher.close();
    }
    updateWatcher(rulesFile) {
        this._watcher = chokidar
            .watch(rulesFile, { persistent: true, ignoreInitial: true })
            .on("change", async () => {
            await new Promise((res) => setTimeout(res, 5));
            try {
                const content = (0, fsutils_1.readFile)(rulesFile);
                this._rules.content = content;
                this._logger.logLabeled("BULLET", "storage", "Change detected, updating rules for Cloud Storage...");
                await this.loadRuleset();
            }
            catch (e) {
                const message = e instanceof Error ? e.message : String(e);
                this._logger.logLabeled("DEBUG", "storage", `A rule file change was detected, but there was an error reading it: ${message}`);
            }
        });
    }
    async loadRuleset() {
        const { ruleset, issues } = await this._runtime.loadRuleset({ files: [this._rules] });
        if (ruleset) {
            this._ruleset = ruleset;
            return issues;
        }
        issues.all.forEach((issue) => {
            try {
                const parsedIssue = JSON.parse(issue);
                this._logger.log("WARN", `${parsedIssue.description_.replace(/\.$/, "")} in ${parsedIssue.sourcePosition_.fileName_}:${parsedIssue.sourcePosition_.line_}`);
            }
            catch {
                this._logger.logLabeled("WARN", "storage", issue);
            }
        });
        return issues;
    }
}
class ResourceBasedStorageRulesManager {
    constructor(_rulesConfig, _runtime) {
        this._runtime = _runtime;
        this._rulesManagers = new Map();
        for (const { resource, rules } of _rulesConfig) {
            this.createRulesManager(resource, rules);
        }
    }
    async start() {
        const allIssues = new runtime_1.StorageRulesIssues();
        for (const rulesManager of this._rulesManagers.values()) {
            allIssues.extend(await rulesManager.start());
        }
        return allIssues;
    }
    getRuleset(resource) {
        return this._rulesManagers.get(resource)?.getRuleset();
    }
    async stop() {
        await Promise.all(Array.from(this._rulesManagers.values(), async (rulesManager) => await rulesManager.stop()));
    }
    createRulesManager(resource, rules) {
        const rulesManager = new DefaultStorageRulesManager(rules, this._runtime);
        this._rulesManagers.set(resource, rulesManager);
        return rulesManager;
    }
}
