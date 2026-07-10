"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.getFirestoreConfig = getFirestoreConfig;
const error_1 = require("../error");
const logger_1 = require("../logger");
function getFirestoreConfig(projectId, options) {
    const fsConfig = options.config.src.firestore;
    if (fsConfig === undefined) {
        return [];
    }
    const rc = options.rc;
    let allDatabases = !options.only;
    const onlyDatabases = new Set();
    if (options.only) {
        const split = options.only.split(",");
        if (split.includes("firestore")) {
            allDatabases = true;
        }
        else {
            for (const value of split) {
                if (value.startsWith("firestore:")) {
                    const target = value.split(":")[1];
                    onlyDatabases.add(target);
                }
            }
        }
    }
    if (!Array.isArray(fsConfig)) {
        if (fsConfig) {
            const databaseId = fsConfig.database || `(default)`;
            return [{ rules: fsConfig.rules, indexes: fsConfig.indexes, database: databaseId }];
        }
        else {
            logger_1.logger.debug("Possibly invalid database config: ", JSON.stringify(fsConfig));
            return [];
        }
    }
    if (onlyDatabases.has("rules")) {
        onlyDatabases.delete("rules");
        allDatabases = true;
    }
    if (onlyDatabases.has("indexes")) {
        onlyDatabases.delete("indexes");
        allDatabases = true;
    }
    const results = [];
    for (const c of fsConfig) {
        const { database, target } = c;
        if (target) {
            if (allDatabases || onlyDatabases.has(target)) {
                rc.requireTarget(projectId, "firestore", target);
                const databases = rc.target(projectId, "firestore", target);
                for (const database of databases) {
                    results.push({ database, rules: c.rules, indexes: c.indexes });
                }
                onlyDatabases.delete(target);
            }
        }
        else if (database) {
            if (allDatabases || onlyDatabases.has(database)) {
                results.push(c);
                onlyDatabases.delete(database);
            }
        }
        else {
            throw new error_1.FirebaseError('Must supply either "target" or "databaseId" in firestore config');
        }
    }
    if (onlyDatabases.has("rules")) {
        onlyDatabases.delete("rules");
    }
    if (onlyDatabases.has("indexes")) {
        onlyDatabases.delete("indexes");
    }
    if (!allDatabases && onlyDatabases.size !== 0) {
        throw new error_1.FirebaseError(`Could not find configurations in firebase.json for the following database targets: ${[
            ...onlyDatabases,
        ].join(", ")}`);
    }
    return results;
}
