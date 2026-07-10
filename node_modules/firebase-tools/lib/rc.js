"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.RC = void 0;
exports.loadRC = loadRC;
const _ = require("lodash");
const clc = require("colorette");
const cjson = require("cjson");
const fs = require("fs");
const path = require("path");
const detectProjectRoot_1 = require("./detectProjectRoot");
const error_1 = require("./error");
const fsutils = require("./fsutils");
const utils = require("./utils");
const TARGET_TYPES = {
    storage: { resource: "bucket", exclusive: true },
    database: { resource: "instance", exclusive: true },
    hosting: { resource: "site", exclusive: true },
};
function loadRC(options) {
    const cwd = options.cwd || process.cwd();
    const dir = (0, detectProjectRoot_1.detectProjectRoot)(options);
    const potential = path.resolve(dir || cwd, "./.firebaserc");
    return RC.loadFile(potential);
}
class RC {
    static loadFile(rcpath) {
        let data = {};
        if (fsutils.fileExistsSync(rcpath)) {
            try {
                data = cjson.load(rcpath);
            }
            catch (e) {
                utils.logWarning("JSON error trying to load " + clc.bold(rcpath));
            }
        }
        return new RC(rcpath, data);
    }
    constructor(rcpath, data) {
        this.path = rcpath;
        this.data = { projects: {}, targets: {}, etags: {}, ...data };
    }
    set(key, value) {
        _.set(this.data, key, value);
        return;
    }
    unset(key) {
        return _.unset(this.data, key);
    }
    resolveAlias(alias) {
        return this.data.projects[alias] || alias;
    }
    hasProjectAlias(alias) {
        return !!this.data.projects[alias];
    }
    addProjectAlias(alias, project) {
        this.set(["projects", alias], project);
        return this.save();
    }
    removeProjectAlias(alias) {
        this.unset(["projects", alias]);
        return this.save();
    }
    get hasProjects() {
        return Object.keys(this.data.projects).length > 0;
    }
    get projects() {
        return this.data.projects;
    }
    allTargets(project) {
        return this.data.targets[project] || {};
    }
    targets(project, type) {
        return this.data.targets[project]?.[type] || {};
    }
    target(project, type, name) {
        return this.data.targets[project]?.[type]?.[name] || [];
    }
    applyTarget(project, type, targetName, resources) {
        if (!TARGET_TYPES[type]) {
            throw new error_1.FirebaseError(`Unrecognized target type ${clc.bold(type)}. Must be one of ${Object.keys(TARGET_TYPES).join(", ")}`);
        }
        if (typeof resources === "string") {
            resources = [resources];
        }
        const changed = [];
        for (const resource of resources) {
            const cur = this.findTarget(project, type, resource);
            if (cur && cur !== targetName) {
                this.unsetTargetResource(project, type, cur, resource);
                changed.push({ resource: resource, target: cur });
            }
        }
        const existing = this.target(project, type, targetName);
        const list = Array.from(new Set(existing.concat(resources))).sort();
        this.set(["targets", project, type, targetName], list);
        this.save();
        return changed;
    }
    removeTarget(project, type, resource) {
        const name = this.findTarget(project, type, resource);
        if (!name) {
            return null;
        }
        this.unsetTargetResource(project, type, name, resource);
        this.save();
        return name;
    }
    clearTarget(project, type, name) {
        if (!this.target(project, type, name).length) {
            return false;
        }
        this.unset(["targets", project, type, name]);
        this.save();
        return true;
    }
    findTarget(project, type, resource) {
        const targets = this.targets(project, type);
        for (const targetName in targets) {
            if ((targets[targetName] || []).includes(resource)) {
                return targetName;
            }
        }
        return null;
    }
    unsetTargetResource(project, type, name, resource) {
        const updatedResources = this.target(project, type, name).filter((r) => r !== resource);
        if (updatedResources.length) {
            this.set(["targets", project, type, name], updatedResources);
        }
        else {
            this.unset(["targets", project, type, name]);
        }
    }
    requireTarget(project, type, name) {
        const target = this.target(project, type, name);
        if (!target.length) {
            throw new error_1.FirebaseError(`Deploy target ${clc.bold(name)} not configured for project ${clc.bold(project)}. Configure with:

  firebase target:apply ${type} ${name} <resources...>`);
        }
        return target;
    }
    getEtags(projectId) {
        return this.data.etags[projectId] || { extensionInstances: {} };
    }
    setEtags(projectId, resourceType, etagData) {
        if (!this.data.etags[projectId]) {
            this.data.etags[projectId] = {};
        }
        this.data.etags[projectId][resourceType] = etagData;
        this.save();
    }
    save() {
        if (this.path) {
            fs.writeFileSync(this.path, JSON.stringify(this.data, null, 2), {
                encoding: "utf8",
            });
            return true;
        }
        return false;
    }
}
exports.RC = RC;
