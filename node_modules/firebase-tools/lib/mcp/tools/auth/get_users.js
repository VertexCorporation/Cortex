"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.get_users = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const auth_1 = require("../../../gcp/auth");
exports.get_users = (0, tool_1.tool)("auth", {
    name: "get_users",
    description: "Use this to retrieve one or more Firebase Auth users based on a list of UIDs or a list of emails.",
    inputSchema: zod_1.z.object({
        uids: zod_1.z.array(zod_1.z.string()).optional().describe("A list of user UIDs to retrieve."),
        emails: zod_1.z.array(zod_1.z.string()).optional().describe("A list of user emails to retrieve."),
        phone_numbers: zod_1.z
            .array(zod_1.z.string())
            .optional()
            .describe("A list of user phone numbers to retrieve."),
        limit: zod_1.z
            .number()
            .optional()
            .default(100)
            .describe("The numbers of users to return. 500 is the upper limit. Defaults to 100."),
    }),
    annotations: {
        title: "Get Firebase Auth Users",
        readOnlyHint: true,
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async ({ uids, emails, phone_numbers, limit }, { projectId }) => {
    const prune = (user) => {
        const { passwordHash, salt, ...prunedUser } = user;
        return prunedUser;
    };
    let users = [];
    if (uids?.length) {
        const promises = uids.map((uid) => (0, auth_1.findUser)(projectId, undefined, undefined, uid).catch(() => null));
        users.push(...(await Promise.all(promises)).filter((u) => !!u));
    }
    if (emails?.length) {
        const promises = emails.map((email) => (0, auth_1.findUser)(projectId, email, undefined, undefined).catch(() => null));
        users.push(...(await Promise.all(promises)).filter((u) => !!u));
    }
    if (phone_numbers?.length) {
        const promises = phone_numbers.map((phone) => (0, auth_1.findUser)(projectId, undefined, phone, undefined).catch(() => null));
        users.push(...(await Promise.all(promises)).filter((u) => !!u));
    }
    if (!uids?.length && !emails?.length && !phone_numbers?.length) {
        users = await (0, auth_1.listUsers)(projectId, limit || 100);
    }
    return (0, util_1.toContent)({ users: users.map(prune) });
});
