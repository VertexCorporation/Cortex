"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PrettyPrint = void 0;
const clc = require("colorette");
const Table = require("cli-table3");
const sort = require("./api-sort");
const types = require("./api-types");
const logger_1 = require("../logger");
const util = require("./util");
const utils_1 = require("../utils");
class PrettyPrint {
    prettyPrintIndexes(indexes) {
        if (indexes.length === 0) {
            logger_1.logger.info("None");
            return;
        }
        const sortedIndexes = indexes.sort(sort.compareApiIndex);
        sortedIndexes.forEach((index) => {
            logger_1.logger.info(this.prettyIndexString(index));
        });
    }
    getDatabaseEdition(database) {
        return !database.databaseEdition ||
            database.databaseEdition === types.DatabaseEdition.DATABASE_EDITION_UNSPECIFIED
            ? types.DatabaseEdition.STANDARD
            : database.databaseEdition;
    }
    getDatabaseApiType(database) {
        return database.type;
    }
    prettyPrintDatabases(databases) {
        if (databases.length === 0) {
            logger_1.logger.info("No databases found.");
            return;
        }
        const sortedDatabases = databases.sort(sort.compareApiDatabase);
        const table = new Table({
            head: ["Database Name", "Edition", "Type"],
            colWidths: [
                Math.max(...sortedDatabases.map((database) => database.name.length + 5), 20),
                20,
                20,
            ],
        });
        table.push(...sortedDatabases.map((database) => {
            const edition = this.getDatabaseEdition(database);
            const apiType = this.getDatabaseApiType(database);
            return [this.prettyDatabaseString(database), edition, apiType];
        }));
        logger_1.logger.info(table.toString());
    }
    prettyPrintDatabase(database) {
        let colValueWidth = Math.max(50, 5 + database.name.length);
        if (database.cmekConfig) {
            colValueWidth = Math.max(140, 20 + database.cmekConfig.kmsKeyName.length);
        }
        const table = new Table({
            head: ["Field", "Value"],
            colWidths: [30, colValueWidth],
        });
        const edition = this.getDatabaseEdition(database);
        const apiType = this.getDatabaseApiType(database);
        table.push(["Name", clc.yellow(database.name)], ["Create Time", clc.yellow(database.createTime)], ["Last Update Time", clc.yellow(database.updateTime)], ["Type", clc.yellow(apiType)], ["Edition", clc.yellow(edition)], ["Location", clc.yellow(database.locationId)], ["Delete Protection State", clc.yellow(database.deleteProtectionState)], ["Point In Time Recovery", clc.yellow(database.pointInTimeRecoveryEnablement)], ["Earliest Version Time", clc.yellow(database.earliestVersionTime)], ["Version Retention Period", clc.yellow(database.versionRetentionPeriod)]);
        if (database.cmekConfig) {
            table.push(["KMS Key Name", clc.yellow(database.cmekConfig.kmsKeyName)]);
            if (database.cmekConfig.activeKeyVersion) {
                table.push([
                    "Active Key Versions",
                    clc.yellow(this.prettyStringArray(database.cmekConfig.activeKeyVersion)),
                ]);
            }
        }
        logger_1.logger.info(table.toString());
    }
    prettyStringArray(stringArray) {
        let result = "";
        stringArray.forEach((str) => {
            result += `${str}\n`;
        });
        return result;
    }
    prettyPrintBackups(backups) {
        if (backups.length === 0) {
            logger_1.logger.info("No backups found.");
            return;
        }
        const sortedBackups = backups.sort(sort.compareApiBackup);
        const table = new Table({
            head: ["Backup Name", "Database Name", "Snapshot Time", "State"],
            colWidths: [
                Math.max(...sortedBackups.map((backup) => backup.name.length + 5), 20),
                Math.max(...sortedBackups.map((backup) => backup.database.length + 5), 20),
                30,
                10,
            ],
        });
        table.push(...sortedBackups.map((backup) => [
            this.prettyBackupString(backup),
            this.prettyDatabaseString(backup.database || ""),
            backup.snapshotTime,
            backup.state,
        ]));
        logger_1.logger.info(table.toString());
    }
    prettyPrintBackupSchedules(backupSchedules, databaseId) {
        if (backupSchedules.length === 0) {
            logger_1.logger.info(`No backup schedules for database ${databaseId} found.`);
            return;
        }
        const sortedBackupSchedules = backupSchedules.sort(sort.compareApiBackupSchedule);
        sortedBackupSchedules.forEach((schedule) => this.prettyPrintBackupSchedule(schedule));
    }
    prettyPrintBackupSchedule(backupSchedule) {
        const table = new Table({
            head: ["Field", "Value"],
            colWidths: [25, Math.max(50, 5 + backupSchedule.name.length)],
        });
        table.push(["Name", clc.yellow(backupSchedule.name)], ["Create Time", clc.yellow(backupSchedule.createTime)], ["Last Update Time", clc.yellow(backupSchedule.updateTime)], ["Retention", clc.yellow(backupSchedule.retention)], ["Recurrence", this.prettyRecurrenceString(backupSchedule)]);
        logger_1.logger.info(table.toString());
    }
    prettyRecurrenceString(backupSchedule) {
        if (backupSchedule.dailyRecurrence) {
            return clc.yellow("DAILY");
        }
        else if (backupSchedule.weeklyRecurrence) {
            return clc.yellow(`WEEKLY (${backupSchedule.weeklyRecurrence.day})`);
        }
        return "";
    }
    prettyPrintBackup(backup) {
        const table = new Table({
            head: ["Field", "Value"],
            colWidths: [25, Math.max(50, 5 + backup.name.length, 5 + backup.database.length)],
        });
        table.push(["Name", clc.yellow(backup.name)], ["Database", clc.yellow(backup.database)], ["Database UID", clc.yellow(backup.databaseUid)], ["State", clc.yellow(backup.state)], ["Snapshot Time", clc.yellow(backup.snapshotTime)], ["Expire Time", clc.yellow(backup.expireTime)], ["Stats", clc.yellow(backup.stats)]);
        logger_1.logger.info(table.toString());
    }
    prettyPrintOperation(operation) {
        const table = new Table({
            head: ["Operation", ""],
        });
        table.push(["Name", clc.yellow(operation.name)], ["Done?", clc.yellow(operation.done ? "YES" : "NO")], ["Metadata", clc.yellow(JSON.stringify(operation.metadata, undefined, 2))]);
        if (operation.response) {
            table.push(["Response", clc.yellow(JSON.stringify(operation.response, undefined, 2))]);
        }
        logger_1.logger.info(table.toString());
    }
    prettyPrintOperations(operations) {
        if (operations.length === 0) {
            logger_1.logger.info("No operations found.");
            return;
        }
        const table = new Table({
            head: ["Operation Name", "Done"],
        });
        for (const op of operations) {
            table.push([clc.yellow(op.name), op.done ? clc.green("YES") : clc.yellow("NO")]);
        }
        logger_1.logger.info(table.toString());
    }
    prettyPrintLocations(locations) {
        if (locations.length === 0) {
            logger_1.logger.info("No Locations Available");
            return;
        }
        const table = new Table({
            head: ["Display Name", "LocationId"],
            colWidths: [20, 30],
        });
        table.push(...locations
            .sort(sort.compareLocation)
            .map((location) => [location.displayName, location.locationId]));
        logger_1.logger.info(table.toString());
    }
    printFieldOverrides(fields) {
        if (fields.length === 0) {
            logger_1.logger.info("None");
            return;
        }
        const sortedFields = fields.sort(sort.compareApiField);
        sortedFields.forEach((field) => {
            logger_1.logger.info(this.prettyFieldString(field));
        });
    }
    prettyIndexString(index, includeState = true) {
        let result = "";
        if (index.state && includeState) {
            const stateMsg = `[${index.state}] `;
            if (index.state === types.State.READY) {
                result += clc.green(stateMsg);
            }
            else if (index.state === types.State.CREATING) {
                result += clc.yellow(stateMsg);
            }
            else {
                result += clc.red(stateMsg);
            }
        }
        const nameInfo = util.parseIndexName(index.name);
        result += clc.cyan(`(${nameInfo.collectionGroupId})`);
        result += " -- ";
        index.fields.forEach((field) => {
            if (field.fieldPath === "__name__") {
                return;
            }
            let configString;
            if (field.order) {
                configString = field.order;
            }
            else if (field.arrayConfig) {
                configString = field.arrayConfig;
            }
            else if (field.searchConfig) {
                configString = "SEARCH";
            }
            else if (field.vectorConfig) {
                configString = `VECTOR<${field.vectorConfig.dimension}>`;
            }
            result += `(${field.fieldPath},${configString}) `;
        });
        result += " -- ";
        if (index.density !== undefined) {
            result += clc.cyan(`Density:${index.density} `);
        }
        if (index.multikey !== undefined) {
            result += clc.cyan(`Multikey:${index.multikey ? "YES" : "NO"}`);
        }
        return result;
    }
    prettyBackupString(backup) {
        return clc.yellow(backup.name || "");
    }
    prettyBackupScheduleString(backupSchedule) {
        return clc.yellow(backupSchedule.name || "");
    }
    prettyDatabaseString(database) {
        return clc.yellow(typeof database === "string" ? database : database.name);
    }
    firebaseConsoleDatabaseUrl(project, databaseId) {
        const urlFriendlyDatabaseId = databaseId === "(default)" ? "-default-" : databaseId;
        return (0, utils_1.consoleUrl)(project, `/firestore/databases/${urlFriendlyDatabaseId}/data`);
    }
    prettyFieldString(field) {
        let result = "";
        const parsedName = util.parseFieldName(field.name);
        result +=
            "[" +
                clc.cyan(parsedName.collectionGroupId) +
                "." +
                clc.yellow(parsedName.fieldPath) +
                "] --";
        const fieldIndexes = field.indexConfig.indexes || [];
        if (fieldIndexes.length > 0) {
            fieldIndexes.forEach((index) => {
                const firstField = index.fields[0];
                const mode = firstField.order || firstField.arrayConfig;
                result += ` (${mode})`;
            });
        }
        else {
            result += " (no indexes)";
        }
        const fieldTtl = field.ttlConfig;
        if (fieldTtl) {
            result += ` TTL(${fieldTtl.state})`;
        }
        return result;
    }
}
exports.PrettyPrint = PrettyPrint;
