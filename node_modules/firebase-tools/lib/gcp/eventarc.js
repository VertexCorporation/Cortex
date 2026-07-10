"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.API_VERSION = void 0;
exports.getChannel = getChannel;
exports.createChannel = createChannel;
exports.updateChannel = updateChannel;
exports.deleteChannel = deleteChannel;
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
const lodash_1 = require("lodash");
const proto_1 = require("./proto");
exports.API_VERSION = "v1";
const client = new apiv2_1.Client({
    urlPrefix: (0, api_1.eventarcOrigin)(),
    auth: true,
    apiVersion: exports.API_VERSION,
});
async function getChannel(name) {
    const res = await client.get(name, { resolveOnHTTPError: true });
    if (res.status === 404) {
        return undefined;
    }
    return res.body;
}
async function createChannel(channel) {
    const pathParts = channel.name.split("/");
    const res = await client.post(pathParts.slice(0, -1).join("/"), channel, {
        queryParams: { channelId: (0, lodash_1.last)(pathParts) },
    });
    return res.body;
}
async function updateChannel(channel) {
    const res = await client.put(channel.name, channel, {
        queryParams: {
            updateMask: (0, proto_1.fieldMasks)(channel).join(","),
        },
    });
    return res.body;
}
async function deleteChannel(name) {
    await client.delete(name);
}
