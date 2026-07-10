"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.validate_security_rules = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const rules_1 = require("../../../gcp/rules");
const path_1 = require("path");
const apiv2_1 = require("../../../apiv2");
const rtdb_1 = require("../../../rtdb");
const error_1 = require("../../../error");
const getDefaultDatabaseInstance_1 = require("../../../getDefaultDatabaseInstance");
function formatRulesetIssues(issues, rulesSource) {
    const sourceLines = rulesSource.split("\n");
    const formattedOutput = [];
    for (const issue of issues) {
        const { sourcePosition, description, severity } = issue;
        let issueString = `${severity}: ${description} [Ln ${sourcePosition.line}, Col ${sourcePosition.column}]`;
        if (sourcePosition.line) {
            const lineIndex = sourcePosition.line - 1;
            if (lineIndex >= 0 && lineIndex < sourceLines.length) {
                const errorLine = sourceLines[lineIndex];
                issueString += `\n\`\`\`\n${errorLine}`;
                if (sourcePosition.column &&
                    sourcePosition.currentOffset &&
                    sourcePosition.endOffset &&
                    sourcePosition.column > 0 &&
                    sourcePosition.endOffset > sourcePosition.currentOffset) {
                    const startColumnOnLine = sourcePosition.column - 1;
                    const errorTokenLength = sourcePosition.endOffset - sourcePosition.currentOffset;
                    if (startColumnOnLine >= 0 &&
                        errorTokenLength > 0 &&
                        startColumnOnLine <= errorLine.length) {
                        const padding = " ".repeat(startColumnOnLine);
                        const carets = "^".repeat(errorTokenLength);
                        issueString += `\n${padding}${carets}\n\`\`\``;
                    }
                }
            }
        }
        formattedOutput.push(issueString);
    }
    return formattedOutput.join("\n\n");
}
exports.validate_security_rules = (0, tool_1.tool)("core", {
    name: "validate_security_rules",
    description: "Use this to check Firebase Security Rules for Firestore, Storage, or Realtime Database for syntax and validation errors.",
    inputSchema: zod_1.z.object({
        type: zod_1.z.enum(["firestore", "storage", "rtdb"]),
        source: zod_1.z
            .string()
            .optional()
            .describe("The rules source code to check. Provide either this or a path."),
        source_file: zod_1.z
            .string()
            .optional()
            .describe("A file path, relative to the project root, to a file containing the rules source you want to validate. Provide this or source, not both."),
    }),
    annotations: {
        title: "Validate Firebase Security Rules",
        readOnlyHint: true,
    },
    _meta: {
        requiresProject: true,
        requiresAuth: true,
    },
    isAvailable: async (ctx) => {
        const [rtdbActive, storageActive, firestoreActive] = await Promise.all([
            (0, util_1.checkFeatureActive)("database", ctx.projectId, {
                config: ctx.config,
            }),
            (0, util_1.checkFeatureActive)("storage", ctx.projectId, {
                config: ctx.config,
            }),
            (0, util_1.checkFeatureActive)("firestore", ctx.projectId, {
                config: ctx.config,
            }),
        ]);
        return rtdbActive || storageActive || firestoreActive;
    },
}, async ({ type, source, source_file }, { projectId, config, host }) => {
    let rulesSourceContent;
    if (source && source_file) {
        return (0, util_1.mcpError)("Must supply `source` or `source_file`, not both.");
    }
    else if (source_file) {
        try {
            const filePath = (0, path_1.resolve)(source_file, host.cachedProjectDir);
            if (filePath.includes("../"))
                return (0, util_1.mcpError)("Cannot read files outside of the project directory.");
            rulesSourceContent = config.readProjectFile(source_file);
        }
        catch (e) {
            return (0, util_1.mcpError)(`Failed to read source_file '${source_file}': ${e.message}`);
        }
    }
    else if (source) {
        rulesSourceContent = source;
    }
    else {
        return (0, util_1.mcpError)("Must supply at least one of `source` or `source_file`.");
    }
    if (type === "rtdb") {
        const dbUrl = await (0, getDefaultDatabaseInstance_1.getDefaultDatabaseInstance)(projectId);
        const client = new apiv2_1.Client({ urlPrefix: dbUrl });
        try {
            await (0, rtdb_1.updateRulesWithClient)(client, source, { dryRun: true });
        }
        catch (e) {
            host.logger.debug(`failed to validate rules at url ${dbUrl}`);
            return (0, util_1.mcpError)((0, error_1.getErrMsg)(e));
        }
        return (0, util_1.toContent)("The inputted rules are valid!");
    }
    const result = await (0, rules_1.testRuleset)(projectId, [
        { name: "test.rules", content: rulesSourceContent },
    ]);
    if (result.body?.issues?.length) {
        const issues = result.body.issues;
        let out = `Found ${issues.length} issues in rules source:\n\n`;
        out += formatRulesetIssues(issues, rulesSourceContent);
        return (0, util_1.toContent)(out);
    }
    return (0, util_1.toContent)("OK: No errors detected.");
});
