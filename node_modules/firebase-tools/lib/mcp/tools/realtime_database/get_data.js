"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_data = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const url = require("node:url");
const apiv2_1 = require("../../../apiv2");
const consumers_1 = require("node:stream/consumers");
const node_path_1 = require("node:path");
exports.get_data = (0, tool_1.tool)("database", {
    name: "get_data",
    description: "Use this to retrieve data from the specified location in a Firebase Realtime Database.",
    inputSchema: zod_1.z.object({
        databaseUrl: zod_1.z
            .string()
            .optional()
            .describe("connect to the database at url. If omitted, use default database instance <project>-default-rtdb.firebasedatabase.app. Can point to emulator URL (e.g. localhost:6000/<instance>)"),
        path: zod_1.z.string().describe("The path to the data to read. (ex: /my/cool/path)"),
    }),
    annotations: {
        title: "Get Realtime Database data",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: false,
        requiresProject: false,
    },
}, async ({ path: getPath, databaseUrl }, { projectId, host }) => {
    if (!getPath.startsWith("/")) {
        return (0, util_1.mcpError)(`paths must start with '/' (you passed ''${getPath}')`);
    }
    const dbUrl = new url.URL(databaseUrl
        ? `${databaseUrl}/${getPath}.json`
        : node_path_1.default.join(`https://${projectId}-default-rtdb.us-central1.firebasedatabase.app`, `${getPath}.json`));
    const client = new apiv2_1.Client({
        urlPrefix: dbUrl.origin,
        auth: true,
    });
    host.logger.debug(`sending read request to path '${getPath}' for url '${dbUrl.toString()}'`);
    const res = await client.request({
        method: "GET",
        path: dbUrl.pathname,
        responseType: "stream",
        resolveOnHTTPError: true,
    });
    const content = await (0, consumers_1.text)(res.body);
    return (0, util_1.toContent)(content);
});
