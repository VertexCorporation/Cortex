"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizeRulesConfig = normalizeRulesConfig;
exports.getRulesConfig = getRulesConfig;
const error_1 = require("../error");
const logger_1 = require("../logger");
const utils = require("../utils");
function normalizeRulesConfig(rulesConfig, options) {
    const config = options.config;
    return rulesConfig.map((rc) => {
        return {
            instance: rc.instance,
            rules: config.path(rc.rules),
        };
    });
}
function getRulesConfig(projectId, options) {
    const dbConfig = options.config.src.database;
    if (dbConfig === undefined) {
        return [];
    }
    const rc = options.rc;
    let allDatabases = !options.only;
    const onlyDatabases = new Set();
    if (options.only) {
        const split = options.only.split(",");
        if (split.includes("database")) {
            allDatabases = true;
        }
        else {
            for (const value of split) {
                if (value.startsWith("database:")) {
                    const target = value.split(":")[1];
                    onlyDatabases.add(target);
                }
            }
        }
    }
    if (!Array.isArray(dbConfig)) {
        if (dbConfig && dbConfig.rules) {
            utils.assertIsStringOrUndefined(options.instance);
            const instance = options.instance || `${options.project}-default-rtdb`;
            return [{ rules: dbConfig.rules, instance }];
        }
        else {
            logger_1.logger.debug("Possibly invalid database config: ", JSON.stringify(dbConfig));
            return [];
        }
    }
    const results = [];
    for (const c of dbConfig) {
        const { instance, target } = c;
        if (target) {
            if (allDatabases || onlyDatabases.has(target)) {
                rc.requireTarget(projectId, "database", target);
                const instances = rc.target(projectId, "database", target);
                for (const i of instances) {
                    results.push({ instance: i, rules: c.rules });
                }
                onlyDatabases.delete(target);
            }
        }
        else if (instance) {
            if (allDatabases) {
                results.push(c);
            }
        }
        else {
            throw new error_1.FirebaseError('Must supply either "target" or "instance" in database config');
        }
    }
    if (!allDatabases && onlyDatabases.size !== 0) {
        throw new error_1.FirebaseError(`Could not find configurations in firebase.json for the following database targets: ${[
            ...onlyDatabases,
        ].join(", ")}`);
    }
    return results;
}
