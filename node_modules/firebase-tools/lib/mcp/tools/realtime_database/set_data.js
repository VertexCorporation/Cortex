"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.set_data = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const url = require("node:url");
const utils_1 = require("../../../utils");
const apiv2_1 = require("../../../apiv2");
const error_1 = require("../../../error");
const node_path_1 = require("node:path");
exports.set_data = (0, tool_1.tool)("database", {
    name: "set_data",
    description: "Use this to write data to the specified location in a Firebase Realtime Database.",
    inputSchema: zod_1.z.object({
        databaseUrl: zod_1.z
            .string()
            .optional()
            .describe("connect to the database at url. If omitted, use default database instance <project>-default-rtdb.us-central1.firebasedatabase.app. Can point to emulator URL (e.g. localhost:6000/<instance>)"),
        path: zod_1.z.string().describe("The path to the data to read. (ex: /my/cool/path)"),
        data: zod_1.z.string().describe('The JSON to write. (ex: {"alphabet": ["a", "b", "c"]})'),
    }),
    annotations: {
        title: "Set Realtime Database data",
        readOnlyHint: false,
        idempotentHint: true,
    },
    _meta: {
        requiresAuth: false,
        requiresProject: false,
    },
}, async ({ path: setPath, databaseUrl, data }, { projectId, host }) => {
    if (!setPath.startsWith("/")) {
        return (0, util_1.mcpError)(`paths must start with '/' (you passed ''${setPath}')`);
    }
    const dbUrl = new url.URL(databaseUrl
        ? `${databaseUrl}/${setPath}.json`
        : node_path_1.default.join(`https://${projectId}-default-rtdb.us-central1.firebasedatabase.app`, `${setPath}.json`));
    const client = new apiv2_1.Client({
        urlPrefix: dbUrl.origin,
        auth: true,
    });
    const inStream = (0, utils_1.stringToStream)(data);
    host.logger.debug(`sending write request to path '${setPath}' for url '${dbUrl.toString()}'`);
    try {
        await client.request({
            method: "PUT",
            path: dbUrl.pathname,
            body: inStream,
        });
    }
    catch (err) {
        host.logger.debug((0, error_1.getErrMsg)(err));
        return (0, util_1.mcpError)(`Unexpected error while setting data: ${(0, error_1.getErrMsg)(err)}`);
    }
    return (0, util_1.toContent)("write successful!");
});
