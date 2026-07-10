"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.confirmDangerousQuery = confirmDangerousQuery;
exports.interactiveExecuteQuery = interactiveExecuteQuery;
const ora = require("ora");
const clc = require("colorette");
const logger_1 = require("../../logger");
const prompt_1 = require("../../prompt");
const Table = require("cli-table3");
const destructiveSqlKeywords = ["DROP", "DELETE"];
function checkIsDestructiveSql(query) {
    const upperCaseQuery = query.toUpperCase();
    return destructiveSqlKeywords.some((keyword) => upperCaseQuery.includes(keyword.toUpperCase()));
}
async function confirmDangerousQuery(query) {
    if (checkIsDestructiveSql(query)) {
        return await (0, prompt_1.confirm)({
            message: clc.yellow("This query may be destructive. Are you sure you want to proceed?"),
            default: false,
        });
    }
    return true;
}
async function interactiveExecuteQuery(query, conn) {
    const spinner = ora("Executing query...").start();
    try {
        const results = await conn.query(query);
        spinner.succeed(clc.green("Query executed successfully"));
        if (Array.isArray(results.rows) && results.rows.length > 0) {
            const table = new Table({
                head: Object.keys(results.rows[0]).map((key) => clc.cyan(key)),
                style: { head: [], border: [] },
            });
            for (const row of results.rows) {
                table.push(Object.values(row));
            }
            logger_1.logger.info(table.toString());
        }
        else {
            if (query.toUpperCase().includes("SELECT")) {
                logger_1.logger.info(clc.yellow("No results returned"));
            }
        }
    }
    catch (err) {
        spinner.fail(clc.red(`Failed executing query: ${err}`));
    }
}
