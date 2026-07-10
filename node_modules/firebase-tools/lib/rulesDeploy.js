"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RulesDeploy = exports.RulesetServiceType = void 0;
const _ = require("lodash");
const colorette_1 = require("colorette");
const fs = require("fs-extra");
const gcp = require("./gcp");
const logger_1 = require("./logger");
const error_1 = require("./error");
const utils = require("./utils");
const prompt_1 = require("./prompt");
const getProjectNumber_1 = require("./getProjectNumber");
const resourceManager_1 = require("./gcp/resourceManager");
const QUOTA_EXCEEDED_STATUS_CODE = 429;
const RULESET_COUNT_LIMIT = 1000;
const RULESETS_TO_GC = 10;
const CROSS_SERVICE_FUNCTIONS = /firestore\.(get|exists)/;
const CROSS_SERVICE_RULES_ROLE = "roles/firebaserules.firestoreServiceAgent";
var RulesetServiceType;
(function (RulesetServiceType) {
    RulesetServiceType["CLOUD_FIRESTORE"] = "cloud.firestore";
    RulesetServiceType["FIREBASE_STORAGE"] = "firebase.storage";
})(RulesetServiceType || (exports.RulesetServiceType = RulesetServiceType = {}));
const RulesetType = {
    [RulesetServiceType.CLOUD_FIRESTORE]: "firestore",
    [RulesetServiceType.FIREBASE_STORAGE]: "storage",
};
class RulesDeploy {
    constructor(options, type) {
        this.options = options;
        this.type = type;
        this.project = options.project;
        this.rulesFiles = [];
        this.rulesetNames = {};
    }
    addFile(path, databaseId) {
        const fullPath = this.options.config.path(path);
        let src;
        try {
            src = fs.readFileSync(fullPath, "utf8");
        }
        catch (e) {
            logger_1.logger.debug("[rules read error]", e.stack);
            throw new error_1.FirebaseError(`Error reading rules file ${(0, colorette_1.bold)(path)}`);
        }
        this.rulesFiles.push({ path, files: [{ name: path, content: src }], databaseId });
    }
    async compile() {
        await Promise.all(this.rulesFiles.map((entry) => {
            return this.compileRuleset(entry.path, entry.files);
        }));
    }
    async getCurrentRules(service, releases, databaseId) {
        const latestName = await gcp.rules.getLatestRulesetName(this.options.project, service, releases, databaseId);
        let latestContent = null;
        if (latestName) {
            latestContent = await gcp.rules.getRulesetContent(latestName);
        }
        return { latestName, latestContent };
    }
    async checkStorageRulesIamPermissions(rulesContent) {
        if (rulesContent?.match(CROSS_SERVICE_FUNCTIONS) === null) {
            return;
        }
        if (this.options.nonInteractive) {
            return;
        }
        const projectNumber = await (0, getProjectNumber_1.getProjectNumber)(this.options);
        const saEmail = `service-${projectNumber}@gcp-sa-firebasestorage.iam.gserviceaccount.com`;
        try {
            if (await (0, resourceManager_1.serviceAccountHasRoles)(projectNumber, saEmail, [CROSS_SERVICE_RULES_ROLE], true)) {
                return;
            }
            const addRole = await (0, prompt_1.confirm)({
                message: `Cloud Storage for Firebase needs an IAM Role to use cross-service rules. Grant the new role?`,
                default: true,
                force: this.options.force,
            });
            if (addRole) {
                await (0, resourceManager_1.addServiceAccountToRoles)(projectNumber, saEmail, [CROSS_SERVICE_RULES_ROLE], true);
                utils.logLabeledBullet(RulesetType[this.type], "updated service account for cross-service rules...");
            }
        }
        catch (e) {
            logger_1.logger.warn("[rules] Error checking or updating Cloud Storage for Firebase service account permissions.");
            logger_1.logger.warn("[rules] Cross-service Storage rules may not function properly", e.message);
        }
    }
    async createRulesets(service) {
        const createdRulesetNames = [];
        const releases = await gcp.rules.listAllReleases(this.options.project);
        const newRulesetsByKey = new Map();
        for (const entry of this.rulesFiles) {
            const { path: filename, files, databaseId } = entry;
            const normalizedDatabaseId = databaseId === "(default)" ? undefined : databaseId;
            const { latestName: latestRulesetName, latestContent: latestRulesetContent } = await this.getCurrentRules(service, releases, normalizedDatabaseId);
            const key = this.type === RulesetServiceType.FIREBASE_STORAGE
                ? filename
                : `${filename}:${databaseId || ""}`;
            if (latestRulesetName && _.isEqual(files, latestRulesetContent)) {
                utils.logLabeledBullet(RulesetType[this.type], `latest version of ${(0, colorette_1.bold)(filename)} already up to date, skipping upload...`);
                this.rulesetNames[key] = latestRulesetName;
                continue;
            }
            if (service === RulesetServiceType.FIREBASE_STORAGE) {
                await this.checkStorageRulesIamPermissions(files[0]?.content);
            }
            utils.logLabeledBullet(RulesetType[this.type], `uploading rules ${(0, colorette_1.bold)(filename)}...`);
            let attachmentPoint;
            if (this.type === RulesetServiceType.CLOUD_FIRESTORE &&
                databaseId &&
                databaseId !== "(default)") {
                const projectNumber = await (0, getProjectNumber_1.getProjectNumber)(this.options);
                attachmentPoint = `firestore.googleapis.com/projects/${projectNumber}/databases/${databaseId}`;
            }
            newRulesetsByKey.set(key, gcp.rules.createRuleset(this.options.project, files, attachmentPoint));
        }
        try {
            await Promise.all(newRulesetsByKey.values());
            for (const [key, rulesetName] of newRulesetsByKey) {
                this.rulesetNames[key] = await rulesetName;
                createdRulesetNames.push(await rulesetName);
            }
        }
        catch (err) {
            if ((0, error_1.getErrStatus)(err) !== QUOTA_EXCEEDED_STATUS_CODE) {
                throw err;
            }
            utils.logLabeledBullet(RulesetType[this.type], "quota exceeded error while uploading rules");
            const history = await gcp.rules.listAllRulesets(this.options.project);
            if (history.length > RULESET_COUNT_LIMIT) {
                const confirmed = await (0, prompt_1.confirm)({
                    message: `You have ${history.length} rules, do you want to delete the oldest ${RULESETS_TO_GC} to free up space?`,
                    force: this.options.force,
                });
                if (confirmed) {
                    const releases = await gcp.rules.listAllReleases(this.options.project);
                    const unreleased = history.filter((ruleset) => {
                        return !releases.find((release) => release.rulesetName === ruleset.name);
                    });
                    const entriesToDelete = unreleased.reverse().slice(0, RULESETS_TO_GC);
                    for (const entry of entriesToDelete) {
                        await gcp.rules.deleteRuleset(this.options.project, gcp.rules.getRulesetId(entry));
                        logger_1.logger.debug(`[rules] Deleted ${entry.name}`);
                    }
                    utils.logLabeledWarning(RulesetType[this.type], "retrying rules upload");
                    return this.createRulesets(service);
                }
            }
        }
        return createdRulesetNames;
    }
    async release(filename, resourceName, subResourceName) {
        if (resourceName === RulesetServiceType.FIREBASE_STORAGE && !subResourceName) {
            throw new error_1.FirebaseError(`Cannot release resource type "${resourceName}"`);
        }
        const key = this.type === RulesetServiceType.FIREBASE_STORAGE
            ? filename
            : `${filename}:${subResourceName || ""}`;
        const releaseName = subResourceName && subResourceName !== "(default)"
            ? `${resourceName}/${subResourceName}`
            : resourceName;
        await gcp.rules.updateOrCreateRelease(this.options.project, this.rulesetNames[key], releaseName);
        utils.logLabeledSuccess(RulesetType[this.type], `released rules ${(0, colorette_1.bold)(filename)} to ${(0, colorette_1.bold)(resourceName)}`);
    }
    async compileRuleset(filename, files) {
        utils.logLabeledBullet(this.type, `checking ${(0, colorette_1.bold)(filename)} for compilation errors...`);
        const response = await gcp.rules.testRuleset(this.options.project, files);
        if (_.get(response, "body.issues", []).length) {
            const warnings = [];
            const errors = [];
            response.body.issues.forEach((issue) => {
                const issueMessage = `[${issue.severity.substring(0, 1)}] ${issue.sourcePosition.line}:${issue.sourcePosition.column} - ${issue.description}`;
                if (issue.severity === "ERROR") {
                    errors.push(issueMessage);
                }
                else {
                    warnings.push(issueMessage);
                }
            });
            if (warnings.length > 0) {
                warnings.forEach((warning) => {
                    utils.logWarning(warning);
                });
            }
            if (errors.length > 0) {
                const add = errors.length === 1 ? "" : "s";
                const message = `Compilation error${add} in ${(0, colorette_1.bold)(filename)}:\n${errors.join("\n")}`;
                throw new error_1.FirebaseError(message, { exit: 1 });
            }
        }
        utils.logLabeledSuccess(this.type, `rules file ${(0, colorette_1.bold)(filename)} compiled successfully`);
    }
}
exports.RulesDeploy = RulesDeploy;
