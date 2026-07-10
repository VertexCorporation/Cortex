"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.createTopic = createTopic;
exports.getTopic = getTopic;
exports.updateTopic = updateTopic;
exports.deleteTopic = deleteTopic;
const apiv2_1 = require("../apiv2");
const api_1 = require("../api");
const proto = require("./proto");
const API_VERSION = "v1";
const client = new apiv2_1.Client({
    urlPrefix: (0, api_1.pubsubOrigin)(),
    auth: true,
    apiVersion: API_VERSION,
});
async function createTopic(topic) {
    const result = await client.put(topic.name, topic);
    return result.body;
}
async function getTopic(name) {
    const result = await client.get(name);
    return result.body;
}
async function updateTopic(topic) {
    const queryParams = {
        updateMask: proto.fieldMasks(topic).join(","),
    };
    const result = await client.patch(topic.name, topic, { queryParams });
    return result.body;
}
async function deleteTopic(name) {
    await client.delete(name);
}
