"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.send_message = void 0;
const zod_1 = require("zod");
const tool_1 = require("../../tool");
const util_1 = require("../../util");
const sendMessage_1 = require("../../../messaging/sendMessage");
exports.send_message = (0, tool_1.tool)("messaging", {
    name: "send_message",
    description: "Use this to send a message to a Firebase Cloud Messaging registration token or topic. ONLY ONE of `registration_token` or `topic` may be supplied in a specific call.",
    inputSchema: zod_1.z.object({
        registration_token: zod_1.z
            .string()
            .optional()
            .describe("A specific device registration token for delivery. Supply either this or topic."),
        topic: zod_1.z
            .string()
            .optional()
            .describe("A topic name for delivery. Supply either this or registration_token."),
        title: zod_1.z.string().optional().describe("The title of the push notification message."),
        body: zod_1.z.string().optional().describe("The body of the push notification  message."),
        image: zod_1.z
            .string()
            .optional()
            .describe("The URL of an image that will be displayed with the notification. JPEG, PNG, BMP have full support across platforms. Animated GIF and video only work on iOS. WebP and HEIF have varying levels of support across platforms and platform versions."),
    }),
    annotations: {
        title: "Send FCM Message",
    },
    _meta: {
        requiresAuth: true,
        requiresProject: true,
    },
}, async ({ registration_token, topic, title, body }, { projectId }) => {
    if (!registration_token && !topic) {
        return (0, util_1.mcpError)("Must supply either a `registration_token` or `topic` parameter to `send_message`.");
    }
    if (registration_token && topic) {
        return (0, util_1.mcpError)("Cannot supply both `registration_token` and `topic` in a single `send_message` request.");
    }
    return (0, util_1.toContent)(await (0, sendMessage_1.sendFcmMessage)(projectId, { token: registration_token, topic, title, body }));
});
